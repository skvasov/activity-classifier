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
  
  init(actionDispatcher: ActionDispatcher, model: Model, modelRepository: ModelRepository) {
    self.actionDispatcher = actionDispatcher
    self.model = model
    self.modelRepository = modelRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.RunModel())
      do {
        for try await motions in try await modelRepository.run(model, for: 100, with: 50) {
          var prediction = try modelRepository.predict(motions)
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
