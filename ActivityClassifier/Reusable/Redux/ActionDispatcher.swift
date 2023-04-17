//
//  ActionDispatcher.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation
import ReSwift

public protocol ActionDispatcher {

  func dispatchOnMain(_ action: Action)
}

extension Store: ActionDispatcher {
  public func dispatchOnMain(_ action: Action) {
    Task {
      await MainActor.run {
        dispatch(action)
      }
    }
  }
}
