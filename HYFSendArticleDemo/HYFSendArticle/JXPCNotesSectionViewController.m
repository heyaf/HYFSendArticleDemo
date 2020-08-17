//
//  JXPCNotesSectionViewController.m
//  JXPClientSideProject
//
//  Created by iOS on 2020/8/3.
//  Copyright © 2020 he. All rights reserved.
//

#import "JXPCNotesSectionViewController.h"

@interface JXPCNotesSectionViewController ()

@property (nonatomic,strong) UIButton *rightBtn;
@property (nonatomic,strong) UITextField  *headerTitleTextfield;   //头部textfield
@property (nonatomic,strong) UILabel *numLabel;

@end

@implementation JXPCNotesSectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self baseSet];
}
-(void)baseSet{
    self.navigationItem.title = @"段落标题";
    self.view.backgroundColor = kWhiteColor;


    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    UIView *headerlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 0.5)];
     headerlineView.backgroundColor = kRGB(235, 235, 235);
    [self.view addSubview:headerlineView];
    [self setRightBtn];
    
    UIView *textfielBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, kScreenW, 85)];
    textfielBgView.backgroundColor = kWhiteColor;
    [self.view addSubview:textfielBgView];
    
    [textfielBgView addSubview:self.headerTitleTextfield];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenW-100, 57, 85, 14)];
    numLabel.text = @"0/15";
    numLabel.textColor = kMainGrayColor;
    numLabel.font = kNormalFont(14);
    numLabel.textAlignment = NSTextAlignmentRight;
    [textfielBgView addSubview:numLabel];
    _numLabel = numLabel;
    
    UIView *headerlineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 84.5, kScreenW, 0.5)];
     headerlineView1.backgroundColor = kRGB(235, 235, 235);
    [textfielBgView addSubview:headerlineView1];
    
    UIButton *messageBtn = [UIButton buttonWithType:0];
    messageBtn.frame = CGRectMake(5, 105, 75, 16);
    [messageBtn setImage:kIMAGE_Name(@"add_paragraph_prompt") forState:0];
    [messageBtn setTitle:@"提示" forState:0];
    [messageBtn setTitleColor:kRGB(153, 153, 153) forState:0];
    messageBtn.titleLabel.font = kNormalFont(15);
    [self.view addSubview:messageBtn];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 135, kScreenW-30, 15)];
    messageLabel.text = @"用段落标题给文章分段，使表达更清晰。";
    messageLabel.textColor = kMainGrayColor;
    messageLabel.font = kNormalFont(15);
    [self.view addSubview:messageLabel];
    
    
    UILabel *messageLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 160, kScreenW-30, 15)];
    messageLabel1.text = @"段落标题将以“目录”的形式存在。";
    messageLabel1.textColor = kMainGrayColor;
    messageLabel1.font = kNormalFont(15);
    [self.view addSubview:messageLabel1];
    
}
- (void)setRightBtn{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 60, 25);
    rightButton.titleLabel.font = kNormalFont(16);
    [rightButton setTitleColor:kRGB(0, 160, 233) forState:0];
    [rightButton setTitle:@"完成" forState:0];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 12, 6, 15)];
    if (self.titleStr.length>0) {
        [_rightBtn setTitleColor:kRGB(0, 160, 233) forState:0];
    }
    _rightBtn = rightButton;
    rightButton.adjustsImageWhenHighlighted = NO;
    [rightButton addTarget:self action:@selector(makesureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonitem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = rightButtonitem;
}

-(UITextField *)headerTitleTextfield{
    if (!_headerTitleTextfield) {
        _headerTitleTextfield = [[UITextField alloc] initWithFrame:CGRectMake(15, 17, kScreenW-30, 22)];
        _headerTitleTextfield.textColor = kMainBlackColor;
        _headerTitleTextfield.font = kBoldFont(18);
        _headerTitleTextfield.text = self.titleStr;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        // 设置富文本对象的颜色
        attributes[NSForegroundColorAttributeName] = kRGB(153, 153,153);
        attributes[NSFontAttributeName] = kNormalFont(18);
        [_headerTitleTextfield addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];

        _headerTitleTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入段落名称" attributes:attributes];
    }
    return _headerTitleTextfield;
}
#pragma mark - textField代理方法


-(void)changedTextField:(UITextField *)textField
{
    if (textField.text.length>15) {
        textField.text = [textField.text substringToIndex:15];
    }
//    if (textField.text.length==0) {
//        [_rightBtn setTitleColor:kRGB(153, 153, 153) forState:0];
//    }else{
//        [_rightBtn setTitleColor:kRGB(0, 160, 233) forState:0];
//    }
    _numLabel.text = kStringFormat(@"%lu/15",(unsigned long)textField.text.length);

}

- (void)makesureBtnClick{
    
//    if (self.headerTitleTextfield.text.length==0) {
//        return;
//    }
    if ([self.headerTitleTextfield.text isEqualToString:self.titleStr]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [_headerTitleTextfield resignFirstResponder];
    if (self.maksureBlock) {
        self.maksureBlock(self.titleStr, self.headerTitleTextfield.text,self.titleId);
    }
    [self.navigationController popViewControllerAnimated:YES];

}
@end
