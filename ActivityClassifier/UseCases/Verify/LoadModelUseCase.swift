//
//  LoadModelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

class LoadModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let modelRepository: ModelRepository
  
  init(actionDispatcher: ActionDispatcher, modelRepository: ModelRepository) {
    self.actionDispatcher = actionDispatcher
    self.modelRepository = modelRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(VerifyActions.LoadModel())
      do {
        let model = try await modelRepository.loadAll().first
        actionDispatcher.dispatch(VerifyActions.LoadedModel(model: model))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(VerifyActions.LoadingModelFailed(error: errorMessage))
      }
    }
  }
}
