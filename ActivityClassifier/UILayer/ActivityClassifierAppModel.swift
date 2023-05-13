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
  
  init(observerForActivityClassifierApp: Observer, startWatchAppUseCase: UseCase, sendModelUseCase: UseCase) {
    self.observerForActivityClassifierApp = observerForActivityClassifierApp
    self.startWatchAppUseCase = startWatchAppUseCase
    self.sendModelUseCase = sendModelUseCase
  }
  
  func onAppear() {
    observerForActivityClassifierApp.startObserving()
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
}
