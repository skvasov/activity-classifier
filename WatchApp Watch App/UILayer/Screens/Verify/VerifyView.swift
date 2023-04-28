//
//  VerifyView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import SwiftUI

struct VerifyView: View {
  @ObservedObject var model: VerifyViewModel
  
  init(model: VerifyViewModel) {
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      if model.isLoading {
        makeLoadingView()
      } else if let model = model.model {
        makeContentView(trainingModel: model)
      } else {
        makeEmptyStateView()
      }
    }
    .onAppear {
      model.onAppear()
    }
    .disabled(model.isLoading)
  }
  
  func makeContentView(trainingModel: Model) -> some View {
    ZStack {
      VStack {
        Text("\(model.prediction?.topLabel ?? "-") \(String(format: "%.0f%%", (model.prediction?.topProbability ?? 0.0) * 100))")
        makeRunButton()
      }
      VStack {
        Spacer()
        Text(trainingModel.name ?? "")
      }
    }
  }
  
  func makeRunButton() -> some View {
    Button(model.isRunning ? "Stop" : "Run") {
      // TODO: remove logic from view
      model.isRunning ? model.stop() : model.run()
    }
    .buttonStyle(BorderedProminentButtonStyle())
  }
  
  private func makeEmptyStateView() -> some View {
    Text("Import a new ML model on your iPhone")
  }
  
  private func makeLoadingView() -> some View {
    ProgressView()
  }
}

struct VerifyView_Previews: PreviewProvider {
  static var previews: some View {
    WatchAppDependencyContainer().makeVerifyView()
  }
}
