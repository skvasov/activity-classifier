//
//  DIContainer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import SwiftUI

class DIContainer: ObservableObject {
  func makeTabBarView() -> some View {
    TabBarView()
  }
  
  func makeLabelsView() -> some View {
    let model = LabelsViewModel()
    return LabelsView(model: model)
  }
  
  func makeTrainingRecordsView() -> some View {
    TrainingRecordsView()
  }
  
  func makeVerifyView() -> some View {
    VerifyView()
  }
  
  func makeSettingsView() -> some View {
    SettingsView()
  }
}
