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
  func startWorkout() async throws
  func endWorkout()
}

class RealWorkoutRepository {
  private let healthStore = HKHealthStore()
  private var workoutSession: HKWorkoutSession?
}

extension RealWorkoutRepository: WorkoutRepository {
  func startWorkout() async throws {
    guard workoutSession == nil else { return }
    
    let typesToShare: Set = [HKQuantityType.workoutType()]
    let typesToRead: Set = [HKQuantityType.workoutType()]
    
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else {
        continuation.resume()
        return
      }
      
      self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { [weak self] success, error in
        guard let self = self else {
          continuation.resume(throwing: WorkoutManagerError.unknownError)
          return
        }
        
        guard error == nil else {
          continuation.resume(throwing: error!)
          return
        }
        
        if success {
          let configuration = HKWorkoutConfiguration()
          configuration.activityType = .golf
          configuration.locationType = .outdoor
          
          do {
            self.workoutSession = try HKWorkoutSession(healthStore: self.healthStore, configuration: configuration)
            self.workoutSession?.startActivity(with: Date())
            continuation.resume()
          } catch {
            continuation.resume(throwing: error)
          }
        } else {
          continuation.resume(throwing: WorkoutManagerError.unknownError)
        }
      }
    }
  }
  
  func endWorkout() {
    workoutSession?.end()
    workoutSession = nil
  }
}
