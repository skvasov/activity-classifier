//
//  TrainingRecordsView.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import SwiftUI

struct TrainingRecordsView: View {
  @ObservedObject var model: TrainingRecordsViewModel
  
  init(model: TrainingRecordsViewModel) {
    self.model = model
  }
  
  var body: some View {
    Group {
      if model.isLoading {
        loadingView()
      }
      else if model.trainingRecords.isEmpty {
        emptyStateView()
      } else {
        contentView()
      }
    }
    .navigationTitle(model.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          model.isEditing ? model.cancel() : model.edit()
        } label: {
          Text(model.isEditing ? "Done" : "Edit")
        }
      }
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          model.isEditing ? model.removeAll() : model.goBack()
        } label: {
          model.isEditing
          ? AnyView(Text("Remove all"))
          : AnyView(Image(systemName: "chevron.backward"))
        }
      }
    }
    .onAppear {
      model.onAppear()
    }
  }
  
  func contentView() -> some View {
    VStack {
      List {
        ForEach(Array(model.trainingRecords.enumerated()), id: \.offset) { index, trainingRecord in
          HStack {
            Text(trainingRecord.name)
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
      Button("Record") {
        model.add()
      }
    }
  }
  
  func emptyStateView() -> some View {
    VStack {
      Text("Tap Record to add new records")
      Button("Record") {
        model.add()
      }
    }
  }
  
  func loadingView() -> some View {
    ProgressView("Loading...")
  }
}

struct TrainingRecords_Previews: PreviewProvider {
  static var previews: some View {
    let contrainer = DIContainer()
    let label = TrainingLabel(name: "Wing", numOfChildren: 30)
    let trainingRecordsView = contrainer.makeTrainingRecordsView(label: label)
    return trainingRecordsView
      .environmentObject(contrainer)
  }
}
