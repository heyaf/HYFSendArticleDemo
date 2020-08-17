//
//  HYFSendArticleViewController.m
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/17.
//  Copyright © 2020 heyafei. All rights reserved.
//

#import "HYFSendArticleViewController.h"
#import "UITextView+GYCategory.h"
#import "LMTextHTMLParser.h"
#import "NSTextAttachment+LMText.h"
#import "JXPCNotesSectionViewController.h"
#import <TZImagePickerController/TZImagePickerController.h>

#import "NSString+Tool.h"
#define bottomViewH (115+48+ kSafeAreaBottom)
@interface HYFSendArticleViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate,TZImagePickerControllerDelegate>

@property (nonatomic,strong) UITextField  *headerTitleTextfield;   //头部textfield
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,assign) NSInteger indeximage; //图片index

@property (nonatomic,assign) NSInteger scenicIndexId; //段落index
@property (nonatomic,strong) NSString *qiniuToken; //七牛云token

@property (nonatomic,strong) UITextView *textView;

@property (nonatomic,strong) UIScrollView *tagScrollview;  //类别背景
@property (nonatomic,strong) UIView *bottomView;   //底部视图
@property (nonatomic,strong) UIButton *sendBtn;

@property (nonatomic,assign) CGFloat cursorPosition;

@property (nonatomic,assign) BOOL keyBoardShow;   //键盘是否弹起

//@property (nonatomic,strong) NSMutableArray *sectionDatamutArray;
//@property (nonatomic,strong) NSMutableArray *titleDataArray;

@property (nonatomic,strong) NSArray *tagArray;
@property (nonatomic,strong) NSMutableArray *selectTagIdArray;

@property (nonatomic,strong) UIButton *menuBtn;

@property (nonatomic, strong)UILabel *placeHolderLabel;

@end

