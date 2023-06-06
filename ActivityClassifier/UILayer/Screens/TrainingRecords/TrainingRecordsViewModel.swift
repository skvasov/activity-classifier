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
  @Published var isPresentingAlert = false
  @Published var presentedAlert: AlertDetails = .init()
  var title: String { label.name }
  
  private let label: TrainingLabel
  private let observerForTrainingRecords: Observer
  private let getTrainingRecordsUseCase: UseCase
  private let addTrainingRecordUseCaseFactory: AddTrainingRecordUseCaseFactory
  private let removeTrainingRecordsUseCaseFactory: RemoveTrainingRecordsUseCaseFactory
  private let backToLabelsUseCase: UseCase
  private let editTrainingRecordsUseCaseFactory: EditTrainingRecordsUseCaseFactory
  private let cancelEditingTrainingRecordsUseCaseFactory: CancelEditingTrainingRecordsUseCaseFactory
  private let closeTrainingRecordsErrorUseCaseFactory: CloseTrainingRecordsErrorUseCaseFactory
  private let addTrainingRecordFromFileUseCaseFactory: AddTrainingRecordFromFileUseCaseFactory
  
  init(
    label: TrainingLabel,
    observerForTrainingRecords: Observer,
    getTrainingRecordsUseCase: UseCase,
    addTrainingRecordUseCaseFactory: @escaping AddTrainingRecordUseCaseFactory,
    removeTrainingRecordsUseCaseFactory: @escaping RemoveTrainingRecordsUseCaseFactory,
    backToLabelsUseCase: UseCase,
    editTrainingRecordsUseCaseFactory: @escaping EditTrainingRecordsUseCaseFactory,
    cancelEditingTrainingRecordsUseCaseFactory: @escaping CancelEditingTrainingRecordsUseCaseFactory,
    closeTrainingRecordsErrorUseCaseFactory: @escaping CloseTrainingRecordsErrorUseCaseFactory,
    addTrainingRecordFromFileUseCaseFactory: @escaping AddTrainingRecordFromFileUseCaseFactory
  ) {
    self.label = label
    self.observerForTrainingRecords = observerForTrainingRecords
    self.getTrainingRecordsUseCase = getTrainingRecordsUseCase
    self.addTrainingRecordUseCaseFactory = addTrainingRecordUseCaseFactory
    self.removeTrainingRecordsUseCaseFactory = removeTrainingRecordsUseCaseFactory
    self.backToLabelsUseCase = backToLabelsUseCase
    self.editTrainingRecordsUseCaseFactory = editTrainingRecordsUseCaseFactory
    self.cancelEditingTrainingRecordsUseCaseFactory = cancelEditingTrainingRecordsUseCaseFactory
    self.closeTrainingRecordsErrorUseCaseFactory = closeTrainingRecordsErrorUseCaseFactory
    self.addTrainingRecordFromFileUseCaseFactory = addTrainingRecordFromFileUseCaseFactory
  }
  
  func onAppear() {
    observerForTrainingRecords.startObserving()
    getTrainingRecordsUseCase.execute()
  }
  
  func add() {
    let useCase = addTrainingRecordUseCaseFactory()
    useCase.execute()
  }
  
  func edit() {
    let useCase = editTrainingRecordsUseCaseFactory()
    useCase.execute()
  }
  
  func cancel() {
    let useCase = cancelEditingTrainingRecordsUseCaseFactory()
    useCase.execute()
  }
  
  func removeAll() {
    let useCase = removeTrainingRecordsUseCaseFactory(trainingRecords)
    useCase.execute()
  }
  
  func goBack() {
    backToLabelsUseCase.execute()
  }
  
  func remove(at index: Int) {
    let useCase = removeTrainingRecordsUseCaseFactory([trainingRecords[index]])
    useCase.execute()
  }
  
  func finishPresentingError() {
    let useCase = closeTrainingRecordsErrorUseCaseFactory()
    useCase.execute()
  }
  
  deinit {
    observerForTrainingRecords.stopObserving()
  }
}

extension TrainingRecordsViewModel: ObserverForTrainingRecordsEventResponder {
  func received(newState state: TrainingRecordsState) {
    trainingRecords = state.trainingRecords.sorted(by: { $0.name.compare($1.name) == .orderedDescending })
    isLoading = state.viewState.isLoading
    isEditing = state.viewState.isEditing
    isAddingNewRecord = state.viewState.isAddingNewRecord
    if let error = state.errorsToPresent.first {
      isPresentingAlert = true
      presentedAlert = .init(error: error, completion: finishPresentingError)
    }
    else {
      isPresentingAlert = false
    }
  }
  
  func received(newTrainingRecordFile fileURL: URL) {
    let useCase = addTrainingRecordFromFileUseCaseFactory(fileURL)
    useCase.execute()
    
  }
}
