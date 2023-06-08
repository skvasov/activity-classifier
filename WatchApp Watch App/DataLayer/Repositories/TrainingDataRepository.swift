//
//  TrainingDataRepository.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 25.04.23.
//

import Foundation

typealias RecordsStoreFactory = () -> any PersistentStore<TrainingRecord>

enum TrainingDataRepositoryError: Error {
  case failedToAddTrainingRecord
}

protocol TrainingDataRepository {
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion]
  func addTrainingRecord(_ record: inout TrainingRecord) async throws
}

class RealTrainingDataRepository {
  private let motionManagerFactory: MotionManagerFactory
  private let recordsStoreFactory: RecordsStoreFactory
  
  init(motionManagerFactory: @escaping MotionManagerFactory, recordsStoreFactory: @escaping RecordsStoreFactory) {
    self.motionManagerFactory = motionManagerFactory
    self.recordsStoreFactory = recordsStoreFactory
  }
}

extension RealTrainingDataRepository: TrainingDataRepository {
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion] {
    let motionManager = motionManagerFactory()
    return try await motionManager.getDeviceMotion(for: window, with: frequency)
  }
  
  func addTrainingRecord(_ record: inout TrainingRecord) async throws {
    let store = recordsStoreFactory()
  
    if let records = try? await store.loadAll() {
      try? await store.remove(records)
    }
    
    try await store.save(record)
    let url = try await store.loadAll().first?.url
    if let url {
      record.url = url
    } else {
      throw TrainingDataRepositoryError.failedToAddTrainingRecord
    }
  }
}
