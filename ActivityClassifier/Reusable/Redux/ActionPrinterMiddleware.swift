//
//  ActionPrinterMiddleware.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation
import ReSwift

let printActionMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      print("\(action), Action dispatched")
      next(action)
      print("new state: \n\(String(describing: getState()))")
      return
    }
  }
}
