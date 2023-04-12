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
  var url: URL?
  
  static var canHaveChildren = true
}
