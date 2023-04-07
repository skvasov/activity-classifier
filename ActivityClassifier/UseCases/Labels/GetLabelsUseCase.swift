//
//  GetLabelsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

class GetLabelsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(LabelsActions.GettingLabels())
      do {
        let labels = try await trainingDataRepository.getAllLabels()
        actionDispatcher.dispatch(LabelsActions.GotLabels(labels: labels))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(LabelsActions.GettingLabelsFailed(error: errorMessage))
      }
    }
  }
}
