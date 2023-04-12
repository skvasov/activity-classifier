//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct TabBarGetters {
  let getTabBarState: (AppState) -> ScopedState<TabBarState>
  
  init(getTabBarState: @escaping (AppState) -> ScopedState<TabBarState>) {
    self.getTabBarState = getTabBarState
  }
  
  func getLabelsState(_ appState: AppState) -> ScopedState<LabelsState> {
    let tabBarState = getTabBarState(appState)
    switch tabBarState {
    case .inScope(let tabBarState):
      return .inScope(tabBarState.labelsState)
    case .outOfScope:
      return .outOfScope
    }
  }
  
  func getVerifyState(_ appState: AppState) -> ScopedState<VerifyState> {
    let tabBarState = getTabBarState(appState)
    switch tabBarState {
    case .inScope(let tabBarState):
      return .inScope(tabBarState.verifyState)
    case .outOfScope:
      return .outOfScope
    }
  }
}
