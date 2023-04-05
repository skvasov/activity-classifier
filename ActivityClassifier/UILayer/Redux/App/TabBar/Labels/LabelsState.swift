//
//  ContentView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct LabelsState: Equatable {
  var labels: [TrainingLabel] = []
  var viewState: LabelsViewState
  var errorsToPresent = Set<ErrorMessage>()
}

struct LabelsViewState: Equatable {
  var isLoading = false
  var isEditing = false
  var isAddingNewLabel = false
}
