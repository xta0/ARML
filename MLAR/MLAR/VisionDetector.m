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
#import <UIKit/UIKit.h>


@implementation VisionDetector{
    
    __weak ARSession* _arSession;
    dispatch_queue_t _faceTrackingQueue;
    VNCoreMLRequest* _faceClassificationRequest;
}

- (id)initWithARSession:(ARSession* )session{
    self = [super init];
    if (self) {
         _faceTrackingQueue = dispatch_queue_create("face-tracking", DISPATCH_QUEUE_SERIAL);
        _arSession = session;
    }
    return self;
    
}

- (void)detectingFaceswithCompletion:(void (^)(CGRect))result{
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_faceTrackingQueue, ^{

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
                
                 dispatch_async(dispatch_get_main_queue(), ^{
                     result(faceRectangle);
                 });
            }
            
        }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    result(CGRectZero);
                });
        }
    
        //loop back
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf detectingFaceswithCompletion:result];
        });
        
    });
}

@end



