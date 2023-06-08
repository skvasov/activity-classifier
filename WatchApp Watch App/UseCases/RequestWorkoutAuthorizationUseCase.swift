//
//  RequestWorkoutAuthorizationUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 8.06.23.
//

import Foundation

class RequestWorkoutAuthorizationUseCase: UseCase {
  private let workoutRepository: WorkoutRepository
  
  init(workoutRepository: WorkoutRepository) {
    self.workoutRepository = workoutRepository
  }
  
  func execute() {
    Task {
      try? await workoutRepository.requestAuthorization()
    }
  }
}