@implementation HYFSendArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self baseSet];
    
    ASLog(@"-----%d,%d",kSafeAreaBottom,kNavBarHeight);
    
    [self CreatTagData];
    [self gettoken];
    //监听键盘frame改变
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    //禁止返回
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 先设置测滑代理
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    // 将系统自带的滑动手势打开
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)baseSet{
    self.navigationItem.title = @"发表游记";
    self.view.backgroundColor = kWhiteColor;
    self.indeximage = 1;
    self.scenicIndexId = 10000;
//    self.sectionDatamutArray = [NSMutableArray arrayWithCapacity:0];
    self.selectTagIdArray = [NSMutableArray arrayWithCapacity:0];
//    self.titleDataArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    UIView *headerlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 0.5)];
     headerlineView.backgroundColor = kRGB(232, 232, 232);
    [self.view addSubview:headerlineView];
    
    [self.view addSubview:self.tableView];
    [self CreatBottomUI];
}
- (void)CreatBottomUI{
    UIView *tagBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH-bottomViewH-kNavBarHeight, kScreenW, 115)];
    tagBgView.backgroundColor = kWhiteColor;
    [self.view addSubview:tagBgView];
    
    UIView *headerlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 0.5)];
     headerlineView.backgroundColor = kRGB(232, 232, 232);
    [tagBgView addSubview:headerlineView];
    
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 50, 17)];
    tagLabel.text = @"标签";
    tagLabel.textColor = kMainBlackColor;
    tagLabel.font = kBoldFont(18);
    [tagBgView addSubview:tagLabel];
    
    UILabel *tagLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, kScreenW-30, 14)];
    tagLabel1.text = @"添加标签，会让更多人看到你的游记哦";
    tagLabel1.textColor = kMainGrayColor;
    tagLabel1.font = kNormalFont(14);
    [tagBgView addSubview:tagLabel1];
    
    
    UIScrollView *tagScrollView = [[UIScrollView alloc] init];
    tagScrollView.frame = CGRectMake(15, 60, kScreenW-15, 50);
    [tagBgView addSubview:tagScrollView];
    tagScrollView.showsHorizontalScrollIndicator = NO;
    _tagScrollview = tagScrollView;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH-kSafeAreaBottom-48-kNavBarHeight, kScreenW, 48)];
    [self.view addSubview:bottomView];
    UIView *headerlineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 0.5)];
     headerlineView1.backgroundColor = kRGB(232, 232, 232);
    [bottomView addSubview:headerlineView1];
    bottomView.backgroundColor = kWhiteColor;
    _bottomView = bottomView;
    
    UIButton *imageBtn = [UIButton buttonWithType:0];
    imageBtn.frame = CGRectMake(5, 5, 40, 40);
    [imageBtn setImage:kIMAGE_Name(@"published_travel_add_images") forState:0];
    [imageBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [imageBtn addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:imageBtn];
    
    UIButton *sectionBtn = [UIButton buttonWithType:0];
    sectionBtn.frame = CGRectMake(60, 5, 40, 40);
    [sectionBtn setImage:kIMAGE_Name(@"published_travel_add_paragraph") forState:0];
    [sectionBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [sectionBtn addTarget:self action:@selector(addsection) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sectionBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:0];
    sendBtn.frame = CGRectMake(kScreenW-55, 5, 50, 40);
    [sendBtn setTitle:@"发表" forState:0];
    sendBtn.titleLabel.font = kNormalFont(16);
    [sendBtn setTitleColor:kRGB(153, 153, 153) forState:0];
    [sendBtn addTarget:self action:@selector(sendTravelNotes) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sendBtn];
    _sendBtn = sendBtn;
}
//请求标签数据
- (void)CreatTagData{
//    NSString *URL = [baseUrl stringByAppendingFormat:@"%@?clientScenicSpotBasicCity=%@",getTravelLatelList,kGetUserDefaults(kStatuesCityName)];
//    [NetDataTool GET:URL parameters:nil success:^(id  _Nonnull responseObject) {
//        NSDictionary * dic = [NetDataTool ManagerDataWithdata:responseObject];
//        if (![dic isKindOfClass:[NSDictionary class]]){
//            return;
//        };
//        if ([dic count]) {
//            NSMutableArray *idArr = [NSMutableArray arrayWithArray:dic[@"clientCityVideolatelList"]];
//            for (NSDictionary *tagdic in idArr) {
//                if ([tagdic[@"cityName"] isEqualToString:@"全部"]) {
//                    [self.selectTagIdArray addObject:tagdic[@"id"]];
//                    [idArr removeObject:tagdic];
//                    break;
//                }
//            }
//
//        }else{
//        }
//    } failure:^(NSError * _Nonnull error) {
//        [MFHUDManager showError:@"网络连接异常，请检查网络后重试"];
//    }];
    
    self.tagArray = @[@"美食",@"景点",@"购物",@"娱乐"];
    [self creatTagBtn];
}
//七牛云token
-(void)gettoken{
//    [NetDataTool GET:[baseUrl stringByAppendingString:getqiqiuToken] parameters:nil success:^(id responseObject) {
//        NSString *str = [NetDataTool ManagerDataWithdata:responseObject];
//        NSString *codeStr = [str componentsSeparatedByString:@"&"][0];
//        if ([codeStr isEqualToString:@"success"]) {
//            self.qiniuToken = [str componentsSeparatedByString:@"&"][1];
//        }
//    } failure:^(NSError *error) {
//
//    }];
}
-(UITableView *)tableView{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0.5, kScreenW, kScreenH-kNavBarHeight-bottomViewH) style:UITableViewStylePlain];
        _tableView.delegate =self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tag = 20;
        _tableView.bounces = NO;
    }
    return _tableView;
}
- (void)CreatMenuView{
    if (!_menuBtn) {
        UIButton *menuBtn = [UIButton buttonWithType:0];
        menuBtn.frame = CGRectMake(0, kScreenH-203-kSafeAreaBottom-31-kNavBarHeight, 100, 31);
        menuBtn.backgroundColor = kClearColor;
        [menuBtn setBackgroundImage:kIMAGE_Name(@"general_directory_with_the_word") forState:0];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        _menuBtn = menuBtn;
    }else{
        _menuBtn.hidden = NO;
        
    }
        

    
}
#pragma mark  -----事件处理-----
- (void)chooseImage{
    NSInteger i = 1;
    TZImagePickerController *controller = [[TZImagePickerController alloc] initWithMaxImagesCount:i delegate:self];
    controller.allowTakeVideo = NO;
    controller.allowPickingVideo = NO;
    controller.allowPickingGif = NO;
    controller.modalPresentationStyle = 0;
    [self presentViewController:controller animated:YES completion:nil];
}
//目录按钮点击
- (void)menuBtnClicked{
    

}
//添加段落
- (void)addsection{
    
    JXPCNotesSectionViewController *notesSectionVC = [[JXPCNotesSectionViewController alloc] init];
    [self.navigationController pushViewController:notesSectionVC animated:YES];
    __weak typeof(self) weakself = self;

    notesSectionVC.maksureBlock = ^(NSString * _Nonnull beforeString, NSString * _Nonnull newString, NSString * _Nonnull titleId) {
        if (beforeString.length==0) {  //此时是新建标题
            UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenW-30, 40)];
            sectionLabel.backgroundColor = kWhiteColor;
            sectionLabel.text = newString;
            sectionLabel.textColor = kMainBlackColor;
            sectionLabel.font = kBoldFont(18);
            UIImage *image = [sectionLabel getImageFromView:sectionLabel];
            NSTextAttachment* textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            textAttachment.bounds = CGRectMake(0, 0, kScreenW-30, 40);

            NSMutableAttributedString *mutString = [NSMutableAttributedString attributedStringWithAttachment:textAttachment];
            

            NSMutableAttributedString *attriStr = [weakself.textView.attributedText mutableCopy];
            textAttachment.attachmentType = LMTextAttachmentTypeCheckBox;

            dispatch_group_t group = dispatch_group_create();

            textAttachment.userInfo = kStringFormat(@"%li+%@",self.scenicIndexId,newString);
            [mutString addAttribute:NSLinkAttributeName value:kStringFormat(@"%li",self.scenicIndexId) range:NSMakeRange(0, 1)];
            weakself.textView.linkTextAttributes = @{ NSForegroundColorAttributeName: kMainBlackColor,
            };
            self.scenicIndexId++;

            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                
                [attriStr insertAttributedString:mutString atIndex:weakself.textView.selectedRange.location];
                weakself.textView.attributedText = attriStr;
                
                NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"\n\n\n"];
                [attriStr insertAttributedString:attStr atIndex:weakself.textView.selectedRange.location];
                [attriStr addAttributes:@{NSFontAttributeName: kNormalFont(15)} range:NSMakeRange(0, attriStr.length)];
                weakself.textView.attributedText = attriStr;

                [self CreatMenuView];
                self.placeHolderLabel.alpha = 0;
            });
        }
    };

}



