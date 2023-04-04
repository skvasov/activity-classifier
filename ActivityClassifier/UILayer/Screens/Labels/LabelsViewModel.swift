//
//  LabelsViewModel.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 4.04.23.
//

import Foundation
import SwiftUI

class LabelsViewModel: ObservableObject {
  @Published var labels: [TrainingLabel] = []
  @Published var isEditing = false
  @Published var isAddingNewLabel = false
  
  func export() {
    
  }
  
  func add() {
    isAddingNewLabel = true
  }
  
  func save(labelName: String) {
    labels.append(TrainingLabel(name: labelName, numOfRecords: 0))
  }
  
  func edit() {
    isEditing = true
  }
  
  func cancel() {
    isEditing = false
  }
  
  func removeAll() {
    isEditing = false
    labels.removeAll()
  }
  
  func remove(at index: Int) {
    labels.remove(at: index)
  }
}
