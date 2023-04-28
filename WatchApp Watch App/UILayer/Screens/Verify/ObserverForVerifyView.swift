//
//  ObserverForVerifyView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation
import Combine

class ObserverForVerifyView: Observer {
  private let verifyState: AnyPublisher<VerifyState, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForVerifyViewEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(verifyState: AnyPublisher<VerifyState, Never>) {
    self.verifyState = verifyState
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    verifyState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)

  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: VerifyState) {
    eventResponder?.received(newState: state)
  }
}
