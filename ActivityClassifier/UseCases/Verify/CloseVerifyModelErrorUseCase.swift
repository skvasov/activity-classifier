//
//  CloseVerifyModelErrorUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 8.06.23.
//

import Foundation

class CloseVerifyModelErrorUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    actionDispatcher.dispatchOnMain(VerifyActions.CloseVerifyError())
  }
}
