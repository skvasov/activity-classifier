//
//  RecordState.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

struct RecordState: Equatable {
  var label: TrainingLabel?
  var viewState: RecordViewState
}

extension RecordState {
  init() {
    self.label = nil
    self.viewState = RecordViewState()
  }
}

struct RecordViewState: Equatable {
  var isLoading = false
  var isAddingNewRecord = false
}


