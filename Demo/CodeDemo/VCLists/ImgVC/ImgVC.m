//
//  ImgVC.m
//  CodeDemo
//
//  Created by shawn on 17/9/11.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "ImgVC.h"
#import "zoomView.h"
#import "ImageProcessor.h"

#import <objc/runtime.h>


CG_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t)
{
    return atan2(t.b, t.a);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2)
{
    //Saving Variables.
    CGFloat fx = (point2.x - point1.x);
    CGFloat fy = (point2.y - point1.y);
    
    return sqrt((fx*fx + fy*fy));
}
CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

@interface ImgVC ()<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UIImageView *imgView;

@end

@implementation ImgVC
{
    CGFloat globalInset;
    
    CGRect initialBounds;
    CGFloat initialDistance;
    
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    
    CGPoint prevPoint;
    CGPoint touchLocation;
    
    CGFloat deltaAngle;
    
    CGAffineTransform startTransform;
    CGRect beginBounds;
    
    CAShapeLayer *border;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    zoomView *zoom = [[zoomView alloc] init];
//    [self.view addSubview:zoom];
    
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 200, 200)];
    [self.view addSubview:imgview];
    
//    [imgview setImage:[self cricleImage:[UIImage imageNamed:@"image6"]]];
    [imgview setImage:[ImageProcessor processUsingCoreImage:[UIImage imageNamed:@"image6"]]];
    
}




// Quartz2D裁剪图片
- (UIImage *)cricleImage:(UIImage *)img {
    UIGraphicsBeginImageContext(img.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextClip(ctx);
    [img drawInRect:rect];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImg;
}




//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
////    UIPinchGestureRecognizer
//    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 100, 100, 100)];
//    self.imgView.center = self.view.center;
//    [self.imgView setImage:[UIImage imageNamed:@"image2"]];
//    self.imgView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:self.imgView];
//    self.imgView.userInteractionEnabled = YES;
//    
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.imgView.frame) - self.imgView.frame.origin.y, 100, 1)];
//    line.backgroundColor = [UIColor redColor];
//    [self.imgView addSubview:line];
//    
//    
//    
//    
//    UIPinchGestureRecognizer *pinchGest = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
//    pinchGest.delegate = self;
//    
////    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
////    rotateViewPanGesture
//    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewPanGesture:)];
//    panGest.delegate = self;
//    
//    UIRotationGestureRecognizer *rotationGest = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureDetected:)];
//    rotationGest.delegate = self;
//    
//    
////    [self.imgView addGestureRecognizer:pinchGest];
////    [self.imgView addGestureRecognizer:panGest];
////    [self.imgView addGestureRecognizer:rotationGest];
//    
//    
//    UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(-10, -10, 20, 20)];
//    dotView.backgroundColor = [UIColor blueColor];
//    dotView.userInteractionEnabled = YES;
//    [self.imgView addSubview:dotView];
//    
////    dotView.center = CGPointMake(self.imgView.frame.origin.x + self.imgView.frame.size.width, self.imgView.frame.origin.y + self.imgView.frame.size.height);
//    
//    [dotView addGestureRecognizer:panGest];
//    
//    
//    [self.imgView setImage:[self addImage:[UIImage imageNamed:@"image4"] toImage:[UIImage imageNamed:@"image2"]]];
//}



-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
//    UIGraphicsBeginImageContext(image2.size);
    UIGraphicsBeginImageContext(CGSizeMake(200, 200));
    
    //Draw image2
    [image2 drawInRect:CGRectMake(0, 0, 200, 200)];
    
//    image2  stretchableImageWithLeftCapWidth:<#(NSInteger)#> topCapHeight:<#(NSInteger)#>
    
    //Draw image1
    [image1 drawInRect:CGRectMake(0, 0, 100, 100)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}





- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}


- (void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self.view];
    
    CGPoint center = CGRectGetCenter(self.imgView.frame);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        deltaAngle = atan2(touchLocation.y-center.y, touchLocation.x-center.x)-CGAffineTransformGetAngle(self.imgView.transform);
        
        initialBounds = self.imgView.bounds;
        initialDistance = CGPointGetDistance(center, touchLocation);
        
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        float ang = atan2(touchLocation.y-center.y, touchLocation.x-center.x);
        
        float angleDiff = deltaAngle - ang;
        [self.imgView setTransform:CGAffineTransformMakeRotation(-angleDiff)];
        [self.view setNeedsDisplay];
//
//        //Finding scale between current touchPoint and previous touchPoint
        double scale = sqrtf(CGPointGetDistance(center, touchLocation)/initialDistance);
//
        CGRect scaleRect = CGRectScale(initialBounds, scale, scale);
        
        
        if (scaleRect.size.width >= self.view.frame.size.width || scaleRect.size.width <= 100 ) {
//            [self.imgView setBounds:CGRectScale(initialBounds, 0.1, )];
        } else {
            [self.imgView setBounds:scaleRect];
        }
        [self.imgView setNeedsDisplay];
//        if (scaleRect.size.width >= (1+globalInset*2 + 20) && scaleRect.size.height >= (1+globalInset*2 + 20)) {
//            if (fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds)) {
//                [textView adjustsFontSizeToFillRect:scaleRect];
//                [self setBounds:scaleRect];
//            }
//        }
        
    }
}







- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// 两指
- (void)pinchGestureDetected:(UIPinchGestureRecognizer *)pinchGesture {
    UIGestureRecognizerState state = [pinchGesture state];
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [pinchGesture scale];
        if (pinchGesture.view.frame.size.width * scale > 300 || pinchGesture.view.frame.size.height * scale > 400) {
            return;
        }
        CGPoint cen = CGPointMake(pinchGesture.view.center.x, pinchGesture.view.center.y);
        pinchGesture.view.frame = CGRectMake(0, 0, pinchGesture.view.frame.size.width * scale, pinchGesture.view.frame.size.height * scale);
        pinchGesture.view.center = cen;
//        [pinchGesture.view setTransform:CGAffineTransformTranslate(pinchGesture.view.transform, scale, scale)];
        [pinchGesture setScale:1.0];
    }
}
// 一指
- (void)panGestureDetected:(UIPanGestureRecognizer *)panGesture {
    UIGestureRecognizerState state = [panGesture state];
    if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        [panGesture.view setTransform:CGAffineTransformTranslate(panGesture.view.transform, translation.x, translation.y)];
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    }
}
// 旋转
- (void)rotationGestureDetected:(UIRotationGestureRecognizer *)rotationGesture {
    UIGestureRecognizerState state = [rotationGesture state];
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        CGFloat rotation = [rotationGesture rotation];
        [rotationGesture.view setTransform:CGAffineTransformRotate(rotationGesture.view.transform, rotation)];
        [rotationGesture setRotation:0];
    }
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
