//
//  GetTraiingLabelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

class GetTrainingLabelUseCase: UseCase {
  private let companionAppRepository: CompanionAppRepository
  init(companionAppRepository: CompanionAppRepository) {
    self.companionAppRepository = companionAppRepository
  }
  
  func execute() {
    Task {
      do {
        let label = try await companionAppRepository.getTrainingLabel()
        print(label)
      } catch {
        print(error)
      }
    }
  }
}
