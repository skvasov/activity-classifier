//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//
import Foundation
import ReSwift

extension Reducers {
  static func labelsReducer(action: Action, state: LabelsState?) -> LabelsState {
    var state = state ?? LabelsState(viewState: LabelsViewState())
    
    switch action {
    case _ as LabelsActions.GettingLabels:
      state.viewState.isLoading = true
    case let action as LabelsActions.GotLabels:
      state.labels = action.labels
      state.viewState.isLoading = false
    case let action as LabelsActions.GettingLabelsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as LabelsActions.AddingLabel:
      state.viewState.isLoading = true
      state.viewState.isAddingNewLabel = false
      state.viewState.isEditing = false
    case let action as LabelsActions.AddedLabel:
      state.labels.append(action.label)
      state.viewState.isLoading = false
      state.viewState.isAddingNewLabel = false
      state.viewState.isEditing = false
    case let action as LabelsActions.AddingLabelFailed:
      state.viewState.isLoading = false
      state.viewState.isAddingNewLabel = false
      state.viewState.isEditing = false
      state.errorsToPresent.insert(action.error)
    case _ as LabelsActions.RemovingLabels:
      state.viewState.isLoading = true
      state.viewState.isAddingNewLabel = false
      state.viewState.isEditing = false
    case let action as LabelsActions.RemovedLabels:
      state.labels.removeAll { label in
        action.removedLabels.contains(label)
      }
      state.viewState.isLoading = false
      state.viewState.isAddingNewLabel = false
    case let action as LabelsActions.RemovingLabelsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case let action as LabelsActions.GoToTrainingRecords:
      state.trainingRecordsState = TrainingRecordsState(label: action.label, viewState: .init())
      state.presentedLabels = [action.label]
    case _ as LabelsActions.BackToLabels:
      state.trainingRecordsState = nil
      state.presentedLabels = []
    case _ as LabelsActions.EditLabels:
      state.viewState.isEditing = true
      state.viewState.isAddingNewLabel = false
    case _ as LabelsActions.CancelEditingLabels:
      state.viewState.isEditing = false
      state.viewState.isAddingNewLabel = false
    case _ as LabelsActions.InputLabelName:
      state.viewState.isAddingNewLabel = true
    case _ as LabelsActions.CancelInputtingLabelName:
      state.viewState.isAddingNewLabel = false
    case _ as LabelsActions.CloseLabelsErrorUseCase:
      state.errorsToPresent.removeFirst()
    default:
      break
    }
    
    if let trainingRecordsState = state.trainingRecordsState {
      state.trainingRecordsState = trainingRecordsReducer(action: action, state: trainingRecordsState)
    }
    
    return state
  }
}
