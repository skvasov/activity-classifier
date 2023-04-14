//
//  ShareTrainingDataUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 14.04.23.
//

import Foundation

class ShareTrainingDataUseCase: UseCase {
  private let trainingDataRepository: TrainingDataRepository
  private let sharingCallback: TrainingDataSharingCallback
  
  init(trainingDataRepository: TrainingDataRepository, sharingCallback: @escaping TrainingDataSharingCallback) {
    self.trainingDataRepository = trainingDataRepository
    self.sharingCallback = sharingCallback
  }
  
  func execute() {
    Task {
      do {
        let url = try await trainingDataRepository.exportTrainingData()
        await MainActor.run {
          self.sharingCallback(.success(url))
        }
      }
      catch {
        await MainActor.run {
          self.sharingCallback(.failure(error))
        }
      }
    }
  }
}
