//
//  CameraCaptureVC.m
//  CodeDemo
//
//  Created by shawn on 17/8/9.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "CameraCaptureVC.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraCaptureVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation CameraCaptureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectImageFromCamera];
    });
}

#pragma mark 从摄像头获取图片或视频
- (void)selectImageFromCamera {
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; //录制视频时长，默认10s
//    _imagePickerController.videoMaximumDuration = 15;
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage];
    //视频上传质量 //UIImagePickerControllerQualityTypeHigh高清 //UIImagePickerControllerQualityTypeMedium中等质量 //UIImagePickerControllerQualityTypeLow低质量 //UIImagePickerControllerQualityType640x480
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置摄像头模式（拍照，录制视频）为录像模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}
#pragma mark 从相册获取图片或视频 
- (void)selectImageFromAlbum {
    //NSLog(@"相册");
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}
#pragma mark -UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {

}

































@end
