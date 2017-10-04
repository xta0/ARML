//
//  FaceDetector.h
//  MLAR
//
//  Created by moxin on 2017/10/2.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARSession;
@interface VisionDetector : NSObject

- (id)initWithARSession:(ARSession* )session;
- (void)detectingFaceswithCompletion:(void(^)(CGRect normalizedRect,NSString* name))result;


@end
