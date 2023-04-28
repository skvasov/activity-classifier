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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let name = dateFormatter.string(from: Date()) + ".json"
        
        let trainingRecord = TrainingRecord(name: name, numOfChildren: 0, content: data)
        try await trainingDataRepository.addTrainingRecord(trainingRecord, for: label)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddedTrainingRecord(trainingRecord: trainingRecord))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddingTrainingRecordFailed(error: errorMessage))
      }
    }
  }
}
