//
//  TrainingRecordsReducer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import ReSwift

extension Reducers {
  static func trainingRecordsReducer(action: Action, state: TrainingRecordsState?) -> TrainingRecordsState {
    var state = state ?? TrainingRecordsState(viewState: TrainingRecordsViewState())
    
    switch action {
    case _ as TrainingRecordsActions.GettingTrainingRecords:
      state.viewState.isLoading = true
    case let action as TrainingRecordsActions.GotTrainingRecords:
      state.trainingRecords = action.trainingRecords
      state.viewState.isLoading = false
    case let action as TrainingRecordsActions.GettingTrainingRecordsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as TrainingRecordsActions.AddingTrainingRecord:
      state.viewState.isLoading = true
    case let action as TrainingRecordsActions.AddedTrainingRecord:
      state.trainingRecords.append(action.trainingRecord)
      state.viewState.isLoading = false
    case let action as TrainingRecordsActions.AddingTrainingRecordFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as TrainingRecordsActions.RemovingTrainingRecords:
      state.viewState.isLoading = true
    case let action as TrainingRecordsActions.RemovedTrainingRecords:
      state.trainingRecords.removeAll { record in
        action.removedTrainingRecords.contains(record)
      }
      state.viewState.isLoading = false
    case let action as TrainingRecordsActions.RemovingTrainingRecordsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    default:
      break
    }
    
    return state
  }
}
