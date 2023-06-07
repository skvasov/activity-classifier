//
//  AVAudioPlayerAsync.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 7.06.23.
//

import AVFoundation

class AVAudioPlayerAsync: NSObject {
  private let player: AVAudioPlayer?
  private var startDate: Date?
  private var continuation: CheckedContinuation<TimeInterval, Never>?
  
  init?(fileURL url: URL, fileTypeHint hint: String) {
    player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: hint)
    player?.prepareToPlay()
  }

  @discardableResult
  func play() async -> TimeInterval {
    player?.delegate = self
    return await withCheckedContinuation { [weak self] continuation in
      self?.continuation = continuation
      self?.startDate = Date()
      self?.player?.play()
    }
  }
}

extension AVAudioPlayerAsync: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    continuation?.resume(returning: Date().timeIntervalSince(startDate ?? Date()))
  }
}

