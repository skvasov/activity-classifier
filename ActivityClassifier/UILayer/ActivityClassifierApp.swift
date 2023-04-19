//
//  ActivityClassifierApp.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

@main
struct ActivityClassifierApp: App {
  let contrainer: AppDependencyContainer
  let model: ActivityClassifierAppModel
  
  init() {
    self.contrainer = AppDependencyContainer()
    self.model = self.contrainer.makeAppModel()
  }
  
  var body: some Scene {
    WindowGroup {
      Group {
        contrainer.makeTabBarView()
      }
      .onAppear {
        model.onAppear()
      }
    }
  }
}
