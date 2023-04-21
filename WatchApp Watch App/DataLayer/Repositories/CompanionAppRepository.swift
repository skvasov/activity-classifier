//
//  CompanionAppRepository.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

protocol CompanionAppRepository {
  func getTrainingLabel() async throws -> TrainingLabel?
}

class RealCompanionAppRepository: CompanionAppRepository {
  private let watchConnectivityManager: any WatchConnectvityManager<WatchContext>
  
  init(watchConnectivityManager: any WatchConnectvityManager<WatchContext>) {
    self.watchConnectivityManager = watchConnectivityManager
  }
  
  func getTrainingLabel() async throws -> TrainingLabel? {
    try await watchConnectivityManager.getAppContext()?.label
  }
}

