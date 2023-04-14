//
//  SettingsActions.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation
import ReSwift

struct SettingsActions {

  struct LoadSettings: Action {}
  struct LoadedSettings: Action {
    let settings: Settings?
  }
  struct LoadingSettingsFailed: Action {
    let error: ErrorMessage
  }
  
  struct SaveSettings: Action {}
  struct SavedSettings: Action {
    let settings: Settings
  }
  struct SavingSettingsFailed: Action {
    let error: ErrorMessage
  }
  
  struct CloseSettingsError: Action {}
}

