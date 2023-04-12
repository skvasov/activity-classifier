//
//  TrainingRecordsActions.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import ReSwift

struct VerifyActions {
  
  struct LoadModel: Action {}
  struct LoadedModel: Action {
    let model: Model?
  }
  struct LoadingModelFailed: Action {
    let error: ErrorMessage
  }
  
  struct ImportModel: Action {}
  struct CancelImportingModel: Action {}
  
  struct SaveModel: Action {}
  struct SavedModel: Action {
    let model: Model?
  }
  struct SavingModelFailed: Action {
    let error: ErrorMessage
  }
  
  struct RunModel: Action {}
  struct RunningModelFailed: Action {
    let error: ErrorMessage
  }
  
  struct StopModel: Action {}
  struct DidStopModel: Action {}
  struct StoppingModelFailed: Action {
    let error: ErrorMessage
  }
  
  struct GotPrediction: Action {
    let prediction: Prediction
  }
  
  struct CloseVerifyError: Action {}
}

