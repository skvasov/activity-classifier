//
//  File.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

struct TrainingRecord: Equatable, Storable {
  var name: String
  var numOfChildren: Int
  var content: Data?
  var url: URL?
  
  static var canHaveChildren = false
}

extension TrainingRecord {
  init(content: Data) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    self.name = dateFormatter.string(from: Date()) + ".json"
    self.numOfChildren = 0
    self.content = content
  }
}
