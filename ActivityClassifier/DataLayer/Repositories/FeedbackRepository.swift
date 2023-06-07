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
  func generateStartFeedback(for duration: Int) async
  func generateFinishFeedback() async
}

class RealFeedbackRepository: NSObject {
  private static let stepInSec: Int = 1
  private static let stepInMillisec: Int = 1000
  
  private var isAudioSessionActive = false
  private lazy var shortBeepPlayer = makeAudioPlayer(fileName: "ShortBeep", withExtension: "wav")
  private lazy var longBeepPlayer = makeAudioPlayer(fileName: "LongBeep", withExtension: "mp3")
  private lazy var finishBeepPlayer = makeAudioPlayer(fileName: "FinishBeep", withExtension: "wav")
  
  private func activateAudioSessionIfNeeded() {
    if !isAudioSessionActive {
      try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try? AVAudioSession.sharedInstance().setActive(true)
      isAudioSessionActive = true
    }
  }
  
  func makeAudioPlayer(fileName: String, withExtension ext: String) -> AVAudioPlayerAsync? {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else { return nil }
    return AVAudioPlayerAsync(fileURL: url, fileTypeHint: ext)
  }
}

extension RealFeedbackRepository: FeedbackRepository {
  func generateStartFeedback(for duration: Int) async {
    
    activateAudioSessionIfNeeded()
    
    for _ in 0..<duration {
      if let beepDuration = await shortBeepPlayer?.play() {
        try? await Task.sleep(for: .milliseconds(Self.stepInMillisec - Int(beepDuration * 1000)))
      }
    }
    await longBeepPlayer?.play()
  }
  
  func generateFinishFeedback() async {
    activateAudioSessionIfNeeded()
    
    await finishBeepPlayer?.play()
  }
}