//发表
- (void)sendTravelNotes{
    NSAttributedString *attributedString = _textView.attributedText;
    if (attributedString.length==0||[[self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return;
    }

    NSRange effectiveRange = NSMakeRange(0, 0);
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:0];
    NSString *clientSectionId = @"";
    
    while (effectiveRange.location + effectiveRange.length < attributedString.length) {
        NSDictionary *attributes = [attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            if (attachment.attachmentType ==LMTextAttachmentTypeImage) {
                NSDictionary *valueDic = @{
                    @"contentType":@(1),
                    @"travelContent":attachment.userInfo,
                    @"clientSectionId":clientSectionId
                };
                [dataArr addObject:valueDic];
            }else{
                clientSectionId = [attachment.userInfo componentsSeparatedByString:@"+"][0];
            }
        }else{
            NSString *text = [[attributedString string] substringWithRange:effectiveRange];
            if (text.length>0) {

                text = [text stringByReplacingOccurrencesOfString:@"\n\n\n\n\n\n" withString:@""];
                text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSDictionary *valueDic = @{
                    @"contentType":@(0),
                    @"travelContent":text,
                    @"clientSectionId":clientSectionId
                };
                [dataArr addObject:valueDic];
            }
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    NSInteger state=0;  //记录内容 0表示不含文本或者图片
    for (NSDictionary*dictionAry in dataArr) {
        if (![NSString isEmpty:dictionAry[@"travelContent"]]) {
            state =1;
        }
    }
    if (state==0) {
        return;
    }
    ASLog(@"文章数据%@",dataArr);

}
#pragma mark - TZImage Picker Controller Delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    for (UIImage *chooseImage in photos) {
        
        NSTextAttachment* textAttachment = [[NSTextAttachment alloc] init];
        CGSize size = CGSizeZero;

        if (chooseImage.size.height>chooseImage.size.width) {
            size = CGSizeMake(kScreenW-30, (kScreenW-30)/9*16+20);
        }else{
            size = CGSizeMake(kScreenW-30, (kScreenW-30)/4*3+20);

        }

        UIImage *sizeImage = [self Resize:chooseImage toSize:size];
        textAttachment.image = [self getCornerRadius:sizeImage];

        textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);
        NSAttributedString* imageAttachment = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);

//        QNUploadManager *upManager = [[QNUploadManager alloc] init];
//       QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
//       }
//                                                                    params:nil
//                                                                  checkCrc:NO
//                                                        cancellationSignal:nil];
//       [upManager putFile:[self getImagePath:chooseImage index:self.indeximage] key:nil token:self.qiniuToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//
//           textAttachment.userInfo = resp[@"key"];
           dispatch_group_leave(group);

//       }
//        option:uploadOption];

        __weak typeof(self) weakself = self;
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSMutableAttributedString *attriStr = [weakself.textView.attributedText mutableCopy];
            textAttachment.attachmentType = LMTextAttachmentTypeImage;
            
            self.indeximage++;
            [attriStr insertAttributedString:imageAttachment atIndex:weakself.textView.selectedRange.location];
            NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"\n\n"];
            [attriStr appendAttributedString:attStr];
            
            [attriStr addAttributes:@{NSFontAttributeName: kNormalFont(15)} range:NSMakeRange(0, attriStr.length)];
            weakself.textView.attributedText = attriStr;
            [self.sendBtn setTitleColor:kRGB(0, 160, 233) forState:0];
            self.placeHolderLabel.alpha= 0;
            
        });
        
    }
}

