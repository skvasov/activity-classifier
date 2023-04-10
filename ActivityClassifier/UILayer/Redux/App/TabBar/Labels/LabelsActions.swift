//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import ReSwift

struct LabelsActions {

  struct GetLabels: Action {}
  struct GotLabels: Action {
    let labels: [TrainingLabel]
  }
  struct GettingLabelsFailed: Action {
    let error: ErrorMessage
  }
  
  struct InputLabelName: Action {}
  struct CancelInputtingLabelName: Action {}
  
  struct AddLabel: Action {}
  struct AddedLabel: Action {
    let label: TrainingLabel
  }
  struct AddingLabelFailed: Action {
    let error: ErrorMessage
  }
  
  struct RemoveLabels: Action {}
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
  struct EditLabels: Action {}
  struct CancelEditingLabels: Action {}
  
  struct ExportTrainingData: Action {}
  struct ExportedTrainingData: Action {
  }
  struct ExportingTrainingDataFailed: Action {
    let label: TrainingLabel
  }
  
  struct CloseLabelsErrorUseCase: Action {}
}

