//
//  URL+Ext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation

extension URL {
  static var trainingDataDirectory: URL {
    documentsDirectory.appending(path: "training_data")
  }
  
  static var trainingDataArchive: URL {
    documentsDirectory.appending(path: "archive").appendingPathExtension("zip")
  }
  
  static var modelsDirectory: URL {
    documentsDirectory.appending(path: "models")
  }
  
  static var modelArchive: URL {
    temporaryDirectory.appending(path: "model").appendingPathExtension("zip")
  }
}
