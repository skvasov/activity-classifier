//
//  AddTrainingRecordUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class AddTrainingRecordUseCase: UseCase {
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
      actionDispatcher.dispatch(TrainingRecordsActions.AddTrainingRecord())
      do {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let name = dateFormatter.string(from: Date())
        let trainingRecord = TrainingRecord(name: name, numOfChildren: 0)
        try await trainingDataRepository.addTrainingRecord(trainingRecord, for: label)
        actionDispatcher.dispatch(TrainingRecordsActions.AddedTrainingRecord(trainingRecord: trainingRecord))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(TrainingRecordsActions.AddingTrainingRecordFailed(error: errorMessage))
      }
    }
  }
}
