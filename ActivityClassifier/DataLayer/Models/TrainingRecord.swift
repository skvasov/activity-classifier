//
//  File.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

struct TrainingRecord: Equatable, Storable {
  private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
  
  var name: String
  var numOfChildren: Int
  var content: Data?
  var url: URL?
  
  static var canHaveChildren = false
}

extension TrainingRecord {
  init(content: Data) {
    self.name = Self.makeName()
    self.numOfChildren = 0
    self.content = content
  }
  
  static func makeName() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Self.dateFormat
    return dateFormatter.string(from: Date()) + ".json"
  }
}
