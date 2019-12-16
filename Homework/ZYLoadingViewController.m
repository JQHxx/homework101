//
//  ZYLoadingViewController.m
//  ZuoYe
//
//  Created by vision on 2019/4/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ZYLoadingViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"
#import "APPInfoManager.h"

@interface ZYLoadingViewController ()

@property (nonatomic,strong) UIImageView *contentImgView;

@end

@implementation ZYLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.contentImgView];
    [self loadHomeData];
}

#pragma mark
-(void)loadHomeData{
    NSString *version = [[APPInfoManager sharedAPPInfoManager] appBundleVersion];
    NSDictionary *parmas = @{@"token":kUserTokenValue,@"version":version};
    [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kCheckSwitchAPI parameters:parmas success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSNumber *paySwitch = [data valueForKey:@"pay_switch"];
        [NSUserDefaultsInfos putKey:kPaySwitch andValue:paySwitch];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = kAppDelegate;
            MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
            appDelegate.window.rootViewController = myTabbarVC;
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = kAppDelegate;
            MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
            appDelegate.window.rootViewController = myTabbarVC;
        });
    }];
}

#pragma mark
-(UIImageView *)contentImgView{
    if (!_contentImgView) {
        _contentImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _contentImgView.image = [UIImage imageNamed:IS_IPAD?@"loading_ipad":(isXDevice?@"loading_iphoneX":@"loading")];
    }
    return _contentImgView;
}

@end
