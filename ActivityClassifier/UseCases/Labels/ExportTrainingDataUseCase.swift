//
//  ExportTrainingDataUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 7.04.23.
//

import Foundation

class ExportTrainingDataUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    actionDispatcher.dispatch(LabelsActions.CancelEditingLabels())
  }
}