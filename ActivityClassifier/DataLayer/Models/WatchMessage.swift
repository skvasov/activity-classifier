//
//  WatchMessage.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 13.05.23.
//

import Foundation

struct WatchMessage: Codable {
  enum `Type`: Int, Codable {
    case latestModelRequest
  }
  
  var type: `Type`
}