#pragma mark ---标题---

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELLID"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section==0) {
        [cell.contentView addSubview:self.headerTitleTextfield];
        cell.contentView.backgroundColor = kWhiteColor;
        UIView *headerlineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, kScreenW, 0.5)];
        headerlineView.backgroundColor = kRGB(240, 240, 240);
        [cell.contentView addSubview:headerlineView];
    }else if (indexPath.section==1){
        [cell.contentView addSubview:self.textView];
        cell.contentView.backgroundColor = kWhiteColor;

    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 56;
    }
    return _textView.height+20;
}
-(UITextField *)headerTitleTextfield{
    if (!_headerTitleTextfield) {
        _headerTitleTextfield = [[UITextField alloc] initWithFrame:CGRectMake(13, 17, kScreenW-30, 22)];
        _headerTitleTextfield.delegate = self;
        _headerTitleTextfield.textColor = kMainBlackColor;
        _headerTitleTextfield.font = kBoldFont(18);
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        // 设置富文本对象的颜色
        attributes[NSForegroundColorAttributeName] = kRGB(153, 153,153);
        attributes[NSFontAttributeName] = kBoldFont(18);
        [_headerTitleTextfield addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];

        _headerTitleTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入游记标题" attributes:attributes];
        if (self.titleStr.length>0) {
            _headerTitleTextfield.text = self.titleStr;
        }
    }
    return _headerTitleTextfield;
}
-(UITextView *)textView{
    if (!_textView) {
        _textView=[[UITextView alloc]initWithFrame:CGRectMake(10, 10, kScreenW-20, kScreenH-kNavBarHeight-bottomViewH-56-20)];
        [_textView setTextColor:kMainBlackColor];
        [_textView setFont:kNormalFont(15)];
        _textView.scrollEnabled = YES;    // 不允许滚动
        _textView.backgroundColor = kWhiteColor;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.tag = 555;

        [_textView setDelegate:self];
        
        self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 14)];
        self.placeHolderLabel.text = @"请输入正文";
        self.placeHolderLabel.textColor = kRGB(153, 1531, 53);
        self.placeHolderLabel.font = kNormalFont(15);
        self.placeHolderLabel.enabled = NO;
        [_textView addSubview:self.placeHolderLabel];

    }
    return _textView;
}
#pragma mark - textField代理方法

