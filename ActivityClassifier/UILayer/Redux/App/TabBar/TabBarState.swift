//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct TabBarState: Equatable {
  var labelsState: LabelsState
  var verifyState: VerifyState
  var settingsState: SettingsState
  
  init() {
    self.labelsState = LabelsState(viewState: LabelsViewState())
    self.verifyState = VerifyState(viewState: VerifyViewState())
    self.settingsState = SettingsState(viewState: SettingsViewState())
  }
}
