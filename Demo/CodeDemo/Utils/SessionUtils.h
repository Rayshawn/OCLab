//
//  SessionUtils.h
//  CodeDemo
//
//  Created by shawn on 17/8/10.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>



typedef NS_ENUM(NSUInteger, SessionPresetOfResolution){
    SessionPresetLow               = 0,
    SessionPresetMedium            = 1,
    SessionPresetHigh              = 2,
    SessionPreset320x240           = 3,
    SessionPreset352x288           = 4,
    SessionPreset640x480           = 5,
    SessionPreset960x540           = 6,
    SessionPreset1280x720          = 7,
    SessionPreset1920x1080         = 8,
    SessionPreset3840x2160         = 9
};

@protocol SessionUtilsDelegate <NSObject>

@optional
- (void)videoCaptureOutputWithImage:(UIImage *)image;// 输出图片
- (void)videoCaptureOutputWithSampleBuffer:(CMSampleBufferRef *)sampleBuffer;// 输出bufferRef
@end



@interface SessionUtils : NSObject

@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;

@property (nonatomic, weak) id<SessionUtilsDelegate> delegate;

/**
 开始
 */
- (void)startRunning;
/**
 停止
 */
- (void)stopRunning;

@end











