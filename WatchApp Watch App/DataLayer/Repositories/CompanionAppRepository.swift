//
//  CompanionAppRepository.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

protocol CompanionAppRepository {
  func getTrainingLabel() async throws -> TrainingLabel?
  func addTrainingRecord(_ trainingRecord: TrainingRecord) async throws
  func getSettings() async throws -> Settings
}

class RealCompanionAppRepository: CompanionAppRepository {
  private let watchConnectivityManager: any WatchConnectvityManager<WatchContext>
  
  init(watchConnectivityManager: any WatchConnectvityManager<WatchContext>) {
    self.watchConnectivityManager = watchConnectivityManager
  }
  
  func getTrainingLabel() async throws -> TrainingLabel? {
    try await watchConnectivityManager.getAppContext()?.label
  }
  
  func addTrainingRecord(_ trainingRecord: TrainingRecord) async throws {
    if let url = trainingRecord.url {
      try await self.watchConnectivityManager.transferFile(url)
    }
  }
  
  func getSettings() async throws -> Settings {
    try await watchConnectivityManager.getAppContext()?.settings ?? .default
  }
}

