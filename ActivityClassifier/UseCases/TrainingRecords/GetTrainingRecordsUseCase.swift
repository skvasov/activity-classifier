//
//  GetTrainingRecordsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class GetTrainingRecordsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let label: TrainingLabel
  private let trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel, trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.label = label
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(TrainingRecordsActions.GetTrainingRecords())
      do {
        let trainingRecords = try await trainingDataRepository.getAllTrainingRecords(for: label)
        actionDispatcher.dispatch(TrainingRecordsActions.GotTrainingRecords(trainingRecords: trainingRecords))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(TrainingRecordsActions.GettingTrainingRecordsFailed(error: errorMessage))
      }
    }
  }
}
