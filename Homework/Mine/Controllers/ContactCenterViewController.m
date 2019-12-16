//
//  ContactCenterViewController.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ContactCenterViewController.h"

#define QQ_NUMBER    @"5037334"
#define WX_NUMBER    @"zuoye1001"
#define PHONE_NUMBER @"15675858101"

@interface ContactCenterViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray  *images;
    NSArray  *titles;
    NSArray  *values;
}

@property (nonatomic ,strong) UIView      *headView;
@property (nonatomic ,strong) UITableView *serviceTableView;

@end

@implementation ContactCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"客服中心";
     images = @[@"QQ",@"WeChat",@"telephone"];
    titles = @[@"客服QQ",@"客服微信",@"客服热线"];
    values = @[QQ_NUMBER,WX_NUMBER,PHONE_NUMBER];
    
    [self.view addSubview:self.serviceTableView];
    self.serviceTableView.tableHeaderView = self.headView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    cell.textLabel.text = titles[indexPath.row];
    cell.textLabel.textColor = [UIColor commonColor_black];
    cell.textLabel.font = [UIFont regularFontWithSize:16.0f];
    cell.detailTextLabel.text = values[indexPath.row];
    cell.detailTextLabel.textColor = [UIColor commonColor_black];
    cell.detailTextLabel.font = [UIFont regularFontWithSize:16.0f];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = WX_NUMBER;
        [self.view makeToast:@"微信号已复制" duration:1.0 position:CSToastPositionCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            NSURL *URL = [NSURL URLWithString:@"weixin://"];
            if (@available(iOS 10.0, *)) {
                [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                    MyLog(@"iOS10 Open %@: %d",URL,success);
                }];
            } else {
                // Fallback on earlier versions
                BOOL success = [application openURL:URL];
                MyLog(@"Open %@: %d",URL,success);
            }
        });
    }else{
        NSString *scheme = nil;
        if (indexPath.row==0) {
            scheme = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",QQ_NUMBER];
        }else {
            scheme=[NSString stringWithFormat:@"telprompt://%@",PHONE_NUMBER];
        }
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:scheme];
        if (@available(iOS 10.0, *)) {
            [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                MyLog(@"iOS10 Open %@: %d",URL,success);
            }];
        } else {
            // Fallback on earlier versions
            BOOL success = [application openURL:URL];
            MyLog(@"Open %@: %d",URL,success);
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

#pragma mark -- getters
#pragma mark 头部
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-104)/2.0, 37, 100, 100)];
        imgView.image = [UIImage imageNamed:@"my_customer_service_xiaobao"];
        [_headView addSubview:imgView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom+10, kScreenWidth-40, 30)];
        lab.text = @"在线客服-客服小宝";
        lab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont regularFontWithSize:15.0f];
        [_headView addSubview:lab];
    }
    return _headView;
}

#pragma mark 我的主界面
-(UITableView *)serviceTableView{
    if (!_serviceTableView) {
        _serviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,kNavHeight+3, kScreenWidth, kScreenHeight-kTabHeight) style:UITableViewStylePlain];
        _serviceTableView.dataSource = self;
        _serviceTableView.delegate = self;
        _serviceTableView.showsVerticalScrollIndicator=NO;
        _serviceTableView.scrollEnabled = NO;
        _serviceTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _serviceTableView.tableFooterView = [[UIView alloc] init];
    }
    return _serviceTableView;
}




@end
