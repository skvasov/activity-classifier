//
//  MLModel+Ext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 2.06.23.
//

import CoreML

extension MLModel {
  var predictionWindow: Int? {
    guard
      let creatorDefinedDict = modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey] as? [String: Any],
      let predictionWindowString = creatorDefinedDict["prediction_window"] as? String,
      let predictionWindow = Int(predictionWindowString)
    else { return nil }
    
    return predictionWindow
  }
}

