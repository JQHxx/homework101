//
//  MineViewController.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MineViewController.h"
#import "UserInfoViewController.h"
#import "SetupViewController.h"
#import "ChatViewController.h"
#import "BuyCoachViewController.h"
#import "MineHeaderView.h"
#import "GuideTableViewCell.h"
#import "NonServiceTableViewCell.h"
#import "GuideServiceModel.h"
#import "UserModel.h"
#import <MJRefresh/MJRefresh.h>
#import "TeacherModel.h"

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,NonServiceTableViewCellDelegate>{
    NSArray *titlesArr;
    NSArray *imagesArr;
    NSArray *classesArray;
}

@property (nonatomic,strong) UITableView    *mineTableView;
@property (nonatomic,strong) MineHeaderView *headerView;

@property (nonatomic,strong) NSMutableArray *guideServiceArray;
@property (nonatomic,strong) UserModel      *userInfo;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
    
    BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
    
    titlesArr = paySwitch?@[@"我的辅导反馈",@"我的辅导记录",@"客服中心"]:@[@"我的辅导反馈",@"我的辅导记录",@"我的消费记录",@"我的优惠券",@"邀请好友",@"客服中心"];
    imagesArr = paySwitch?@[@"my_tutor_feedback",@"my_tutor_record",@"my_customer_service"]: @[@"my_tutor_feedback",@"my_tutor_record",@"my_consumption_record",@"my_coupon",@"my_invite_friends",@"my_customer_service"];
    classesArray = paySwitch?@[@"MyGuideFeedback",@"MyCoachRecord",@"ContactCenter"]: @[@"MyGuideFeedback",@"MyCoachRecord",@"ExpensesRecord",@"Coupons",@"CoachCoupon",@"ContactCenter"];
    
    [self.view addSubview:self.mineTableView];
    self.mineTableView.tableHeaderView = self.headerView;
    self.headerView.hidden = YES;
    
    [self loadUserInfoData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的"];
    
    if ([HomeworkManager sharedHomeworkManager].isUpdateUserInfo) {
        [self loadUserInfoData];
        [HomeworkManager sharedHomeworkManager].isUpdateUserInfo = NO;
    }
    
    if ([HomeworkManager sharedHomeworkManager].isUpdateTeacher) {
        self.tabBarController.selectedIndex = 1;
        [HomeworkManager sharedHomeworkManager].isUpdateTeacher = NO;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的"];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return self.guideServiceArray.count>0?self.guideServiceArray.count:1;
    }else{
        return titlesArr.count;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, kScreenWidth-100, 20)];
        titleLab.text = @"我的辅导服务";
        titleLab.textColor = [UIColor colorWithHexString:@"#303030"];
        titleLab.font = [UIFont mediumFontWithSize:18.0f];
        [aView addSubview:titleLab];
        
        UIButton *moreBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-88, 5, 68, 40):CGRectMake(kScreenWidth-68, 5, 48, 30)];
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"my_arrow_black"] forState:UIControlStateNormal];
        moreBtn.titleLabel.font = [UIFont regularFontWithSize:14.0f];
        moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0,IS_IPAD?56:38, 0, 0);
        [moreBtn addTarget:self action:@selector(moreGuideServiceAction:) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:moreBtn];
        
        return aView;
    }else{
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.guideServiceArray.count>0) {
            GuideTableViewCell *cell = [[GuideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            GuideServiceModel *model = self.guideServiceArray[indexPath.row];
            cell.serviceModel = model;
            
            cell.guideButton.tag = indexPath.row;
            [cell.guideButton addTarget:self action:@selector(toAskTeacherForCoachAction:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.rechargeButton.tag = indexPath.row;
            [cell.rechargeButton addTarget:self action:@selector(toRechargeAction:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }else{
            NonServiceTableViewCell *cell = [[NonServiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellDelegate = self;
            return cell;
        }
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = titlesArr[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:imagesArr[indexPath.row]];
        cell.textLabel.font = [UIFont regularFontWithSize:16.0];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        cell.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (self.guideServiceArray.count>0) {
            return IS_IPAD?100:78;
        }else{
            return (kScreenWidth-36)*(132.0/678.0);
        }
    }else{
        return IS_IPAD?70:50;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?40:0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        NSString *classStr = [NSString stringWithFormat:@"%@ViewController",classesArray[indexPath.row]];
        Class aClass = NSClassFromString(classStr);
        BaseViewController *vc = (BaseViewController *)[[aClass alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark NonServiceTableViewCellDelegate
-(void)nonServiceCellDidClickBtnAction{
    self.tabBarController.selectedIndex = 1;
}

#pragma mark -- Event response
#pragma mark 编辑个人资料
-(void)edituserInfoAction:(UIButton*)sender{
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.user = self.userInfo;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark 设置
-(void)rightNavigationItemAction{
    SetupViewController *setupVC = [[SetupViewController alloc] init];
    [self.navigationController pushViewController:setupVC animated:YES];
}

#pragma mark 更多服务
-(void)moreGuideServiceAction:(UIButton *)sender{
    self.tabBarController.selectedIndex = 0;
}

#pragma mark 辅导
-(void)toAskTeacherForCoachAction:(UIButton *)sender{
    GuideServiceModel *model = self.guideServiceArray[sender.tag];
    if (!kIsEmptyString(model.third_id)) {
        ChatViewController *chatVC = [[ChatViewController alloc]init];
        chatVC.conversationType = ConversationType_PRIVATE;
        chatVC.targetId = model.third_id;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark 续费
-(void)toRechargeAction:(UIButton *)sender{
    GuideServiceModel *model = self.guideServiceArray[sender.tag];
    TeacherModel *teacher = [[TeacherModel alloc] init];
    teacher.t_id = model.t_id;
    teacher.third_id = model.third_id;
    teacher.cover = model.cover;
    teacher.guide_time = model.guide_time;
    teacher.subject = model.subject;
    teacher.name = model.teacher_name;
    BuyCoachViewController *buyVC = [[BuyCoachViewController alloc] init];
    buyVC.teacher = teacher;
    [self.navigationController pushViewController:buyVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadUserInfoData{
    [[HttpRequest sharedInstance] postWithURLString:kMineApI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSDictionary *userDict = [data valueForKey:@"user"];
        [self.userInfo setValues:userDict];
        
        [NSUserDefaultsInfos putKey:kUserId andValue:self.userInfo.s_id];
        [NSUserDefaultsInfos putKey:kUserGrade andValue:self.userInfo.grade];
        [NSUserDefaultsInfos putKey:kUserNickname andValue:self.userInfo.name];
        [NSUserDefaultsInfos putKey:kUserHeadPic andValue:self.userInfo.cover];
        
        NSArray *guideArr = [data valueForKey:@"guide"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in guideArr) {
            GuideServiceModel *model = [[GuideServiceModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        self.guideServiceArray = tempArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerView.hidden = NO;
            [self.mineTableView.mj_header endRefreshing];
            self.headerView.userModel = self.userInfo;
            [self.mineTableView reloadData];
        });
        
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mineTableView.mj_header endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
    
}


#pragma mark -- Getters
#pragma mark 我的
-(UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-kTabHeight) style:UITableViewStyleGrouped];
        _mineTableView.dataSource = self;
        _mineTableView.delegate = self;
        _mineTableView.tableFooterView = [[UIView alloc] init];
        _mineTableView.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        _mineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _mineTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadUserInfoData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _mineTableView.mj_header=header;
    }
    return _mineTableView;
}

#pragma mark
-(MineHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,KStatusHeight +(IS_IPAD?125:95))];
        [_headerView.editButton addTarget:self action:@selector(edituserInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.setupBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerView;
}

-(NSMutableArray *)guideServiceArray{
    if (!_guideServiceArray) {
        _guideServiceArray = [[NSMutableArray alloc] init];
    }
    return _guideServiceArray;
}

-(UserModel *)userInfo{
    if (!_userInfo) {
        _userInfo = [[UserModel alloc] init];
    }
    return _userInfo;
}

@end
