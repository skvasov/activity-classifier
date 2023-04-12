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
  func run(_ model: Model) async throws
  func stop() async throws
  func predict(_ deviceMotion: DeviceMotion) async throws -> Prediction
}

class RealModelRepository {
  private let modelStore: any PersistentStore<Model>
  private var mlModel: MLModel?
  
  init(modelStore: any PersistentStore<Model>) {
    self.modelStore = modelStore
  }
}

extension RealModelRepository: ModelRepository {
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
  
  func run(_ model: Model) async throws {
    guard let url = model.url else { throw ModelRepositoryError.invalidModelFile }
    
    let compiledModelURL = try await MLModel.compileModel(at: url)
    mlModel = try MLModel(contentsOf: compiledModelURL)
  }
  
  func stop() async throws {
    mlModel = nil
  }
  
  func predict(_ deviceMotion: DeviceMotion) async throws -> Prediction {
    guard let mlModel else { throw ModelRepositoryError.modelNotRunning }
    
    let featureProvider = try mlModel.prediction(from: deviceMotion)
    return Prediction(featureProvider)
  }
}
