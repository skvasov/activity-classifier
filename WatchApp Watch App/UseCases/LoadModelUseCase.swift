//
//  LoadModelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 28.04.23.
//

import Foundation

class LoadModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let companionAppRepository: CompanionAppRepository
  
  init(actionDispatcher: ActionDispatcher, companionAppRepository: CompanionAppRepository) {
    self.actionDispatcher = actionDispatcher
    self.companionAppRepository = companionAppRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.LoadModel())
      do {
        //let model = try await modelRepository.loadAll().first
        //actionDispatcher.dispatchOnMain(VerifyActions.LoadedModel(model: model))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(VerifyActions.LoadingModelFailed(error: errorMessage))
      }
    }
  }
}
