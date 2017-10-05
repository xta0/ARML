//
//  ARTextNode.h
//  MLAR
//
//  Created by moxin on 2017/10/4.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface ARTextNode : NSObject

+ (SCNNode* )nodeWithText:(NSString* )name Position:(SCNVector3)pos;

@end


@interface SCNNode(animation)

- (void)show;
- (void)hide;


@end
