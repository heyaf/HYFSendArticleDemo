//
//  AppDelegate.m
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/12.
//  Copyright © 2020 heyafei. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init] ];
    self.window.rootViewController =nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}





@end
