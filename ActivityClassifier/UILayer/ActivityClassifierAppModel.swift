//
//  ActivityClassifierAppModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

class ActivityClassifierAppModel {
  private let observerForActivityClassifierApp: Observer
  private let startWatchAppUseCase: UseCase
  private let sendModelUseCase: UseCase
  private let clearCacheUseCase: UseCase
  private let updateWatchContextUseCase: UseCase
  private var isAppeared = false
  
  init(observerForActivityClassifierApp: Observer, startWatchAppUseCase: UseCase, sendModelUseCase: UseCase, clearCacheUseCase: UseCase, updateWatchContextUseCase: UseCase) {
    self.observerForActivityClassifierApp = observerForActivityClassifierApp
    self.startWatchAppUseCase = startWatchAppUseCase
    self.sendModelUseCase = sendModelUseCase
    self.clearCacheUseCase = clearCacheUseCase
    self.updateWatchContextUseCase = updateWatchContextUseCase
  }
  
  func onAppear() {
    observerForActivityClassifierApp.startObserving()
    
    if !isAppeared {
      self.isAppeared = true
      clearCacheUseCase.execute()
    }
    
    startWatchAppUseCase.execute()
  }
  
  deinit {
    observerForActivityClassifierApp.stopObserving()
  }
}

extension ActivityClassifierAppModel: ObserverForActivityClassifierAppEventResponder {
  func receivedLatestModelRequest() {
    sendModelUseCase.execute()
  }
  
  func receivedSelectedTrainingLabel() {
    updateWatchContextUseCase.execute()
  }
}
