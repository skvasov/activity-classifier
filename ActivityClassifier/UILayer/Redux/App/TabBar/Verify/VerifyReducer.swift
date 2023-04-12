//
//  TrainingRecordsReducer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import ReSwift

extension Reducers {
  static func verifyReducer(action: Action, state: VerifyState) -> VerifyState {
    var state = state
    
    switch action {
    case _ as VerifyActions.ImportModel:
      state.viewState.isImporting = true
      state.viewState.isLoading = true
    case _ as VerifyActions.CancelImportingModel:
      state.viewState.isImporting = false
      state.viewState.isLoading = false
    case _ as VerifyActions.SaveModel:
      state.viewState.isImporting = false
      state.viewState.isLoading = true
    case let action as VerifyActions.SavedModel:
      state.model = action.model
      state.viewState.isLoading = false
      state.viewState.isRunning = false
    case let action as VerifyActions.SavingModelFailed:
      state.viewState.isImporting = false
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as VerifyActions.LoadModel:
      state.viewState.isLoading = true
    case let action as VerifyActions.LoadedModel:
      state.model = action.model
      state.viewState.isLoading = false
      state.viewState.isRunning = false
    case let action as VerifyActions.LoadingModelFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as VerifyActions.RunModel:
      state.viewState.isLoading = true
    case let action as VerifyActions.RunningModelFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as VerifyActions.StopModel:
      state.viewState.isLoading = true
    case _ as VerifyActions.DidStopModel:
      state.viewState.isLoading = false
      state.viewState.isRunning = false
    case let action as VerifyActions.StoppingModelFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as TrainingRecordsActions.CloseTrainingRecordsErrorUseCase:
      state.errorsToPresent.removeFirst()
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
