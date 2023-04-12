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
