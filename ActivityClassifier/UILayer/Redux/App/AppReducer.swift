//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//
import Foundation
import ReSwift

struct Reducers {}

extension Reducers {
  static func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    
    state.tabBarState = tabBarReducer(action: action, state: state.tabBarState)
    
    return state
  }
}
