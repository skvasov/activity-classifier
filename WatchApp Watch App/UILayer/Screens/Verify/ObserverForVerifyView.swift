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
  private let latestModel: AnyPublisher<Model, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForVerifyViewEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(verifyState: AnyPublisher<VerifyState, Never>, latestModel: AnyPublisher<Model, Never>) {
    self.verifyState = verifyState
    self.latestModel = latestModel
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    verifyState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.received(newState: state)
      }
      .store(in: &subscriptions)

    latestModel
      .receive(on: DispatchQueue.main)
      .sink { [weak self] model in
        self?.received(newModel: model)
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func received(newState state: VerifyState) {
    eventResponder?.received(newState: state)
  }
  
  func received(newModel model: Model) {
    eventResponder?.received(newModel: model)
  }
}
