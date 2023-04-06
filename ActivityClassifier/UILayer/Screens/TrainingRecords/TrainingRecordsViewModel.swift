//
//  TrainingRecordsViewModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import SwiftUI

class TrainingRecordsViewModel: ObservableObject {
  @Published var trainingRecords: [TrainingRecord] = []
  @Published var isLoading = false
  @Published var isEditing = false
  @Published var isAddingNewRecord = false
  var title: String { label.name }
  
  private let label: TrainingLabel
  private let observerForTrainingRecords: Observer
  private let getTrainingRecordsUseCase: UseCase
  private let addTrainingRecordUseCaseFactory: AddTrainingRecordUseCaseFactory
  private let removeTrainingRecordsUseCaseFactory: RemoveTrainingRecordsUseCaseFactory
  
  init(label: TrainingLabel, observerForTrainingRecords: Observer, getTrainingRecordsUseCase: UseCase, addTrainingRecordUseCaseFactory: @escaping AddTrainingRecordUseCaseFactory, removeTrainingRecordsUseCaseFactory: @escaping RemoveTrainingRecordsUseCaseFactory) {
    self.label = label
    self.observerForTrainingRecords = observerForTrainingRecords
    self.getTrainingRecordsUseCase = getTrainingRecordsUseCase
    self.addTrainingRecordUseCaseFactory = addTrainingRecordUseCaseFactory
    self.removeTrainingRecordsUseCaseFactory = removeTrainingRecordsUseCaseFactory
  }
  
  func onAppear() {
    observerForTrainingRecords.startObserving()
    getTrainingRecordsUseCase.execute()
  }
  
  func add() {
    isAddingNewRecord = true
    let useCase = addTrainingRecordUseCaseFactory()
    useCase.execute()
  }
  
  func edit() {
    isEditing = true
  }
  
  func cancel() {
    isEditing = false
  }
  
  func removeAll() {
    let useCase = removeTrainingRecordsUseCaseFactory(trainingRecords)
    useCase.execute()
  }
  
  func remove(at index: Int) {
    let useCase = removeTrainingRecordsUseCaseFactory([trainingRecords[index]])
    useCase.execute()
  }
  
  deinit {
    observerForTrainingRecords.stopObserving()
  }
}

extension TrainingRecordsViewModel: ObserverForTrainingRecordsEventResponder {
  func received(newState state: TrainingRecordsState) {
    trainingRecords = state.trainingRecords
    isLoading = state.viewState.isLoading
    isEditing = state.viewState.isEditing
    isAddingNewRecord = state.viewState.isAddingNewRecord
  }
}
