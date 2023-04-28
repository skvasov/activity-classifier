//
//  VerifyReducer.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import ReSwift

extension Reducers {
  static func verifyReducer(action: Action, state: VerifyState) -> VerifyState {
    var state = state
    
    switch action {
    case _ as VerifyActions.LoadModel:
      state.viewState.isLoading = true
    case let action as VerifyActions.LoadedModel:
      state.model = action.model
      state.viewState.isLoading = false
      state.viewState.isRunning = false
    case let action as VerifyActions.LoadingModelFailed:
      state.viewState.isLoading = false
    case _ as VerifyActions.RunModel:
      state.viewState.isLoading = true
    case let action as VerifyActions.RunningModelFailed:
      state.viewState.isLoading = false
    case _ as VerifyActions.StopModel:
      state.viewState.isLoading = true
    case _ as VerifyActions.DidStopModel:
      state.viewState.isLoading = false
      state.viewState.isRunning = false
    case let action as VerifyActions.StoppingModelFailed:
      state.viewState.isLoading = false
    case let action as VerifyActions.GotPrediction:
      state.viewState.isLoading = false
      state.viewState.isRunning = true
      state.prediction = action.prediction
    default:
      break
    }
    
    return state
  }
}
