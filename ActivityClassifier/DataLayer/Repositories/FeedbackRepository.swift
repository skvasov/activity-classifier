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
  
#if os(iOS)
  private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
#endif
}

extension RealFeedbackRepository: FeedbackRepository {
  func generateFeedback(for duration: Int) async {
    Task {
      guard let shortBeepURL = Bundle.main.url(forResource: "ShortBeep", withExtension: "mp3") else { return }
      guard let longBeepURL = Bundle.main.url(forResource: "LongBeep", withExtension: "mp3") else { return }
      
      try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try? AVAudioSession.sharedInstance().setActive(true)
      
      
      let shortBeepPlayer = try? AVAudioPlayer(contentsOf: shortBeepURL, fileTypeHint: AVFileType.mp3.rawValue)
      let longBeepPlayer = try? AVAudioPlayer(contentsOf: longBeepURL, fileTypeHint: AVFileType.mp3.rawValue)
      
      for second in 0..<duration {
        
        let player = second < duration - Self.stepInSec ? shortBeepPlayer : longBeepPlayer
        player?.play()
#if os(iOS)
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
