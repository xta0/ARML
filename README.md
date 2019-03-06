# ARML

This demo project demonstrates how to identify faces using Apple's new Vision,CoreML and ARKit APIs.The code is written in Objective-C .
## Requirements

- Xcode 9
- iPhone 6s or newer
- CoreML model

## Tricks


- **Camera Hacking** : Since ARkit uses a fixed-lense camera to render the screen, the camera won't be able to auto-focus by itself. To tune the camere you need to get access to the `AVCaptureDevice`or`AVCaptureSession `. However, this is not possible in ARKit as described [here](https://forums.developer.apple.com/thread/81971) . I solve this by accessing the `availableSenors` property of the `ARSesion` in runtime and find the `ARImageSensor` which holds the reference to the `AVCaptureDevice` and `AVCaptureSession` object. 

 
- **Machine Learning**: To identity different people you need a pre-trained CoreML model. You can use `caffe` or other neural network infrastructure to train your model.  For this demo, I use the Mircorsoft's [Custom Vision Serivce](https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/home) which is really convenient to train  images online and you can also download the reslut in CoreML model format.


## Acknowledgements

- [CoreML-in-ARKit](https://github.com/hanleyweng/CoreML-in-ARKit)
- [spiderpig](https://github.com/biscuitehh/spiderpig)

## Resources
- Link to [CoreML documentation](https://developer.apple.com/documentation/coreml)
- Link Apple WWDC videos, samples, and materials for information on [CoreML](https://developer.apple.com/videos/play/wwdc2017/710) and [Vision Framework](https://developer.apple.com/videos/play/wwdc2017/506/)
- Link to [Custom Vision Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/home)

## ScreenShot

<img src="./screenshot.gif" width="480
00px"/>

