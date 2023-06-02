//
//  ClearFileCacheUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 2.06.23.
//

import Foundation

class ClearCacheUseCase: UseCase {
  
  private let fileCacheManager: FileCacheManager
  
  init(fileCacheManager: FileCacheManager) {
    self.fileCacheManager = fileCacheManager
  }
  
  func execute() {
    Task {
      fileCacheManager.clearCache()
    }
  }
}

