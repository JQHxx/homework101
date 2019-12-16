//
//  AdvantageViewController.m
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "AdvantageViewController.h"
#import "ExperienceBuyViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"

@interface AdvantageViewController ()


@end

@implementation AdvantageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"优势介绍";
}

#pragma mark 监听跳转
-(void)webListenToJumpWithUrl:(NSString *)url{
    if ([url rangeOfString:@"getdiscounts"].location != NSNotFound) {
        ExperienceBuyViewController *experienBuyVC = [[ExperienceBuyViewController alloc] init];
        experienBuyVC.selGrade = self.grade;
        [self.navigationController pushViewController:experienBuyVC animated:YES];
    }else if([url rangeOfString:@"lookfirst"].location != NSNotFound){
        [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
        AppDelegate *appDelegate = kAppDelegate;
        MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
        appDelegate.window.rootViewController = myTabbarVC;
        myTabbarVC.selectedIndex = 1;
    }
}


@end
