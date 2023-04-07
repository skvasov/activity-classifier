//
//  EditLabelsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 7.04.23.
//

import Foundation

class EditLabelsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    actionDispatcher.dispatch(LabelsActions.EditLabels())
  }
}
