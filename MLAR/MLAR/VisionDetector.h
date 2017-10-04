//
//  FaceDetector.h
//  MLAR
//
//  Created by moxin on 2017/10/2.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface VisionDetector : NSObject

+ (instancetype)sharedInstance;

- (void)detectingFaces:(CVPixelBufferRef)pixelBuffer withCompletion:(void(^)(CGRect normalizedRect))result;


@end
