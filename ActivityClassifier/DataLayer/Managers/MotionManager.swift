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
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion]
  func getDeviceMotion(for window: Int, with frequency: Int) throws -> AsyncStream<[DeviceMotion]>
  func stopGettingDeviceMotion()
}

class RealMotionManager: MotionManager {
  static let shared = RealMotionManager()
  
  private var continuation: AsyncStream<DeviceMotion>.Continuation?
  private var currentManager: CMMotionManager?
  
  private init() { }
  
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion] {
    return try await withCheckedThrowingContinuation { continuation in
      let interval = 1.0 / Double(frequency)
      let manager = CMMotionManager()
      manager.deviceMotionUpdateInterval = interval
      
      var motions: [CMDeviceMotion] = []
      manager.startDeviceMotionUpdates(to: .main) { motion, error in
        guard error == nil else {
          manager.stopDeviceMotionUpdates()
          continuation.resume(throwing: error!)
          return
        }
        
        guard motions.count < window else {
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
  
  func getDeviceMotion(for window: Int, with frequency: Int) throws -> AsyncStream<[DeviceMotion]> {
    stopGettingDeviceMotion()
    
    // TODO: Propagate error from `startDeviceMotionUpdates`
    return AsyncStream { continuation in
      let interval = 1 / Double(frequency)
      let manager = CMMotionManager()
      currentManager = manager
      manager.deviceMotionUpdateInterval = interval
      
      var motions: [CMDeviceMotion] = []
      manager.startDeviceMotionUpdates(to: .main) { motion, error in
        guard error == nil else {
          self.stopGettingDeviceMotion()
          return
        }
        
        if let motion {
          motions.append(motion)
          if motions.count == window {
            continuation.yield(motions.map(DeviceMotion.init))
            motions.removeAll()
          }
        }
      }
    }
  }
  
  func stopGettingDeviceMotion() {
    currentManager?.stopDeviceMotionUpdates()
    continuation?.finish()
    continuation = nil
  }
}
