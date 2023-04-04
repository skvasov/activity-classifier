//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//
import Foundation
import ReSwift

public struct Reducers {}

extension Reducers {

  static func appReducer(action: Action, state: AppState?) -> AppState {
    return state ?? AppState.tab
  }
}
