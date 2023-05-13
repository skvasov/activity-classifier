//
//  SendModelUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 13.05.23.
//

import Foundation

class SendModelUseCase: UseCase {
  private let modelRepository: ModelRepository
  private let watchAppRepository: WatchAppRepository
  
  init(modelRepository: ModelRepository, watchAppRepository: WatchAppRepository) {
    self.modelRepository = modelRepository
    self.watchAppRepository = watchAppRepository
  }
  
  func execute() {
    Task {
      do {
        guard let model = try await modelRepository.load() else { return }
        try await watchAppRepository.sendModel(model)
      }
      catch {
        print(error)
      }
    }
  }
}
