//
//  UIView+viewtoImage.h
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/17.
//  Copyright © 2020 heyafei. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (viewtoImage)
- (UIImage *)getImageFromView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
