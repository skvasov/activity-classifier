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
  private let getLatestModelUseCase: UseCase
  
  init(observerForVerify: Observer, getLatestModelUseCase: UseCase) {
    self.observerForVerify = observerForVerify
    self.getLatestModelUseCase = getLatestModelUseCase
  }
  
  func onAppear() {
    observerForVerify.startObserving()
    getLatestModelUseCase.execute()
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


