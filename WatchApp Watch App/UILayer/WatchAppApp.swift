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
  @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate
  let contrainer: WatchAppDependencyContainer
  let model: WatchAppModel
  
  init() {
    self.contrainer = WatchAppDependencyContainer()
    self.model = self.contrainer.makeWatchAppModel()
  }
  
  var body: some Scene {
    WindowGroup {
      TabView {
        contrainer.makeRecordView()
        contrainer.makeVerifyView()
      }
      .onAppear {
        model.onAppear()
      }
    }
  }
}

class ExtensionDelegate: NSObject, ObservableObject, WKApplicationDelegate {
  func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
  }
}

