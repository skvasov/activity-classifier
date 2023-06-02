//
//  FileCacheManager.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 2.06.23.
//

import Foundation

protocol FileCacheManager {
  func clearCache()
  func makeFileCopy(for sourceURL: URL) throws -> URL
  func createTemporaryDirectory() throws -> URL
}

class RealFileCacheManager: FileCacheManager {
  private let fileManager = FileManager.default
  private let fileCacheDirectory: URL
  
  init(fileCacheDirectory: URL) {
    self.fileCacheDirectory = fileCacheDirectory
  }
  
  func clearCache() {
    try? fileManager.contentsOfDirectory(at: fileCacheDirectory, includingPropertiesForKeys: nil).forEach { url in
      try? fileManager.removeItem(at: url)
    }
  }
  
  func makeFileCopy(for sourceURL: URL) throws -> URL {
    let copyDirectory = try createTemporaryDirectory()
    let copyURL = copyDirectory.appending(path: sourceURL.lastPathComponent)
    try fileManager.copyItem(at: sourceURL, to: copyURL)
    return copyURL
  }
  
  func createTemporaryDirectory() throws -> URL {
    let tempDirectory = fileCacheDirectory.appending(path: UUID().uuidString)
    try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    return tempDirectory
  }
}
