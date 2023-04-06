//
//  TrainingRecordsActions.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import ReSwift

struct TrainingRecordsActions {

  struct GettingTrainingRecords: Action {}
  struct GotTrainingRecords: Action {
    let trainingRecords: [TrainingRecord]
  }
  struct GettingTrainingRecordsFailed: Action {
    let error: ErrorMessage
  }
  
  struct AddingTrainingRecord: Action {}
  struct AddedTrainingRecord: Action {
    let trainingRecord: TrainingRecord
  }
  struct AddingTrainingRecordFailed: Action {
    let error: ErrorMessage
  }
  
  struct RemovingTrainingRecords: Action {}
  struct RemovedTrainingRecords: Action {
    let removedTrainingRecords: [TrainingRecord]
  }
  struct RemovingTrainingRecordsFailed: Action {
    let error: ErrorMessage
  }
}

