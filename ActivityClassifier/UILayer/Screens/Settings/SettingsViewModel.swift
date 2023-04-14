//
//  SettingsViewModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

class SettingsViewModel: ObservableObject {
  @Published var settings = Settings.default
  @Published var isLoading = false
  @Published var isPresentingAlert = false
  @Published var presentedAlert: AlertDetails = .init()
  var duration: Double { Double(settings.predictionWindow) / Double(settings.frequency) }
  
  private let observerForSettings: Observer
  private let loadSettingsUseCase: UseCase
  private let saveSettingsUseCaseFactory: SaveSettingsUseCaseFactory
  private let closeLabelsErrorUseCaseFactory: CloseSettingsErrorUseCaseFactory
  
  init(observerForSettings: Observer,
       loadSettingsUseCase: UseCase,
       saveSettingsUseCaseFactory: @escaping SaveSettingsUseCaseFactory,
       closeLabelsErrorUseCaseFactory: @escaping CloseSettingsErrorUseCaseFactory) {
    self.observerForSettings = observerForSettings
    self.loadSettingsUseCase = loadSettingsUseCase
    self.saveSettingsUseCaseFactory = saveSettingsUseCaseFactory
    self.closeLabelsErrorUseCaseFactory = closeLabelsErrorUseCaseFactory
  }
  
  func onAppear() {
    observerForSettings.startObserving()
    loadSettingsUseCase.execute()
  }
  
  func incrementFrequency() {
    var copy = settings
    copy.frequency += 1
    let useCase = saveSettingsUseCaseFactory(copy)
    useCase.execute()
  }
  
  func decrementFrequency() {
    var copy = settings
    copy.frequency -= 1
    let useCase = saveSettingsUseCaseFactory(copy)
    useCase.execute()
  }
  
  func incrementPredictionWindow() {
    var copy = settings
    copy.predictionWindow += 1
    let useCase = saveSettingsUseCaseFactory(copy)
    useCase.execute()
  }
  
  func decrementPredictionWindow() {
    var copy = settings
    copy.predictionWindow -= 1
    let useCase = saveSettingsUseCaseFactory(copy)
    useCase.execute()
  }
  
  func incrementDelay() {
    var copy = settings
    copy.delay += 1
    let useCase = saveSettingsUseCaseFactory(copy)
    useCase.execute()
  }
  
  func decrementDelay() {
    var copy = settings
    copy.delay -= 1
    let useCase = saveSettingsUseCaseFactory(copy)
    useCase.execute()
  }
  
  func finishPresentingError() {
    let useCase = closeLabelsErrorUseCaseFactory()
    useCase.execute()
  }
  
  deinit {
    observerForSettings.stopObserving()
  }
}

extension SettingsViewModel: ObserverForSettingsEventResponder {
  func received(newState state: SettingsState) {
    settings = state.settings ?? .default
    isLoading = state.viewState.isLoading
    if let error = state.errorsToPresent.first {
      isPresentingAlert = true
      presentedAlert = .init(error: error, completion: finishPresentingError)
    }
    else {
      isPresentingAlert = false
    }
  }
}
