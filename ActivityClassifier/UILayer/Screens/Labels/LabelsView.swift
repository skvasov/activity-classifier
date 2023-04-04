//
//  LabelsView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct LabelsView: View {
  @EnvironmentObject var container: DIContainer
  @ObservedObject var model: LabelsViewModel
  @State private var newLabelName: String = ""
  
  
  init(model: LabelsViewModel) {
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      Group {
        if model.labels.isEmpty {
          emptyStateView()
        } else {
          contentView()
        }
      }
      .navigationDestination(for: TrainingLabel.self, destination: { label in
        container.makeTrainingRecordsView()
      })
      .navigationTitle("Labels")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if !model.isEditing {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              model.add()
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
            Button {
              model.isEditing ? model.removeAll() : model.export()
            } label: {
              model.isEditing
              ? AnyView(Text("Remove all"))
              : AnyView(Image(systemName: "square.and.arrow.up"))
            }
          }
        }
      }
      .alert("Input label name", isPresented: $model.isAddingNewLabel, actions: {
        TextField("Label name", text: $newLabelName)
        Button("Save", action: {
          model.save(labelName: newLabelName)
          newLabelName = ""
        })
        Button("Cancel", role: .cancel, action: {})
      })
    }
  }
  
  func contentView() -> some View {
    List {
      ForEach(Array(model.labels.enumerated()), id: \.offset) { index, label in
        NavigationLink(value: label) {
          HStack {
            Text(label.name)
            Spacer()
            Text("(\(label.numOfRecords))")
          }
        }
        .swipeActions(edge: .trailing) {
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
  
  func emptyStateView() -> some View {
    Text("Tap + to add new labels")
  }
}

struct LabelsView_Previews: PreviewProvider {
  static var previews: some View {
    LabelsView(model: LabelsViewModel())
      .environmentObject(DIContainer())
  }
}
