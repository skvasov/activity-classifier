//
//  VerifyState.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

struct VerifyState: Equatable {
  var model: Model?
  var prediction: Prediction?
  var viewState: VerifyViewState
}

extension VerifyState {
  init() {
    self.model = nil
    self.prediction = nil
    self.viewState = VerifyViewState()
  }
}

struct VerifyViewState: Equatable {
  var isLoading = false
  var isRunning = false
}


