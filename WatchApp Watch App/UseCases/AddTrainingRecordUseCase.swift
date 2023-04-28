//
//  AddTrainingRecordUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 25.04.23.
//

import Foundation

class AddTrainingRecordUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let companionAppRepository: CompanionAppRepository
  private let trainingDataRepository: TrainingDataRepository
  private let feedbackRepository: FeedbackRepository
  
  init(actionDispatcher: ActionDispatcher, companionAppRepository: CompanionAppRepository, trainingDataRepository: TrainingDataRepository, feedbackRepository: FeedbackRepository) {
    self.actionDispatcher = actionDispatcher
    self.companionAppRepository = companionAppRepository
    self.trainingDataRepository = trainingDataRepository
    self.feedbackRepository = feedbackRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(RecordActions.AddTrainingRecord())
      do {
        let settings = try await companionAppRepository.getSettings()
        await feedbackRepository.generateFeedback(for: settings.delay)
        
        let motions = try await self.trainingDataRepository.getDeviceMotion(for: settings.predictionWindow, with: settings.frequency)
        let data = try JSONEncoder().encode(motions)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let name = dateFormatter.string(from: Date()) + ".json"
        
        var trainingRecord = TrainingRecord(name: name, numOfChildren: 0, content: data)
        // TODO: Refactor URL
        let url = try await trainingDataRepository.addTrainingRecord(trainingRecord)
        trainingRecord.url = url
        try await companionAppRepository.addTrainingRecord(trainingRecord)
        actionDispatcher.dispatchOnMain(RecordActions.AddedTrainingRecord())
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(RecordActions.AddingTrainingRecordFailed(error: errorMessage))
      }
    }
  }
}
