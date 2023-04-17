//
//  AddLabelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

enum AddLabelUseCaseError: Error, LocalizedError {
  case invalidName
  
  var errorDescription: String? {
    switch self {
    case .invalidName:
        return "Invalid name. Alphanumericals only"
    }
  }
}

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
      actionDispatcher.dispatch(LabelsActions.AddLabel())
      do {
        guard labelName.isAlphanumeric else { throw AddLabelUseCaseError.invalidName }
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
