//
//  ScopedState.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

enum ScopedState<StateType: Equatable>: Equatable {
  case outOfScope
  case inScope(StateType)
}
