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
  private let loadModelUseCase: UseCase
  private let runModelUseCaseFactory: RunModelUseCaseFactory
  private let stopModelUseCase: UseCase
  
  init(observerForVerify: Observer, loadModelUseCase: UseCase, runModelUseCaseFactory: @escaping RunModelUseCaseFactory, stopModelUseCase: UseCase) {
    self.observerForVerify = observerForVerify
    self.loadModelUseCase = loadModelUseCase
    self.runModelUseCaseFactory = runModelUseCaseFactory
    self.stopModelUseCase = stopModelUseCase
  }
  
  func onAppear() {
    observerForVerify.startObserving()
    loadModelUseCase.execute()
  }
  
  func run() {
    guard let model = model else { return }
    let useCase = runModelUseCaseFactory(model)
    useCase.execute()
  }
  
  func stop() {
    stopModelUseCase.execute()
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
  
  func received(newModel model: Model) {
    loadModelUseCase.execute()
  }
}


