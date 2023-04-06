//
//  GoToTrainingRecordsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class GoToTrainingRecordsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let label: TrainingLabel
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel) {
    self.actionDispatcher = actionDispatcher
    self.label = label
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.GoToTrainingRecords(label: label))
    }
  }
}
