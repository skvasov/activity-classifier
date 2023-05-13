//
//  ObserverForActivityClassifierAppEventResponder.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 13.05.23.
//

import Foundation

protocol ObserverForActivityClassifierAppEventResponder: AnyObject {
  func receivedLatestModelRequest()
}
