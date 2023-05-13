//
//  WatchAppRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation
import Zip
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
}

class RealWatchAppRepository {
  private let connectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>
  private var subscriptions = Set<AnyCancellable>()
  private let latestModelRequestSubject = PassthroughSubject<Void, Never>()
  
  init(connectivityManager: any WatchConnectvityManager<WatchContext, WatchMessage>) {
    self.connectivityManager = connectivityManager
    
    connectivityManager.messagePublisher()
      .sink { [weak self] watchMessage in
        switch watchMessage.type {
        case .latestModelRequest:
          self?.latestModelRequestSubject.send(())
        default:
          break
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
    let archiveURL = URL.modelArchive
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      do {
        // TODO: Use Adapter pattern here?
        try Zip.zipFiles(paths: [url], zipFilePath: archiveURL, password: nil) { progress in
          if progress == 1 {
            continuation.resume(returning: ())
          }
        }
      } catch {
        continuation.resume(throwing: error)
      }
    }
    try await connectivityManager.transferFile(archiveURL)
  }
  
  func latestModelRequestPublisher() -> AnyPublisher<Void, Never> {
    latestModelRequestSubject
      .eraseToAnyPublisher()
  }
}
