//
//  CompanionAppRepository.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import Combine

protocol CompanionAppRepository {
  func getTrainingLabel() async throws -> TrainingLabel?
  func addTrainingRecord(_ trainingRecord: TrainingRecord) async throws
  func getSettings() async throws -> Settings
  func requestLatestModel() async throws
  
  func latestModelFilePublisher() -> AnyPublisher<URL, Never>
}

class RealCompanionAppRepository: CompanionAppRepository {
  private let watchConnectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>
  private let fileCacheManager: FileCacheManager
  private var subscriptions = Set<AnyCancellable>()
  private let latestModelFileSubject = PassthroughSubject<URL, Never>()
  
  init(watchConnectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>, fileCacheManager: FileCacheManager) {
    self.watchConnectivityManager = watchConnectivityManager
    self.fileCacheManager = fileCacheManager
    
    self.watchConnectivityManager.delegate = self
    
    watchConnectivityManager.fileTransferPublisher()
      .sink { [weak self] url in
        self?.latestModelFileSubject.send(url)
      }
      .store(in: &subscriptions)
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
  
  func requestLatestModel() async throws {
    try await watchConnectivityManager.activateSession()
    try await watchConnectivityManager.sendMessage(WatchMessage(type: .latestModelRequest))
  }
  
  func latestModelFilePublisher() -> AnyPublisher<URL, Never> {
    latestModelFileSubject
      .eraseToAnyPublisher()
  }
}

extension RealCompanionAppRepository: WatchConnectvityManagerDelegate {
  func watchConnectvityManager(_ manager: any WatchConnectvityManager, temporaryFileURLFor url: URL) -> URL? {
    return try? fileCacheManager.makeFileCopy(for: url)
  }
}
