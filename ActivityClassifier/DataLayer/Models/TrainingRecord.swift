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
  var content: Data? = nil
  static var canHaveChildren = false
  
  init(name: String, numOfChildren: Int) {
    self.name = name
    self.numOfChildren = numOfChildren
  }
}
