//
//  ObserverForRecordView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import Combine

class ObserverForRecordView: Observer {
  private let recordState: AnyPublisher<RecordState, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForRecordViewEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(recordState: AnyPublisher<RecordState, Never>) {
    self.recordState = recordState
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    recordState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: RecordState) {
    eventResponder?.received(newState: state)
  }
}
