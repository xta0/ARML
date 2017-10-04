//
//  ARTextNode.m
//  MLAR
//
//  Created by moxin on 2017/10/4.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import "ARTextNode.h"
#import <SceneKit/SceneKit.h>

@implementation ARTextNode

+ (SCNNode* )nodeWithText:(NSString* )name Position:(SCNVector3)pos{
    
    float bubbleDepth  = 0.01; // the 'depth' of 3D text
    SCNBillboardConstraint* billboardConstraint = [SCNBillboardConstraint new];
    billboardConstraint.freeAxes = SCNBillboardAxisY;
    
    //text
    SCNText* bubbleText = [SCNText textWithString:name extrusionDepth:bubbleDepth];
    bubbleText.font = [UIFont fontWithName:@"Futura" size:0.15];
    bubbleText.alignmentMode = kCAAlignmentCenter;
    bubbleText.firstMaterial.diffuse.contents = (__bridge id)[UIColor orangeColor].CGColor;
    bubbleText.firstMaterial.specular.contents = (__bridge id)[UIColor whiteColor].CGColor;
    //    bubbleText.firstMaterial.isDoubleSided = YES;
    bubbleText.chamferRadius = bubbleDepth;
    
    //node
    SCNVector3 minBound, maxBound;
    [bubbleText getBoundingBoxMin:&minBound max:&maxBound];
    SCNNode* bubbleNode = [SCNNode nodeWithGeometry:bubbleText];
 // Centre Node - to Centre-Bottom point
    bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2.0);
    
    // Reduce default text size
    bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2);
    bubbleNode.simdPosition = simd_make_float3(0.05, 0.04, 0);
    // CENTRE POINT NODE
    SCNSphere* sphere = [SCNSphere sphereWithRadius:0.004];
    sphere.firstMaterial.diffuse.contents = (__bridge id)[UIColor grayColor].CGColor;
    SCNNode* sphereNode = [SCNNode nodeWithGeometry:sphere];
    sphereNode.opacity = 0.6;
    
    SCNNode* parentNode = [SCNNode new];
    [parentNode addChildNode:bubbleNode];
    [parentNode addChildNode:sphereNode];
    parentNode.constraints = @[billboardConstraint];
    parentNode.position = pos;
    
    return parentNode;
}

@end
