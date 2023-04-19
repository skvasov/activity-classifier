//
//  ActivityClassifierAppModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

class ActivityClassifierAppModel {
  private let startWatchAppUseCase: StartWatchAppUseCase
  
  init(startWatchAppUseCase: StartWatchAppUseCase) {
    self.startWatchAppUseCase = startWatchAppUseCase
  }
  
  func onAppear() {
    startWatchAppUseCase.execute()
  }
}
