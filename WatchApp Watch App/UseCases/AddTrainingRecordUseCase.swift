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
  private let workoutRepository: WorkoutRepository
  
  init(actionDispatcher: ActionDispatcher, companionAppRepository: CompanionAppRepository, trainingDataRepository: TrainingDataRepository, feedbackRepository: FeedbackRepository, workoutRepository: WorkoutRepository) {
    self.actionDispatcher = actionDispatcher
    self.companionAppRepository = companionAppRepository
    self.trainingDataRepository = trainingDataRepository
    self.feedbackRepository = feedbackRepository
    self.workoutRepository = workoutRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(RecordActions.AddTrainingRecord())
      do {
        try await workoutRepository.startWorkout()
        
        let settings = try await companionAppRepository.getSettings()
        await feedbackRepository.generateStartFeedback(for: settings.delay)
        
        let motions = try await self.trainingDataRepository.getDeviceMotion(for: settings.predictionWindow, with: settings.frequency)
        
        await feedbackRepository.generateFinishFeedback()
        
        var trainingRecord = TrainingRecord(content: try motions.makeData())
        // TODO: Refactor URL
        trainingRecord.url = try await trainingDataRepository.addTrainingRecord(trainingRecord)
        try await companionAppRepository.addTrainingRecord(trainingRecord)
        actionDispatcher.dispatchOnMain(RecordActions.AddedTrainingRecord())
        workoutRepository.endWorkout()
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(RecordActions.AddingTrainingRecordFailed(error: errorMessage))
        workoutRepository.endWorkout()
      }
    }
  }
}
