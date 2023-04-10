//
//  MotionManager.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation
import CoreMotion

typealias MotionManagerFactory = () -> MotionManager

protocol MotionManager {
  func getDeviceMotion(for duration: TimeInterval, with frequency: Double) async throws ->  [DeviceMotion]
}

class RealMotionManager: MotionManager {
  static let shared = RealMotionManager()
  
  private init() { }
  
  func getDeviceMotion(for duration: TimeInterval, with frequency: Double) async throws ->  [DeviceMotion] {
    let finish = Date().timeIntervalSince1970 + duration
    return try await withCheckedThrowingContinuation { continuation in
      let interval = 1 / frequency
      let manager = CMMotionManager()
      manager.deviceMotionUpdateInterval = interval
      
      var motions: [CMDeviceMotion] = []
      manager.startDeviceMotionUpdates(to: .main) { motion, error in
        guard error == nil else {
          manager.stopDeviceMotionUpdates()
          continuation.resume(throwing: error!)
          return
        }
        
        guard finish > Date().timeIntervalSince1970 else {
          manager.stopDeviceMotionUpdates()
          continuation.resume(returning: motions.map(DeviceMotion.init))
          return
        }
        
        if let motion {
          motions.append(motion)
        }
      }
    }
  }
}
