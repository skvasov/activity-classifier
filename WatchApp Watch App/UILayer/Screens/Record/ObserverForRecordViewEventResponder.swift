//
//  ObserverForRecordViewEventResponder.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import Foundation

protocol ObserverForRecordViewEventResponder: AnyObject {
  func received(newState state: RecordState)
  func received(newWatchContext context: WatchContext)
}
