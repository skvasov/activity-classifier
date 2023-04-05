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
  
  private let observerForLabels: Observer
  private let getLabelsUseCase: UseCase
  private let addLabelUseCaseFactory: AddLabelUseCaseFactory
  private let removeLabelsUseCaseFactory: RemoveLabelsUseCaseFactory
  
  init(observerForLabels: Observer, getLabelsUseCase: UseCase, addLabelUseCaseFactory: @escaping AddLabelUseCaseFactory, removeLabelsUseCaseFactory: @escaping RemoveLabelsUseCaseFactory) {
    self.observerForLabels = observerForLabels
    self.getLabelsUseCase = getLabelsUseCase
    self.addLabelUseCaseFactory = addLabelUseCaseFactory
    self.removeLabelsUseCaseFactory = removeLabelsUseCaseFactory
  }
  
  func onAppear() {
    observerForLabels.startObserving()
    getLabelsUseCase.execute()
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
    labels = state.labels
    isLoading = state.viewState.isLoading
    isEditing = state.viewState.isEditing
    isAddingNewLabel = state.viewState.isAddingNewLabel
  }
}
