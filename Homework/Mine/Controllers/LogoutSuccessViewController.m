//
//  LogoutSuccessViewController.m
//  Homework
//
//  Created by vision on 2019/10/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "LogoutSuccessViewController.h"

@interface LogoutSuccessViewController ()

@end

@implementation LogoutSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
    
    [self initLogoutSuccessView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"账号注销成功"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"账号注销成功"];
}

-(void)confirmAction:(UIButton *)sender{
    [HttpRequest signOut];
}

#pragma mark 初始化
-(void)initLogoutSuccessView{
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-70)/2.0,KStatusHeight+(IS_IPAD?64:51), 70, 82)];
    iconImageView.image = [UIImage imageNamed:@"purchase_success"];
    [self.view addSubview:iconImageView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20,iconImageView.bottom+15,kScreenWidth-40,IS_IPAD?32:20)];
    titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLab.font = [UIFont mediumFontWithSize:18];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"您的账号已经注销成功！";
    [self.view addSubview:titleLab];
    
    UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(20,titleLab.bottom+15,kScreenWidth-40,IS_IPAD?80:48)];
    tipsLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
    tipsLab.font = [UIFont regularFontWithSize:14];
    tipsLab.textAlignment = NSTextAlignmentCenter;
    tipsLab.numberOfLines = 0;
    tipsLab.text = @"7天内如需找回，请联系客服\n电话号码：15675858101";
    [self.view addSubview:tipsLab];
    
    UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(20,tipsLab.bottom+15,kScreenWidth-40,IS_IPAD?36:24)];
    descLab.textColor = [UIColor colorWithHexString:@"#FF9100"];
    descLab.font = [UIFont regularFontWithSize:14];
    descLab.textAlignment = NSTextAlignmentCenter;
    descLab.text = @"*7天后，将彻底删除一切信息";
    [self.view addSubview:descLab];
    
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-85, 300, 62)];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
}


@end
