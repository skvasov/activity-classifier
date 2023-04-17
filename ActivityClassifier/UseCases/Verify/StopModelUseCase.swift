//
//  StopModelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

class StopModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let modelRepository: ModelRepository
  
  init(actionDispatcher: ActionDispatcher, modelRepository: ModelRepository) {
    self.actionDispatcher = actionDispatcher
    self.modelRepository = modelRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.StopModel())
      do {
        try await modelRepository.stop()
        actionDispatcher.dispatchOnMain(VerifyActions.DidStopModel())
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(VerifyActions.StoppingModelFailed(error: errorMessage))
      }
    }
  }
}
