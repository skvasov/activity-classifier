//
//  TrainingDataRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation
import Combine

typealias RecordsStoreFactory = (Storable) -> any PersistentStore<TrainingRecord>

protocol TrainingDataRepository {
  var selectedTrainingLabel: TrainingLabel? { get set }
  func invalidateSelectedTrainingLabel()
  func selectedTrainingLabelPublisher() -> AnyPublisher<TrainingLabel?, Never>
  func addLabel(_ label: TrainingLabel) async throws
  func getAllLabels() async throws -> [TrainingLabel]
  func removeLabels(_ labels: [TrainingLabel]) async throws
  func addTrainingRecord(_ record: TrainingRecord, for label: TrainingLabel) async throws
  func getAllTrainingRecords(for label: TrainingLabel) async throws -> [TrainingRecord]
  func removeTrainingRecords(_ records: [TrainingRecord], for label: TrainingLabel) async throws
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion]
  func exportTrainingData() async throws -> URL
}

class RealTrainingDataRepository {
  private let labelsStore: any PersistentStore<TrainingLabel>
  private let recordsStoreFactory: RecordsStoreFactory
  private let motionManagerFactory: MotionManagerFactory
  private let archiver: Archiver
  private let selectedTrainingRecordSubject = PassthroughSubject<TrainingLabel?, Never>()
  
  var selectedTrainingLabel: TrainingLabel? {
    didSet {
      selectedTrainingRecordSubject.send(selectedTrainingLabel)
    }
  }
  
  init(labelsStore: any PersistentStore<TrainingLabel>, recordsStoreFactory: @escaping RecordsStoreFactory, motionManagerFactory: @escaping MotionManagerFactory, archiver: Archiver) {
    self.labelsStore = labelsStore
    self.recordsStoreFactory = recordsStoreFactory
    self.motionManagerFactory = motionManagerFactory
    self.archiver = archiver
  }
}

extension RealTrainingDataRepository: TrainingDataRepository {
  func invalidateSelectedTrainingLabel() {
    Task {
      if let name = selectedTrainingLabel?.name {
        let upToDateLabel = try await self.labelsStore.loadAll().first { $0.name.compare(name) == .orderedSame }
        self.selectedTrainingLabel = upToDateLabel
      } else {
        self.selectedTrainingLabel = nil
      }
    }
  }
  
  func selectedTrainingLabelPublisher() -> AnyPublisher<TrainingLabel?, Never> {
    selectedTrainingRecordSubject
      .eraseToAnyPublisher()
  }
  
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
  
  func getDeviceMotion(for window: Int, with frequency: Int) async throws ->  [DeviceMotion] {
    let motionManager = motionManagerFactory()
    return try await motionManager.getDeviceMotion(for: window, with: frequency)
  }
  
  func exportTrainingData() async throws -> URL {
    try await archiver.archive()
    return archiver.destinationURL
  }
}
