//
//  WatchContext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 18.04.23.
//

import Foundation

struct WatchContext {
  let label: TrainingLabel?
  let model: Model?
}

extension WatchContext: DictionaryCodable {
  private enum Keys: String {
    case label
    case model
  }
  var dictionary: [String : Any] {
    [
      Keys.label.rawValue: label as Any,
      Keys.model.rawValue: model as Any
    ]
  }
  
  init(_ dictionary: [String : Any]) throws {
    self.label = dictionary[Keys.label.rawValue] as? TrainingLabel
    self.model = dictionary[Keys.model.rawValue] as? Model
  }
}
