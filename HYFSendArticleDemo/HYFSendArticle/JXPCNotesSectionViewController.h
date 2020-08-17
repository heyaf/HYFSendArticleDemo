//
//  JXPCNotesSectionViewController.h
//  JXPClientSideProject
//
//  Created by iOS on 2020/8/3.
//  Copyright © 2020 he. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface JXPCNotesSectionViewController : UIViewController

@property (nonatomic,strong) NSString *titleStr;

@property (nonatomic,strong) NSString *titleId;

@property (nonatomic,copy) void(^maksureBlock)(NSString *beforeString,NSString *newString,NSString *titleId);
@end

NS_ASSUME_NONNULL_END
