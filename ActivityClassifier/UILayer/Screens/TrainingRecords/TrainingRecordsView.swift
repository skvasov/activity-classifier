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
        makeLoadingView()
      }
      else if model.trainingRecords.isEmpty {
        makeEmptyStateView()
      } else {
        makeContentView()
      }
    }
    .navigationTitle("\(model.title) (\(model.trainingRecords.count))")
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
          : AnyView(
            Image(systemName: "chevron.backward")
              .frame(width: 44, height: 44)
          )
        }
      }
    }
    .onAppear {
      model.onAppear()
    }
    .alert(model.presentedAlert.title, isPresented: $model.isPresentingAlert, actions: {
      model.presentedAlert.actions
    }, message: {
      model.presentedAlert.messageView
    })
    .disabled(model.isAddingNewRecord)
  }
  
  func makeContentView() -> some View {
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
      .safeAreaInset(edge: .bottom) {
        makeRecordButton()
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
      }
    }
  }
  
  func makeEmptyStateView() -> some View {
    VStack {
      Text("Tap Record to add a new record")
      makeRecordButton()
    }
  }
  
  func makeLoadingView() -> some View {
    ProgressView("Loading...")
  }
  
  func makeRecordButton() -> some View {
    Button(model.isAddingNewRecord ? "Recording..." : "Record") {
      model.add()
    }
    .buttonStyle(BorderedProminentButtonStyle())
  }
}

struct TrainingRecords_Previews: PreviewProvider {
  static var previews: some View {
    let label = TrainingLabel(name: "Wing", numOfChildren: 30)
    let appContrainer = AppDependencyContainer()
    let labelsContainer = LabelsDependencyContainer(appContainer: appContrainer)
    return labelsContainer.makeTrainingRecordsView(label: label)
  }
}
