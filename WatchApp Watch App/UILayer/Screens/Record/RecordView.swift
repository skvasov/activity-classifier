//
//  RecordView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import SwiftUI

struct RecordView: View {
  let model: RecordViewModel
  
  init(model: RecordViewModel) {
    self.model = model
  }
  
  var body: some View {
    Text("Record!")
      .onAppear {
        model.onAppear()
      }
  }
}

struct RecordView_Previews: PreviewProvider {
  static var previews: some View {
    WatchAppDependencyContainer().makeRecordView()
  }
}
