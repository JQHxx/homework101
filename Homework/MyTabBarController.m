//
//  MyTabBarController.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyTabBarController.h"
#import "HomeViewController.h"
#import "TeacherViewController.h"
#import "MineViewController.h"
#import "BaseNavigationController.h"
#import "APPInfoManager.h"
#import "HWPopTool.h"


@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#B4B4B4"],NSFontAttributeName:[UIFont mediumFontWithSize:10]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FF7568"],NSFontAttributeName:[UIFont mediumFontWithSize:10]} forState:UIControlStateSelected];
    
    [UITabBar appearance].translucent = NO;
    
    self.tabBar.barStyle = UIBarStyleDefault;
    
    [self setTabbarBackView];
    [self initMyTabBar];
    [self loadVersionUpdateData];
}

-(void)viewWillLayoutSubviews{
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = kTabHeight;
    tabFrame.origin.y = kScreenHeight - kTabHeight;
    self.tabBar.frame = tabFrame;
}

#pragma mark -- Event response
#pragma mark 去更新
-(void)updateVersionAction{
    [[HWPopTool sharedInstance] closeWithBlcok:^{
        NSString *urlStr = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", APPID];
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:urlStr];
        [application openURL:URL options:@{} completionHandler:^(BOOL success) {
            MyLog(@"iOS10 Open %@: %d",urlStr,success);
        }];
    }];
}

#pragma mark 关闭更新
-(void)closeUpdateAction{
    [[HWPopTool sharedInstance] closeWithBlcok:nil];
}

#pragma mark -- Private Methods
#pragma mark 初始化
- (void)initMyTabBar{
    HomeViewController *mainVC = [[HomeViewController alloc] init];
    BaseNavigationController * nav1 = [[BaseNavigationController alloc] initWithRootViewController:mainVC];
    
    UITabBarItem * mainItem = [[UITabBarItem alloc] initWithTitle:@"辅导" image:[[UIImage imageNamed:@"home_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"home"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav1 setTabBarItem:mainItem];
    
    TeacherViewController *teacherVC = [[TeacherViewController alloc] init];
    BaseNavigationController * nav2 = [[BaseNavigationController alloc] initWithRootViewController:teacherVC];
    UITabBarItem * teacherItem = [[UITabBarItem alloc] initWithTitle:@"老师" image:[[UIImage imageNamed:@"teacher_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"teacher"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav2 setTabBarItem:teacherItem];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    BaseNavigationController * nav3 = [[BaseNavigationController alloc] initWithRootViewController:mineVC];
    UITabBarItem * mineItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[[UIImage imageNamed:@"my_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"my"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav3 setTabBarItem:mineItem];
    
    self.viewControllers = @[nav1,nav2,nav3];
}


-(void)setTabbarBackView{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTabHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:backView atIndex:0];
    self.tabBar.opaque = YES;
}

#pragma mark 版本更新
-(void)loadVersionUpdateData{
    NSString *version = [[APPInfoManager sharedAPPInfoManager] appBundleVersion];
    NSDictionary *params = @{@"version":version,@"system":@"ios"};
    [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kVersionUpdateAPI parameters:params success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *appVersion = [data valueForKey:@"app_version"];
        BOOL result = [version compare:appVersion] == NSOrderedAscending;
        if (result) {
            NSArray *appDesArr = [data valueForKey:@"app_des"];
            NSString *tempStr = @"";
            for (NSInteger i=0; i<appDesArr.count; i++) {
                NSString *valueStr = [NSString stringWithFormat:@"%ld.%@\n",i+1,appDesArr[i]];
                tempStr = [tempStr stringByAppendingString:valueStr];
            }
            NSInteger label = [[data valueForKey:@"label"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showVersionViewWithVerNum:appVersion verDesc:tempStr label:label];
            });
        }
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark 版本视图
-(void)showVersionViewWithVerNum:(NSString *)versionNum verDesc:(NSString *)versionDesc label:(NSInteger)label{
    CGFloat versionViewWidth = 280;
    
    UIView *contentView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, versionViewWidth, 600)];
    contentView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, versionViewWidth,166)];
    imgView.image = [UIImage imageNamed:@"version_update_photo"];
    [contentView addSubview:imgView];
    
    UILabel *subTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(20,imgView.bottom-27, versionViewWidth-40, 18)];
    subTitleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
    subTitleLab.textColor = [UIColor whiteColor];
    subTitleLab.textAlignment = NSTextAlignmentCenter;
    subTitleLab.text = [NSString stringWithFormat:@"V%@",versionNum];
    [contentView addSubview:subTitleLab];
    
    if (label<2) {
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(versionViewWidth-36, 88, 22, 22)];
        [closeBtn setImage:[UIImage imageNamed:@"version_update_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeUpdateAction) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:closeBtn];
        
    }
    
    UIView *subContentView = [[UIView alloc] initWithFrame:CGRectMake(0,imgView.bottom, versionViewWidth, 200)];
    subContentView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:subContentView];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    contentLabel.text = versionDesc;
    CGSize size = [contentLabel.text boundingRectWithSize:CGSizeMake(versionViewWidth-50, CGFLOAT_MAX) withTextFont:contentLabel.font];
    contentLabel.frame = CGRectMake(25,10,versionViewWidth-50, size.height);
    [subContentView addSubview:contentLabel];
    
    UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, contentLabel.bottom, versionViewWidth-60,50)];
    [updateBtn setBackgroundImage:[UIImage imageNamed:@"version_update_button"] forState:UIControlStateNormal];
    [updateBtn addTarget:self action:@selector(updateVersionAction) forControlEvents:UIControlEventTouchUpInside];
    [subContentView addSubview:updateBtn];
    
    subContentView.frame = CGRectMake(0, imgView.bottom, versionViewWidth, updateBtn.bottom+10);
    [subContentView setBorderWithCornerRadius:5.0 type:UIViewCornerTypeAll];
    contentView.frame = CGRectMake(0, 0,versionViewWidth, subContentView.bottom);
    
    [HWPopTool sharedInstance].shadeBackgroundType = ShadeBackgroundTypeSolid;
    [HWPopTool sharedInstance].closeButtonType = ButtonPositionTypeNone;
    [HWPopTool sharedInstance].tapOutsideToDismiss = NO;
    [[HWPopTool sharedInstance] showWithPresentView:contentView animated:YES];
}

@end
