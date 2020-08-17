//
//  UIView+Frame.h
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/17.
//  Copyright © 2020 heyafei. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Frame)
@property(nonatomic, assign)CGFloat x;
@property(nonatomic, assign)CGFloat y;
@property(nonatomic, assign)CGFloat width;
@property(nonatomic, assign)CGFloat height;
@property(nonatomic, assign)CGSize size;
@property(nonatomic, assign)CGPoint origin;
@property(nonatomic, assign)CGFloat centerX;
@property(nonatomic, assign)CGFloat centerY;


@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
-(void)removeAllSubviews;
@end

NS_ASSUME_NONNULL_END
