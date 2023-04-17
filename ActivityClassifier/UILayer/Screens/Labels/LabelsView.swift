//
//  LabelsView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct LabelsView: View {
  @ObservedObject var model: LabelsViewModel
  private let trainingDataSharingModel: TrainingDataSharingModel
  private let trainingRecordsViewFactory: TrainingRecordsViewFactory
  
  init(model: LabelsViewModel, trainingDataSharingModel: TrainingDataSharingModel, trainingRecordsViewFactory: @escaping TrainingRecordsViewFactory) {
    self.model = model
    self.trainingDataSharingModel = trainingDataSharingModel
    self.trainingRecordsViewFactory = trainingRecordsViewFactory
  }
  
  var body: some View {
    NavigationStack(path: $model.presentedLabels) {
      Group {
        if model.isLoading {
          makeLoadingView()
        }
        else if model.labels.isEmpty {
          makeEmptyStateView()
        } else {
          makeContentView()
        }
      }
      .navigationTitle("Labels")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if !model.isEditing {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              model.addLabel()
            } label: {
              Image(systemName: "plus")
            }
          }
        }
        if !model.labels.isEmpty {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              model.isEditing ? model.cancel() : model.edit()
            } label: {
              Text(model.isEditing ? "Done" : "Edit")
            }
          }
          ToolbarItem(placement: .navigationBarLeading) {
            if model.isEditing {
              Button {
                model.removeAll()
              } label: {
                Text("Remove all")
              }
            } else {
              ShareLink(item: trainingDataSharingModel, preview: SharePreview(Text("Traning data archive"))) {
                Image(systemName: "square.and.arrow.up")
              }
            }
          }
        }
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
  
  func makeContentView() -> some View {
    List {
      ForEach(Array(model.labels.enumerated()), id: \.offset) { index, label in
        Button {
          model.goToTrainingRecords(for: index)
        } label: {
          HStack {
            Text(label.name)
            Spacer()
            Text("(\(label.numOfChildren))")
            Image(systemName: "chevron.right")
          }
        }
        .swipeActions(edge: .trailing) {
          if model.isEditing {
            Button(role: .destructive) {
              model.remove(at: index)
            } label: {
              Image(systemName: "trash")
                .foregroundColor(.white)
            }
          }
        }
      }
    }
    .navigationDestination(for: TrainingLabel.self, destination: { label in
      trainingRecordsViewFactory(label)
    })
  }
  
  func makeEmptyStateView() -> some View {
    Text("Tap '+' to add a new label")
  }
  
  func makeLoadingView() -> some View {
    ProgressView("Loading...")
  }
}

struct LabelsView_Previews: PreviewProvider {
  static var previews: some View {
    AppDependencyContainer().makeLabelsView()
  }
}
