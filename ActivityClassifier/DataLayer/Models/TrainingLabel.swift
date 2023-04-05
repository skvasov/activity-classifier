//
//  TrainingLabel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation

struct TrainingLabel: Hashable, Equatable, Storable {
  var name: String
  var numOfChildren: Int
  var content: Data?
  
  static var canHaveChildren = true
  
  init(name: String, numOfChildren: Int) {
    self.name = name
    self.numOfChildren = numOfChildren
  }
}
