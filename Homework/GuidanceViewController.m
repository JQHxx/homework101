//
//  GuidanceViewController.m
//  Tianjiyun
//
//  Created by vision on 16/9/20.
//  Copyright © 2016年 vision. All rights reserved.
//

#import "GuidanceViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import <UMAnalytics/MobClick.h>

@interface GuidanceViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
}
@end

@implementation GuidanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self initGuidanceView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"引导页"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"引导页"];
}

#pragma mark --Private methods
#pragma mark 初始化引导页
-(void)initGuidanceView{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor=[UIColor whiteColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth * 4,kScreenHeight);
    
    for (int i = 0; i < 4; i++) {
        UIImage *image = IS_IPHONE_Xr?[UIImage imageNamed:[NSString stringWithFormat:@"xr_iosguide0%d",i+1]]:[UIImage imageNamed:[NSString stringWithFormat:@"iosguide0%d", i+1]];
        UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0,kScreenWidth, kScreenHeight)];
        [contentView setImage:image];
        [_scrollView addSubview:contentView];
        
        if (i == 3) {
            UIImage *image = [UIImage imageNamed:@"start"];
            CGRect btnFrame = kScreenWidth<375.0?CGRectMake(kScreenWidth*3+(kScreenWidth-180)/2, kScreenHeight-60, 180, 40):CGRectMake(kScreenWidth*3+(kScreenWidth-180)/2, kScreenHeight-70, 180, 40);
            UIButton *button = [[UIButton alloc] initWithFrame:btnFrame];
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(startUse:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:button];
            
        }
    }
}
#pragma mark --Response Methods
#pragma mark 进入app
- (void)startUse:(id)sender{
    
    [NSUserDefaultsInfos putKey:kShowGuidance andValue:[NSNumber numberWithBool:YES]];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:loginVC];
    AppDelegate *appDelegate=kAppDelegate;
    appDelegate.window.rootViewController= nav;
    
}
#pragma mark 切换图片
- (void)pageChanged:(UIPageControl *)pageControl{
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * pageControl.currentPage, 0, _scrollView.width, _scrollView.height) animated:YES];
}

@end
