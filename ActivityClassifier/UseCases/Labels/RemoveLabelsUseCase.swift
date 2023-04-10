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
  private let trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, labels: [TrainingLabel], trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.labels = labels
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.RemoveLabels())
      do {
        try await trainingDataRepository.removeLabels(labels)
        actionDispatcher.dispatch(LabelsActions.RemovedLabels(removedLabels: labels))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(LabelsActions.RemovingLabelsFailed(error: errorMessage))
      }
    }
  }
}
