//
//  UIView+viewtoImage.m
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/17.
//  Copyright © 2020 heyafei. All rights reserved.
//

#import "UIView+viewtoImage.h"



@implementation UIView (viewtoImage)
- (UIImage *)getImageFromView:(UIView *)view{
    
//    UIGraphicsBeginImageContext(view.bounds.size);
//    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
    
    UIGraphicsBeginImageContextWithOptions(view.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
