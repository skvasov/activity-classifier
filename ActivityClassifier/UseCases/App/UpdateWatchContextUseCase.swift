//
//  UpdateWatchContextUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

class UpdateWatchContextUseCase: UseCase {
  
  private let watchAppRepository: WatchAppRepository
  private let settingsRepository: SettingsRepository
  private let trainingDataRepository: TrainingDataRepository
  
  init(watchAppRepository: WatchAppRepository, settingsRepository: SettingsRepository, trainingDataRepository: TrainingDataRepository) {
    self.watchAppRepository = watchAppRepository
    self.settingsRepository = settingsRepository
    self.trainingDataRepository = trainingDataRepository
  }
  
  func execute() {
    Task {
      do {
        let settings = try await settingsRepository.load()
        var context = try await watchAppRepository.getAppContext() ?? WatchContext(settings: settings)
        context.label = trainingDataRepository.selectedTrainingLabel
        context.settings = settings
        try await watchAppRepository.updateAppContext(context)
      }
      catch {
        print(error)
      }
    }
  }
}

