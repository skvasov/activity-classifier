//
//  TrainingRecordsReducer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import ReSwift

extension Reducers {
  static func trainingRecordsReducer(action: Action, state: TrainingRecordsState) -> TrainingRecordsState {
    var state = state
    
    switch action {
    case _ as TrainingRecordsActions.GetTrainingRecords:
      state.viewState.isLoading = true
    case let action as TrainingRecordsActions.GotTrainingRecords:
      state.trainingRecords = action.trainingRecords
      state.viewState.isLoading = false
    case let action as TrainingRecordsActions.GettingTrainingRecordsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as TrainingRecordsActions.AddTrainingRecord:
      state.viewState.isAddingNewRecord = true
      state.viewState.isEditing = false
    case let action as TrainingRecordsActions.AddedTrainingRecord:
      state.trainingRecords.append(action.trainingRecord)
      state.viewState.isAddingNewRecord = false
      state.viewState.isLoading = false
      state.viewState.isEditing = false
    case let action as TrainingRecordsActions.AddingTrainingRecordFailed:
      state.viewState.isLoading = false
      state.viewState.isAddingNewRecord = false
      state.viewState.isEditing = false
      state.errorsToPresent.insert(action.error)
    case _ as TrainingRecordsActions.RemoveTrainingRecords:
      state.viewState.isLoading = true
      state.viewState.isAddingNewRecord = false
      state.viewState.isEditing = false
    case let action as TrainingRecordsActions.RemovedTrainingRecords:
      state.trainingRecords.removeAll { label in
        action.removedTrainingRecords.contains(label)
      }
      state.viewState.isLoading = false
      state.viewState.isAddingNewRecord = false
    case let action as TrainingRecordsActions.RemovingTrainingRecordsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as TrainingRecordsActions.EditTrainingRecords:
      state.viewState.isEditing = true
      state.viewState.isAddingNewRecord = false
    case _ as TrainingRecordsActions.CancelEditingTrainingRecords:
      state.viewState.isEditing = false
      state.viewState.isAddingNewRecord = false
    case _ as TrainingRecordsActions.CloseTrainingRecordsErrorUseCase:
      state.errorsToPresent.removeFirst()
      
    default:
      break
    }
    
    return state
  }
}
