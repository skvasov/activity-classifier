//
//  TrainingRecordsState.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

struct VerifyState: Equatable {
  var model: Model?
  var viewState: VerifyViewState
  var errorsToPresent = Set<ErrorMessage>()
}

struct VerifyViewState: Equatable {
  var isLoading = false
  var isImporting = false
  var isRunning = false
}
