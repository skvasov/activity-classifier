//
//  ObserverForWatchApp.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 13.05.23.
//

import Foundation
import Combine

class ObserverForWatchApp: Observer {
  private let latestModelFile: AnyPublisher<URL, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForWatchAppEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(latestModelFile: AnyPublisher<URL, Never>) {
    self.latestModelFile = latestModelFile
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    latestModelFile
      .receive(on: DispatchQueue.main)
      .sink { [weak self] url in
        self?.received(newLatestModelFileURL: url)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newLatestModelFileURL url: URL) {
    eventResponder?.received(newLatestModelFileURL: url)
  }
}
