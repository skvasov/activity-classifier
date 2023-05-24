//
//  ImportModelFileUseCase.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 12.04.23.
//

import Foundation

class SaveModelUseCase: UseCase {
  private let actionDispatcher: ActionDispatcher
  private let importResult: Result<URL, Error>
  private let modelRepository: ModelRepository
  private let watchAppRepository: WatchAppRepository
  
  init(actionDispatcher: ActionDispatcher, importResult: Result<URL, Error>, modelRepository: ModelRepository, watchAppRepository: WatchAppRepository) {
    self.actionDispatcher = actionDispatcher
    self.importResult = importResult
    self.modelRepository = modelRepository
    self.watchAppRepository = watchAppRepository
  }
  
  func execute() {
    Task {
      // TODO: Check for bg thread?
      await MainActor.run {
        actionDispatcher.dispatchOnMain(VerifyActions.SaveModel())
      }
      switch importResult {
      case .success(var url):
        do {
          _ = url.startAccessingSecurityScopedResource()
          
          let modelToSave = Model(url: url)
          try await modelRepository.save(modelToSave)
          
          url.stopAccessingSecurityScopedResource()
          url.removeAllCachedResourceValues()
          
          let model = try await modelRepository.load()
          
          if let model {
            try await watchAppRepository.sendModel(model)
          }
          
          actionDispatcher.dispatchOnMain(VerifyActions.SavedModel(model: model))
        } catch {
          dispatch(error: error)
        }
      case .failure(let error):
        dispatch(error: error)
      }
    }
  }
  
  private func dispatch(error: Error) {
    let errorMessage = ErrorMessage(error: error)
    actionDispatcher.dispatchOnMain(VerifyActions.SavingModelFailed(error: errorMessage))
  }
}
