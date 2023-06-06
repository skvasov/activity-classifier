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
  private let updateWatchContextUseCaseFactory: UpdateWatchContextUseCaseFactory
  private let closeLabelsErrorUseCaseFactory: CloseSettingsErrorUseCaseFactory
  
  init(observerForSettings: Observer,
       loadSettingsUseCase: UseCase,
       saveSettingsUseCaseFactory: @escaping SaveSettingsUseCaseFactory,
       updateWatchContextUseCaseFactory: @escaping UpdateWatchContextUseCaseFactory,
       closeLabelsErrorUseCaseFactory: @escaping CloseSettingsErrorUseCaseFactory) {
    self.observerForSettings = observerForSettings
    self.loadSettingsUseCase = loadSettingsUseCase
    self.saveSettingsUseCaseFactory = saveSettingsUseCaseFactory
    self.updateWatchContextUseCaseFactory = updateWatchContextUseCaseFactory
    self.closeLabelsErrorUseCaseFactory = closeLabelsErrorUseCaseFactory
  }
  
  func onAppear() {
    observerForSettings.startObserving()
    loadSettingsUseCase.execute()
  }
  
  func incrementFrequency() {
    var copy = settings
    copy.frequency += 1
    saveSettings(copy)
  }
  
  func decrementFrequency() {
    var copy = settings
    copy.frequency -= 1
    saveSettings(copy)
  }
  
  func incrementPredictionWindow() {
    var copy = settings
    copy.predictionWindow += 1
    saveSettings(copy)
  }
  
  func decrementPredictionWindow() {
    var copy = settings
    copy.predictionWindow -= 1
    saveSettings(copy)
  }
  
  func incrementDelay() {
    var copy = settings
    copy.delay += 1
    saveSettings(copy)
  }
  
  func decrementDelay() {
    var copy = settings
    copy.delay -= 1
    saveSettings(copy)
  }
  
  func finishPresentingError() {
    let useCase = closeLabelsErrorUseCaseFactory()
    useCase.execute()
  }
  
  private func saveSettings(_ settings: Settings) {
    let useCase = saveSettingsUseCaseFactory(settings) { [weak self] in
      let updateWatchContextUseCase = self?.updateWatchContextUseCaseFactory()
      updateWatchContextUseCase?.execute()
    }
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
