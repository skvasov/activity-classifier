//
//  RecordsViewModel.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

class RecordViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var isAddingNewRecord = false
  @Published var label: TrainingLabel?
  
  private let observerForRecord: Observer
  private let getTrainingLabelUseCase: GetTrainingLabelUseCase
  private let addTrainingRecordUseCase: AddTrainingRecordUseCase
  
  init(observerForRecord: Observer, getTrainingLabelUseCase: GetTrainingLabelUseCase, addTrainingRecordUseCase: AddTrainingRecordUseCase) {
    self.observerForRecord = observerForRecord
    self.getTrainingLabelUseCase = getTrainingLabelUseCase
    self.addTrainingRecordUseCase = addTrainingRecordUseCase
  }
  
  func onAppear() {
    observerForRecord.startObserving()
    getTrainingLabelUseCase.execute()
  }
  
  func add() {
    addTrainingRecordUseCase.execute()
  }
  
  deinit {
    observerForRecord.stopObserving()
  }
}

extension RecordViewModel: ObserverForRecordViewEventResponder {
  func received(newState state: RecordState) {
    label = state.label
    isLoading = state.viewState.isLoading
    isAddingNewRecord = state.viewState.isAddingNewRecord
  }
}


