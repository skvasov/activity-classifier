//
//  Motion.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation
import CoreMotion
import CoreML

class DeviceMotion: Codable {
  var timestamp: TimeInterval
  
  var rotationX: Double
  var rotationY: Double
  var rotationZ: Double
  
  var attitudeRoll: Double
  var attitudePitch: Double
  var attitudeYaw: Double
  
  var attitudeRotationMatrixM11: Double
  var attitudeRotationMatrixM12: Double
  var attitudeRotationMatrixM13: Double
  var attitudeRotationMatrixM21: Double
  var attitudeRotationMatrixM22: Double
  var attitudeRotationMatrixM23: Double
  var attitudeRotationMatrixM31: Double
  var attitudeRotationMatrixM32: Double
  var attitudeRotationMatrixM33: Double
  
  var attitudeQuaternionX: Double
  var attitudeQuaternionY: Double
  var attitudeQuaternionZ: Double
  var attitudeQuaternionW: Double
  
  var gravityX: Double
  var gravityY: Double
  var gravityZ: Double
  
  var userAccelerationX: Double
  var userAccelerationY: Double
  var userAccelerationZ: Double
  
  init(_ data: CMDeviceMotion) {
    self.timestamp = data.timestamp
    
    self.rotationX = data.rotationRate.x
    self.rotationY = data.rotationRate.y
    self.rotationZ = data.rotationRate.z
    
    self.attitudeRoll = data.attitude.roll
    self.attitudePitch = data.attitude.pitch
    self.attitudeYaw = data.attitude.yaw
    
    self.attitudeRotationMatrixM11 = data.attitude.rotationMatrix.m11
    self.attitudeRotationMatrixM12 = data.attitude.rotationMatrix.m12
    self.attitudeRotationMatrixM13 = data.attitude.rotationMatrix.m13
    self.attitudeRotationMatrixM21 = data.attitude.rotationMatrix.m21
    self.attitudeRotationMatrixM22 = data.attitude.rotationMatrix.m22
    self.attitudeRotationMatrixM23 = data.attitude.rotationMatrix.m23
    self.attitudeRotationMatrixM31 = data.attitude.rotationMatrix.m31
    self.attitudeRotationMatrixM32 = data.attitude.rotationMatrix.m32
    self.attitudeRotationMatrixM33 = data.attitude.rotationMatrix.m33
    
    self.attitudeQuaternionX = data.attitude.quaternion.x
    self.attitudeQuaternionY = data.attitude.quaternion.y
    self.attitudeQuaternionZ = data.attitude.quaternion.z
    self.attitudeQuaternionW = data.attitude.quaternion.w
    
    self.gravityX = data.gravity.x
    self.gravityY = data.gravity.y
    self.gravityZ = data.gravity.z
    
    self.userAccelerationX = data.userAcceleration.x
    self.userAccelerationY = data.userAcceleration.y
    self.userAccelerationZ = data.userAcceleration.z
  }
}

extension DeviceMotion {
  static var featureNames: Set<String> {
    Set([
      "rotationX",
      "rotationY",
      "rotationZ",
            
      "attitudeRoll",
      "attitudePitch",
      "attitudeYaw",
            
      "attitudeRotationMatrixM11",
      "attitudeRotationMatrixM12",
      "attitudeRotationMatrixM13",
      "attitudeRotationMatrixM21",
      "attitudeRotationMatrixM22",
      "attitudeRotationMatrixM23",
      "attitudeRotationMatrixM31",
      "attitudeRotationMatrixM32",
      "attitudeRotationMatrixM33",
            
      "attitudeQuaternionX",
      "attitudeQuaternionY",
      "attitudeQuaternionZ",
      "attitudeQuaternionW",
            
      "gravityX",
      "gravityY",
      "gravityZ",
            
      "userAccelerationX",
      "userAccelerationY",
      "userAccelerationZ"
    ])
  }
  
  func featureValue(for featureName: String) -> Double? {
    switch featureName {
    case "rotationX":
      return rotationX
    case "rotationY":
      return rotationY
    case "rotationZ":
      return rotationZ
      
    case "attitudeRoll":
      return attitudeRoll
    case "attitudePitch":
      return attitudePitch
    case "attitudeYaw":
      return attitudeYaw
      
    case "attitudeRotationMatrixM11":
      return attitudeRotationMatrixM11
    case "attitudeRotationMatrixM12":
      return attitudeRotationMatrixM12
    case "attitudeRotationMatrixM13":
      return attitudeRotationMatrixM13
    case "attitudeRotationMatrixM21":
      return attitudeRotationMatrixM21
    case "attitudeRotationMatrixM22":
      return attitudeRotationMatrixM22
    case "attitudeRotationMatrixM23":
      return attitudeRotationMatrixM23
    case "attitudeRotationMatrixM31":
      return attitudeRotationMatrixM31
    case "attitudeRotationMatrixM32":
      return attitudeRotationMatrixM32
    case "attitudeRotationMatrixM33":
      return attitudeRotationMatrixM33
      
    case "attitudeQuaternionX":
      return attitudeQuaternionX
    case "attitudeQuaternionY":
      return attitudeQuaternionY
    case "attitudeQuaternionZ":
      return attitudeQuaternionZ
    case "attitudeQuaternionW":
      return attitudeQuaternionW
      
    case "gravityX":
      return gravityX
    case "gravityY":
      return gravityY
    case "gravityZ":
      return gravityZ
      
    case "userAccelerationX":
      return userAccelerationX
    case "userAccelerationY":
      return userAccelerationY
    case "userAccelerationZ":
      return userAccelerationZ
      
    default:
      return nil
    }
  }
}

class DeviceMotionFeatureProvider: MLFeatureProvider {
  private enum AdditionalFeatures: String {
    case stateIn = "stateIn"
  }
  
  private let motions: [DeviceMotion]
  private let stateIn: MLMultiArray
  
  init(_ motions: [DeviceMotion], stateIn: MLMultiArray?) throws {
    self.motions = motions
    // TODO: what is 400 ???
    self.stateIn = try (stateIn ?? MLMultiArray(Array(repeating: 0.0, count: 400)))
  }
  
  var featureNames: Set<String> {
    var set = DeviceMotion.featureNames
    set.insert(AdditionalFeatures.stateIn.rawValue)
    return set
  }
  
  func featureValue(for featureName: String) -> MLFeatureValue? {
    if featureName.compare(AdditionalFeatures.stateIn.rawValue) == .orderedSame {
      return MLFeatureValue(multiArray: stateIn)
    }
    
    var values: [Double] = []
    for motion in motions {
      guard let value = motion.featureValue(for: featureName) else { return nil }
      values.append(value)
    }
    
    guard let array = try? MLMultiArray(values) else { return nil }
    
    return MLFeatureValue(multiArray: array)
  }
}
