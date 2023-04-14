//
//  SettingsState.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

struct SettingsState: Equatable {
  var settings: Settings?
  var viewState: SettingsViewState
  var errorsToPresent = Set<ErrorMessage>()
}

struct SettingsViewState: Equatable {
  var isLoading = false
}
