//
//  ObserverForTrainingRecordsEventResponder.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 6.04.23.
//

import Foundation

protocol ObserverForTrainingRecordsEventResponder: AnyObject {
  func received(newState state: TrainingRecordsState)
  func received(newTrainingRecordFile fileURL: URL)
}
