//
//  FinishedInputingLabelNameUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 7.04.23.
//

import Foundation

class CancelInputtingLabelNameUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    actionDispatcher.dispatchOnMain(LabelsActions.CancelInputtingLabelName())
  }
}
