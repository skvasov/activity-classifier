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
      actionDispatcher.dispatch(VerifyActions.RunModel())
      do {
        try await modelRepository.run(model)
        actionDispatcher.dispatch(VerifyActions.DidRunModel())
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(VerifyActions.RunningModelFailed(error: errorMessage))
      }
    }
  }
}
