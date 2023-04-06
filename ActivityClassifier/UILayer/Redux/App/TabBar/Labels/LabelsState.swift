//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct LabelsState: Equatable {
  var labels: [TrainingLabel] = []
  var presentedLabels: [TrainingLabel] = []
  var viewState: LabelsViewState
  var errorsToPresent = Set<ErrorMessage>()
  var trainingRecordsState: TrainingRecordsState?
  
  static func sameCase(lhs: LabelsState, rhs: LabelsState) -> Bool {
    if let leftTrainingRecordState = lhs.trainingRecordsState,
       let rightTrainingRecordState = rhs.trainingRecordsState,
       leftTrainingRecordState != rightTrainingRecordState
    {
      return true
    }
    
    return lhs == rhs
  }
}

struct LabelsViewState: Equatable {
  var isLoading = false
  var isEditing = false
  var isAddingNewLabel = false
}
