//
//  AlertDetails.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 7.04.23.
//

import SwiftUI

struct AlertDetails {
  struct TextField {
    let placeholder: String
    let text: Binding<String>
  }
  
  struct Button {
    let title: String
    let isCancel: Bool
    let action: () -> Void
  }
  
  let title: String
  let messages: [String]
  let textFields: [TextField]
  let buttons: [Button]
  
  @ViewBuilder
  var body: some View {
    ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
      Text(message)
    }
    ForEach(Array(textFields.enumerated()), id: \.offset) { _, textField in
      SwiftUI.TextField(textField.placeholder, text: textField.text)
    }
    ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
      SwiftUI.Button(button.title, role: button.isCancel ? .cancel : nil, action: button.action)
    }
  }
}

extension AlertDetails {
  init() {
    self.title = ""
    self.messages = []
    self.textFields = []
    self.buttons = []
  }
}

