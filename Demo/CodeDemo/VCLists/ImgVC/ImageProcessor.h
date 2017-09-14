//
//  ImageProcessor.h
//  CodeDemo
//
//  Created by shawn on 17/9/14.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageProcessor : NSObject
+ (UIImage *)proccessUsingCoreGraphics:(UIImage *)input;

+ (UIImage *)processUsingCoreImage:(UIImage*)input;
@end
