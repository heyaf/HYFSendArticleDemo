//
//  ViewController.m
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/12.
//  Copyright © 2020 heyafei. All rights reserved.
//

#import "ViewController.h"
#import "HYFSendArticleViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kWhiteColor;
    self.navigationItem.title = @"首页";
    UIButton *senBtn = [UIButton buttonWithType:0];
    senBtn.frame = CGRectMake(0, 0, 100, 60);
    [senBtn setTitle:@"发表文章" forState:0];
    [senBtn setTitleColor:kBlackColor forState:0];
    [self.view addSubview:senBtn];
    senBtn.center = self.view.center;
    [senBtn addTarget:self action:@selector(pushSend) forControlEvents:UIControlEventTouchUpInside];
}
- (void)pushSend{
    HYFSendArticleViewController *sendVC = [[HYFSendArticleViewController alloc] init];
    ASLog(@"%@",self.navigationController);
    [self.navigationController pushViewController:sendVC animated:YES];
}

@end
