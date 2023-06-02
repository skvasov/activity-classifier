//
//  ObserverForTrainingRecords.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation
import Combine

class ObserverForTrainingRecords: Observer {
  private let trainingRecordsState: AnyPublisher<TrainingRecordsState, Never>
  private let trainingRecordFile: AnyPublisher<URL, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForTrainingRecordsEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(trainingRecordsState: AnyPublisher<TrainingRecordsState, Never>, trainingRecordFile: AnyPublisher<URL, Never>) {
    self.trainingRecordsState = trainingRecordsState
    self.trainingRecordFile = trainingRecordFile
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    trainingRecordsState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)
    
    trainingRecordFile
      .receive(on: DispatchQueue.main)
      .sink { [weak self] fileURL in
        self?.received(newTrainingRecordFile: fileURL)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: TrainingRecordsState) {
    eventResponder?.received(newState: state)
  }
  
  func received(newTrainingRecordFile fileURL: URL) {
    eventResponder?.received(newTrainingRecordFile: fileURL)
  }
}
