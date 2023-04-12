//
//  Prediction.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation
import CoreML

struct Prediction {
  private enum Keys: String {
    case label = "label"
    case labelProbability = "labelProbability"
  }
  
  private let featureProvider: MLFeatureProvider
  
  var topLabel: String? {
    return featureProvider.featureValue(for: Keys.label.rawValue)?.stringValue
  }
  
  var topProbability: Double? {
    let dict = featureProvider.featureValue(for: Keys.labelProbability.rawValue)?.dictionaryValue
    guard let topLabel else { return nil }
    return dict?[topLabel]?.doubleValue
  }
  
  init(_ featureProvider: MLFeatureProvider) {
    self.featureProvider = featureProvider
  }
}

extension Prediction: Equatable {
  static func == (lhs: Prediction, rhs: Prediction) -> Bool {
    lhs.featureProvider === rhs.featureProvider
  }
}
