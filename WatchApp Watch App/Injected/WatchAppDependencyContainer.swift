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
    let getTrainingLabelUseCase = GetTrainingLabelUseCase(companionAppRepository: companionAppRepository)
    let model = RecordViewModel(
      observerForRecord: observerForRecord,
      getTrainingLabelUseCase: getTrainingLabelUseCase
    )
    observerForRecord.eventResponder = model
    return RecordView(model: model)
  }
}
