//
//  CloseTrainingRecordsErrorUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation

class CloseTrainingRecordsErrorUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    actionDispatcher.dispatchOnMain(TrainingRecordsActions.CloseTrainingRecordsErrorUseCase())
  }
}
