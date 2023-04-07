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
  private let trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, labelName: String, trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.labelName = labelName
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.AddingLabel())
      do {
        let label = TrainingLabel(name: labelName, numOfChildren: 0)
        try await trainingDataRepository.addLabel(label)
        actionDispatcher.dispatch(LabelsActions.AddedLabel(label: label))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(LabelsActions.AddingLabelFailed(error: errorMessage))
      }
    }
  }
}
