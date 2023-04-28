//
//  VerifyActions.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
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
}
