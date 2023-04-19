//
//  PersistentStore.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

enum PersistentStoreError: Error {
  case alreadyExists
}

protocol PersistentStore<Item> {
  associatedtype Item: Storable
  
  func save(_ item: Item) async throws
  func loadAll() async throws -> [Item]
  func remove(_ items: [Item]) async throws
}
