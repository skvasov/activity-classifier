//
//  RecordReducer.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import ReSwift

extension Reducers {
  static func recordReducer(action: Action, state: RecordState) -> RecordState {
    var state = state
    
    switch action {
    case _ as RecordActions.GetTrainingLabel:
      state.viewState.isLoading = true
    case let action as RecordActions.GotTrainingLabel:
      state.viewState.isLoading = false
      state.label = action.label
    case let action as RecordActions.GettingTrainingLabelFailed:
      state.viewState.isLoading = false
      
    case _ as RecordActions.AddTrainingRecord:
      state.viewState.isAddingNewRecord = true
    case _ as RecordActions.AddedTrainingRecord:
      state.viewState.isAddingNewRecord = false
    case let action as RecordActions.AddingTrainingRecordFailed:
      state.viewState.isAddingNewRecord = false
    default:
      break
    }
    
    return state
  }
}
