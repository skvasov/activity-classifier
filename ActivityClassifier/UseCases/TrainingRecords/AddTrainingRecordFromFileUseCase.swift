//
//  AddTrainingRecordFromFileUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 2.06.23.
//

import Foundation

class AddTrainingRecordFromFileUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let label: TrainingLabel
  private let trainingDataRepository: TrainingDataRepository
  private let trainingRecordFile: URL
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel, trainingDataRepository: TrainingDataRepository, trainingRecordFile: URL) {
    self.actionDispatcher = actionDispatcher
    self.label = label
    self.trainingRecordFile = trainingRecordFile
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddTrainingRecord())
      do {
        let data = try Data(contentsOf: trainingRecordFile)
        
        let trainingRecord = TrainingRecord(content: data)
        try await trainingDataRepository.addTrainingRecord(trainingRecord, for: label)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddedTrainingRecord(trainingRecord: trainingRecord))
        
        trainingDataRepository.invalidateSelectedTrainingLabel()
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(TrainingRecordsActions.AddingTrainingRecordFailed(error: errorMessage))
      }
    }
  }
}
