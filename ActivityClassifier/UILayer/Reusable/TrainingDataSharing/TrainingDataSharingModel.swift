//
//  TrainingDataSharingModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation
import CoreTransferable

class TrainingDataSharingModel {
  private let shareTrainingDataUseCaseFactory: ShareTrainingDataUseCaseFactory
  
  init(shareTrainingDataUseCaseFactory: @escaping ShareTrainingDataUseCaseFactory) {
    self.shareTrainingDataUseCaseFactory = shareTrainingDataUseCaseFactory
  }
  
  func export(with continuation: CheckedContinuation<SentTransferredFile, Error>) {
    let useCase = shareTrainingDataUseCaseFactory { result in
      switch result {
      case .success(let url):
        continuation.resume(returning: SentTransferredFile(url))
      case .failure(let error):
        continuation.resume(throwing: error)
      }
    }
    useCase.execute()
  }
}

extension TrainingDataSharingModel: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    FileRepresentation(contentType: .zip) { model in
      return try await withCheckedThrowingContinuation { continuation in
        model.export(with: continuation)
      }
    } importing: { received in
      return AppDependencyContainer().makeTrainingDataSharingModel()
    }
  }
}
