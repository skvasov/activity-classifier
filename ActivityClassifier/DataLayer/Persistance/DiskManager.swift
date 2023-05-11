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
    let path = url.path()
    
    if !fileManager.fileExists(atPath: folderURL.path()) {
      try fileManager.createDirectory(atPath: folderURL.path(), withIntermediateDirectories: true)
    }
    
    guard
      fileManager.fileExists(atPath: path, isDirectory: nil) == false
    else {
      throw PersistentStoreError.alreadyExists
    }
    if T.canHaveChildren {
      if let sourceURL = item.url {
        try fileManager.copyItem(at: sourceURL, to: url)
      } else {
        try fileManager.createDirectory(atPath: url.path(), withIntermediateDirectories: true)
      }
    } else {
      try fileManager.createDirectory(atPath: url.deletingLastPathComponent().path(), withIntermediateDirectories: true)
      if let sourceURL = item.url {
        try fileManager.copyItem(at: sourceURL, to: url)
      } else {
        fileManager.createFile(atPath: url.path(), contents: item.content)
      }
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
        let url = folderURL.appending(path: name, directoryHint: T.canHaveChildren ? .isDirectory : .notDirectory)
        return T(name: name, numOfChildren: numOfChildren, url: url)
      }
  }
  
  func remove(_ items: [T]) async throws {
    try items.forEach { item in
      let url = folderURL.appending(path: item.name)
      try fileManager.removeItem(at: url)
    }
  }
}
