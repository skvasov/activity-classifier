//
//  LaunchWatchAppUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

class StartWatchAppUseCase: UseCase {
  
  private let watchAppRepository: WatchAppRepository
  
  init(watchAppRepository: WatchAppRepository) {
    self.watchAppRepository = watchAppRepository
  }
  
  func execute() {
    Task {
      do {
        try await watchAppRepository.startWatchApp()
      }
      catch {}
    }
  }
}
