//
//  ObserverForLabelsEventResponder.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

protocol ObserverForLabelsEventResponder: AnyObject {
  func received(newState state: LabelsState)
}