-(void)changedTextField:(UITextField *)textField
{
    if (textField.text.length>15) {
        textField.text = [textField.text substringToIndex:15];
    }
}
-(void)textViewDidChange:(UITextView *)textView{
   
    
   NSAttributedString *attributedString = _textView.attributedText;
   NSRange effectiveRange = NSMakeRange(0, 0);
   NSMutableArray *titleArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:0];

   
   while (effectiveRange.location + effectiveRange.length < attributedString.length) {
       NSDictionary *attributes = [attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
       NSTextAttachment *attachment = attributes[@"NSAttachment"];
       if (attachment) {
           if (attachment.attachmentType ==LMTextAttachmentTypeImage) {
           }else{
               [titleArr addObject:attachment.userInfo];
           }
       }else{
           NSString *text = [[attributedString string] substringWithRange:effectiveRange];
           if (text.length>0) {

               text = [text stringByReplacingOccurrencesOfString:@"\n\n\n\n\n\n" withString:@""];
               text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
               NSDictionary *valueDic = @{
                   @"contentType":@(0),
                   @"travelContent":text,
                   @"clientSectionId":@"1"
               };
               [dataArr addObject:valueDic];
           }
       }
       effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
   }
    NSInteger state=0;  //记录内容 0表示不含文本或者图片
    for (NSDictionary*dictionAry in dataArr) {
        if (![NSString isEmpty:dictionAry[@"travelContent"]]) {
            state =1;
        }
    }
    if (state==0) {
        [self.sendBtn setTitleColor:kRGB(153, 153, 153) forState:0];

    }else{
        [self.sendBtn setTitleColor:kRGB(0, 160, 233) forState:0];

    }
    if (titleArr.count==0) {
        self.menuBtn.hidden = YES;
    }
    
    


}



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHolderLabel.alpha = 0;//开始编辑时
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{//将要停止编辑(不是第一响应者时)
    if ([NSString isEmpty:textView.text]&&textView.tag==555) {
        self.placeHolderLabel.alpha = 1;
    }
    return YES;
}
#pragma mark - 点击label文字识别跳转



-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    NSInteger scenicId = [[URL absoluteString] integerValue];
    NSString *scenicName = [self getSectionNameWithId:scenicId];
    NSInteger loction = [self getSectionLocWithId:scenicId];

//
    JXPCNotesSectionViewController *notesSectionVC = [[JXPCNotesSectionViewController alloc] init];
    notesSectionVC.titleStr = scenicName;
    [self.navigationController pushViewController:notesSectionVC animated:YES];
    __weak typeof(self) weakself = self;
    notesSectionVC.maksureBlock = ^(NSString * _Nonnull beforeString, NSString * _Nonnull newString, NSString * _Nonnull titleId) {
   
        NSAttributedString *attributedString =weakself.textView.attributedText;


        if (newString.length>0) {  //此时是替换标题
            UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenW-30, 40)];
            sectionLabel.backgroundColor = kWhiteColor;
            sectionLabel.text = newString;
            sectionLabel.textColor = kMainBlackColor;
            sectionLabel.font = kBoldFont(18);
            UIImage *image = [sectionLabel getImageFromView:sectionLabel];
            NSTextAttachment* textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = image;
            textAttachment.bounds = CGRectMake(0, 0, kScreenW-30, 40);

            NSMutableAttributedString *mutString = [NSMutableAttributedString attributedStringWithAttachment:textAttachment];

   
               NSMutableAttributedString *attriStr = [weakself.textView.attributedText mutableCopy];
               textAttachment.attachmentType = LMTextAttachmentTypeCheckBox;

               dispatch_group_t group = dispatch_group_create();

               textAttachment.userInfo = kStringFormat(@"%li+%@",self.scenicIndexId,newString);
               [mutString addAttribute:NSLinkAttributeName value:kStringFormat(@"%li",self.scenicIndexId) range:NSMakeRange(0, 1)];
                  weakself.textView.linkTextAttributes = @{ NSForegroundColorAttributeName: kMainBlackColor,
                  };
            self.scenicIndexId++;
//

               dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                   [attriStr replaceCharactersInRange:NSMakeRange(loction, 1) withAttributedString:mutString];
