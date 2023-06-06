//
//  RemoveTrainingRecordsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class RemoveTrainingRecordsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let label: TrainingLabel
  private let trainingRecords: [TrainingRecord]
  private let trainingDataRepository: TrainingDataRepository
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel, trainingRecords: [TrainingRecord], trainingDataRepository: TrainingDataRepository) {
    self.actionDispatcher = actionDispatcher
    self.label = label
    self.trainingRecords = trainingRecords
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(TrainingRecordsActions.RemoveTrainingRecords())
      do {
        try await trainingDataRepository.removeTrainingRecords(trainingRecords, for: label)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.RemovedTrainingRecords(removedTrainingRecords: trainingRecords))
        
        trainingDataRepository.invalidateSelectedTrainingLabel()
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.RemovingTrainingRecordsFailed(error: errorMessage))
      }
    }
  }
}
