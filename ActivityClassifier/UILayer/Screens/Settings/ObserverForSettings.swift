//
//  ObserverForSettings.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation
import Combine

class ObserverForSettings: Observer {
  private let settingsState: AnyPublisher<SettingsState, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForSettingsEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(settingsState: AnyPublisher<SettingsState, Never>) {
    self.settingsState = settingsState
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    settingsState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: SettingsState) {
    eventResponder?.received(newState: state)
  }
}
