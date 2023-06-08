//
//  SpeechSynthesizerRepository.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 8.06.23.
//

import Foundation
import AVFoundation

protocol SpeechSynthesizerRepository {
  func speak(_ text: String)
}

class RealSpeechSynthesizerRepository: SpeechSynthesizerRepository {
  private let synthesizer = AVSpeechSynthesizer()
  private let voice = AVSpeechSynthesisVoice(language: "en-US")
  
  func speak(_ text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = voice

    synthesizer.speak(utterance)
  }
}
