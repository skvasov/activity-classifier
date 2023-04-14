//
//  ActivityClassifierApp.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

@main
struct ActivityClassifierApp: App {
  let contrainer = AppDependencyContainer()
  
  var body: some Scene {
    WindowGroup {
      contrainer.makeTabBarView()
    }
  }
}
