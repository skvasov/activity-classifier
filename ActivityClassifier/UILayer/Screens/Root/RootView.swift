//
//  RootView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct RootView: View {
  @EnvironmentObject var container: DIContainer
  
  var body: some View {
    container.makeTabBarView()
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
