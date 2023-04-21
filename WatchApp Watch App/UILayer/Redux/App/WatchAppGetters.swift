//
//  WatchAppGetters.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

struct WatchAppGetters {
  func geRecordState(_ appState: WatchAppState) -> ScopedState<RecordState> {
    .inScope(appState.recordState)
  }
}
