//
//  DiskManager.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

class DiskManager<T: Storable> {
  private let fileManager = FileManager.default
  private let folderURL: URL
  
  init(folderURL: URL) {
    self.folderURL = folderURL
  }
}

extension DiskManager: PersistentStore {
  func save(_ item: T) async throws {
    let url = folderURL.appending(path: item.name)
    if type(of: item).canHaveChildren {
      try fileManager.createDirectory(atPath: url.path(), withIntermediateDirectories: true)
    } else {
      fileManager.createFile(atPath: url.path(), contents: item.content)
    }
  }
  
  func loadAll() async throws -> [T] {
    try fileManager.contentsOfDirectory(atPath: folderURL.path())
      .map { name in
        var numOfChildren = 0
        if T.canHaveChildren {
          let path = folderURL.appending(path: name).path()
          let contents = try fileManager.contentsOfDirectory(atPath: path)
          numOfChildren = contents.count
        }
        return T(name: name, numOfChildren: numOfChildren)
      }
  }
  
  func remove(_ items: [T]) async throws {
    try items.forEach { item in
      let url = folderURL.appending(path: item.name)
      try fileManager.removeItem(at: url)
    }
  }
}