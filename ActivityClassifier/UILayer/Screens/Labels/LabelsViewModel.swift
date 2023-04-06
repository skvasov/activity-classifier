//
//  LabelsViewModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import SwiftUI

class LabelsViewModel: ObservableObject {
  @Published var labels: [TrainingLabel] = []
  @Published var isLoading = false
  @Published var isEditing = false
  @Published var isAddingNewLabel = false
  @Published var presentedLabels: [TrainingLabel] = []
  
  private let observerForLabels: Observer
  private let getLabelsUseCase: UseCase
  private let addLabelUseCaseFactory: AddLabelUseCaseFactory
  private let removeLabelsUseCaseFactory: RemoveLabelsUseCaseFactory
  private let goToTrainingRecordsUseCaseFactory: GoToTrainingRecordsUseCaseFactory
  
  init(observerForLabels: Observer, getLabelsUseCase: UseCase, addLabelUseCaseFactory: @escaping AddLabelUseCaseFactory, removeLabelsUseCaseFactory: @escaping RemoveLabelsUseCaseFactory, goToTrainingRecordsUseCaseFactory: @escaping GoToTrainingRecordsUseCaseFactory) {
    self.observerForLabels = observerForLabels
    self.getLabelsUseCase = getLabelsUseCase
    self.addLabelUseCaseFactory = addLabelUseCaseFactory
    self.removeLabelsUseCaseFactory = removeLabelsUseCaseFactory
    self.goToTrainingRecordsUseCaseFactory = goToTrainingRecordsUseCaseFactory
  }
  
  func onAppear() {
    observerForLabels.startObserving()
    getLabelsUseCase.execute()
  }
  
  func goToTrainingRecords(for index: Int) {
    let useCase = goToTrainingRecordsUseCaseFactory(labels[index])
    useCase.execute()
  }
  
  func export() {
    
  }
  
  func add() {
    isAddingNewLabel = true
  }
  
  func save(labelName: String) {
    let useCase = addLabelUseCaseFactory(labelName)
    useCase.execute()
  }
  
  func edit() {
    isEditing = true
  }
  
  func cancel() {
    isEditing = false
  }
  
  func removeAll() {
    let useCase = removeLabelsUseCaseFactory(labels)
    useCase.execute()
  }
  
  func remove(at index: Int) {
    let useCase = removeLabelsUseCaseFactory([labels[index]])
    useCase.execute()
  }
  
  deinit {
    observerForLabels.stopObserving()
  }
}

extension LabelsViewModel: ObserverForLabelsEventResponder {
  func received(newState state: LabelsState) {
    labels = state.labels.sorted(by: { $0.name.compare($1.name) == .orderedAscending })
    isLoading = state.viewState.isLoading
    isEditing = state.viewState.isEditing
    isAddingNewLabel = state.viewState.isAddingNewLabel
    presentedLabels = state.presentedLabels
  }
}
