//
//  UserDefaultsManager.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

class UserDefaultsManager<T: Storable> {
  private let userDefaults = UserDefaults.standard
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
}

extension UserDefaultsManager: PersistentStore {
  func save(_ item: T) async throws {
    let data = try encoder.encode(item)
    userDefaults.set(data, forKey: item.name)
    userDefaults.synchronize()
  }
  
  func loadAll() async throws -> [T] {
    userDefaults.dictionaryRepresentation().keys
      .compactMap { userDefaults.data(forKey: $0) }
      .compactMap { try? decoder.decode(T.self, from: $0) }
  }
  
  func remove(_ items: [T]) async throws {
    items.forEach { item in
      userDefaults.removeObject(forKey: item.name)
    }
    userDefaults.synchronize()
  }
}