//                   [attriStr insertAttributedString:mutString atIndex:weakself.textView.selectedRange.location];
                   NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"\n\n\n"];
                   [attriStr insertAttributedString:attStr atIndex:loction];
                   [attriStr addAttributes:@{NSFontAttributeName: kNormalFont(15)} range:NSMakeRange(0, attriStr.length)];
                   weakself.textView.attributedText = attriStr;
       

               });


        }else{
            NSMutableAttributedString *attriStr = [weakself.textView.attributedText mutableCopy];
            NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:@""];
            [attriStr replaceCharactersInRange:NSMakeRange(loction, 1) withAttributedString:mutStr];
            NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:@"\n"];
            [attriStr appendAttributedString:attStr];
            [attriStr addAttributes:@{NSFontAttributeName: kNormalFont(15)} range:NSMakeRange(0, attriStr.length)];
            weakself.textView.attributedText = attriStr;
        }
    };
    
    
    return NO;
}
//textview代理事件


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.tag ==20) {
    }else{
        ASLog(@"-开始-");
        if (self.keyBoardShow) {
            return;
        }
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        if (scrollView.contentOffset.y>56) {
            
            if (translatedPoint.y<0) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.tableView.contentOffset = CGPointMake(0, 56);
                }completion:^(BOOL finished) {
//                    self.textView.height = kScreenH-kNavBarHeight-bottomViewH-20;

                } ];
            }
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.contentOffset = CGPointMake(0, 0);
            } completion:^(BOOL finished) {
//                self.textView.height = kScreenH-kNavBarHeight-bottomViewH-56-20;
            }];
            
        }
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.tag!=20) {
        __weak typeof(self) weakself = self;;

        if (scrollView.contentOffset.y>56) {
            [UIView animateWithDuration:0.2 animations:^{
                weakself.textView.height = kScreenH-kNavBarHeight-bottomViewH-20;
            }completion:^(BOOL finished) {
//                [self.tableView reloadData];
            }];

        }else{
            [UIView animateWithDuration:0.2 animations:^{
                weakself.textView.height = kScreenH-kNavBarHeight-bottomViewH-56-20;

            } completion:^(BOOL finished) {
//                [self.tableView reloadData];

            }];
        }

    }

}
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    if (scrollView.tag!=20) {
//        __weak typeof(self) weakself = self;;
//
//        if (scrollView.contentOffset.y>56) {
//            [UIView animateWithDuration:0.2 animations:^{
//                weakself.textView.height = kScreenH-kNavBarHeight-bottomViewH-20;
//            }completion:^(BOOL finished) {
////                [self.tableView reloadData];
//            }];
//
//        }else{
//            [UIView animateWithDuration:0.2 animations:^{
//                weakself.textView.height = kScreenH-kNavBarHeight-bottomViewH-56-20;
//
//            } completion:^(BOOL finished) {
////                [self.tableView reloadData];
//
//            }];
//        }
//
//    }
//
//}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
//-(void)textViewDidChange:(UITextView *)textView{
//
//    if (textView.selectedTextRange) {
//
//        _cursorPosition = [textView caretRectForPosition:textView.selectedTextRange.start].origin.y;
//
//    } else {
//
//        _cursorPosition =0;
//    }
//
//}


#pragma mark ---键盘事件监听------

//常见tag按钮子视图
-(void)creatTagBtn{
    
   //间距
    CGFloat padding =15;
    CGFloat titBtnX =0;
    CGFloat titBtnY =10;
    CGFloat titBtnH =30;
     for(int i =0; i <self.tagArray.count; i++){
         UIButton *titBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         titBtn.tag = 1000+i;
         [titBtn setTitle:_tagArray[i] forState:UIControlStateNormal];
         titBtn.titleLabel.font= [UIFont systemFontOfSize:13];
         [titBtn setTitleColor:kRGB(153, 153, 153) forState:0];
          [titBtn addTarget:self action:@selector(tagButtonClick:) forControlEvents:UIControlEventTouchUpInside];
         CGSize titleSize = [_tagArray[i] boundingRectWithSize:CGSizeMake(MAXFLOAT, titBtnH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titBtn.titleLabel.font} context:nil].size;

         CGFloat titBtnW = titleSize.width+2* 25;
         titBtn.frame=CGRectMake(titBtnX, titBtnY, titBtnW, titBtnH);

         titBtnX += titBtnW + padding;
         [self.tagScrollview addSubview:titBtn];
         kViewRadius(titBtn, 15);
         titBtn.backgroundColor = kRGB(245, 245, 245);
         
         if (titBtnX>kScreenW-15) {
             self.tagScrollview.contentSize = CGSizeMake(titBtnX, 0);
         }

     }

}

//点击事件

- (void)tagButtonClick:(UIButton*)btn{
    NSInteger index = btn.tag-1000;

    NSInteger tagId = [self.tagArray[index] integerValue];
    if ([self.selectTagIdArray containsObject:@(tagId)]) {
        [self.selectTagIdArray removeObject:@(tagId)];
        
        [btn setTitleColor:kRGB(153, 153, 153) forState:0];
        [btn setBackgroundColor:kRGB(245, 245, 245)];
        kViewBorderRadius(btn, 15, 0, kClearColor);
    }else{
        [self.selectTagIdArray addObject:@(tagId)];
        [btn setBackgroundColor:kRGB(242, 255, 251)];
        kViewBorderRadius(btn, 15, 0.5, kRGB(71, 204, 160));
        [btn setTitleColor:kRGB(71, 204, 160) forState:0];
    }

}
//键盘将要弹出
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度 keyboardHeight
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.height = kScreenH-kNavBarHeight-48-keyboardHeight;
        weakself.bottomView.y = kScreenH-keyboardHeight-48-kNavBarHeight;
        self.textView.height = self.tableView.height-56-20;
    }];
    self.keyBoardShow = YES;
}

