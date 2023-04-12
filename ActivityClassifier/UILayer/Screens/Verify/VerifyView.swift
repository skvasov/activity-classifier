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
      // TODO: Allow .mlmodel files only
      .fileImporter(isPresented: $model.isImporting, allowedContentTypes: [.item]) { result in
        model.saveModel(result)
      }
      .onAppear {
        model.onAppear()
      }
    }
  }
  
  func makeContentView() -> some View {
    ZStack {
      VStack {
        Text("-")
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
      Text("Tap Import button to add an ML model")
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
//    .background(model.isRunning ? Color.red : Color.primary)
    
  }
}

struct VerifyView_Previews: PreviewProvider {
  static var previews: some View {
    DIContainer().makeVerifyView()
  }
}
