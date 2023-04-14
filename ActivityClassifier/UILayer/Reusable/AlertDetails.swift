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
  let message: String?
  let textFields: [TextField]
  let buttons: [Button]
  
  @ViewBuilder
  var actions: some View {
    ForEach(Array(textFields.enumerated()), id: \.offset) { _, textField in
      SwiftUI.TextField(textField.placeholder, text: textField.text)
    }
    ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
      SwiftUI.Button(button.title, role: button.isCancel ? .cancel : nil, action: button.action)
    }
  }
  
  @ViewBuilder
  var messageView: some View {
    Text(message ?? "")
  }
}

extension AlertDetails {
  init() {
    self.title = ""
    self.message = nil
    self.textFields = []
    self.buttons = []
  }
  
  init(error: ErrorMessage, completion: @escaping () -> Void) {
    self.title = "Error"
    self.message = error.message
    self.textFields = []
    self.buttons = [
      AlertDetails.Button(title: "OK", isCancel: true, action: {
        completion()
      })
    ]
  }
}

