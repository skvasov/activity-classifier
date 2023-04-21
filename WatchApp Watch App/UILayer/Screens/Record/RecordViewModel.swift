//
//  RecordsViewModel.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

class RecordViewModel: ObservableObject {
  private let observerForRecord: Observer
  private let getTrainingLabelUseCase: GetTrainingLabelUseCase
  
  init(observerForRecord: Observer, getTrainingLabelUseCase: GetTrainingLabelUseCase) {
    self.observerForRecord = observerForRecord
    self.getTrainingLabelUseCase = getTrainingLabelUseCase
  }
  
  func onAppear() {
    observerForRecord.startObserving()
    getTrainingLabelUseCase.execute()
  }
  
  deinit {
    observerForRecord.stopObserving()
  }
}

extension RecordViewModel: ObserverForRecordViewEventResponder {
  func received(newState state: RecordState) {
    
  }
}


