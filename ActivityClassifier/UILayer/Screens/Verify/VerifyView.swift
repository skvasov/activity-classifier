//
//  VerifyView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct VerifyView: View {
  @ObservedObject var model: VerifyViewModel
  
  init(model: VerifyViewModel) {
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      Group {
        if model.isLoading {
          makeLoadingView()
        }
        else if model.model == nil {
          makeEmptyStateView()
        } else {
          makeContentView()
        }
      }
      .navigationTitle("Verify Model")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            model.importModel()
          } label: {
            Image(systemName: "square.and.arrow.down")
          }
          .disabled(model.isLoading)
        }
      }
      .fileImporter(
        isPresented: $model.isImporting,
        allowedContentTypes: [
          .init(filenameExtension: "mlmodel", conformingTo: .item) ?? .item
        ]) { result in
          model.saveModel(result)
        }
        .alert(model.presentedAlert.title, isPresented: $model.isPresentingAlert, actions: {
          model.presentedAlert.actions
        }, message: {
          model.presentedAlert.messageView
        })
        .onAppear {
          model.onAppear()
        }
    }
  }
  
  func makeContentView() -> some View {
    ZStack {
      VStack {
        Text("\(model.prediction?.topLabel ?? "-") \(String(format: "%.0f%%", (model.prediction?.topProbability ?? 0.0) * 100))")
        makeRunButton()
      }
      VStack {
        Spacer()
        Text(model.model?.name ?? "")
      }
    }
  }
  
  func makeEmptyStateView() -> some View {
    VStack {
      Text("Tap 'Import' button to add an ML model")
    }
  }
  
  func makeLoadingView() -> some View {
    ProgressView("Loading...")
  }
  
  func makeRunButton() -> some View {
    Button(model.isRunning ? "Stop" : "Run") {
      model.isRunning ? model.stop() : model.run()
    }
    .buttonStyle(BorderedProminentButtonStyle())
  }
}

struct VerifyView_Previews: PreviewProvider {
  static var previews: some View {
    AppDependencyContainer().makeVerifyView()
  }
}
