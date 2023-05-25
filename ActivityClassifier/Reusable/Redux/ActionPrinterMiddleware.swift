//
//  ActionPrinterMiddleware.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 5.04.23.
//

import Foundation
import ReSwift

#if os(iOS)
let printActionMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
      print("\(action), Action dispatched")
      next(action)
      let stateString = String(describing: getState())
        .replacingOccurrences(of: "Optional", with: "")
        .replacingOccurrences(of: "ActivityClassifier.", with: "")
      print("new state: \n\(stateString)")
      return
    }
  }
}
#endif


#if os(watchOS)
let printActionMiddleware: Middleware<WatchAppState> = { dispatch, getState in
  return { next in
    return { action in
    print("\(action), Action dispatched")
      next(action)
      let stateString = String(describing: getState())
        .replacingOccurrences(of: "Optional", with: "")
        .replacingOccurrences(of: "ActivityClassifier.", with: "")
      print("new state: \n\(stateString)")
      return
    }
  }
}
#endif
