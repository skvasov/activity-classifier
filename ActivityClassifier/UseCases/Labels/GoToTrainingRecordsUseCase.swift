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
  private var trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel, trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.label = label
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      trainingDataRepository.selectedTrainingLabel = label
      actionDispatcher.dispatchOnMain(LabelsActions.GoToTrainingRecords(label: label))
    }
  }
}
