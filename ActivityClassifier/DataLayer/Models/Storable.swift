//
//  Storable.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

protocol Storable: Codable {
  var name: String { get set }
  var numOfChildren: Int { get set }
  var content: Data? { get set }
  var url: URL? { get set }
  static var canHaveChildren: Bool { get }
  
  init(name: String, numOfChildren: Int, content: Data?, url: URL?)
}

extension Storable {
  init(url: URL) {
    self = Self(name: url.lastPathComponent, numOfChildren: 0, content: nil, url: url)
  }
  
  init(name: String, numOfChildren: Int, url: URL) {
    self = Self(name: name, numOfChildren: numOfChildren, content: nil, url: url)
  }
  
  init(name: String, numOfChildren: Int, content: Data) {
    self = Self(name: name, numOfChildren: numOfChildren, content: content, url: nil)
  }
  
  init(name: String, numOfChildren: Int) {
    self = Self(name: name, numOfChildren: numOfChildren, content: nil, url: nil)
  }
}
