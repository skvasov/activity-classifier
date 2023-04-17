//
//  BackToLabelsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class BackToLabelsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    actionDispatcher.dispatchOnMain(LabelsActions.BackToLabels())
  }
}
