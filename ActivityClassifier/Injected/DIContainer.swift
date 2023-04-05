//
//  DIContainer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import SwiftUI
import ReSwift
import Combine

typealias AddLabelUseCaseFactory = (String) -> UseCase
typealias RemoveLabelsUseCaseFactory = ([TrainingLabel]) -> UseCase

class DIContainer: ObservableObject {
  let stateStore: Store = Store<AppState>(reducer: Reducers.appReducer, state: AppState(), middleware: [printActionMiddleware])
  var actionDispatcher: ActionDispatcher
  private let appGetters = AppGetters()
  private let tabBarGetters: TabBarGetters
  
  init() {
    self.actionDispatcher = stateStore
    self.tabBarGetters  = TabBarGetters(getTabBarState: appGetters.getTabBarState)
  }
  
  func makeTabBarView() -> some View {
    TabBarView()
  }
  
  func makeLabelsView() -> some View {
    let labelsState = stateStore.publisher { $0.select(self.tabBarGetters.getLabelsState) }
    let observerForLabels = ObserverForLabels(labelsState: labelsState)
    let getLabelsUseCase = GetLabelsUseCase(actionDispatcher: stateStore)
    let addLabelUseCaseFactory = { labelName in
      AddLabelUseCase(actionDispatcher: self.stateStore, labelName: labelName)
    }
    let removeLabelsUseCaseFactory = { labels in
      RemoveLabelsUseCase(actionDispatcher: self.stateStore, labels: labels)
    }
    let model = LabelsViewModel(
      observerForLabels: observerForLabels,
      getLabelsUseCase: getLabelsUseCase,
      addLabelUseCaseFactory: addLabelUseCaseFactory,
      removeLabelsUseCaseFactory: removeLabelsUseCaseFactory)
    observerForLabels.eventResponder = model
    return LabelsView(model: model)
  }
  
  func makeTrainingRecordsView() -> some View {
    TrainingRecordsView()
  }
  
  func makeVerifyView() -> some View {
    VerifyView()
  }
  
  func makeSettingsView() -> some View {
    SettingsView()
  }
}
