//
//  TabBarView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct TabBarView: View {
  @EnvironmentObject var contaier: DIContainer
  
  var body: some View {
    TabView {
      contaier.makeLabelsView()
        .tabItem {
          Label("Labels", systemImage: "list.bullet")
        }
      contaier.makeVerifyView()
        .tabItem {
          Label("Verify", systemImage: "hands.sparkles")
        }
      contaier.makeSettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape.2")
        }
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    TabBarView()
      .environmentObject(DIContainer())
  }
}
