//
//  String+Ext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 17.04.23.
//

import Foundation

extension String {
  var isAlphanumeric: Bool {
    return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
  }
}
