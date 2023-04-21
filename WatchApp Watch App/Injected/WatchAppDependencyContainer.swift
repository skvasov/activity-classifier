//
//  WatchAppDependencyContainer.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import SwiftUI

class WatchAppDependencyContainer {
  //let stateStore: Store = Store<AppState>(reducer: Reducers.appReducer, state: AppState(), middleware: [printActionMiddleware])
  
  func makeWatchAppModel() -> WatchAppModel {
    WatchAppModel()
  }
  
  func makeRecordView() -> some View {
    let model = RecordsViewModel()
    return RecordView(model: model)
  }
}
