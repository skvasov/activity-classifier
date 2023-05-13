//
//  GetLatestModelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 11.05.23.
//

import Foundation

class GetLatestModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let modelRepository: ModelRepository
  private let companionAppRepository: CompanionAppRepository
  
  init(actionDispatcher: ActionDispatcher, modelRepository: ModelRepository, companionAppRepository: CompanionAppRepository) {
    self.actionDispatcher = actionDispatcher
    self.modelRepository = modelRepository
    self.companionAppRepository = companionAppRepository
  }
  
  func execute() {
    Task {
      do {
        try await companionAppRepository.requestLatestModel()
      }
      catch {
        print(error)
      }
    }
  }
}
