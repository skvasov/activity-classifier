//
//  RunModelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 24.05.23.
//

import Foundation

class RunModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let model: Model
  private let modelRepository: ModelRepository
  private let companionAppRepository: CompanionAppRepository
  private let workoutRepository: WorkoutRepository
  private let speechSynthesizerRepository: SpeechSynthesizerRepository
  
  
  init(actionDispatcher: ActionDispatcher, model: Model, modelRepository: ModelRepository, companionAppRepository: CompanionAppRepository, workoutRepository: WorkoutRepository, speechSynthesizerRepository: SpeechSynthesizerRepository) {
    self.actionDispatcher = actionDispatcher
    self.model = model
    self.modelRepository = modelRepository
    self.companionAppRepository = companionAppRepository
    self.workoutRepository = workoutRepository
    self.speechSynthesizerRepository = speechSynthesizerRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.RunModel())
      do {
        try await workoutRepository.startWorkout()
        let settings = try await companionAppRepository.getSettings()
        for try await motions in try await modelRepository.run(model, with: settings.frequency) {
          let prediction = try modelRepository.predict(motions)
          
          if let topLabel = prediction.topLabel {
            speechSynthesizerRepository.speak(topLabel)
          }
          
          actionDispatcher.dispatchOnMain(VerifyActions.GotPrediction(prediction: prediction))
        }
        workoutRepository.endWorkout()
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(VerifyActions.RunningModelFailed(error: errorMessage))
        workoutRepository.endWorkout()
      }
    }
  }
}
