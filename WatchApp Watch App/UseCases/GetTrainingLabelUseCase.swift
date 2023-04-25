//
//  GetTraiingLabelUseCase.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

class GetTrainingLabelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let companionAppRepository: CompanionAppRepository
  
  init(actionDispatcher: ActionDispatcher, companionAppRepository: CompanionAppRepository) {
    self.actionDispatcher = actionDispatcher
    self.companionAppRepository = companionAppRepository
  }
  
  func execute() {
    Task {
      actionDispatcher.dispatchOnMain(RecordActions.GetTrainingLabel())
      do {
        let label = try await companionAppRepository.getTrainingLabel()
        actionDispatcher.dispatchOnMain(RecordActions.GotTrainingLabel(label: label))
      } catch {
        let errorMessage = ErrorMessage(error: error)
        actionDispatcher.dispatchOnMain(RecordActions.GettingTrainingLabelFailed(error: errorMessage))
      }
    }
  }
}
