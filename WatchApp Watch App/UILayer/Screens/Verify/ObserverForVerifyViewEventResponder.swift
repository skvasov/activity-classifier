//
//  ObserverForVerifyViewEventResponder.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

protocol ObserverForVerifyViewEventResponder: AnyObject {
  func received(newState state: VerifyState)
}
