//
//  ActionDispatcher.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation
import ReSwift

public protocol ActionDispatcher {

  func dispatch(_ action: Action)
}

extension Store: ActionDispatcher {
}
