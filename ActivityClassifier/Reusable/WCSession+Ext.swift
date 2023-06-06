//
//  WCSession+Ext.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.06.23.
//

import WatchConnectivity

extension WCSession {
  enum Keys: String {
    case timestamp
    case context
  }
  
  var contextData: Data? {
    guard let setTimeInterval = applicationContext[Keys.timestamp.rawValue] as? TimeInterval
    else {
      return receivedApplicationContext[Keys.context.rawValue] as? Data
    }
    guard let receivedTimeInterval = receivedApplicationContext[Keys.timestamp.rawValue] as? TimeInterval
    else {
      return applicationContext[Keys.context.rawValue] as? Data
    }
    
    return setTimeInterval > receivedTimeInterval
      ? applicationContext[Keys.context.rawValue] as? Data
      : receivedApplicationContext[Keys.context.rawValue] as? Data
  }
}
