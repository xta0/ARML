//
//  FaceDetector.m
//  MLAR
//
//  Created by moxin on 2017/10/2.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import "VisionDetector.h"
#import <ARKit/ARKit.h>
#import <Vision/Vision.h>
#import <CoreML/CoreML.h>
#import <UIKit/UIKit.h>
#import "Face11.h"
#import "Utils.h"


#define __test__ 0
@implementation VisionDetector{
    
    __weak ARSession* _arSession;
    dispatch_queue_t _faceTrackingQueue;
    VNCoreMLRequest* _faceClassificationRequest;
    VNCoreMLModel* _faceClassificationModel;
}

- (id)initWithARSession:(ARSession* )session{
    self = [super init];
    if (self) {
         _faceTrackingQueue = dispatch_queue_create("face-tracking", DISPATCH_QUEUE_SERIAL);
        _arSession = session;
        
        //get coreml model
        _faceClassificationModel = [VNCoreMLModel modelForMLModel:[[Face11 new] model] error:nil];
        
        
    }
    return self;
    
}


- (void)detectingFaceswithCompletion:(void (^)(CGRect,NSString*))result{
    
//    __weak typeof(self) weakSelf = self;
    dispatch_async(_faceTrackingQueue, ^{
        

        @autoreleasepool{
            //raw image
            CIImage* image = [[CIImage imageWithCVPixelBuffer:_arSession.currentFrame.capturedImage] imageByApplyingCGOrientation:kCGImagePropertyOrientationRight];
           
            //face tracking
            VNImageRequestHandler* faceDetectHandler = [[VNImageRequestHandler alloc]initWithCIImage:image options:@{}];
            VNDetectFaceRectanglesRequest* faceDetectRequest = [VNDetectFaceRectanglesRequest new];
            [faceDetectHandler performRequests:@[faceDetectRequest] error:nil];
        
            NSArray* results = faceDetectRequest.results;
            if (results.count > 0) {
                //get first one
                VNFaceObservation* observation = results.firstObject;
                if(observation.confidence >= 0.8){
                    //get bounding rect
                    CGRect faceRectangle = observation.boundingBox;

                    //crop image
//                    CGRect croppedRect = cropRect(faceRectangle, image.extent);
//                    CIImage* croppedImage = [image imageByCroppingToRect:croppedRect];
    #if __test__
                    static int x = 0;
                    __block void(^save)(void) = ^{
                        CIContext* context = [CIContext contextWithOptions:nil];
                        CGImageRef cgImage = [context createCGImage:croppedImage fromRect:croppedImage.extent];
                        UIImage *image = [UIImage imageWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                   
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            save();
                        });
                    };


                    if(!x){
                        save();
                        x = 1;
                    }
    #endif
                    //classification
//                    VNImageRequestHandler* faceClassificationHandler = [[VNImageRequestHandler alloc]initWithCIImage:croppedImage options:@{}];
                    VNImageRequestHandler* faceClassificationHandler = [[VNImageRequestHandler alloc]initWithCIImage:image options:@{}];
                    VNCoreMLRequest* faceClassificationRequest = [[VNCoreMLRequest alloc]initWithModel:self->_faceClassificationModel];
                    faceClassificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionScaleFit;
                    [faceClassificationHandler performRequests:@[faceClassificationRequest] error:nil];
                    NSArray* classifiedResults = faceClassificationRequest.results;
                    if (classifiedResults.count >0 ) {
                       
                        for(VNClassificationObservation* result in classifiedResults){
                             NSLog(@"Possible Faces:<%@,%.1f>",result.identifier, result.confidence);
                        }
                        VNClassificationObservation* bestResult = classifiedResults.firstObject;
                        if (bestResult.confidence > 0.5) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                result(faceRectangle,bestResult.identifier);
                            });
                            
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                result(faceRectangle,@"unknown");
                            });
                        }
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            result(faceRectangle,@"unknown");
                        });
                    }
                }
                
            }else{
                NSLog(@"No Faces!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        result(CGRectZero,nil);
                    });
            }
        }
    
        //loop back
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self detectingFaceswithCompletion:result];
        });
        
    });
}


@end



