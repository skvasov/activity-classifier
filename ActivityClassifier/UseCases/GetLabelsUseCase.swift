//
//  GetLabelsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

class GetLabelsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  
  init(actionDispatcher: ActionDispatcher) {
    self.actionDispatcher = actionDispatcher
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.GettingLabels())
      try? await Task.sleep(for: .seconds(2))
      actionDispatcher.dispatch(LabelsActions.GotLabels(labels: [
        TrainingLabel(name: "Wing", numOfRecords: 30),
        TrainingLabel(name: "Shot", numOfRecords: 5)
      ]))
    }
  }
}
