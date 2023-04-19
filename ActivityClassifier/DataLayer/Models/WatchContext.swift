//
//  WatchContext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 18.04.23.
//

import Foundation

struct WatchContext {
  var label: TrainingLabel?
}

extension WatchContext: DictionaryCodable {
  private enum Keys: String {
    case label
  }
  var dictionary: [String : Any] {
    [
      Keys.label.rawValue: label as Any
    ]
  }
  
  init(_ dictionary: [String : Any]) throws {
    self.label = dictionary[Keys.label.rawValue] as? TrainingLabel
  }
}
