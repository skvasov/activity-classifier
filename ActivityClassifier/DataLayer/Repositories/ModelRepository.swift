//
//  ModelRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation
import CoreML

enum ModelRepositoryError: Error {
  case invalidModelFile
  case modelNotRunning
}

protocol ModelRepository {
  func save(_ model: Model) async throws
  func loadAll() async throws -> [Model]
  func removeAll() async throws
  func run(_ model: Model, for window: Int, with frequency: Double) async throws -> AsyncStream<[DeviceMotion]>
  func stop()
  func predict(_ deviceMotions: [DeviceMotion]) throws -> Prediction
}

class RealModelRepository {
  private let modelStore: any PersistentStore<Model>
  private let motionManager: MotionManager
  private var mlModel: MLModel?
  private var stateOut: MLMultiArray?
  
  init(modelStore: any PersistentStore<Model>, motionManager: MotionManager) {
    self.modelStore = modelStore
    self.motionManager = motionManager
  }
}

extension RealModelRepository: ModelRepository {
  private enum Keys: String {
    case stateOut = "stateOut"
  }
  
  func save(_ model: Model) async throws {
    try await modelStore.save(model)
  }
  
  func loadAll() async throws -> [Model] {
    try await modelStore.loadAll()
  }
  
  func removeAll() async throws {
    let models = try await modelStore.loadAll()
    try await modelStore.remove(models)
  }
  
  func run(_ model: Model, for window: Int, with frequency: Double) async throws -> AsyncStream<[DeviceMotion]> {
    guard let url = model.url else { throw ModelRepositoryError.invalidModelFile }
    
    let compiledModelURL = try await MLModel.compileModel(at: url)
    mlModel = try MLModel(contentsOf: compiledModelURL)
    stateOut = nil
    
    return try motionManager.getDeviceMotion(for: window, with: frequency)
  }
  
  func stop() {
    mlModel = nil
    stateOut = nil
    motionManager.stopGettingDeviceMotion()
  }
  
  func predict(_ deviceMotions: [DeviceMotion]) throws -> Prediction {
    guard let mlModel else { throw ModelRepositoryError.modelNotRunning }
    
    let input = try DeviceMotionFeatureProvider(deviceMotions, stateIn: stateOut)
    let output = try mlModel.prediction(from: input)
    
    stateOut = output.featureValue(for: Keys.stateOut.rawValue)?.multiArrayValue
    
    return Prediction(output)
  }
}
