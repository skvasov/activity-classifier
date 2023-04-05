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
    case let action as LabelsActions.AddedLabel:
      state.labels.append(action.label)
      state.viewState.isLoading = false
    case let action as LabelsActions.AddingLabelFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as LabelsActions.RemovingLabel:
      state.viewState.isLoading = true
    case let action as LabelsActions.RemovedLabel:
      state.labels.removeAll { label in
        action.removedLabels.contains(label)
      }
      state.viewState.isLoading = false
    case let action as LabelsActions.RemovingLabelFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    default:
      break
    }
    
    return state
  }
}
