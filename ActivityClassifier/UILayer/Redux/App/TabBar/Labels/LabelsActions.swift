//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import ReSwift

struct LabelsActions {

  struct GettingLabels: Action {}
  struct GotLabels: Action {
    let labels: [TrainingLabel]
  }
  struct GettingLabelsFailed: Action {
    let error: ErrorMessage
  }
  
  struct AddingLabel: Action {}
  struct AddedLabel: Action {
    let label: TrainingLabel
  }
  struct AddingLabelFailed: Action {
    let error: ErrorMessage
  }
  
  struct RemovingLabel: Action {}
  struct RemovedLabel: Action {
    let removedLabels: [TrainingLabel]
  }
  struct RemovingLabelFailed: Action {
    let error: ErrorMessage
  }
}

