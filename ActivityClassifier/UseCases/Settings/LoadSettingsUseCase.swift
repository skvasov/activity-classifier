//
//  LoadSettingsUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

class LoadSettingsUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let settingsRepository: SettingsRepository
  
  init(actionDispatcher: ActionDispatcher, settingsRepository: SettingsRepository) {
    self.actionDispatcher = actionDispatcher
    self.settingsRepository = settingsRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(SettingsActions.LoadSettings())
      do {
        let settings = try await settingsRepository.load()
        actionDispatcher.dispatchOnMain(SettingsActions.LoadedSettings(settings: settings))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(SettingsActions.LoadingSettingsFailed(error: errorMessage))
      }
    }
  }
}
