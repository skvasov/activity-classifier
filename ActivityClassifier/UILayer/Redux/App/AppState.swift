//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct AppState: Equatable {
  var tabBarState: TabBarState
  
  init() {
    tabBarState = TabBarState()
  }
}
