//
//  CustomerServiceViewController.m
//  Homework
//
//  Created by vision on 2019/10/16.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CustomerServiceViewController.h"
#import <UMAnalytics/MobClick.h>

@interface CustomerServiceViewController ()

@property (nonatomic,strong) UIView               *navView;

@end

@implementation CustomerServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.navView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"在线客服"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"在线客服"];
}

#pragma mark 返回
-(void)serviceBackAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark 导航栏背景
-(UIView *)navView{
    if (!_navView) {
         _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
               
         UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
         [leftBtn setImage:[UIImage imageNamed:@"return_black"] forState:UIControlStateNormal];
         [leftBtn addTarget:self action:@selector(serviceBackAction:) forControlEvents:UIControlEventTouchUpInside];
         [_navView addSubview:leftBtn];
       
         UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-240)/2, KStatusHeight+12, 240, 22)];
         titleLab.textColor=[UIColor commonColor_black];
         titleLab.font=[UIFont mediumFontWithSize:18.0f];
         titleLab.textAlignment=NSTextAlignmentCenter;
         titleLab.text = @"在线客服";
         [_navView addSubview:titleLab];
    }
    return _navView;
}

@end
