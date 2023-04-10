//
//  Motion.swift
//  ActivityClassifier
//
//  Created by Sergei Kvasov on 10.04.23.
//

import Foundation
import CoreMotion

struct DeviceMotion: Codable {
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
}

extension DeviceMotion {
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
