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
  
  init(actionDispatcher: ActionDispatcher, importResult: Result<URL, Error>, modelRepository: ModelRepository) {
    self.actionDispatcher = actionDispatcher
    self.importResult = importResult
    self.modelRepository = modelRepository
  }
  
  func execute() {
    Task {
      // TODO: Check for bg thread?
      await MainActor.run {
        actionDispatcher.dispatchOnMain(VerifyActions.SaveModel())
      }
      switch importResult {
      case .success(let url):
        do {
          try await modelRepository.removeAll()
        } catch let error as NSError where error.code == 260 {
          // Do nothing, models folder doesn't exist
        } catch {
          dispatch(error: error)
        }
        
        do {
          _ = url.startAccessingSecurityScopedResource()
          let data = try Data(contentsOf: url)
          url.stopAccessingSecurityScopedResource()
          let model = Model(name: url.lastPathComponent, numOfChildren: 0, content: data)
          try await modelRepository.save(model)
          let firstModel = try await modelRepository.loadAll().first
          
          actionDispatcher.dispatchOnMain(VerifyActions.SavedModel(model: firstModel))
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
