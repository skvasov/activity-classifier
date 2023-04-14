//
//  SettingsReducer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation
import ReSwift

extension Reducers {
  static func settingsReducer(action: Action, state: SettingsState) -> SettingsState {
    var state = state
    
    switch action {
    case _ as SettingsActions.LoadSettings:
      state.viewState.isLoading = true
    case let action as SettingsActions.LoadedSettings:
      state.settings = action.settings
      state.viewState.isLoading = false
    case let action as SettingsActions.LoadingSettingsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as SettingsActions.SaveSettings:
      state.viewState.isLoading = true
    case let action as SettingsActions.SavedSettings:
      state.settings = action.settings
      state.viewState.isLoading = false
    case let action as SettingsActions.SavingSettingsFailed:
      state.viewState.isLoading = false
      state.errorsToPresent.insert(action.error)
    case _ as SettingsActions.CloseSettingsError:
      state.errorsToPresent.removeFirst()
    default:
      break
    }
    
    return state
  }
}
