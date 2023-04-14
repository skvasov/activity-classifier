//
//  SettingsRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

protocol SettingsRepository {
  func save(_ settings: Settings) async throws
  func load() async throws -> Settings?
}

class RealSettingsRepository {
  private let settingsStore: any PersistentStore<Settings>
  
  init(settingsStore: any PersistentStore<Settings>) {
    self.settingsStore = settingsStore
  }
}

extension RealSettingsRepository: SettingsRepository {
  func save(_ settings: Settings) async throws {
    let allSettings = try await settingsStore.loadAll()
    try await settingsStore.remove(allSettings)
    try await settingsStore.save(settings)
  }
  
  func load() async throws -> Settings? {
    try await settingsStore.loadAll().first
  }
}
