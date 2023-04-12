//
//  Array+Ext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation
import CoreTransferable

struct Archiver {
  let sourceFolderURL: URL
  let archivedFileURL: URL
 
  // TODO: Refactor
  
  // Source: https://gist.github.com/algal/2880f79061197cc54d918631f252cd75
  func archive() throws {
    // TODO: Try archiving in TrainingDataRepository
    
    let fileManager = FileManager.default
    
    try fileManager.removeItem(at: archivedFileURL)
    
    let srcDir: URL
    let srcDirIsTemporary: Bool
    
    // otherwise we need to copy the simple file to a temporary directory in order for
    // NSFileCoordinatorReadingOptions.ForUploading to actually zip it up
    srcDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    try fileManager.createDirectory(at: srcDir, withIntermediateDirectories: true, attributes: nil)
    let tmpURL = srcDir.appendingPathComponent(sourceFolderURL.lastPathComponent)
    try fileManager.copyItem(at: sourceFolderURL, to: tmpURL)
    srcDirIsTemporary = true
    
    let fileCoordinator = NSFileCoordinator()
    var readError: NSError?
    var copyError: NSError?
    var error: NSError?
    
    var readSucceeded:Bool = false
    // coordinateReadingItemAtURL is invoked synchronously, but the passed in zippedURL is only valid
    // for the duration of the block, so it needs to be copied out
    fileCoordinator.coordinate(readingItemAt: srcDir,
                     options: NSFileCoordinator.ReadingOptions.forUploading,
                     error: &readError)
    {
      (zippedURL: URL) -> Void in
      readSucceeded = true
      // assert: read succeeded
      do {
        try fileManager.copyItem(at: zippedURL, to: archivedFileURL)
      } catch let caughtCopyError {
        copyError = caughtCopyError as NSError
      }
    }
    
    if let readError, !readSucceeded {
      // assert: read failed, readError describes our reading error
      NSLog("%@","zipping failed")
      error =  readError
    }
    else if readError == nil && !readSucceeded  {
      NSLog("%@","NSFileCoordinator has violated its API contract. It has errored without throwing an error object")
      error = NSError.init(domain: Bundle.main.bundleIdentifier!, code: 0, userInfo: nil)
    }
    else if let copyError {
      // assert: read succeeded, copy failed
      NSLog("%@","zipping succeeded but copying the zip file failed")
      error = copyError
    }
    
    if srcDirIsTemporary {
      do {
        try fileManager.removeItem(at: srcDir)
      }
      catch {
        // Not going to throw, because we do have a valid output to return. We're going to rely on
        // the operating system to eventually cleanup the temporary directory.
        NSLog("%@","Warning. Zipping succeeded but could not remove temporary directory afterwards")
      }
    }
    if let error { throw error }
  }
}

extension Archiver: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .zip) { zip in
      try zip.archive()
      return SentTransferredFile(zip.archivedFileURL)
    } importing: { received in
      return Self.init(sourceFolderURL: .trainingDataDirectory, archivedFileURL: .trainingDataArchive)
    }
  }
}
