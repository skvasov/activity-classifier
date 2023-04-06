//
//  TrainingDataRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

typealias RecordsStoreFactory = (Storable) -> any PersistentStore<TrainingRecord>

protocol TrainingDataRepository {
  func addLabel(_ label: TrainingLabel) async throws
  func getAllLabels() async throws -> [TrainingLabel]
  func removeLabels(_ labels: [TrainingLabel]) async throws
  func addTrainingRecord(_ record: TrainingRecord, for label: TrainingLabel) async throws
  func getAllTrainingRecords(for label: TrainingLabel) async throws -> [TrainingRecord]
  func removeTrainingRecords(_ records: [TrainingRecord], for label: TrainingLabel) async throws
}

class RealTrainingDataRepository {
  private let labelsStore: any PersistentStore<TrainingLabel>
  private let recordsStoreFactory: RecordsStoreFactory
  
  init(labelsStore: any PersistentStore<TrainingLabel>, recordsStoreFactory: @escaping RecordsStoreFactory) {
    self.labelsStore = labelsStore
    self.recordsStoreFactory = recordsStoreFactory
  }
}

extension RealTrainingDataRepository: TrainingDataRepository {
  func addLabel(_ label: TrainingLabel) async throws {
    try await labelsStore.save(label)
  }
  
  func getAllLabels() async throws -> [TrainingLabel] {
    try await labelsStore.loadAll()
  }
  
  func removeLabels(_ labels: [TrainingLabel]) async throws {
    try await labelsStore.remove(labels)
  }
  
  func addTrainingRecord(_ record: TrainingRecord, for label: TrainingLabel) async throws {
    let recordsStore = recordsStoreFactory(label)
    try await recordsStore.save(record)
  }
  
  func getAllTrainingRecords(for label: TrainingLabel) async throws -> [TrainingRecord] {
    let recordsStore = recordsStoreFactory(label)
    return try await recordsStore.loadAll()
  }
  
  func removeTrainingRecords(_ records: [TrainingRecord], for label: TrainingLabel) async throws {
    let recordsStore = recordsStoreFactory(label)
    try await recordsStore.remove(records)
  }
}
