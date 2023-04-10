//
//  TrainingRecordsActions.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import ReSwift

struct TrainingRecordsActions {

  struct GetTrainingRecords: Action {}
  struct GotTrainingRecords: Action {
    let trainingRecords: [TrainingRecord]
  }
  struct GettingTrainingRecordsFailed: Action {
    let error: ErrorMessage
  }
  
  struct AddTrainingRecord: Action {}
  struct AddedTrainingRecord: Action {
    let trainingRecord: TrainingRecord
  }
  struct AddingTrainingRecordFailed: Action {
    let error: ErrorMessage
  }
  
  struct RemoveTrainingRecords: Action {}
  struct RemovedTrainingRecords: Action {
    let removedTrainingRecords: [TrainingRecord]
  }
  struct RemovingTrainingRecordsFailed: Action {
    let error: ErrorMessage
  }
  
  struct EditTrainingRecords: Action {}
  struct CancelEditingTrainingRecords: Action {}
  
  struct CloseTrainingRecordsErrorUseCase: Action {}
}

