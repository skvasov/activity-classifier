//
//  ActivityClassifierApp.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

@main
struct ActivityClassifierApp: App {
  var body: some Scene {
    WindowGroup {
      let contrainer = DIContainer()
      contrainer.makeTabBarView()
        .environmentObject(contrainer)
    }
  }
}
