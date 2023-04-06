//
//  ObserverForLabels.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation
import Combine

class ObserverForLabels: Observer {
  private let labelsState: AnyPublisher<LabelsState, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForLabelsEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(labelsState: AnyPublisher<LabelsState, Never>) {
    self.labelsState = labelsState
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    labelsState
      .receive(on: DispatchQueue.main)
      .removeDuplicates(by: LabelsState.sameCase)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: LabelsState) {
    eventResponder?.received(newState: state)
  }
}
