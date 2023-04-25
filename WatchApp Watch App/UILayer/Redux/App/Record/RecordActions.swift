//
//  RecordActions.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import ReSwift

struct RecordActions {
  struct GetTrainingLabel: Action {}
  struct GotTrainingLabel: Action {
    let label: TrainingLabel?
  }
  struct GettingTrainingLabelFailed: Action {
    let error: ErrorMessage
  }
  
  struct AddTrainingRecord: Action {}
  struct AddedTrainingRecord: Action {}
  struct AddingTrainingRecordFailed: Action {
    let error: ErrorMessage
  }
}
