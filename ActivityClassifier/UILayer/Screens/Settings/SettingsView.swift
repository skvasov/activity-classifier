//
//  SettingsView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject var model: SettingsViewModel
  
  init(model: SettingsViewModel) {
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          Stepper("Frequency, \(model.settings.frequency) Hz") {
            model.incrementFrequency()
          } onDecrement: {
            model.decrementFrequency()
          }
          Stepper("Prediction window, \(model.settings.predictionWindow)") {
            model.incrementPredictionWindow()
          } onDecrement: {
            model.decrementPredictionWindow()
          }
          Stepper("Delay, \(model.settings.delay) sec") {
            model.incrementDelay()
          } onDecrement: {
            model.decrementDelay()
          }
        } footer: {
          Text(String(format: "Sensor data will be recorded for %.2f sec after the %d sec pause after tapping 'Record' button.", model.duration, model.settings.delay))
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
    }
    .onAppear {
      model.onAppear()
    }
    .alert(model.presentedAlert.title, isPresented: $model.isPresentingAlert, actions: {
      model.presentedAlert.actions
    }) {
      model.presentedAlert.messageView
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    DIContainer().makeSettingsView()
  }
}
