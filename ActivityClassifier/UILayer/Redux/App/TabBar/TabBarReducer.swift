//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//
import Foundation
import ReSwift

extension Reducers {
  static func tabBarReducer(action: Action, state: TabBarState?) -> TabBarState {
    var state = state ?? TabBarState()
    
    state.labelsState = labelsReducer(action: action, state: state.labelsState)
    state.verifyState = verifyReducer(action: action, state: state.verifyState)
    
    return state
  }
}
