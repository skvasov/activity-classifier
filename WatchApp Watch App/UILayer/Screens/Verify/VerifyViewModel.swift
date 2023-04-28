//
//  VerifyViewModel.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

class VerifyViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var isRunning = false
  @Published var model: Model?
  @Published var prediction: Prediction?
  
  private let observerForVerify: Observer
  
  init(observerForVerify: Observer) {
    self.observerForVerify = observerForVerify
  }
  
  func onAppear() {
    observerForVerify.startObserving()
  }
  
  func run() {
    
  }
  
  func stop() {
    
  }
  
  deinit {
    observerForVerify.stopObserving()
  }
}

extension VerifyViewModel: ObserverForVerifyViewEventResponder {
  func received(newState state: VerifyState) {
    model = state.model
    prediction = state.prediction
    isLoading = state.viewState.isLoading
    isRunning = state.viewState.isRunning
  }
}


