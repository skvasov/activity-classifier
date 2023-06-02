//
//  RecordView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import SwiftUI

struct RecordView: View {
  @ObservedObject var model: RecordViewModel
  
  init(model: RecordViewModel) {
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      if model.isLoading {
        makeLoadingView()
      } else if let label = model.label {
        makeContentView(label: label)
      } else {
        makeEmptyStateView()
      }
    }
    .onAppear {
      model.onAppear()
    }
    .disabled(model.isAddingNewRecord)
  }
  
  private func makeContentView(label: TrainingLabel) -> some View {
    VStack {
      Text("Tap Record to add a new record")
        .multilineTextAlignment(.center)
      Button(model.isAddingNewRecord ? "Recording..." : "Record") {
        model.add()
      }
      .buttonStyle(BorderedProminentButtonStyle())
    }
    .navigationTitle("\(label.name) (\(label.numOfChildren))")
  }
  
  private func makeEmptyStateView() -> some View {
    Text("Add a new label on your iPhone and select it")
      .multilineTextAlignment(.center)
      .navigationTitle("")
  }
  
  private func makeLoadingView() -> some View {
    ProgressView()
  }
}

struct RecordView_Previews: PreviewProvider {
  static var previews: some View {
    WatchAppDependencyContainer().makeRecordView()
  }
}
