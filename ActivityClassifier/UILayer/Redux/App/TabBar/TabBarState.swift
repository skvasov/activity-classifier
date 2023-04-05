//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct TabBarState: Equatable {
  var labelsState: LabelsState
  
  init() {
    self.labelsState = LabelsState(viewState: LabelsViewState())
  }
}
