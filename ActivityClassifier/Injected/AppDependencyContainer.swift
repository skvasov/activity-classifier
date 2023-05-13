//
//  AppDependencyContainer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import SwiftUI
import ReSwift
import Combine

typealias TabsFactory = () -> AnyView
typealias TrainingRecordsViewFactory = (TrainingLabel) -> AnyView

typealias AddLabelUseCaseFactory = (String) -> UseCase
typealias RemoveLabelsUseCaseFactory = ([TrainingLabel]) -> UseCase
typealias EditLabelsUseCaseFactory = () -> UseCase
typealias CancelEditingLabelsUseCaseFactory = () -> UseCase
typealias InputLabelNameUseCaseFactory = () -> UseCase
typealias CancelInputtingLabelNameUseCaseFactory = () -> UseCase
typealias GoToTrainingRecordsUseCaseFactory = (TrainingLabel) -> UseCase
typealias CloseLabelsErrorUseCaseFactory = () -> UseCase
typealias TrainingDataRepositoryFactory = (URL) -> TrainingDataRepository

typealias ImportModelUseCaseFactory = () -> UseCase
typealias CancelImportingModelUseCaseFactory = () -> UseCase
typealias SaveModelUseCaseFactory = (Result<URL, Error>) -> UseCase
typealias RunModelUseCaseFactory = (Model) -> UseCase
typealias StopModelUseCaseFactory = () -> UseCase
typealias LoadModelUseCaseFactory = () -> UseCase

typealias LoadSettingsUseCaseFactory = () -> UseCase
typealias SaveSettingsUseCaseFactory = (Settings) -> UseCase
typealias CloseSettingsErrorUseCaseFactory = () -> UseCase

typealias TrainingDataSharingCallback = (Result<URL, Error>) -> Void
typealias ShareTrainingDataUseCaseFactory = (@escaping TrainingDataSharingCallback) -> UseCase


class AppDependencyContainer {
  let stateStore: Store = Store<AppState>(reducer: Reducers.appReducer, state: AppState(), middleware: [printActionMiddleware])
  let appGetters = AppGetters()
  let tabBarGetters: TabBarGetters
  let trainingDataRepository: TrainingDataRepository = {
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
      motionManagerFactory: motionManagerFactory,
      archiver: RealArchiver(sourceFolderURL: .trainingDataDirectory, archivedFileURL: .trainingDataArchive))
  }()
  let modelRepository: ModelRepository = {
    let folderURL = URL.modelsDirectory
    let modelStore = DiskManager<Model>(folderURL: folderURL)
    return RealModelRepository(
      modelStore: modelStore,
      motionManager: RealMotionManager.shared)
  }()
  let settingsRepository: SettingsRepository = {
    let settingsStore = UserDefaultsManager<Settings>()
    return RealSettingsRepository(settingsStore: settingsStore)
  }()
  let watchConnectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>
  let watchAppRepository: WatchAppRepository
  
  init() {
    self.tabBarGetters = TabBarGetters(getTabBarState: appGetters.getTabBarState)
    self.watchConnectivityManager = RealWatchConnectvityManager<WatchContext, WatchMessage>()
    self.watchAppRepository = RealWatchAppRepository(connectivityManager: watchConnectivityManager)
  }
  
  func makeAppModel() -> ActivityClassifierAppModel {
    let observerForActivityClassifierApp = ObserverForActivityClassifierApp(
      latestModelRequest: watchAppRepository.latestModelRequestPublisher())
    let startWatchAppUseCase = StartWatchAppUseCase(watchAppRepository: watchAppRepository)
    let sendModelUseCase = SendModelUseCase(
      modelRepository: modelRepository,
      watchAppRepository: watchAppRepository)
    let model = ActivityClassifierAppModel(
      observerForActivityClassifierApp: observerForActivityClassifierApp,
      startWatchAppUseCase: startWatchAppUseCase,
      sendModelUseCase: sendModelUseCase)
    observerForActivityClassifierApp.eventResponder = model
    return model
  }
  
  func makeTabBarView() -> some View {
    let tabsFactory: TabsFactory = {
      AnyView(self.makeTabs())
    }
    return TabBarView(tabsFactory: tabsFactory)
  }
  
  @ViewBuilder
  func makeTabs() -> some View {
    makeLabelsView()
      .tabItem {
        Label("Labels", systemImage: "list.bullet")
      }
    makeVerifyView()
      .tabItem {
        Label("Verify", systemImage: "hands.sparkles")
      }
    makeSettingsView()
      .tabItem {
        Label("Settings", systemImage: "gearshape.2")
      }
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
      closeLabelsErrorUseCaseFactory: closeLabelsErrorUseCaseFactory
    )
    observerForLabels.eventResponder = model
    
    let trainingRecordsViewFactory: TrainingRecordsViewFactory = { label in
      let labelsDependencyContainer = LabelsDependencyContainer(appContainer: self)
      return AnyView(labelsDependencyContainer.makeTrainingRecordsView(label: label))
    }
    return LabelsView(
      model: model,
      trainingDataSharingModel: makeTrainingDataSharingModel(),
      trainingRecordsViewFactory: trainingRecordsViewFactory)
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
      RunModelUseCase(
        actionDispatcher: self.stateStore,
        model: model,
        modelRepository: self.modelRepository,
        settingsRepository: self.settingsRepository
      )
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
  
  func makeTrainingDataSharingModel() -> TrainingDataSharingModel {
    let shareTrainingDataUseCaseFactory: ShareTrainingDataUseCaseFactory = { callback in
      ShareTrainingDataUseCase(trainingDataRepository: self.trainingDataRepository, sharingCallback: callback)
    }
    let model = TrainingDataSharingModel(shareTrainingDataUseCaseFactory: shareTrainingDataUseCaseFactory)
    return model
  }
}
