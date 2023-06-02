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
  
  init(actionDispatcher: ActionDispatcher, model: Model, modelRepository: ModelRepository, companionAppRepository: CompanionAppRepository) {
    self.actionDispatcher = actionDispatcher
    self.model = model
    self.modelRepository = modelRepository
    self.companionAppRepository = companionAppRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.RunModel())
      do {
        let settings = try await companionAppRepository.getSettings()
        for try await motions in try await modelRepository.run(model, with: settings.frequency) {
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
