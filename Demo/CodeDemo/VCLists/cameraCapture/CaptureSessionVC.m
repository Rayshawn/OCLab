//
//  CaptureSessionVC.m
//  CodeDemo
//
//  Created by shawn on 17/8/10.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "CaptureSessionVC.h"

#import <AVFoundation/AVFoundation.h>

@interface CaptureSessionVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CaptureSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 80, 100, 100)];
    [self.view addSubview:_imageView];
    
    
    _session = [[AVCaptureSession alloc] init];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [_session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    [self setSessionInputDevice];
    [self setSessionOutputDevice];
}

- (void)setSessionInputDevice {
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ([_session canAddInput:inputDevice]) {
        [_session addInput:inputDevice];
    }
}
- (void)setSessionOutputDevice {
    AVCaptureVideoDataOutput *outputDevice = [[AVCaptureVideoDataOutput alloc] init];
//    [outputDevice connectionWithMediaType:AVMediaTypeVideo];
    NSDictionary *rgbOutputSeting = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [outputDevice setVideoSettings:rgbOutputSeting];
    [outputDevice setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t outputDeviceQueue = dispatch_queue_create("outputDeviceQueue", DISPATCH_QUEUE_SERIAL);
    [outputDevice setSampleBufferDelegate:self queue:outputDeviceQueue];
    if ([_session canAddOutput:outputDevice]) {
        [_session addOutput:outputDevice];
    }
    [outputDevice connectionWithMediaType:AVMediaTypeVideo];
//    [[outputDevice connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    AVCaptureConnection *connection = [outputDevice connectionWithMediaType:AVMediaTypeVideo];
    if ([connection isVideoOrientationSupported]) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    [_session startRunning];
    
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    UIImage *im = [self convert11SampleBufferToUIImageSampleBuffer:sampleBuffer];    
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.image = im;
    });
    
}





- (UIImage *)convert11SampleBufferToUIImageSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the plane pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    // Get the number of bytes per row for the plane pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaNone);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationRight];
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}












/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
