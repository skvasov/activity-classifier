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
typealias EditLabelsUseCaseFactory = () -> UseCase
typealias CancelEditingLabelsUseCaseFactory = () -> UseCase
typealias InputLabelNameUseCaseFactory = () -> UseCase
typealias CancelInputtingLabelNameUseCaseFactory = () -> UseCase
typealias GoToTrainingRecordsUseCaseFactory = (TrainingLabel) -> UseCase
typealias CloseLabelsErrorUseCaseFactory = () -> UseCase
typealias TrainingDataRepositoryFactory = (URL) -> TrainingDataRepository

typealias AddTrainingRecordUseCaseFactory = () -> UseCase
typealias RemoveTrainingRecordsUseCaseFactory = ([TrainingRecord]) -> UseCase
typealias EditTrainingRecordsUseCaseFactory = () -> UseCase
typealias CancelEditingTrainingRecordsUseCaseFactory = () -> UseCase
typealias CloseTrainingRecordsErrorUseCaseFactory = () -> UseCase

typealias ImportModelUseCaseFactory = () -> UseCase
typealias CancelImportingModelUseCaseFactory = () -> UseCase
typealias SaveModelUseCaseFactory = (Result<URL, Error>) -> UseCase
typealias RunModelUseCaseFactory = (Model) -> UseCase
typealias StopModelUseCaseFactory = () -> UseCase
typealias LoadModelUseCaseFactory = () -> UseCase

typealias LoadSettingsUseCaseFactory = () -> UseCase
typealias SaveSettingsUseCaseFactory = (Settings) -> UseCase
typealias CloseSettingsErrorUseCaseFactory = () -> UseCase


class DIContainer: ObservableObject {
  private let stateStore: Store = Store<AppState>(reducer: Reducers.appReducer, state: AppState(), middleware: [printActionMiddleware])
  private let appGetters = AppGetters()
  private let tabBarGetters: TabBarGetters
  private let labelsGetters: LabelsGetters
  private let trainingDataRepository: TrainingDataRepository = {
    let folderURL = URL.trainingDataDirectory
    let labelsStore = DiskManager<TrainingLabel>(folderURL: folderURL)
    let recordsStoreFactory: RecordsStoreFactory = { (storable: Storable) in
      DiskManager(folderURL: folderURL.appending(path: storable.name))
    }
    let motionManagerFactory: MotionManagerFactory = {
      RealMotionManager.shared
    }
    return RealTrainingDataRepository(
      labelsStore: labelsStore,
      recordsStoreFactory: recordsStoreFactory,
      motionManagerFactory: motionManagerFactory)
  }()
  private let modelRepository: ModelRepository = {
    let folderURL = URL.modelsDirectory
    let modelStore = DiskManager<Model>(folderURL: folderURL)
    return RealModelRepository(
      modelStore: modelStore,
      motionManager: RealMotionManager.shared)
  }()
  private let settingsRepository: SettingsRepository = {
    let settingsStore = UserDefaultsManager<Settings>()
    return RealSettingsRepository(settingsStore: settingsStore)
  }()
  
  private var trainingRecordsModels: [TrainingLabel: TrainingRecordsViewModel] = [:]
  
