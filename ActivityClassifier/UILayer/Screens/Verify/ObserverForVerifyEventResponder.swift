//
//  ObserverForVerifyEventResponder.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

protocol ObserverForVerifyEventResponder: AnyObject {
  func received(newState state: VerifyState)
}
