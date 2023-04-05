//
//  PersistentStore.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

protocol Storable: Codable {
  var name: String { get }
  var numOfChildren: Int { get }
  var content: Data? { get }
  static var canHaveChildren: Bool { get }
  
  init(name: String, numOfChildren: Int)
}

protocol PersistentStore<Item> {
  associatedtype Item: Storable
  
  func save(_ item: Item) async throws
  func loadAll() async throws -> [Item]
  func remove(_ items: [Item]) async throws
}
