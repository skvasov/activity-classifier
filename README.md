# Activity-Classifier

The project helps to create Apple's ML models to classify user motion activities: golf shots, frisbee throws, etc. 

It consists of iOS and watchOS apps that:
- gather training data(user motion) from iPhone or Apple Watch sensors(gyro & accelerometer)
- export training data to your Mac
- import an ML model into the apps
- run and verify an ML model on iPhone or Apple Watch

Implemented with Apple's Core ML and Create ML frameworks

## Gathering training data
1. open iOS app on `Labels` tab
2. tap `+` button to add a new label(user activity), for exaple for frisbee: PushPass, RollerThrow, Backhand, etc
3. tap on a label to start gathering training data
4. on your iPhone or Apple Watch tap `Record` button and after a beep sound do your activity
5. after recording data for all labels tap `⬆️` button and save archive to your Mac

## Training an ML model on Mac
1. open Xcode, in menu select `Xcode` -> `Open Developer Tool` -> `Create ML`
2. create a new project and choose `Motion Activity Classification`
3. add your training data to the project(unarchive previously exported ZIP file)
4. tap `Choose Features` button and select all features except `timestamp`
5. tap `Train▶️` button
6. after successful training tap `Output` tab and export an ML model by tapping `Get` button

## Verifying an ML model on device
1. Save an ML model to `Files` app on your iPhone
2. open `Activity Classifier` app on your iPhone, go to `Verify` tab and tap `⬇️` button
3. import an ML model from `Files` app
4. tap `Run` button on your iPhone or Applw Watch

## Settings
Use `Settings` tab in the iOS app to adjust prediction window, frequency and delay.
