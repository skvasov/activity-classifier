//
//  ObserverForSettingsEventResponder.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

protocol ObserverForSettingsEventResponder: AnyObject {
  func received(newState state: SettingsState)
}
