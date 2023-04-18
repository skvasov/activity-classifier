//
//  WatchConnectvityManager.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 18.04.23.
//

import Foundation
import WatchConnectivity
import HealthKit

enum WatchConnectvityManagerError: Error {
  case deviceNotReachable
}

private typealias ActivationContinuation = CheckedContinuation<WCSessionActivationState, Error>

protocol WatchConnectvityManager<Context> {
  associatedtype Context: DictionaryCodable

  func startWatchApp() async throws
  func updateAppContext(_ context: Context) async throws
  func getAppContext() throws -> Context
}

class RealWatchConnectvityManager<T: DictionaryCodable>: NSObject, WCSessionDelegate {
  private var activationContinuations: [ActivationContinuation] = []
  
  private override init() {
    super.init()
    WCSession.default.delegate = self
  }
  
  private func activateSession() async throws {
    if WCSession.default.activationState == .activated {
      guard WCSession.default.isReachable else { throw WatchConnectvityManagerError.deviceNotReachable }
    } else {
      let activationState = try await withCheckedThrowingContinuation { (continuation: ActivationContinuation) in
        self.activationContinuations.append(continuation)
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
  
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
  }
}

extension RealWatchConnectvityManager: WatchConnectvityManager {
  
  func startWatchApp() async throws {
    try await HKHealthStore().startWatchApp(toHandle: HKWorkoutConfiguration())
  }
  
  func updateAppContext(_ context: T) async throws {
    try await activateSession()
    try WCSession.default.updateApplicationContext(context.dictionary)
  }
  
  func getAppContext() throws -> T {
    try T(WCSession.default.receivedApplicationContext)
  }
}

protocol DictionaryCodable {
  var dictionary: [String: Any] { get }
  init(_ dictionary: [String: Any]) throws
}

