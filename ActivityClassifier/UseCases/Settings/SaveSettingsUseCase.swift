//
//  SaveSettingsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

enum SaveSettingsUseCaseError: Error {
  case invalidSettings
}

class SaveSettingsUseCase: UseCase {
  enum Boundaries {
    static let minFrequency = 1
    static let maxFrequency = 100
    static let defaultFrequency = 50
    
    static let minPredictionWindow = 1
    static let maxPredictionWindow = 1000
    static let defaultPredictionWindow = 100
    
    static let minDelay = 0
    static let maxDelay = 10
    static let defaultDelay = 0
  }
  
  private let actionDispatcher: ActionDispatcher
  private let settings: Settings
  private let settingsRepository: SettingsRepository
  
  init(actionDispatcher: ActionDispatcher, settings: Settings, settingsRepository: SettingsRepository) {
    self.actionDispatcher = actionDispatcher
    self.settings = settings
    self.settingsRepository = settingsRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(SettingsActions.SaveSettings())
      do {
        try validateSettings()
        try await settingsRepository.save(settings)
        actionDispatcher.dispatchOnMain(SettingsActions.SavedSettings(settings: settings))
      }
      catch _ as SaveSettingsUseCaseError {
        let errorMessage = ErrorMessage(message: "Invalid settings")
        actionDispatcher.dispatchOnMain(SettingsActions.SavingSettingsFailed(error: errorMessage))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(SettingsActions.SavingSettingsFailed(error: errorMessage))
      }
    }
  }
  
  private func validateSettings() throws {
    guard
      settings.frequency >= Boundaries.minFrequency,
      settings.frequency <= Boundaries.maxFrequency,
      settings.frequency <= settings.predictionWindow,
      settings.predictionWindow >= Boundaries.minPredictionWindow,
      settings.predictionWindow <= Boundaries.maxPredictionWindow,
      settings.delay >= Boundaries.minDelay,
      settings.delay <= Boundaries.maxDelay
    else {
      throw SaveSettingsUseCaseError.invalidSettings
    }
  }
}

extension Settings {
  static var `default`: Settings {
    .init(
      frequency: SaveSettingsUseCase.Boundaries.defaultFrequency,
      predictionWindow: SaveSettingsUseCase.Boundaries.defaultPredictionWindow,
      delay: SaveSettingsUseCase.Boundaries.defaultDelay)
  }
}
