//
//  AddTrainingRecordUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class AddTrainingRecordUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let label: TrainingLabel
  private let trainingDataRepository: TrainingDataRepository
  private let settingsRepository: SettingsRepository
  private let feedbackRepository: FeedbackRepository
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel, trainingDataRepository: TrainingDataRepository, settingsRepository: SettingsRepository, feedbackRepository: FeedbackRepository) {
    self.actionDispatcher = actionDispatcher
    self.label = label
    self.trainingDataRepository = trainingDataRepository
    self.settingsRepository = settingsRepository
    self.feedbackRepository = feedbackRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddTrainingRecord())
      do {
        let settings = try await settingsRepository.load()

        await feedbackRepository.generateFeedback(for: settings.delay)
        
        let motions = try await trainingDataRepository.getDeviceMotion(for: settings.predictionWindow, with: settings.frequency)
        let data = try JSONEncoder().encode(motions)
        
        let trainingRecord = TrainingRecord(content: data)
        try await trainingDataRepository.addTrainingRecord(trainingRecord, for: label)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddedTrainingRecord(trainingRecord: trainingRecord))
        
        trainingDataRepository.invalidateSelectedTrainingLabel()
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddingTrainingRecordFailed(error: errorMessage))
      }
    }
  }
}
