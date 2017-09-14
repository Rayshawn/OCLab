//
//  ImageProcessor.m
//  CodeDemo
//
//  Created by shawn on 17/9/14.
//  Copyright © 2017年 wangrui. All rights reserved.
//

#import "ImageProcessor.h"


@implementation ImageProcessor


//Core Graphics
+ (UIImage *)proccessUsingCoreGraphics:(UIImage *)input {
    CGRect imageRect = {CGPointZero, input.size};
    NSInteger inputWidth = CGRectGetWidth(imageRect);
    NSInteger inputHeight = CGRectGetHeight(imageRect);
    
    // 1) Calculate the location of Ghosty
    UIImage *ghostImage = [UIImage imageNamed:@"image8"];
    CGFloat ghostImageAspectRatio = ghostImage.size.width / ghostImage.size.height;
    
    NSInteger targetGhostWidth = inputWidth * 0.25;
    CGSize ghostSize = CGSizeMake(targetGhostWidth, targetGhostWidth/ghostImageAspectRatio);
    CGPoint ghostOrigin = CGPointMake(inputWidth * 0.5, inputHeight * 0.2);
    
    CGRect ghostRect = {ghostOrigin, ghostSize};
    
    
    // 2) Draw your image into the context.
    UIGraphicsBeginImageContext(input.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip, 0, -inputHeight);
    CGContextConcatCTM(context, flipThenShift);
    CGContextDrawImage(context, imageRect, [input CGImage]);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextSetAlpha(context, 1);
    CGRect transformedGhostRect = CGRectApplyAffineTransform(ghostRect, flipThenShift);
    CGContextDrawImage(context, transformedGhostRect, [ghostImage CGImage]);
    
    // 3) Retrieve your processed image
    UIImage * imageWithGhost = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 4) Draw your image into a grayscale context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    context = CGBitmapContextCreate(nil, inputWidth, inputHeight,
                                    8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [imageWithGhost CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * finalImage = [UIImage imageWithCGImage:imageRef];
    // 5) Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return finalImage;
//    return nil;
}

// Core Image
+ (UIImage *)processUsingCoreImage:(UIImage*)input {
    CIImage * inputCIImage = [[CIImage alloc] initWithImage:input];
    // 1. Create a grayscale filter
    CIFilter * grayFilter = [CIFilter filterWithName:@"CIColorControls"];
    [grayFilter setValue:@(0) forKeyPath:@"inputSaturation"];
    // 2. Create your ghost filter
    // Use Core Graphics for this
    
    UIImage * ghostImage = [self createPaddedGhostImageWithSize:input.size];
    
    CIImage * ghostCIImage = [[CIImage alloc] initWithImage:ghostImage];
    // 3. Apply alpha to Ghosty
    CIFilter * alphaFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    CIVector * alphaVector = [CIVector vectorWithX:0 Y:0 Z:0.5 W:0];
    [alphaFilter setValue:alphaVector forKeyPath:@"inputAVector"];
    // 4. Alpha blend filter
    CIFilter * blendFilter = [CIFilter filterWithName:@"CISourceAtopCompositing"];
    // 5. Apply your filters
    [alphaFilter setValue:ghostCIImage forKeyPath:@"inputImage"];
    ghostCIImage = [alphaFilter outputImage];
    [blendFilter setValue:ghostCIImage forKeyPath:@"inputImage"];
    [blendFilter setValue:inputCIImage forKeyPath:@"inputBackgroundImage"];
    CIImage * blendOutput = [blendFilter outputImage];
    [grayFilter setValue:blendOutput forKeyPath:@"inputImage"];
    CIImage * outputCIImage = [grayFilter outputImage];
    // 6. Render your output image
    CIContext * context = [CIContext contextWithOptions:nil];
    CGImageRef outputCGImage = [context createCGImage:outputCIImage fromRect:[outputCIImage extent]];
    UIImage * outputImage = [UIImage imageWithCGImage:outputCGImage];
    CGImageRelease(outputCGImage);
    return outputImage;
}




+ (UIImage *)createPaddedGhostImageWithSize:(CGSize)inputSize {
    UIImage * ghostImage = [UIImage imageNamed:@"image8"];
    CGFloat ghostImageAspectRatio = ghostImage.size.width / ghostImage.size.height;
    NSInteger targetGhostWidth = inputSize.width * 0.25;
    CGSize ghostSize = CGSizeMake(targetGhostWidth, targetGhostWidth / ghostImageAspectRatio);
    CGPoint ghostOrigin = CGPointMake(inputSize.width * 0.5, inputSize.height * 0.2);
    CGRect ghostRect = {ghostOrigin, ghostSize};
    UIGraphicsBeginImageContext(inputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect inputRect = {CGPointZero, inputSize};
    CGContextClearRect(context, inputRect);
    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-inputSize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedGhostRect = CGRectApplyAffineTransform(ghostRect, flipThenShift);
    CGContextDrawImage(context, transformedGhostRect, [ghostImage CGImage]);
    UIImage * paddedGhost = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return paddedGhost;

}








@end