  init() {
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
    let goToTrainingRecordsUseCaseFactory = { label in
      GoToTrainingRecordsUseCase(
        actionDispatcher: self.stateStore,
        label: label)
    }
    let editLabelsUseCaseFactory = {
      EditLabelsUseCase(actionDispatcher: self.stateStore)
    }
    let cancelEditingLabelsUseCaseFactory = {
      CancelEditingLabelsUseCase(actionDispatcher: self.stateStore)
    }
    let inputLabelNameUseCaseFactory = {
      InputLabelNameUseCase(actionDispatcher: self.stateStore)
    }
    let cancelInputtingLabelNameUseCaseFactory = {
      CancelInputtingLabelNameUseCase(actionDispatcher: self.stateStore)
    }
    let closeLabelsErrorUseCaseFactory = {
      CloseLabelsErrorUseCase(actionDispatcher: self.stateStore)
    }
    let model = LabelsViewModel(
      observerForLabels: observerForLabels,
      getLabelsUseCase: getLabelsUseCase,
      addLabelUseCaseFactory: addLabelUseCaseFactory,
      removeLabelsUseCaseFactory: removeLabelsUseCaseFactory,
      goToTrainingRecordsUseCaseFactory: goToTrainingRecordsUseCaseFactory,
      editLabelsUseCaseFactory: editLabelsUseCaseFactory,
      cancelEditingLabelsUseCaseFactory: cancelEditingLabelsUseCaseFactory,
      inputLabelNameUseCaseFactory: inputLabelNameUseCaseFactory,
      cancelInputtingLabelNameUseCaseFactory: cancelInputtingLabelNameUseCaseFactory,
      closeLabelsErrorUseCaseFactory: closeLabelsErrorUseCaseFactory,
      archiver: Archiver(sourceFolderURL: .trainingDataDirectory, archivedFileURL: .trainingDataArchive)
    )
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
        trainingDataRepository: self.trainingDataRepository,
        settingsRepository: self.settingsRepository
      )
    }
    let removeTrainingRecordsUseCaseFactory = { trainingRecords in
      RemoveTrainingRecordsUseCase(
        actionDispatcher: self.stateStore,
        label: label,
        trainingRecords: trainingRecords,
        trainingDataRepository: self.trainingDataRepository)
    }
    let backToLabelsUseCase = BackToLabelsUseCase(actionDispatcher: stateStore)
    let editTrainingRecordsUseCaseFactory = {
      EditTrainingRecordsUseCase(actionDispatcher: self.stateStore)
    }
    let cancelEditingTrainingRecordsUseCaseFactory = {
      CancelEditingTrainingRecordsUseCase(actionDispatcher: self.stateStore)
    }
    let closeTrainingRecordsErrorUseCaseFactory = {
      CloseTrainingRecordsErrorUseCase(actionDispatcher: self.stateStore)
    }
    let model = trainingRecordsModels[label] ?? TrainingRecordsViewModel(
      label: label,
      observerForTrainingRecords: observerForLabels,
      getTrainingRecordsUseCase: getTrainingRecordsUseCase,
      addTrainingRecordUseCaseFactory: addTrainingRecordUseCaseFactory,
      removeTrainingRecordsUseCaseFactory: removeTrainingRecordsUseCaseFactory,
      backToLabelsUseCase: backToLabelsUseCase,
      editTrainingRecordsUseCaseFactory: editTrainingRecordsUseCaseFactory,
      cancelEditingTrainingRecordsUseCaseFactory: cancelEditingTrainingRecordsUseCaseFactory,
      closeTrainingRecordsErrorUseCaseFactory: closeTrainingRecordsErrorUseCaseFactory
    )
    observerForLabels.eventResponder = model
    trainingRecordsModels.removeAll()
    trainingRecordsModels[label] = model
    return TrainingRecordsView(model: model)
  }
  
  func makeVerifyView() -> some View {
    let verifyState = stateStore.publisher { $0.select(self.tabBarGetters.getVerifyState) }
    let observerForVerify = ObserverForVerify(verifyState: verifyState)
    let importModelUseCaseFactory = {
      ImportModelUseCaseUseCase(actionDispatcher: self.stateStore)
    }
    let cancelImportingModelUseCaseFactory = {
      CancelImportingModelUseCase(actionDispatcher: self.stateStore)
    }
    let saveModelUseCaseFactory: SaveModelUseCaseFactory = { importResult in
      SaveModelUseCase(actionDispatcher: self.stateStore, importResult: importResult, modelRepository: self.modelRepository)
    }
    let runModelUseCaseFactory: RunModelUseCaseFactory = { model in
      RunModelUseCase(actionDispatcher: self.stateStore, model: model, modelRepository: self.modelRepository)
    }
    let stopModelUseCaseFactory = {
      StopModelUseCase(actionDispatcher: self.stateStore, modelRepository: self.modelRepository)
    }
    let loadModelUseCaseFactory = {
      LoadModelUseCase(actionDispatcher: self.stateStore, modelRepository: self.modelRepository)
    }
    let model = VerifyViewModel(
      observerForVerify: observerForVerify,
      importModelUseCaseFactory: importModelUseCaseFactory,
      cancelImportingModelUseCaseFactory: cancelImportingModelUseCaseFactory,
      saveModelUseCaseFactory: saveModelUseCaseFactory,
      runModelUseCaseFactory: runModelUseCaseFactory,
      stopModelUseCaseFactory: stopModelUseCaseFactory,
      loadModelUseCaseFactory: loadModelUseCaseFactory
    )
    observerForVerify.eventResponder = model
    return VerifyView(model: model)
  }
  
  func makeSettingsView() -> some View {
    let settingsState = stateStore.publisher { $0.select(self.tabBarGetters.getSettingsState) }
    let observerForSettings = ObserverForSettings(settingsState: settingsState)
    let loadSettingsUseCase = LoadSettingsUseCase(actionDispatcher: stateStore, settingsRepository: settingsRepository)
    let saveSettingsUseCaseFactory: SaveSettingsUseCaseFactory = { settings in
      SaveSettingsUseCase(
        actionDispatcher: self.stateStore,
        settings: settings,
        settingsRepository: self.settingsRepository)
    }
    let closeLabelsErrorUseCaseFactory: CloseLabelsErrorUseCaseFactory = {
      CloseSettingsErrorUseCase(actionDispatcher: self.stateStore)
    }
    let model = SettingsViewModel(
      observerForSettings: observerForSettings,
      loadSettingsUseCase: loadSettingsUseCase,
      saveSettingsUseCaseFactory: saveSettingsUseCaseFactory,
      closeLabelsErrorUseCaseFactory: closeLabelsErrorUseCaseFactory)
    observerForSettings.eventResponder = model
    return SettingsView(model: model)
  }
}
