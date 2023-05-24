//
//  SaveModelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 24.05.23.
//

import Foundation

class SaveModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let url: URL
  private let modelRepository: ModelRepository
  
  init(actionDispatcher: ActionDispatcher, url: URL, modelRepository: ModelRepository) {
    self.actionDispatcher = actionDispatcher
    self.url = url
    self.modelRepository = modelRepository
  }
  
  func execute() {
    Task {
      let modelToSave = Model(url: url)
      try await modelRepository.save(modelToSave)
      try FileManager.default.removeItem(at: url)
    }
  }
}
