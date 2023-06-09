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
      actionDispatcher.dispatchOnMain(LabelsActions.GetLabels())
      do {
        let labels = try await trainingDataRepository.getAllLabels()
        actionDispatcher.dispatchOnMain(LabelsActions.GotLabels(labels: labels))
      }
      catch let error as NSError where error.code == 260 {
        // Do nothing, training data folder doesn't exist
        actionDispatcher.dispatchOnMain(LabelsActions.GotLabels(labels: []))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(LabelsActions.GettingLabelsFailed(error: errorMessage))
      }
    }
  }
}
