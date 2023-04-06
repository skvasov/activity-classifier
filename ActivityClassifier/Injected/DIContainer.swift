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
typealias TrainingDataRepositoryFactory = (URL) -> TrainingDataRepository
typealias AddTrainingRecordUseCaseFactory = () -> UseCase
typealias RemoveTrainingRecordsUseCaseFactory = ([TrainingRecord]) -> UseCase

class DIContainer: ObservableObject {
  private let stateStore: Store = Store<AppState>(reducer: Reducers.appReducer, state: AppState(), middleware: [printActionMiddleware])
  private let actionDispatcher: ActionDispatcher
  private let appGetters = AppGetters()
  private let tabBarGetters: TabBarGetters
  private let labelsGetters: LabelsGetters
  private lazy var trainingDataRepository = makeTrainingDataRepository(folderURL: URL.documentsDirectory)
  
  init() {
    self.actionDispatcher = stateStore
    self.tabBarGetters = TabBarGetters(getTabBarState: appGetters.getTabBarState)
    self.labelsGetters = LabelsGetters(getLabelsState: tabBarGetters.getLabelsState)
  }
  
  func makeTabBarView() -> some View {
    TabBarView()
  }
  
  func makeLabelsView() -> some View {
    let labelsState = stateStore.publisher { $0.select(self.tabBarGetters.getLabelsState) }
    let observerForLabels = ObserverForLabels(labelsState: labelsState)
    let getLabelsUseCase = GetLabelsUseCase(
      actionDispatcher: stateStore,
      trainingDataRepository: trainingDataRepository)
    let addLabelUseCaseFactory = { labelName in
      AddLabelUseCase(
        actionDispatcher: self.stateStore,
        labelName: labelName,
        trainingDataRepository: self.trainingDataRepository)
    }
    let removeLabelsUseCaseFactory = { labels in
      RemoveLabelsUseCase(
        actionDispatcher: self.stateStore,
        labels: labels,
        trainingDataRepository: self.trainingDataRepository)
    }
    let model = LabelsViewModel(
      observerForLabels: observerForLabels,
      getLabelsUseCase: getLabelsUseCase,
      addLabelUseCaseFactory: addLabelUseCaseFactory,
      removeLabelsUseCaseFactory: removeLabelsUseCaseFactory)
    observerForLabels.eventResponder = model
    return LabelsView(model: model)
  }
  
  func makeTrainingRecordsView(label: TrainingLabel) -> some View {
    let trainingRecordsState = stateStore.publisher { $0.select(self.labelsGetters.getTrainingRecordsState) }
    let observerForLabels = ObserverForTrainingRecords(trainingRecordsState: trainingRecordsState)
    let getTrainingRecordsUseCase = GetTrainingRecordsUseCase(
      actionDispatcher: stateStore,
      label: label,
      trainingDataRepository: trainingDataRepository)
    let addTrainingRecordUseCaseFactory = {
      AddTrainingRecordUseCase(
        actionDispatcher: self.stateStore,
        label: label,
        trainingDataRepository: self.trainingDataRepository)
    }
    let removeTrainingRecordsUseCaseFactory = { trainingRecords in
      RemoveTrainingRecordsUseCase(
        actionDispatcher: self.stateStore,
        label: label,
        trainingRecords: trainingRecords,
        trainingDataRepository: self.trainingDataRepository)
    }
    let model = TrainingRecordsViewModel(
      label: label,
      observerForTrainingRecords: observerForLabels,
      getTrainingRecordsUseCase: getTrainingRecordsUseCase,
      addTrainingRecordUseCaseFactory: addTrainingRecordUseCaseFactory,
      removeTrainingRecordsUseCaseFactory: removeTrainingRecordsUseCaseFactory)
    observerForLabels.eventResponder = model
    return TrainingRecordsView(model: model)
  }
  
  func makeVerifyView() -> some View {
    VerifyView()
  }
  
  func makeSettingsView() -> some View {
    SettingsView()
  }
  
  func makeTrainingDataRepository(folderURL: URL) -> TrainingDataRepository {
    let labelsStore = DiskManager<TrainingLabel>(folderURL: folderURL)
    let recordsStoreFactory: RecordsStoreFactory = { (storable: Storable) in
      DiskManager(folderURL: folderURL.appending(path: storable.name))
    }
    return RealTrainingDataRepository(
      labelsStore: labelsStore,
      recordsStoreFactory: recordsStoreFactory)
  }
}
