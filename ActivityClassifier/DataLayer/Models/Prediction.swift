//
//  Prediction.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation
import CoreML

struct Prediction {
  private let featureProvider: MLFeatureProvider
  lazy var topFeatureName: String? = {
    var topFeatureName: String? = nil
    var topValue: Double = 0
    
    featureProvider.featureNames.forEach { featureName in
      let featureValue = featureProvider.featureValue(for: featureName)
      if let value = featureValue?.doubleValue, value > topValue {
        topValue = value
        topFeatureName = featureName
      }
    }
    
    guard let topFeatureName else { return nil }
    return topFeatureName
  }()
  
  lazy var topValue: Double? = {
    guard
      let topFeatureName,
      let value = featureProvider.featureValue(for: topFeatureName)?.doubleValue
    else { return nil }
    
    return value
  }()
  
  init(_ featureProvider: MLFeatureProvider) {
    self.featureProvider = featureProvider
  }
}
