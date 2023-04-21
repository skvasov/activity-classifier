//
//  WatchAppState.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

struct WatchAppState: Equatable {
  var recordState: RecordState
  
  init() {
    recordState = RecordState()
  }
}
