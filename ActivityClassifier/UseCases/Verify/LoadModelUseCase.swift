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
      actionDispatcher.dispatchOnMain(VerifyActions.LoadModel())
      do {
        let model = try await modelRepository.load()
        actionDispatcher.dispatchOnMain(VerifyActions.LoadedModel(model: model))
      }
      catch let error as NSError where error.code == 260 { // Folder with ML models doesn't exist yet
        actionDispatcher.dispatchOnMain(VerifyActions.LoadedModel(model: nil))
      }
      catch let error {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(VerifyActions.LoadingModelFailed(error: errorMessage))
      }
    }
  }
}