//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification{
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.height = kScreenH-kNavBarHeight-bottomViewH;
        weakself.bottomView.y = kScreenH-kNavBarHeight-kSafeAreaBottom-48;
        self.textView.height = kScreenH-kNavBarHeight-bottomViewH-56-20;
    } completion:^(BOOL finished) {
        
    }];
    
    weakself.keyBoardShow = NO;



}
#pragma mark ---段落处理-----
//根据段落ID获取段落位置
- (NSInteger)getSectionLocWithId:(NSInteger)sectionId{
    NSAttributedString *attributedString = _textView.attributedText;

    NSRange effectiveRange = NSMakeRange(0, 0);
    NSInteger loction =0;
    while (effectiveRange.location + effectiveRange.length < attributedString.length) {
        NSDictionary *attributes = [attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            if (attachment.attachmentType ==LMTextAttachmentTypeImage) {
              
            }else{
               NSInteger clientSectionId = [[attachment.userInfo componentsSeparatedByString:@"+"][0] intValue];
                if (clientSectionId==sectionId) {
                    loction =  effectiveRange.location;
                }
            }
        }else{
           
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    return loction;
}
//根据段落ID获取段落标题
- (NSString *)getSectionNameWithId:(NSInteger)sectionId{
    NSAttributedString *attributedString = _textView.attributedText;

    NSRange effectiveRange = NSMakeRange(0, 0);
    NSString *scenicName = @"";
    while (effectiveRange.location + effectiveRange.length < attributedString.length) {
        NSDictionary *attributes = [attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            if (attachment.attachmentType ==LMTextAttachmentTypeImage) {
              
            }else{
               NSInteger clientSectionId = [[attachment.userInfo componentsSeparatedByString:@"+"][0] intValue];
                if (clientSectionId==sectionId) {
                    scenicName =  [attachment.userInfo componentsSeparatedByString:@"+"][1];
                }
            }
        }else{
           
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    return scenicName;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
//表情符号的判断
- (BOOL)stringContainsEmoji:(NSString *)string {

    __block BOOL returnValue = NO;

    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        if (0x278b <= hs && hs <= 0x2792) {
                                            //自带九宫格拼音键盘
                                            returnValue = NO;;
                                        }else if (0x263b == hs) {
                                            returnValue = NO;;
                                        }else {
                                            returnValue = YES;
                                        }
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];

    return returnValue;
}

#pragma mark ---图片处理---

//照片获取本地路径转换
- (NSString *)getImagePath:(UIImage *)Image index:(NSInteger) index{
    NSString *filePath = nil;
    NSData *data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }

    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
//    NSString *ImagePath = kStringFormat(@"/TravelNotes/the%liImage.png",index);
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/theFirstImage.png"];

    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];

    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
}

- (UIImage *)getCornerRadius:(UIImage *)image
{
    //开启图片的上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGRect imageRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    //绘制圆角矩形
    [[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:15.0] addClip];
    //绘制图片
    [image drawInRect:imageRect];
    //从上下文中获取图片
    UIImage *finalimage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图片的上下文
    UIGraphicsEndImageContext();
    return finalimage;
}
-(UIImage*)Resize:(UIImage*)sourceImage toSize:(CGSize)targetSize{
//  UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor){
            scaleFactor = widthFactor; // scale to fit height
        }else{
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else{
            if (widthFactor < heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
        }
        UIGraphicsBeginImageContext(targetSize); // this will crop
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width  = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        [sourceImage drawInRect:thumbnailRect];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if(newImage == nil){
            NSLog(@"could not scale image");
        }
        //pop the context to get back to the default
        UIGraphicsEndImageContext();
        
        return newImage;
    }


@end
