//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct AppGetters {
  func getTabBarState(_ appState: AppState) -> ScopedState<TabBarState> {
    .inScope(appState.tabBarState)
  }
}
