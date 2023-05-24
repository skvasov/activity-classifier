//
//  ModelRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation
import CoreML
import Zip
import Combine

enum ModelRepositoryError: Error {
  case invalidModelFile
  case modelNotRunning
  case invalidModelURL
}

protocol ModelRepository {
  func save(_ model: Model) async throws
  func load() async throws -> Model?
  func run(_ model: Model, for window: Int, with frequency: Int) async throws -> AsyncStream<[DeviceMotion]>
  func stop()
  func predict(_ deviceMotions: [DeviceMotion]) throws -> Prediction
  func latestModelPublisher() -> AnyPublisher<Model, Never>
}

class RealModelRepository {
  private let modelStore: any PersistentStore<Model>
  private let motionManager: MotionManager
  private var mlModel: MLModel?
  private var stateOut: MLMultiArray?
  private let latestModelSubject = PassthroughSubject<Model, Never>()
  
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
  
  func save(_ model: Model) async throws {
    guard let url = model.url else { throw ModelRepositoryError.invalidModelURL }
    
    do { try await removeAll() } catch {}
    
    var model = model
    
#if os(iOS)
    var compiledModelURL: URL?
    do { compiledModelURL = try await MLModel.compileModel(at: url) } catch {}
    
    guard let compiledModelURL else { throw ModelRepositoryError.invalidModelFile }
    model.url = compiledModelURL
    model.name += "c" // TODO:
    try await modelStore.save(model)
    try FileManager.default.removeItem(at: compiledModelURL)
#endif
    
#if os(watchOS)
    // TODO: Use Adapter pattern here?
    func clean(urls: [URL]) throws {
      try urls.forEach { try FileManager.default.removeItem(at: $0) }
    }
    
    let unarchivedFolderURL = try Zip.quickUnzipFile(url)
    guard var modelURL = try FileManager.default.contentsOfDirectory(at: unarchivedFolderURL, includingPropertiesForKeys: nil).first
    else {
      try clean(urls: [url, unarchivedFolderURL])
      return
    }
    
    var path = modelURL.path()
    if path.last == .init("/") {
      path.removeLast()
      modelURL = URL(filePath: path)
    }

    model.name = modelURL.lastPathComponent
    model.url = modelURL
    try await modelStore.save(model)
    try clean(urls: [url, unarchivedFolderURL, modelURL])
#endif
    
    if let model = try await modelStore.loadAll().first {
      latestModelSubject.send(model)
    }
  }
  
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
  
  func latestModelPublisher() -> AnyPublisher<Model, Never> {
    latestModelSubject
      .eraseToAnyPublisher()
  }
}
