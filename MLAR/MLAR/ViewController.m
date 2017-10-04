//
//  ViewController.m
//  MLAR
//
//  Created by moxin on 2017/10/3.
//  Copyright © 2017年 Vizlab. All rights reserved.
//

#import "ViewController.h"
#import <SceneKit/SceneKit.h>
#import <SceneKit/SCNCamera.h>
#import <ARKit/ARKit.h>
#import <Vision/Vision.h>
#import <AVFoundation/AVFoundation.h>
#import "VisionDetector.h"

@interface ViewController () <ARSCNViewDelegate,ARSessionDelegate>{}

@property (nonatomic, strong)ARSCNView *sceneView;


@end

@implementation ViewController{
    VisionDetector* _faceDetector;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup sceneView
    self.sceneView = [[ARSCNView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.sceneView.delegate = self;
    self.sceneView.showsStatistics = YES;
    self.sceneView.autoenablesDefaultLighting = YES;
    [self.view addSubview:self.sceneView];
    
    //config session
    ARWorldTrackingConfiguration* configuration = [ARWorldTrackingConfiguration new];
    self.sceneView.session.delegate = self;
    [self.sceneView.session runWithConfiguration:configuration];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _faceDetector = [[VisionDetector alloc]initWithARSession:self.sceneView.session];
       
        __weak ViewController* weakSelf = self;
        [_faceDetector detectingFaceswithCompletion:^(CGRect normalizedRect) {
            
            [weakSelf showFaceRectangle:normalizedRect];
            
        }];
    });
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate




#pragma mark - ARSessionDelegate

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera{
    
    switch (camera.trackingStateReason) {
        case ARTrackingStateReasonInitializing:
        {
            //hack camera to make it auto focus
            NSArray* availableSensors =  [self.sceneView.session valueForKey:@"availableSensors"];
            for(id sensor in availableSensors){
                if ([sensor isKindOfClass:NSClassFromString(@"ARImageSensor")]) {
                    id imageSensor = sensor;
                    AVCaptureSession* captureSession = [imageSensor valueForKey:@"captureSession"];
                    AVCaptureDevice* captureDevice = [imageSensor valueForKey:@"captureDevice"];
                    
                    if(captureSession && captureDevice)
                    {
                        if([captureDevice lockForConfiguration:nil]){
                            [captureSession beginConfiguration];
                            captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
                            captureDevice.smoothAutoFocusEnabled = YES;
                            [captureDevice unlockForConfiguration];
                        }
                    }
                }
            }
            break;
        }
            
        default:
            break;
    }
    
}

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
    
//    [[VisionDetector sharedInstance] detectingFaces:session.currentFrame.capturedImage withCompletion:^(CGRect normalizedRect) {
//
//        //1,show face rectangle
//        [self showFaceRectangle:normalizedRect];
//
//    }];
}


#pragma mark - private methods

static inline CGRect transformNormalizedBoundingRect(CGSize ScreenSize , CGRect normalizedRect){
    
    CGSize sz = CGSizeMake(normalizedRect.size.width*ScreenSize.width, normalizedRect.size.height*ScreenSize.height);
    CGPoint pt = CGPointMake(normalizedRect.origin.x*ScreenSize.width, ScreenSize.height*(1-normalizedRect.origin.y-normalizedRect.size.height));
    return (CGRect){pt,sz};
}


const NSInteger kFaceRectangle = 10;
- (void)showFaceRectangle:(CGRect) normalizedRect{
    
    [[self.view viewWithTag:kFaceRectangle] removeFromSuperview];
    if (!CGRectEqualToRect(normalizedRect, CGRectZero)) {
        
        //add rectangle
        CGRect faceRect = transformNormalizedBoundingRect(self.view.bounds.size, normalizedRect);
        UIView* view = [[UIView alloc]initWithFrame:faceRect];
        view.tag = kFaceRectangle;
        view.alpha = 0.3;
        view.backgroundColor = [UIColor redColor];
        [self.view addSubview:view];
        
    }
    
}


@end
