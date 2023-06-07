//
//  LabelsDependencyContainer.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation
import SwiftUI
import ReSwift

typealias AddTrainingRecordUseCaseFactory = () -> UseCase
typealias RemoveTrainingRecordsUseCaseFactory = ([TrainingRecord]) -> UseCase
typealias EditTrainingRecordsUseCaseFactory = () -> UseCase
typealias CancelEditingTrainingRecordsUseCaseFactory = () -> UseCase
typealias CloseTrainingRecordsErrorUseCaseFactory = () -> UseCase
typealias UpdateWatchContextUseCaseFactory = () -> UseCase
typealias AddTrainingRecordFromFileUseCaseFactory = (URL) -> UseCase

class LabelsDependencyContainer {
  let stateStore: Store<AppState>
  let labelsGetters: LabelsGetters
  let trainingDataRepository: TrainingDataRepository
  let settingsRepository: SettingsRepository
  let feedbackRepository: FeedbackRepository = {
    RealFeedbackRepository()
  }()
  let watchAppRepository: WatchAppRepository
  
  private static var trainingRecordsModels: [TrainingLabel: TrainingRecordsViewModel] = [:]
  
  init(appContainer: AppDependencyContainer) {
    self.stateStore = appContainer.stateStore
    self.labelsGetters = LabelsGetters(getLabelsState: appContainer.tabBarGetters.getLabelsState)
    self.trainingDataRepository = appContainer.trainingDataRepository
    self.settingsRepository = appContainer.settingsRepository
    self.watchAppRepository = appContainer.watchAppRepository
  }
  
  func makeTrainingRecordsView(label: TrainingLabel) -> some View {
    let trainingRecordsState = stateStore.publisher { $0.select(self.labelsGetters.getTrainingRecordsState) }
    let observerForLabels = ObserverForTrainingRecords(
      trainingRecordsState: trainingRecordsState,
      trainingRecordFile: watchAppRepository.trainingRecordFilePublisher())
    let getTrainingRecordsUseCase = GetTrainingRecordsUseCase(
      actionDispatcher: stateStore,
      label: label,
      trainingDataRepository: trainingDataRepository)
    let addTrainingRecordUseCaseFactory: AddTrainingRecordUseCaseFactory = {
      AddTrainingRecordUseCase(
        actionDispatcher: self.stateStore,
        label: label,
        trainingDataRepository: self.trainingDataRepository,
        settingsRepository: self.settingsRepository,
        feedbackRepository: self.feedbackRepository
      )
    }
    let removeTrainingRecordsUseCaseFactory: RemoveTrainingRecordsUseCaseFactory = { trainingRecords in
      RemoveTrainingRecordsUseCase(
        actionDispatcher: self.stateStore,
        label: label,
        trainingRecords: trainingRecords,
        trainingDataRepository: self.trainingDataRepository
      )
    }
    let backToLabelsUseCase = BackToLabelsUseCase(actionDispatcher: self.stateStore, trainingDataReposioty: self.trainingDataRepository)
    let editTrainingRecordsUseCaseFactory = {
      EditTrainingRecordsUseCase(actionDispatcher: self.stateStore)
    }
    let cancelEditingTrainingRecordsUseCaseFactory = {
      CancelEditingTrainingRecordsUseCase(actionDispatcher: self.stateStore)
    }
    let closeTrainingRecordsErrorUseCaseFactory = {
      CloseTrainingRecordsErrorUseCase(actionDispatcher: self.stateStore)
    }
    let addTrainingRecordFromFileUseCaseFactory = { fileURL in
      AddTrainingRecordFromFileUseCase(
        actionDispatcher: self.stateStore,
        label: label,
        trainingDataRepository: self.trainingDataRepository,
        trainingRecordFile: fileURL
      )
    }
    // REFACTOR: because of SwiftUI bug NavigationStack creates child views many times
    let model = Self.trainingRecordsModels[label] ?? TrainingRecordsViewModel(
      label: label,
      observerForTrainingRecords: observerForLabels,
      getTrainingRecordsUseCase: getTrainingRecordsUseCase,
      addTrainingRecordUseCaseFactory: addTrainingRecordUseCaseFactory,
      removeTrainingRecordsUseCaseFactory: removeTrainingRecordsUseCaseFactory,
      backToLabelsUseCase: backToLabelsUseCase,
      editTrainingRecordsUseCaseFactory: editTrainingRecordsUseCaseFactory,
      cancelEditingTrainingRecordsUseCaseFactory: cancelEditingTrainingRecordsUseCaseFactory,
      closeTrainingRecordsErrorUseCaseFactory: closeTrainingRecordsErrorUseCaseFactory,
      addTrainingRecordFromFileUseCaseFactory: addTrainingRecordFromFileUseCaseFactory
    )
    observerForLabels.eventResponder = model
    Self.trainingRecordsModels.removeAll()
    Self.trainingRecordsModels[label] = model
    return TrainingRecordsView(model: model)
  }
}
