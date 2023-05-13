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
  
  
  init(observerForWatchApp: Observer, getLatestModelUseCase: UseCase) {
    self.observerForWatchApp = observerForWatchApp
    self.getLatestModelUseCase = getLatestModelUseCase
  }
  
  func onAppear() {
    observerForWatchApp.startObserving()
    getLatestModelUseCase.execute()
  }
  
  deinit {
    observerForWatchApp.stopObserving()
  }
}

extension WatchAppModel: ObserverForWatchAppEventResponder {
  func received(newLatestModelFileURL url: URL) {
    
  }
}
