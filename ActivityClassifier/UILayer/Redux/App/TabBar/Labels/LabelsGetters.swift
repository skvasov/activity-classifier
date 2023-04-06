//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct LabelsGetters {
  let getLabelsState: (AppState) -> ScopedState<LabelsState>
  
  init(getLabelsState: @escaping (AppState) -> ScopedState<LabelsState>) {
    self.getLabelsState = getLabelsState
  }
  
  func getTrainingRecordsState(_ appState: AppState) -> ScopedState<TrainingRecordsState> {
    let getLabelsState = getLabelsState(appState)
    switch getLabelsState {
    case .inScope(let labelsState):
      if let trainingRecordsState = labelsState.trainingRecordsState {
        return .inScope(trainingRecordsState)
      }
      return .outOfScope
    case .outOfScope:
      return .outOfScope
    }
  }
}
