//
//  WorkoutManager.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 7.06.23.
//

import Foundation
import HealthKit

enum WorkoutManagerError: Error {
  case unknownError
}

protocol WorkoutRepository {
  func requestAuthorization() async throws
  func startWorkout() async throws
  func endWorkout()
}

class RealWorkoutRepository {
  private let healthStore = HKHealthStore()
  private var workoutSession: HKWorkoutSession?
}

extension RealWorkoutRepository: WorkoutRepository {
  func requestAuthorization() async throws {
    let type = HKQuantityType.workoutType()
    guard healthStore.authorizationStatus(for: type) != .sharingAuthorized else { return }
    
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else {
        continuation.resume()
        return
      }
      
      let typesToShare: Set = [type]
      let typesToRead: Set = [type]
      
      self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
        guard error == nil else {
          continuation.resume(throwing: error!)
          return
        }
        
        guard success else {
          continuation.resume(throwing: WorkoutManagerError.unknownError)
          return
        }
        
        continuation.resume()
      }
    }
  }
  
  func startWorkout() async throws {
    guard workoutSession == nil else { return }
    
    try await requestAuthorization()
    
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .golf
    configuration.locationType = .outdoor
    
    self.workoutSession = try HKWorkoutSession(healthStore: self.healthStore, configuration: configuration)
    self.workoutSession?.startActivity(with: Date())
  }
  
  func endWorkout() {
    workoutSession?.end()
    workoutSession = nil
  }
}
