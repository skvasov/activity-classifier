//
//  FeedbackRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 17.04.23.
//

import Foundation
import UIKit
import AVFoundation

protocol FeedbackRepository {
  func generateFeedback(for duration: Int) async
}

class RealFeedbackRepository {
  private static let stepInSec: Int = 1
  private static let stepInMillisec: Int = 1000
  
  private enum SystemSound: UInt32 {
    case shortBeep = 1117
    case longBeep = 1118
  }
  
#if os(iOS)
  private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
#endif
}

extension RealFeedbackRepository: FeedbackRepository {
  func generateFeedback(for duration: Int) async {
    Task {
      for second in 0..<duration {
        //TODO: generate feedback for apple watch
#if os(iOS)
        let sound = second < duration - Self.stepInSec ? SystemSound.shortBeep : SystemSound.longBeep
        AudioServicesPlaySystemSound(sound.rawValue)
        if second == duration - Self.stepInSec {
          await hapticFeedbackGenerator.impactOccurred()
        }
#endif
        let delay = second == duration - (Self.stepInSec * 2) ? Self.stepInMillisec + Self.stepInMillisec / 2 : Self.stepInMillisec
        try? await Task.sleep(for: .milliseconds(delay))
      }
    }
    
    try? await Task.sleep(for: .seconds(duration))
  }
}
