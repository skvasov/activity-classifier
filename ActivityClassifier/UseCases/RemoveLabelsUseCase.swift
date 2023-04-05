//
//  RemoveLabelsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

class RemoveLabelsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let labels: [TrainingLabel]
  
  init(actionDispatcher: ActionDispatcher, labels: [TrainingLabel]) {
    self.actionDispatcher = actionDispatcher
    self.labels = labels
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.RemovingLabel())
      try? await Task.sleep(for: .seconds(2))
      actionDispatcher.dispatch(LabelsActions.RemovedLabel(removedLabels: labels))
    }
  }
}
