//
//  zoomView.m
//  CodeDemo
//
//  Created by shawn on 17/9/13.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "zoomView.h"


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

@interface zoomView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView * letterView;// 可以缩放的View
@property (nonatomic, strong) UIView * closeView;// 关闭的按钮
@property (nonatomic, strong) UIView * dotView;

@end

@implementation zoomView

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

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 400);
        self.backgroundColor = [UIColor lightGrayColor];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.letterView = [[UIView alloc] initWithFrame:CGRectMake(10, 70, 100, 30)];
    self.letterView.backgroundColor = [UIColor grayColor];
    self.closeView = [[UIView alloc] initWithFrame:CGRectMake(-10, -10, 20, 20)];
    self.closeView.backgroundColor = [UIColor redColor];
    
    self.dotView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.letterView.bounds)-10, CGRectGetMaxY(self.letterView.bounds)-10, 20, 20)];
    self.dotView.backgroundColor = [UIColor blueColor];
    
    [self addSubview:self.letterView];
    [self.letterView addSubview:self.closeView];
    [self.letterView addSubview:self.dotView];
    
    self.dotView.center = CGPointMake(self.letterView.frame.size.width, self.letterView.frame.size.height);
    
    // 移动
    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    panGest.delegate = self;
    [self.letterView addGestureRecognizer:panGest];
    
    
    // 缩放和旋转
    UIPanGestureRecognizer *rotateGest = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewPanGesture:)];
    rotateGest.delegate = self;
    
    self.dotView.userInteractionEnabled = YES;
    [self.dotView addGestureRecognizer:rotateGest];
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.letterView.bounds)-10, -10, 20, 20)];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    [self.letterView addSubview:btn];
    
    
}

- (void)btnClick {
    NSLog(@"click");
}

// 移动
- (void)panGestureDetected:(UIPanGestureRecognizer *)panGesture {
    UIGestureRecognizerState state = [panGesture state];
    if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        [panGesture.view setTransform:CGAffineTransformTranslate(panGesture.view.transform, translation.x, translation.y)];
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    }
}

// 旋转和缩放
- (void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer
{
    touchLocation = [recognizer locationInView:self];
    
    CGPoint center = CGRectGetCenter(self.letterView.frame);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        deltaAngle = atan2(touchLocation.y-center.y, touchLocation.x-center.x)-CGAffineTransformGetAngle(self.letterView.transform);
        
        initialBounds = self.letterView.bounds;
        initialDistance = CGPointGetDistance(center, touchLocation);
        
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        float ang = atan2(touchLocation.y-center.y, touchLocation.x-center.x);
        
        float angleDiff = deltaAngle - ang;
        [self.letterView setTransform:CGAffineTransformMakeRotation(-angleDiff)];
        [self setNeedsDisplay];
        //
        //        //Finding scale between current touchPoint and previous touchPoint
        double scale = sqrtf(CGPointGetDistance(center, touchLocation)/initialDistance);
        //
        CGRect scaleRect = CGRectScale(initialBounds, scale, scale);
        
        
        if (scaleRect.size.width >= self.frame.size.width || scaleRect.size.width <= 100 ) {
            //            [self.letterView setBounds:CGRectScale(initialBounds, 0.1, )];
        } else {
            [self.letterView setBounds:scaleRect];
            self.letterView.center = center;
            self.dotView.center = CGPointMake(CGRectGetMaxX(self.letterView.bounds), CGRectGetMaxY(self.letterView.bounds));
        }
//        [self setNeedsDisplay];
        
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"=>>>%p====%f",self,self.frame.size.width);
    UIView *touchView = [super hitTest:point withEvent:event];
    NSLog(@"===%p---%f",touchView,touchView.frame.size.width);
    
//    if (!touchView) {
        CGPoint resultPoint = [self.dotView convertPoint:point fromView:self];
        if ([self.dotView pointInside:resultPoint withEvent:event]) {
            return self.dotView;
        }
//    }
    return touchView;
}



@end
