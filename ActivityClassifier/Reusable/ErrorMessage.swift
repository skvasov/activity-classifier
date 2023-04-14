//
//  ErrorMessage.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation

struct ErrorMessage: Error, Hashable {
  let message: String
}

extension ErrorMessage {
  init(error: Error) {
    self.message = error.localizedDescription
  }
}
