//
//  WatchAppModel.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

class WatchAppModel {
  private let observerForWatchApp: Observer
  private let getLatestModelUseCase: UseCase
  private let saveModelUseCaseFactory: SaveModelUseCaseFactory
  private let clearCacheUseCase: UseCase
  private var isAppeared = false
  
  
  init(observerForWatchApp: Observer, getLatestModelUseCase: UseCase, saveModelUseCaseFactory: @escaping SaveModelUseCaseFactory, clearCacheUseCase: UseCase) {
    self.observerForWatchApp = observerForWatchApp
    self.getLatestModelUseCase = getLatestModelUseCase
    self.saveModelUseCaseFactory = saveModelUseCaseFactory
    self.clearCacheUseCase = clearCacheUseCase
  }
  
  func onAppear() {
    observerForWatchApp.startObserving()
    
    if !isAppeared {
      self.isAppeared = true
      clearCacheUseCase.execute()
    }
    
    getLatestModelUseCase.execute()
  }
  
  deinit {
    observerForWatchApp.stopObserving()
  }
}

extension WatchAppModel: ObserverForWatchAppEventResponder {
  func received(newLatestModelFileURL url: URL) {
    let useCase = saveModelUseCaseFactory(url)
    useCase.execute()
  }
}
