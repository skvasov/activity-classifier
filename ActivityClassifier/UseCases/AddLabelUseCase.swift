//
//  AddLabelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

class AddLabelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let labelName: String
  
  init(actionDispatcher: ActionDispatcher, labelName: String) {
    self.actionDispatcher = actionDispatcher
    self.labelName = labelName
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.AddingLabel())
      try? await Task.sleep(for: .seconds(2))
      actionDispatcher.dispatch(LabelsActions.AddedLabel(label: TrainingLabel(name: labelName, numOfRecords: Int.random(in: 0...30))))
    }
  }
}
