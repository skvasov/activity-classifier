//
//  ObserverForWatchAppEventResponder.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 13.05.23.
//

import Foundation

protocol ObserverForWatchAppEventResponder: AnyObject {
  func received(newLatestModelFileURL url: URL)
}
