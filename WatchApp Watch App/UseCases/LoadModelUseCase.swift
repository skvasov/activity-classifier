//
//  LoadModelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 28.04.23.
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
      actionDispatcher.dispatchOnMain(VerifyActions.LoadModel())
      do {
        let model = try await modelRepository.load()
        actionDispatcher.dispatchOnMain(VerifyActions.LoadedModel(model: model))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(VerifyActions.LoadingModelFailed(error: errorMessage))
      }
    }
  }
}
