//
//  RunModelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation
import CoreML

class RunModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let model: Model
  private let modelRepository: ModelRepository
  private let settingsRepository: SettingsRepository
  
  init(actionDispatcher: ActionDispatcher, model: Model, modelRepository: ModelRepository, settingsRepository: SettingsRepository) {
    self.actionDispatcher = actionDispatcher
    self.model = model
    self.modelRepository = modelRepository
    self.settingsRepository = settingsRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.RunModel())
      do {
        let settings = try await settingsRepository.load()
        for try await motions in try await modelRepository.run(model, for: settings.predictionWindow, with: settings.frequency) {
          let prediction = try modelRepository.predict(motions)
          actionDispatcher.dispatchOnMain(VerifyActions.GotPrediction(prediction: prediction))
        }
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(VerifyActions.RunningModelFailed(error: errorMessage))
      }
    }
  }
}
