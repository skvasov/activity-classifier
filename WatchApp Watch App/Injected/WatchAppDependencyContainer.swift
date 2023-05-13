//
//  WatchAppDependencyContainer.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import SwiftUI
import ReSwift

class WatchAppDependencyContainer {
  let watchAppGetters = WatchAppGetters()
  let watchConnectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>
  let companionAppRepository: CompanionAppRepository
  let feedbackRepository: FeedbackRepository = {
    RealFeedbackRepository()
  }()
  let trainingDataRepository: TrainingDataRepository = {
    let folderURL = URL.trainingDataDirectory
    let recordsStoreFactory: RecordsStoreFactory = {
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
    self.companionAppRepository = RealCompanionAppRepository(watchConnectivityManager: watchConnectivityManager)
    
    
  }
  
  let stateStore: Store = Store<WatchAppState>(reducer: Reducers.appReducer, state: WatchAppState(), middleware: [printActionMiddleware])
  
  func makeWatchAppModel() -> WatchAppModel {
    let observerForWatchApp = ObserverForWatchApp(latestModelFile: companionAppRepository.latestModelFilePublisher())
    let getLatestModelUseCase = GetLatestModelUseCase(
      actionDispatcher: stateStore,
      modelRepository: modelRepository,
      companionAppRepository: companionAppRepository)
    let model = WatchAppModel(
      observerForWatchApp: observerForWatchApp,
      getLatestModelUseCase: getLatestModelUseCase)
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
      verifyState: verifyState)
    let getLatestModelUseCase = GetLatestModelUseCase(
      actionDispatcher: stateStore,
      modelRepository: modelRepository,
      companionAppRepository: companionAppRepository)
    let model = VerifyViewModel(
      observerForVerify: observerForVerify,
      getLatestModelUseCase: getLatestModelUseCase
    )
    observerForVerify.eventResponder = model
    return VerifyView(model: model)
  }
}
