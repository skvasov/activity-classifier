//
//  BackToLabelsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class BackToLabelsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private var trainingDataReposioty: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, trainingDataReposioty: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.trainingDataReposioty = trainingDataReposioty
  }
  
  func execute() {
    Task {
      trainingDataReposioty.selectedTrainingLabel = nil
      actionDispatcher.dispatchOnMain(LabelsActions.BackToLabels())
    }
  }
}
