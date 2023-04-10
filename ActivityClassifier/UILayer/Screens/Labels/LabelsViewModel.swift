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
  @Published var isPresentingAlert = false
  @Published var presentedAlert: AlertDetails = .init()
  @Published var presentedLabels: [TrainingLabel] = []
  let archiver: Archiver
  
  private let observerForLabels: Observer
  private let getLabelsUseCase: UseCase
  private let addLabelUseCaseFactory: AddLabelUseCaseFactory
  private let removeLabelsUseCaseFactory: RemoveLabelsUseCaseFactory
  private let goToTrainingRecordsUseCaseFactory: GoToTrainingRecordsUseCaseFactory
  private let editLabelsUseCaseFactory: EditLabelsUseCaseFactory
  private let cancelEditingLabelsUseCaseFactory: CancelEditingLabelsUseCaseFactory
  private let inputLabelNameUseCaseFactory: InputLabelNameUseCaseFactory
  private let cancelInputtingLabelNameUseCaseFactory: CancelInputtingLabelNameUseCaseFactory
  private let closeLabelsErrorUseCaseFactory: CloseLabelsErrorUseCaseFactory
  
  
  init(observerForLabels: Observer,
       getLabelsUseCase: UseCase,
       addLabelUseCaseFactory: @escaping AddLabelUseCaseFactory,
       removeLabelsUseCaseFactory: @escaping RemoveLabelsUseCaseFactory,
       goToTrainingRecordsUseCaseFactory: @escaping GoToTrainingRecordsUseCaseFactory,
       editLabelsUseCaseFactory: @escaping EditLabelsUseCaseFactory,
       cancelEditingLabelsUseCaseFactory: @escaping CancelEditingLabelsUseCaseFactory,
       inputLabelNameUseCaseFactory: @escaping InputLabelNameUseCaseFactory,
       cancelInputtingLabelNameUseCaseFactory: @escaping CancelInputtingLabelNameUseCaseFactory,
       closeLabelsErrorUseCaseFactory: @escaping CloseLabelsErrorUseCaseFactory,
       archiver: Archiver
  ) {
    self.observerForLabels = observerForLabels
    self.getLabelsUseCase = getLabelsUseCase
    self.addLabelUseCaseFactory = addLabelUseCaseFactory
    self.removeLabelsUseCaseFactory = removeLabelsUseCaseFactory
    self.goToTrainingRecordsUseCaseFactory = goToTrainingRecordsUseCaseFactory
    self.editLabelsUseCaseFactory = editLabelsUseCaseFactory
    self.cancelEditingLabelsUseCaseFactory = cancelEditingLabelsUseCaseFactory
    self.inputLabelNameUseCaseFactory = inputLabelNameUseCaseFactory
    self.cancelInputtingLabelNameUseCaseFactory = cancelInputtingLabelNameUseCaseFactory
    self.closeLabelsErrorUseCaseFactory = closeLabelsErrorUseCaseFactory
    self.archiver = archiver
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
  
  func addLabel() {
    let useCase = inputLabelNameUseCaseFactory()
    useCase.execute()
  }
  
  func save(labelName: String) {
    let useCase = addLabelUseCaseFactory(labelName)
    useCase.execute()
  }
  
  func cancelLabelNameInput() {
    let useCase = cancelInputtingLabelNameUseCaseFactory()
    useCase.execute()
  }
  
  func edit() {
    let useCase = editLabelsUseCaseFactory()
    useCase.execute()
  }
  
  func cancel() {
    let useCase = cancelEditingLabelsUseCaseFactory()
    useCase.execute()
  }
  
  func removeAll() {
    let useCase = removeLabelsUseCaseFactory(labels)
    useCase.execute()
  }
  
  func remove(at index: Int) {
    let useCase = removeLabelsUseCaseFactory([labels[index]])
    useCase.execute()
  }
  
  func finishPresentingError() {
    let useCase = closeLabelsErrorUseCaseFactory()
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
    presentedLabels = state.presentedLabels
    if state.viewState.isAddingNewLabel {
      isPresentingAlert = true
      presentedAlert = makeNameInputAlert()
    } else if let error = state.errorsToPresent.first {
      isPresentingAlert = true
      presentedAlert = .init(error: error, completion: finishPresentingError)
    }
    else {
      isPresentingAlert = false
    }
  }
  
  private func makeNameInputAlert() -> AlertDetails {
    var name = ""
    let nameBinding: Binding<String> = .init {
      name
    } set: { newValue in
      name = newValue
    }
    
    return AlertDetails(
      title: "Input label name",
      messages: [],
      textFields: [AlertDetails.TextField(placeholder: "Label name", text: nameBinding)],
      buttons: [
        AlertDetails.Button(title: "Cancel", isCancel: true, action: { [weak self] in
          self?.cancelLabelNameInput()
        }),
        AlertDetails.Button(title: "Save", isCancel: false, action: { [weak self] in
          self?.save(labelName: name)
        })
      ])
  }
}
