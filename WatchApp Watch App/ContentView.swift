//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 19.04.23.
//

import SwiftUI

struct ContentView: View {
  
  static var manager = RealWatchConnectvityManager<WatchContext>()
  static var timer: Timer?
  
  init() {
    checkContext()
  }
  
  func checkContext() {
    Self.timer?.invalidate()
    Self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
      Task {
        do {
          let context = try Self.manager.getAppContext()
          print(context)
        }
        catch {
          print(error)
        }
      }
    }
  }
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
