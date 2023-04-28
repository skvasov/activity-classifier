//
//  WatchAppGetters.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

struct WatchAppGetters {
  func getRecordState(_ appState: WatchAppState) -> ScopedState<RecordState> {
    .inScope(appState.recordState)
  }
  
  func getVerifyState(_ appState: WatchAppState) -> ScopedState<VerifyState> {
    .inScope(appState.verifyState)
  }
}
