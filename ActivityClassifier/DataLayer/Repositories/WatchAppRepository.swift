//
//  WatchAppRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation
import Combine

enum WatchAppRepositoryError: Error {
  case invalidModelURL
}

protocol WatchAppRepository {
  func startWatchApp() async throws
  func updateAppContext(_ context: WatchContext) async throws
  func getAppContext() async throws -> WatchContext?
  func sendModel(_ model: Model) async throws
  func latestModelRequestPublisher() -> AnyPublisher<Void, Never>
  func trainingRecordFilePublisher() -> AnyPublisher<URL, Never>
}

class RealWatchAppRepository {
  private let connectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>
  private let fileCacheManager: FileCacheManager
  private var subscriptions = Set<AnyCancellable>()
  private let latestModelRequestSubject = PassthroughSubject<Void, Never>()
  private let trainingRecordFileSubject = PassthroughSubject<URL, Never>()
  private let archiverFactory: ArchiverFactory
  
  init(connectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>, fileCacheManager: FileCacheManager, archiverFactory: @escaping ArchiverFactory) {
    self.connectivityManager = connectivityManager
    self.fileCacheManager = fileCacheManager
    self.archiverFactory = archiverFactory
    
    self.connectivityManager.delegate = self
    
    connectivityManager.fileTransferPublisher()
      .sink { [weak self] fileURL in
        self?.trainingRecordFileSubject.send(fileURL)
      }
      .store(in: &subscriptions)
    
    connectivityManager.messagePublisher()
      .sink { [weak self] watchMessage in
        switch watchMessage.type {
        case .latestModelRequest:
          self?.latestModelRequestSubject.send(())
        }
      }
      .store(in: &subscriptions)
  }
}

extension RealWatchAppRepository: WatchAppRepository {
  func startWatchApp() async throws {
    try await connectivityManager.startWatchApp()
  }
  
  func updateAppContext(_ context: WatchContext) async throws {
    try await connectivityManager.updateAppContext(context)
  }
  
  func getAppContext() async throws -> WatchContext? {
    try await connectivityManager.getAppContext()
  }
  
  func sendModel(_ model: Model) async throws {
    guard let url = model.url else { throw WatchAppRepositoryError.invalidModelURL }
    let archiveDirectory = try fileCacheManager.createTemporaryDirectory()
    let archiveFileURL = archiveDirectory.appending(path: "model.zip") // TODO: not nice
    
    let archiver = archiverFactory(url, archiveFileURL)
    try await archiver.archive()
    
    try await connectivityManager.transferFile(archiveFileURL)
  }
  
  func latestModelRequestPublisher() -> AnyPublisher<Void, Never> {
    latestModelRequestSubject
      .eraseToAnyPublisher()
  }
  
  func trainingRecordFilePublisher() -> AnyPublisher<URL, Never> {
    trainingRecordFileSubject
      .eraseToAnyPublisher()
  }
}

extension RealWatchAppRepository: WatchConnectvityManagerDelegate {
  func watchConnectvityManager(_ manager: any WatchConnectvityManager, temporaryFileURLFor url: URL) -> URL? {
    return try? fileCacheManager.makeFileCopy(for: url)
  }
}

