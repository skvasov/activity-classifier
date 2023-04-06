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
  
  struct RemovingLabels: Action {}
  struct RemovedLabels: Action {
    let removedLabels: [TrainingLabel]
  }
  struct RemovingLabelsFailed: Action {
    let error: ErrorMessage
  }
  
  struct GoToTrainingRecords: Action {
    let label: TrainingLabel
  }
  
  struct BackToLabels: Action {}
}

