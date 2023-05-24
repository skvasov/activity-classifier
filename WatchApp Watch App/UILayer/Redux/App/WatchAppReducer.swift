//
//  WatchAppReducer.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import ReSwift

struct Reducers {}

extension Reducers {
  static func appReducer(action: Action, state: WatchAppState?) -> WatchAppState {
    var state = state ?? WatchAppState()
    
    state.recordState = recordReducer(action: action, state: state.recordState)
    state.verifyState = verifyReducer(action: action, state: state.verifyState)
    
    return state
  }
}
