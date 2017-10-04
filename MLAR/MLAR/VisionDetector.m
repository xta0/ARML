//
//  FaceDetector.m
//  MLAR
//
//  Created by moxin on 2017/10/2.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import "VisionDetector.h"
#import <Vision/Vision.h>
#import <UIKit/UIKit.h>


@implementation VisionDetector{
    
    dispatch_queue_t _faceTrackingQueue;
    CVPixelBufferRef _copiedPixelBufferRef;
    
    VNSequenceRequestHandler* _faceRectDetector;
    VNDetectFaceRectanglesRequest* _faceRectRequest;
    
}

+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken = 0;
    static VisionDetector* instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [VisionDetector new];
    });
    return instance;
}


extern NSString* NSStringFromCGRect(CGRect rect);
- (id)init{
    self = [super init];
    if (self) {
    
        _faceTrackingQueue = dispatch_queue_create("face-tracking", DISPATCH_QUEUE_SERIAL);
        _faceRectDetector = [VNSequenceRequestHandler new];
        _faceRectRequest = [VNDetectFaceRectanglesRequest new];
        

    }
    return self;
    
}


- (void)detectingFaces:(CVPixelBufferRef)pixelBuffer withCompletion:(void(^)(CGRect normalizedRect))result{

    _copiedPixelBufferRef  = pixelBuffer; //create a copy here
    
    dispatch_async(_faceTrackingQueue, ^{
//        CIImage* image = [[CIImage imageWithCVPixelBuffer:pixelBuffer] imageByApplyingCGOrientation:kCGImagePropertyOrientationRight];
//        [_faceRectDetector performRequests:@[_faceRectRequest] onCIImage:image error:nil];
        [_faceRectDetector performRequests:@[_faceRectRequest] onCIImage:[CIImage imageWithCVPixelBuffer:_copiedPixelBufferRef] orientation:kCGImagePropertyOrientationRight error:nil];
        NSArray* results = _faceRectRequest.results;
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
    });
}


@end



