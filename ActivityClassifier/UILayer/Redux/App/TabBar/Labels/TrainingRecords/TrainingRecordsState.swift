//
//  TrainingRecordsState.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

struct TrainingRecordsState: Equatable {
  let label: TrainingLabel
  var trainingRecords: [TrainingRecord] = []
  var viewState: TrainingRecordsViewState
  var errorsToPresent = Set<ErrorMessage>()
}

struct TrainingRecordsViewState: Equatable {
  var isLoading = false
  var isEditing = false
  var isAddingNewRecord = false
}
