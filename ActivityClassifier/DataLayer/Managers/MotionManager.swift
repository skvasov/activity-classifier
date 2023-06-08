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
  func getContinuousDeviceMotion(for window: Int, with frequency: Int) -> AsyncThrowingStream<[DeviceMotion], Error>
  func stopGettingDeviceMotion()
}

class RealMotionManager: MotionManager {
  static let shared = RealMotionManager()
  
  private var continuation: AsyncStream<DeviceMotion>.Continuation?
  private var currentManager: CMMotionManager?
  
  private init() { }
  
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion] {
    return try await withCheckedThrowingContinuation { continuation in
      var isStopped = false
      let manager = makeMotionManager(with: frequency)
      
      var motions: [CMDeviceMotion] = []
      manager.startDeviceMotionUpdates(to: .main) { motion, error in
        guard error == nil else {
          manager.stopDeviceMotionUpdates()
          if !isStopped {
            continuation.resume(throwing: error!)
            isStopped = true
          }
          return
        }
        
        guard motions.count < window else {
          manager.stopDeviceMotionUpdates()
          if !isStopped {
            continuation.resume(returning: motions.map(DeviceMotion.init))
            isStopped = true
          }
          return
        }
        
        if let motion {
          motions.append(motion)
        }
      }
    }
  }
  
  func getContinuousDeviceMotion(for window: Int, with frequency: Int) -> AsyncThrowingStream<[DeviceMotion], Error> {
    stopGettingDeviceMotion()
    
    return AsyncThrowingStream { continuation in
      currentManager = makeMotionManager(with: frequency)
      
      var motions: [CMDeviceMotion] = []
      currentManager?.startDeviceMotionUpdates(to: .main) { motion, error in
        guard error == nil else {
          self.stopGettingDeviceMotion()
          continuation.finish(throwing: error)
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
  
  private func makeMotionManager(with frequency: Int) -> CMMotionManager {
    let interval = 1 / Double(frequency)
    let manager = CMMotionManager()
    manager.deviceMotionUpdateInterval = interval
    return manager
  }
}
