//
//  WatchAppApp.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 19.04.23.
//

import SwiftUI
import HealthKit

@main
struct WatchApp_Watch_AppApp: App {
  @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
  let contrainer: WatchAppDependencyContainer
  let model: WatchAppModel
  
  init() {
    self.contrainer = WatchAppDependencyContainer()
    self.model = self.contrainer.makeWatchAppModel()
  }
  
  var body: some Scene {
    WindowGroup {
      contrainer.makeRecordView()
    }
  }
}

class ExtensionDelegate: NSObject, ObservableObject, WKExtensionDelegate {
  func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
  }
}

