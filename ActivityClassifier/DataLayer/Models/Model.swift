//
//  Model.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

struct Model: Equatable, Storable {
  var name: String
  var numOfChildren: Int
  var content: Data? = nil
  var url: URL?
  
  static var canHaveChildren = false
}
