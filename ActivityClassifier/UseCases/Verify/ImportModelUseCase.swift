//
//  ImportModelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

class ImportModelUseCaseUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(VerifyActions.ImportModel())
    }
  }
}
