//
//  Utils.h
//  MLAR
//
//  Created by moxin on 2017/10/4.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#ifndef Utils_h
#define Utils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>
#import <SceneKit/SceneKitTypes.h>


static inline CGRect transformNormalizedBoundingRect(CGSize ScreenSize , CGRect normalizedRect){
    
    CGSize sz = CGSizeMake(normalizedRect.size.width*ScreenSize.width, normalizedRect.size.height*ScreenSize.height);
    CGPoint pt = CGPointMake(normalizedRect.origin.x*ScreenSize.width, ScreenSize.height*(1-normalizedRect.origin.y-normalizedRect.size.height));
    return (CGRect){pt,sz};
}

static inline CGRect _transformNormalizedBoundingRect(CGSize ScreenSize , CGRect normalizedRect){
    
    CGSize sz = CGSizeMake(normalizedRect.size.width*ScreenSize.width, normalizedRect.size.height*ScreenSize.height);
    CGPoint pt = CGPointMake(CGRectGetMinX(normalizedRect)*ScreenSize.width, ScreenSize.height*(1-CGRectGetMaxY(normalizedRect)));
    return (CGRect){pt,sz};
}

static inline CGRect cropRect(CGRect faceRect, CGRect imageRect){
    
    float w = faceRect.size.width*imageRect.size.width;
    float h = faceRect.size.height*imageRect.size.height;
    float x = faceRect.origin.x*imageRect.size.width;
    float y = faceRect.origin.y*imageRect.size.height;
    
    CGRect boundingRect =  CGRectMake(x, y, w, h);
    CGRect croppedRect = CGRectInset(boundingRect, -0.6*w, -0.6*h);
    
    return croppedRect;
}

static inline float lengthOfVector(SCNVector3 v){
    return sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
}

static inline SCNVector3 positionFromTransformMatrix(matrix_float4x4 matrix){
    return SCNVector3Make(matrix.columns[3].x, matrix.columns[3].y, matrix.columns[3].z);
}

static inline SCNVector3 averagePostion(NSArray<ARHitTestResult* >* results){
    
    float x = 0;
    float y = 0;
    float z = 0;
    NSUInteger count = results.count;
    for(ARHitTestResult* result in results){
        x += result.worldTransform.columns[3].x;
        y += result.worldTransform.columns[3].y;
        z += result.worldTransform.columns[3].z;
    }
    SCNVector3 v=   SCNVector3Make(x/count, y/count, z/count);
    return v;
}






#endif /* Utils_h */
