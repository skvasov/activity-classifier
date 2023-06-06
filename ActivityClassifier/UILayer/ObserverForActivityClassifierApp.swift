//
//  ObserverForActivityClassifierApp.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 13.05.23.
//

import Foundation
import Combine

class ObserverForActivityClassifierApp: Observer {
  private let latestModelRequest: AnyPublisher<Void, Never>
  private let selectedTrainingLabel: AnyPublisher<TrainingLabel?, Never>
  private var subscriptions = Set<AnyCancellable>()
  private var isObserving: Bool { !subscriptions.isEmpty }
  
  weak var eventResponder: ObserverForActivityClassifierAppEventResponder? {
    willSet {
      if newValue == nil {
        stopObserving()
      }
    }
  }
  
  init(latestModelRequest: AnyPublisher<Void, Never>, selectedTrainingLabel: AnyPublisher<TrainingLabel?, Never>) {
    self.latestModelRequest = latestModelRequest
    self.selectedTrainingLabel = selectedTrainingLabel
  }
  
  func startObserving() {
    guard isObserving == false else { return }
    
    latestModelRequest
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.receivedLatestModelRequest()
      }
      .store(in: &subscriptions)
    
    selectedTrainingLabel
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.receivedSelectedTrainingLabel()
      }
      .store(in: &subscriptions)
  }
  
  func stopObserving() {
    subscriptions.removeAll()
  }
  
  func receivedLatestModelRequest() {
    eventResponder?.receivedLatestModelRequest()
  }
  
  func receivedSelectedTrainingLabel() {
    eventResponder?.receivedSelectedTrainingLabel()
  }
}
