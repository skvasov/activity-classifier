//
//  VerifyViewModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

class VerifyViewModel: ObservableObject {
  @Published var model: Model?
  @Published var isImporting: Bool = false {
    // TODO: There is no other way to track user closing file import popup
    didSet {
      if isImportingLastValue != isImporting && isImportingLastValue {
        let useCase = cancelImportingModelUseCaseFactory()
        useCase.execute()
      }
      isImportingLastValue = isImporting
    }
  }
  @Published var isLoading = false
  @Published var isRunning = false
  @Published var isPresentingAlert = false
  @Published var presentedAlert: AlertDetails = .init()
  @Published var prediction: Prediction?
  
  private var isImportingLastValue = false
  private let observerForVerify: Observer
  private let importModelUseCaseFactory: ImportModelUseCaseFactory
  private let cancelImportingModelUseCaseFactory: CancelImportingModelUseCaseFactory
  private let saveModelUseCaseFactory: SaveModelUseCaseFactory
  private let runModelUseCaseFactory: RunModelUseCaseFactory
  private let stopModelUseCaseFactory: StopModelUseCaseFactory
  private let loadModelUseCaseFactory: LoadModelUseCaseFactory
  
  init(
    observerForVerify: Observer,
    importModelUseCaseFactory: @escaping ImportModelUseCaseFactory,
    cancelImportingModelUseCaseFactory: @escaping CancelImportingModelUseCaseFactory,
    saveModelUseCaseFactory: @escaping SaveModelUseCaseFactory,
    runModelUseCaseFactory: @escaping RunModelUseCaseFactory,
    stopModelUseCaseFactory: @escaping StopModelUseCaseFactory,
    loadModelUseCaseFactory: @escaping LoadModelUseCaseFactory
  ) {
    self.observerForVerify = observerForVerify
    self.importModelUseCaseFactory = importModelUseCaseFactory
    self.cancelImportingModelUseCaseFactory = cancelImportingModelUseCaseFactory
    self.saveModelUseCaseFactory = saveModelUseCaseFactory
    self.runModelUseCaseFactory = runModelUseCaseFactory
    self.stopModelUseCaseFactory = stopModelUseCaseFactory
    self.loadModelUseCaseFactory = loadModelUseCaseFactory
  }
  
  func onAppear() {
    observerForVerify.startObserving()
    let useCase = loadModelUseCaseFactory()
    useCase.execute()
  }
  
  func importModel() {
    let useCase = importModelUseCaseFactory()
    useCase.execute()
  }
  
  func cancelImportModel() {
    let useCase = cancelImportingModelUseCaseFactory()
    useCase.execute()
  }
  
  func saveModel(_ importResult: Result<URL, Error>) {
    let useCase = saveModelUseCaseFactory(importResult)
    useCase.execute()
  }
  
  func run() {
    guard let model = model else { return }
    let useCase = runModelUseCaseFactory(model)
    useCase.execute()
  }
  
  func stop() {
    let useCase = stopModelUseCaseFactory()
    useCase.execute()
  }
  
  func finishPresentingError() {
    
  }
  
  deinit {
    observerForVerify.stopObserving()
  }
}

extension VerifyViewModel: ObserverForVerifyEventResponder {
  func received(newState state: VerifyState) {
    model = state.model
    isLoading = state.viewState.isLoading
    isImporting = state.viewState.isImporting
    isRunning = state.viewState.isRunning
    if let error = state.errorsToPresent.first {
      isPresentingAlert = true
      presentedAlert = .init(error: error, completion: finishPresentingError)
    }
    else {
      isPresentingAlert = false
    }
  }
}
