//
//  WatchConnectvityManager.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 18.04.23.
//

import Foundation
import WatchConnectivity
import HealthKit
import Combine

enum WatchConnectvityManagerError: Error {
  case deviceNotReachable
  case fileTransferCanceled
}

private typealias ActivationContinuation = CheckedContinuation<WCSessionActivationState, Error>
private typealias FileTransferContinuation = CheckedContinuation<Void, Error>

protocol WatchConnectvityManagerDelegate: AnyObject {
  func watchConnectvityManager(_ manager: any WatchConnectvityManager, temporaryFileURLFor url: URL) -> URL?
}

protocol WatchConnectvityManager<Context, Message>: AnyObject {
  associatedtype Context: Codable
  associatedtype Message: Codable
  
  var delegate: WatchConnectvityManagerDelegate? { set get }
  
#if os(iOS)
  func startWatchApp() async throws
#endif
  func activateSession() async throws
  func updateAppContext(_ context: Context) async throws
  func getAppContext() async throws -> Context?
  func transferFile(_ fileURL: URL) async throws
  func sendMessage(_ message: Message) async throws
  
  func appContextPublisher() -> AnyPublisher<Context, Never>
  func fileTransferPublisher() -> AnyPublisher<URL, Never>
  func messagePublisher() -> AnyPublisher<Message, Never>
}

class RealWatchConnectvityManager<C: Codable, M: Codable>: NSObject, WCSessionDelegate {
  private var activationContinuations: [ActivationContinuation] = []
  private var fileTranferContinuations: [URL: FileTransferContinuation] = [:]
  private var encoder = JSONEncoder()
  private var decoder = JSONDecoder()
  private let appContextSubject = PassthroughSubject<C, Never>()
  private let fileTransferSubject = PassthroughSubject<URL, Never>()
  private let messagePublisherSubject = PassthroughSubject<M, Never>()
  
  weak var delegate: WatchConnectvityManagerDelegate?
  
  override init() {
    super.init()
    WCSession.default.delegate = self
  }
  
  func activateSession() async throws {
    if WCSession.default.activationState == .activated {
      // TODO: check it out
      //guard WCSession.default.isReachable else { throw WatchConnectvityManagerError.deviceNotReachable }
    } else {
      let activationState = try await withCheckedThrowingContinuation { (continuation: ActivationContinuation) in
        self.activationContinuations.append(continuation)
        WCSession.default.activate()
      }
      
      switch activationState {
      case .inactive, .notActivated:
        throw WatchConnectvityManagerError.deviceNotReachable
      default:
        break
      }
    }
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    activationContinuations.forEach { continuation in
      if let error {
        continuation.resume(throwing: error)
      } else {
        continuation.resume(returning: activationState)
      }
    }
  }
  
  func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
    if let continuation = fileTranferContinuations[fileTransfer.file.fileURL] {
      if let error {
        continuation.resume(throwing: error)
      } else if fileTransfer.progress.isCancelled {
        continuation.resume(throwing: WatchConnectvityManagerError.fileTransferCanceled)
      } else {
        continuation.resume(returning: ())
      }
    }
  }
  
  func session(_ session: WCSession, didReceive file: WCSessionFile) {
    if let tempURL = delegate?.watchConnectvityManager(self, temporaryFileURLFor: file.fileURL) {
      fileTransferSubject.send(tempURL)
    }
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let newContext = try? convert(from: applicationContext[WCSession.Keys.context.rawValue] as? Data) {
      appContextSubject.send(newContext)
    }
  }
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
    do {
      let message = try decoder.decode(M.self, from: messageData)
      messagePublisherSubject.send(message)
      replyHandler(Data())
    }
    catch {
      replyHandler(Data())
    }
  }
  
#if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    
  }
#endif
  
  private func convert(from contextData: Data?) throws -> C? {
    guard
      let data = contextData
    else { return nil }
    return try decoder.decode(C.self, from: data)
  }
}

extension RealWatchConnectvityManager: WatchConnectvityManager {
  
#if os(iOS)
  func startWatchApp() async throws {
    try await HKHealthStore().startWatchApp(toHandle: HKWorkoutConfiguration())
  }
#endif
  
  func updateAppContext(_ context: C) async throws {
    try await activateSession()
    let data = try encoder.encode(context)
    try WCSession.default.updateApplicationContext([
      WCSession.Keys.timestamp.rawValue: Date().timeIntervalSince1970,
      WCSession.Keys.context.rawValue: data
    ])
  }
  
  func getAppContext() async throws -> C? {
    try await activateSession()
    return try convert(from: WCSession.default.contextData)
  }
  
  func transferFile(_ fileURL: URL) async throws {
    let outstandingFileTransfers = WCSession.default.outstandingFileTransfers
    for transfer in outstandingFileTransfers {
      if transfer.file.fileURL == fileURL {
        fileTranferContinuations[fileURL] = nil
        transfer.cancel()
      }
    }
    try await activateSession()
    try await withCheckedThrowingContinuation { (continuation: FileTransferContinuation) in
      self.fileTranferContinuations[fileURL] = continuation
      WCSession.default.transferFile(fileURL, metadata: nil)
    }
  }
  
  func sendMessage(_ message: M) async throws {
    try await activateSession()
    let data = try encoder.encode(message)
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
      WCSession.default.sendMessageData(data) { _ in
        continuation.resume(returning: ())
      }
    })
  }
  
  func appContextPublisher() -> AnyPublisher<C, Never> {
    appContextSubject
      .eraseToAnyPublisher()
  }
  
  func fileTransferPublisher() -> AnyPublisher<URL, Never> {
    fileTransferSubject
      .eraseToAnyPublisher()
  }
  
  func messagePublisher() -> AnyPublisher<M, Never> {
    messagePublisherSubject
      .eraseToAnyPublisher()
  }
}
