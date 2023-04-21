//
//  RecordView.swift
//  WatchApp Watch App
//
//  Created by Sergei Kvasov on 21.04.23.
//

import SwiftUI

struct RecordView: View {
  let model: RecordsViewModel
  
  init(model: RecordsViewModel) {
    self.model = model
  }
  
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

struct RecordView_Previews: PreviewProvider {
  static var previews: some View {
    WatchAppDependencyContainer().makeRecordView()
  }
}
