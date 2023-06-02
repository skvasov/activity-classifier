//
//  WatchAppDependencyContainer.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import SwiftUI
import ReSwift

typealias SaveModelUseCaseFactory = (URL) -> UseCase
typealias RunModelUseCaseFactory = (Model) -> UseCase

class WatchAppDependencyContainer {
  let watchAppGetters = WatchAppGetters()
  let watchConnectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>
  let fileCacheManager: FileCacheManager
  let companionAppRepository: CompanionAppRepository
  let feedbackRepository: FeedbackRepository = {
    RealFeedbackRepository()
  }()
  let trainingDataRepository: TrainingDataRepository = {
    let folderURL = URL.trainingDataDirectory
    let recordsStoreFactory: RecordsStoreFactory = {
      // TODO: Probably refactor to use FileCacheManager insted of DiskManager
      DiskManager(folderURL: folderURL)
    }
    let motionManagerFactory: MotionManagerFactory = {
      RealMotionManager.shared
    }
    
    return RealTrainingDataRepository(
      motionManagerFactory: motionManagerFactory,
      recordsStoreFactory: recordsStoreFactory)
  }()
  let modelRepository: ModelRepository = {
    let folderURL = URL.modelsDirectory
    let modelStore = DiskManager<Model>(folderURL: folderURL)
    return RealModelRepository(
      modelStore: modelStore,
      motionManager: RealMotionManager.shared)
  }()  
  
  init() {
    self.watchConnectivityManager = RealWatchConnectvityManager<WatchContext, WatchMessage>()
    self.fileCacheManager = RealFileCacheManager(fileCacheDirectory: URL.fileCacheDirectory)
    self.companionAppRepository = RealCompanionAppRepository(watchConnectivityManager: watchConnectivityManager, fileCacheManager: self.fileCacheManager)
  }
  
  let stateStore: Store = Store<WatchAppState>(reducer: Reducers.appReducer, state: WatchAppState(), middleware: [printActionMiddleware])
  
  func makeWatchAppModel() -> WatchAppModel {
    let observerForWatchApp = ObserverForWatchApp(latestModelFile: companionAppRepository.latestModelFilePublisher())
    let getLatestModelUseCase = GetLatestModelUseCase(
      actionDispatcher: stateStore,
      modelRepository: modelRepository,
      companionAppRepository: companionAppRepository)
    let saveModelUseCaseFactory: SaveModelUseCaseFactory = { url in
      SaveModelUseCase(actionDispatcher: self.stateStore,
                       url: url,
                       modelRepository: self.modelRepository)
    }
    let clearCacheUseCase = ClearCacheUseCase(fileCacheManager: fileCacheManager)
    let model = WatchAppModel(
      observerForWatchApp: observerForWatchApp,
      getLatestModelUseCase: getLatestModelUseCase,
      saveModelUseCaseFactory: saveModelUseCaseFactory,
      clearCacheUseCase: clearCacheUseCase
    )
    observerForWatchApp.eventResponder = model
    return model
  }
  
  func makeRecordView() -> some View {
    let recordState = stateStore.publisher { $0.select(self.watchAppGetters.getRecordState) }
    let observerForRecord = ObserverForRecordView(
      recordState: recordState,
      watchContext: watchConnectivityManager.appContextPublisher()
    )
    let getTrainingLabelUseCase = GetTrainingLabelUseCase(
      actionDispatcher: stateStore,
      companionAppRepository: companionAppRepository)
    let addTrainingRecordUseCase = AddTrainingRecordUseCase(
      actionDispatcher: stateStore,
      companionAppRepository: companionAppRepository,
      trainingDataRepository: trainingDataRepository,
      feedbackRepository: feedbackRepository)
    let model = RecordViewModel(
      observerForRecord: observerForRecord,
      getTrainingLabelUseCase: getTrainingLabelUseCase,
      addTrainingRecordUseCase: addTrainingRecordUseCase
    )
    observerForRecord.eventResponder = model
    return RecordView(model: model)
  }
  
  func makeVerifyView() -> some View {
    let verifyState = stateStore.publisher { $0.select(self.watchAppGetters.getVerifyState) }
    let observerForVerify = ObserverForVerifyView(
      verifyState: verifyState,
      latestModel: modelRepository.latestModelPublisher()
    )
    let loadModelUseCase = LoadModelUseCase(actionDispatcher: stateStore, modelRepository: modelRepository)
    let runModelUseCaseFactory: RunModelUseCaseFactory = { model in
      RunModelUseCase(
        actionDispatcher: self.stateStore,
        model: model,
        modelRepository: self.modelRepository,
        companionAppRepository: self.companionAppRepository)
    }
    let stopModelUseCase = StopModelUseCase(actionDispatcher: stateStore, modelRepository: modelRepository)
    let model = VerifyViewModel(
      observerForVerify: observerForVerify,
      loadModelUseCase: loadModelUseCase,
      runModelUseCaseFactory: runModelUseCaseFactory,
      stopModelUseCase: stopModelUseCase
    )
    observerForVerify.eventResponder = model
    return VerifyView(model: model)
  }
}
