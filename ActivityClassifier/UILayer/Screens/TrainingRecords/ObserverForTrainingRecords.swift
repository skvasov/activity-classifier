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
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForTrainingRecordsEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(trainingRecordsState: AnyPublisher<TrainingRecordsState, Never>) {
    self.trainingRecordsState = trainingRecordsState
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    trainingRecordsState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: TrainingRecordsState) {
    eventResponder?.received(newState: state)
  }
}
