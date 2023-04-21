//
//  RecordState.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

struct RecordState: Equatable {
  let label: TrainingLabel?
}

extension RecordState {
  init() {
    self.label = nil
  }
}
