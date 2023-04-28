//
//  Settings.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

struct Settings: Storable, Codable, Equatable {
  enum Default {
    static let frequency = 50
    static let predictionWindow = 100
    static let delay = 0
  }
  
  var name = "settings"
  var numOfChildren = 0
  var content: Data? = nil
  var url: URL? = nil
  
  static var canHaveChildren: Bool = false
  
  var frequency: Int
  var predictionWindow: Int
  var delay: Int
}

extension Settings {
  init(name: String, numOfChildren: Int, content: Data?, url: URL?) {
    self.name = name
    self.numOfChildren = numOfChildren
    self.content = content
    self.url = url
    self.frequency = 0
    self.predictionWindow = 0
    self.delay = 0
  }
}

extension Settings {
  static var `default`: Settings {
    .init(
      frequency: Settings.Default.frequency,
      predictionWindow: Settings.Default.predictionWindow,
      delay: Settings.Default.delay)
  }
}

