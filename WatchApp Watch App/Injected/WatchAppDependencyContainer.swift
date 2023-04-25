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
  let watchConnectivityManager: any WatchConnectvityManager<WatchContext>
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
  
  init() {
    self.watchConnectivityManager = RealWatchConnectvityManager<WatchContext>()
    self.companionAppRepository = RealCompanionAppRepository(watchConnectivityManager: watchConnectivityManager)
    
    
  }
  
  let stateStore: Store = Store<WatchAppState>(reducer: Reducers.appReducer, state: WatchAppState(), middleware: [printActionMiddleware])
  
  func makeWatchAppModel() -> WatchAppModel {
    WatchAppModel()
  }
  
  func makeRecordView() -> some View {
    let recordState = stateStore.publisher { $0.select(self.watchAppGetters.geRecordState) }
    let observerForRecord = ObserverForRecordView(recordState: recordState)
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
}
