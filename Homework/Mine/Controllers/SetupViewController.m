//
//  SetupViewController.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "SetupViewController.h"
#import "ClearCacheViewController.h"
#import "BaseWebViewController.h"
#import "LogoutViewController.h"
#import "APPInfoManager.h"


@interface SetupViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray  *titlesArr;
}

@property (nonatomic,strong) UITableView *setTableView;
@property (nonatomic,strong) UISwitch    *messageSwith;
@property (nonatomic,strong) UILabel     *versionLabel;
@property (nonatomic,strong) UIButton    *signOutBtn;

@property (nonatomic,assign) BOOL         isVolume;
 
@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"设置";
    
    self.isVolume = [[NSUserDefaultsInfos getValueforKey:kPushMsgSetting] boolValue];
    
    titlesArr = @[@"消息提醒",@"当前版本",@"清理缓存",@"关于我们",@"注销账号"];
    
    [self.view addSubview:self.setTableView];
    [self.view addSubview:self.signOutBtn];
    
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row==0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.contentView addSubview:self.messageSwith];
    }else if (indexPath.row==1){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.contentView addSubview:self.versionLabel];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = titlesArr[indexPath.row];
    cell.textLabel.font = [UIFont regularFontWithSize:16.0f];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?70:59.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2) {
        ClearCacheViewController *cacheVC = [[ClearCacheViewController alloc] init];
        [self.navigationController pushViewController:cacheVC animated:YES];
    }else if (indexPath.row==3){
        BaseWebViewController *webVC = [[BaseWebViewController alloc] init];
        webVC.urlStr = kAboutUsURL;
        webVC.webTitle = @"关于我们";
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row==4){
        LogoutViewController *logoutVC = [[LogoutViewController alloc] init];
        [self.navigationController pushViewController:logoutVC animated:YES];
    }
}

#pragma mark -- Event Response
#pragma mark 设置消息
-(void)settingSwitchAction:(UISwitch *)aSwitch{
    self.isVolume = aSwitch.isOn;
    [NSUserDefaultsInfos putKey:kPushMsgSetting andValue:[NSNumber numberWithBool:self.isVolume]];
}

#pragma mark 退出登录
-(void)signoutAction:(UIButton *)sender{
    [HttpRequest signOut];
}

#pragma mark -- Getters
#pragma mark 设置
-(UITableView *)setTableView{
    if (!_setTableView) {
        _setTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _setTableView.delegate = self;
        _setTableView.dataSource = self;
        _setTableView.showsVerticalScrollIndicator = NO;
        _setTableView.tableFooterView = [[UIView alloc] init];
        _setTableView.scrollEnabled = NO;
    }
    return _setTableView;
}

#pragma mark 消息提醒
-(UISwitch *)messageSwith{
    if (!_messageSwith) {
        _messageSwith = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-65, 5, 60, 34)];
        _messageSwith.onTintColor = [UIColor systemColor];
        [_messageSwith setOn:self.isVolume];
        [_messageSwith addTarget:self action:@selector(settingSwitchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _messageSwith;
}

#pragma mark 版本号
-(UILabel *)versionLabel{
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-115, 20, 90, 19)];
        _versionLabel.textColor = [UIColor commonColor_gray];
        _versionLabel.font = [UIFont regularFontWithSize:15.0f];
        _versionLabel.textAlignment = NSTextAlignmentRight;
        _versionLabel.text = [[APPInfoManager sharedAPPInfoManager] appBundleVersion];
    }
    return _versionLabel;
}

#pragma mark 退出登录
-(UIButton *)signOutBtn{
    if (!_signOutBtn) {
        _signOutBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-240)/2.0, kScreenHeight-70, 240,IS_IPAD?56:40)];
        _signOutBtn.backgroundColor = [UIColor commonColor_red];
        [_signOutBtn setTitle:@"退出当前帐号" forState:UIControlStateNormal];
        [_signOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _signOutBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        _signOutBtn.layer.cornerRadius = IS_IPAD?28:20;
        [_signOutBtn addTarget:self action:@selector(signoutAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signOutBtn;
}

@end
