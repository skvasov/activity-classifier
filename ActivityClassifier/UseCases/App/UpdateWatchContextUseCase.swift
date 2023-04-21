//
//  UpdateWatchContextUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

class UpdateWatchContextUseCase: UseCase {
  
  private let watchAppRepository: WatchAppRepository
  private let label: TrainingLabel?
  
  init(watchAppRepository: WatchAppRepository, label: TrainingLabel?) {
    self.watchAppRepository = watchAppRepository
    self.label = label
  }
  
  func execute() {
    Task {
      do {
        var context = try watchAppRepository.getAppContext() ?? WatchContext()
        context.label = label
        try await watchAppRepository.updateAppContext(context)
      }
      catch {
        print(error)
      }
    }
  }
}

