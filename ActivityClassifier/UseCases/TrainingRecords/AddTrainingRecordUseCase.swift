//
//  AddTrainingRecordUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

class AddTrainingRecordUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let label: TrainingLabel
  private let trainingDataRepository: TrainingDataRepository
  private let settingsRepository: SettingsRepository
  
  init(actionDispatcher: ActionDispatcher, label: TrainingLabel, trainingDataRepository: TrainingDataRepository, settingsRepository: SettingsRepository) {
    self.actionDispatcher = actionDispatcher
    self.label = label
    self.trainingDataRepository = trainingDataRepository
    self.settingsRepository = settingsRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatch(TrainingRecordsActions.AddTrainingRecord())
      do {
        let settings = try await settingsRepository.load() ?? .default

        try await Task.sleep(for: .seconds(settings.delay))
        
        let motions = try await trainingDataRepository.getDeviceMotion(for: settings.predictionWindow, with: settings.frequency)
        let data = try JSONEncoder().encode(motions)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let name = dateFormatter.string(from: Date()) + ".json"
        
        let trainingRecord = TrainingRecord(name: name, numOfChildren: 0, content: data)
        try await trainingDataRepository.addTrainingRecord(trainingRecord, for: label)
        actionDispatcher.dispatch(TrainingRecordsActions.AddedTrainingRecord(trainingRecord: trainingRecord))
      }
      catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatch(TrainingRecordsActions.AddingTrainingRecordFailed(error: errorMessage))
      }
    }
  }
}
