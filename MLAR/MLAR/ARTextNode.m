//
//  ARTextNode.m
//  MLAR
//
//  Created by moxin on 2017/10/4.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import "ARTextNode.h"
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface UIFont(Trait)
- (UIFont* )fontWithTrait:(UIFontDescriptorSymbolicTraits)trait;
@end

@implementation UIFont(Trait)
- (UIFont* )fontWithTrait:(UIFontDescriptorSymbolicTraits)trait{
    UIFontDescriptor* desc =  [self.fontDescriptor fontDescriptorWithSymbolicTraits:trait];
    return [UIFont fontWithDescriptor:desc size:0];
}

@end

@implementation ARTextNode

+ (SCNNode* )nodeWithText:(NSString* )name Position:(SCNVector3)pos{
    
    float bubbleDepth  = 0.01; // the 'depth' of 3D text
    SCNBillboardConstraint* billboardConstraint = [SCNBillboardConstraint new];
    billboardConstraint.freeAxes = SCNBillboardAxisY;
    
    //text
    SCNText* bubbleText = [SCNText textWithString:name extrusionDepth:bubbleDepth];
    bubbleText.font = [UIFont fontWithName:@"Futura" size:0.12];
    bubbleText.font = [bubbleText.font fontWithTrait:UIFontDescriptorTraitBold];
    
    bubbleText.alignmentMode = kCAAlignmentCenter;
    bubbleText.firstMaterial.diffuse.contents = (__bridge id)[UIColor orangeColor].CGColor;
    bubbleText.firstMaterial.specular.contents = (__bridge id)[UIColor whiteColor].CGColor;
    [bubbleText.firstMaterial setDoubleSided:YES];
    bubbleText.chamferRadius = bubbleDepth;
    
    //node
    SCNVector3 minBound, maxBound;
    [bubbleText getBoundingBoxMin:&minBound max:&maxBound];
    SCNNode* bubbleNode = [SCNNode nodeWithGeometry:bubbleText];
 // Centre Node - to Centre-Bottom point
    bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2.0);
    
    // Reduce default text size
    bubbleNode.scale = SCNVector3Make(0.2, 0.2, 0.2);
    bubbleNode.position = SCNVector3Make(0, 0, 0);
    bubbleNode.simdPosition = simd_make_float3(0.05, 0.04, 0);
    
    //pin a picture
    SCNMaterial* material = [SCNMaterial new];
    material.diffuse.contents = (__bridge id)[UIImage imageNamed:name].CGImage;
    [material setDoubleSided:YES];
    SCNBox* picBox = [SCNBox boxWithWidth:0.5 height:0.5 length:0.01 chamferRadius:0];
    picBox.firstMaterial = material;
    SCNNode* picBoxNode = [SCNNode nodeWithGeometry:picBox];
    picBoxNode.scale = SCNVector3Make(0.1, 0.1, 0.1);
    picBoxNode.simdPosition = simd_make_float3(0.05, 0, 0);
    
    
    SCNNode* parentNode = [SCNNode new];
    [parentNode addChildNode:picBoxNode];
    [parentNode addChildNode:bubbleNode];
//    [parentNode addChildNode:sphereNode];
    parentNode.constraints = @[billboardConstraint];
    parentNode.position = pos;
    
    return parentNode;
}

@end

@implementation SCNNode(animation)

- (void)show{
    
    self.opacity = 0;
    [SCNTransaction begin];
    SCNTransaction.animationDuration = 0.4;
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] ;
    self.opacity = 1;
    [SCNTransaction commit];
}
- (void)hide{
    
    [SCNTransaction begin];
    SCNTransaction.animationDuration = 1.0;
    SCNTransaction.animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] ;
    self.opacity = 0;
    [SCNTransaction commit];
    [self removeFromParentNode];
}


@end
