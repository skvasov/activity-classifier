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
  
#if os(iOS)
  func startWatchApp() async throws
#endif
  func activateSession() async throws
  func updateAppContext(_ context: Context) async throws
  func getAppContext() throws -> Context
}

class RealWatchConnectvityManager<T: DictionaryCodable>: NSObject, WCSessionDelegate {
  private var activationContinuations: [ActivationContinuation] = []
  
  override init() {
    super.init()
    WCSession.default.delegate = self
  }
  
  func activateSession() async throws {
    if WCSession.default.activationState == .activated {
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
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    print(applicationContext)
  }
  
#if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    
  }
#endif
}

extension RealWatchConnectvityManager: WatchConnectvityManager {
  
#if os(iOS)
  func startWatchApp() async throws {
    // TODO: Fix Asked to start a workout, but WKExtensionDelegate <SwiftUI.ExtensionDelegate: 0x600001d1d0c0> doesn't implement handleWorkoutConfiguration:
    try await HKHealthStore().startWatchApp(toHandle: HKWorkoutConfiguration())
  }
#endif
  
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

