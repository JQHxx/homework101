//
//  BuySuccessViewController.m
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BuySuccessViewController.h"
#import "TeacherDetailsViewController.h"
#import "ChatViewController.h"
#import "TeacherTableView.h"
#import "TeacherModel.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"

@interface BuySuccessViewController ()<TeacherTableViewDelegate>

@property(nonatomic,strong) UIView  *headView;
@property(nonatomic,strong) TeacherTableView *teacherTableView;

@end

@implementation BuySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn = YES;

    self.rightImageName = @"tutor_service";
    
    [self.view addSubview:self.teacherTableView];
    [self loadTeachersData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"购买成功"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"购买成功"];
}

#pragma mark -- Delegate
#pragma mark TeacherTableViewDelegate
#pragma mark 老师详情
-(void)teacherTableView:(TeacherTableView *)tableView didSelectCellWithModel:(TeacherModel *)teacher{
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.webTitle = teacher.name;
    detailsVC.urlStr = [NSString stringWithFormat:@"%@?token=%@&t_id=%@",kTeacherDetailsUrl,kUserTokenValue,teacher.t_id];
    detailsVC.teacherDetails = teacher;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark 联系老师
-(void)teacherTableView:(TeacherTableView *)tableView didContactTeacher:(TeacherModel *)teacher{
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = teacher.third_id;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark -- Event response
#pragma mark 确认
-(void)confirmBuyAction:(UIButton *)sender{
    if (self.isExpBuyIn) {
        AppDelegate *appDelegate = kAppDelegate;
        MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
        appDelegate.window.rootViewController = myTabbarVC;
    }else{
       [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -- Private methods
#pragma mark 加载老师信息
-(void)loadTeachersData{
    if (self.isExpBuyIn) {
        NSDictionary *params = @{@"token":kUserTokenValue,@"subject":[NSNumber numberWithInteger:self.subject]};
        [[HttpRequest sharedInstance] postWithURLString:kExpTeacherAPI parameters:params success:^(id responseObject) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSDictionary *teacherDict = [data valueForKey:@"teacher"];
            self.myTeacher = [[TeacherModel alloc] init];
            [self.myTeacher setValues:teacherDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.teacherTableView.teachersArr = [NSMutableArray arrayWithObject:self.myTeacher];
                [self.teacherTableView reloadData];
            });
        } failure:^(NSString *errorStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            });
        }];
    }else{
        self.teacherTableView.teachersArr = [NSMutableArray arrayWithObject:self.myTeacher];
        [self.teacherTableView reloadData];
    }
}

#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark -- getters
#pragma mark 头部视图
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,IS_IPAD?300:240)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-70)/2.0, 20, 70, 82)];
        iconImgView.image = [UIImage imageNamed:@"purchase_success"];
        [_headView addSubview:iconImgView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, iconImgView.bottom+10, kScreenWidth-40,IS_IPAD?42:30)];
        titleLab.text = @"您已购买成功";
        titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
        titleLab.font = [UIFont mediumFontWithSize:18.0f];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_headView addSubview:titleLab];
        
        UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(32, titleLab.bottom, kScreenWidth-64,IS_IPAD?60:40)];
        descLab.text = @"您可以开始辅导了，如果对老师不满意，请随时联系客服进行更换~";
        descLab.textColor = [UIColor colorWithHexString:@"#9C9DA8"];
        descLab.font = [UIFont mediumFontWithSize:13.0f];
        descLab.numberOfLines = 0;
        [_headView addSubview:descLab];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-240)/2.0, descLab.bottom+14,240,IS_IPAD?48:35)];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF6161"] endColor:[UIColor colorWithHexString:@"#FF6D98"]];
        btn.titleLabel.font = [UIFont mediumFontWithSize:15.0f];
        [btn setBorderWithCornerRadius:17.5 type:UIViewCornerTypeAll];
        [btn addTarget:self action:@selector(confirmBuyAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:btn];
        
    }
    return _headView;
}

#pragma mark 老师列表
-(TeacherTableView *)teacherTableView{
    if (!_teacherTableView) {
        _teacherTableView = [[TeacherTableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _teacherTableView.tableHeaderView = self.headView;
    }
    return _teacherTableView;
}

@end
