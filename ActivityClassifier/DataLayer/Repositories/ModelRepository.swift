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
  case invalidModelURL
}

protocol ModelRepository {
#if os(iOS)
  func save(_ model: Model) async throws
#endif
  func load() async throws -> Model?
  func run(_ model: Model, for window: Int, with frequency: Int) async throws -> AsyncStream<[DeviceMotion]>
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
  
  private func removeAll() async throws {
    let models = try await modelStore.loadAll()
    try await modelStore.remove(models)
  }
}

extension RealModelRepository: ModelRepository {
  private enum Keys: String {
    case stateOut = "stateOut"
  }
  
#if os(iOS)
  func save(_ model: Model) async throws {
    guard let url = model.url else { throw ModelRepositoryError.invalidModelURL }
    
    do { try await removeAll() } catch {}
    
    var model = model
    var compiledModelURL: URL?
    do { compiledModelURL = try await MLModel.compileModel(at: url) } catch {}
    
    guard let compiledModelURL else { throw ModelRepositoryError.invalidModelFile }
    model.url = compiledModelURL
    model.name += "c" // TODO:
    try await modelStore.save(model)
    try FileManager.default.removeItem(at: compiledModelURL)
  }
#endif
  
  func load() async throws -> Model? {
    try await modelStore.loadAll().first
  }
  
  func run(_ model: Model, for window: Int, with frequency: Int) async throws -> AsyncStream<[DeviceMotion]> {
    guard let url = model.url else { throw ModelRepositoryError.invalidModelFile }
    
    mlModel = try MLModel(contentsOf: url)
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
