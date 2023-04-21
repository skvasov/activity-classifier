//
//  WatchAppRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 19.04.23.
//

import Foundation

protocol WatchAppRepository {
  func startWatchApp() async throws
  func updateAppContext(_ context: WatchContext) async throws
  func getAppContext() throws -> WatchContext?
}

class RealWatchAppRepository {
  private let connectivityManager: any WatchConnectvityManager<WatchContext>
  
  init(connectivityManager: any WatchConnectvityManager<WatchContext>) {
    self.connectivityManager = connectivityManager
  }
}

extension RealWatchAppRepository: WatchAppRepository {
  func startWatchApp() async throws {
    try await connectivityManager.startWatchApp()
  }
  
  func updateAppContext(_ context: WatchContext) async throws {
    try await connectivityManager.updateAppContext(context)
  }
  
  func getAppContext() throws -> WatchContext? {
    try connectivityManager.getAppContext()
  }
}
