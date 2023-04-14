//
//  TabBarView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct TabBarView: View {
  private let tabsFactory: TabsFactory
  
  init(tabsFactory: @escaping TabsFactory) {
    self.tabsFactory = tabsFactory
  }
  
  var body: some View {
    TabView() {
      tabsFactory()
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var previews: some View {
    AppDependencyContainer().makeTabBarView()
  }
}
