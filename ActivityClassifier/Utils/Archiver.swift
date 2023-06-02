//
//  Array+Ext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation
import Zip

protocol Archiver {
  var sourceURL: URL { get }
  var destinationURL: URL { get }
  
  func archive() async throws
  func unarchive() async throws
}

struct RealArchiver: Archiver {
  let sourceURL: URL
  let destinationURL: URL
  
  func archive() async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      do {
        try Zip.zipFiles(paths: [sourceURL], zipFilePath: destinationURL, password: nil) { progress in
          if progress == 1 {
            continuation.resume(returning: ())
          }
        }
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
  
  func unarchive() async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      do {
        try Zip.unzipFile(sourceURL, destination: destinationURL, overwrite: true, password: nil) { progress in
          if progress == 1 {
            continuation.resume(returning: ())
          }
        }
      } catch {
        continuation.resume(throwing: error)
      }
    }
    
  }
}
