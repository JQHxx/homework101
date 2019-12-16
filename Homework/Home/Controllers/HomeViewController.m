//
//  HomeViewController.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HomeViewController.h"
#import "MessagesViewController.h"
#import "MyConversationViewController.h"
#import "TeacherDetailsViewController.h"
#import "ExperienceCouponViewController.h"
#import "BuyCoachViewController.h"
#import "ChatViewController.h"
#import "CustomerServiceViewController.h"
#import "CoachCouponViewController.h"
#import "MyTeacherTableView.h"
#import "MyFeedbackTableView.h"
#import "SlideMenuView.h"
#import "DragImageView.h"
#import "TeacherModel.h"
#import "CoachFeedbackModel.h"
#import <MJRefresh/MJRefresh.h>


@interface HomeViewController ()<SlideMenuViewDelegate,MyTeacherTableViewDelegate,MyConversationViewControllerDelegate>

@property (nonatomic,strong) SlideMenuView                 *menuView;
@property (nonatomic,strong) UIView                        *menuRedBadge;
@property (nonatomic,strong) UIButton                      *serviceBtn;
@property (nonatomic,strong) UIButton                      *messageBtn;
@property (nonatomic,strong) UIView                        *redBadge;
@property (nonatomic,strong) MyTeacherTableView            *teacherTableView;
@property (nonatomic,strong) MyConversationViewController  *conversationVC;
@property (nonatomic,strong) MyFeedbackTableView           *myFeedbackTableView;

@property (nonatomic,strong) DragImageView                 *dragImgView;

@property (nonatomic,strong) NSMutableArray *myTeachersArray;
@property (nonatomic,strong) NSMutableArray *myFeedbacksArray;

@property (nonatomic,assign) NSInteger page;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    self.page = 1;
    
    [self initHomeView];
    [self loadMyTeachersData];
    [self loadUnreadMessageData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"首页"];
    
    if (self.conversationVC) {
        [self.conversationVC notifyUpdateUnreadMessageCount];
    }
    
    if ([HomeworkManager sharedHomeworkManager].isUpdateHome) {
        [self loadMyTeachersData];
        [HomeworkManager sharedHomeworkManager].isUpdateHome = NO;
    }
    
    if ([HomeworkManager sharedHomeworkManager].isUpdateMessage) {
        [self loadUnreadMessageData];
        [HomeworkManager sharedHomeworkManager].isUpdateMessage = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUnreadMessageData) name:kReloadMsgNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNotification:) name:RCKitDispatchMessageNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"首页"];
}

#pragma mark -- Event response
#pragma mark 消息
-(void)checkMessagesAction:(UIButton *)sender{
    MessagesViewController *messagesVC = [[MessagesViewController alloc] init];
    [self.navigationController pushViewController:messagesVC animated:YES];
}

#pragma mark -- Delegate
#pragma mark  SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    if (index==0) {
        self.myFeedbackTableView.hidden = YES;
        self.teacherTableView.hidden = NO;
        
        if (self.conversationVC) {
            [self.conversationVC.view removeFromSuperview];
            self.conversationVC = nil;
        }
        [self loadMyTeachersData];
    }else if (index==1){
        self.myFeedbackTableView.hidden = self.teacherTableView.hidden = YES;
        [self.view addSubview:self.conversationVC.view];
    }else{
        self.myFeedbackTableView.hidden = NO;
        if (self.conversationVC) {
            [self.conversationVC.view removeFromSuperview];
            self.conversationVC = nil;
        }
        self.teacherTableView.hidden = YES;
        [self loadMyCoachFeedbacksData];
    }
}

#pragma mark MyTeacherTableViewDelegate
#pragma mark 相关操作
-(void)myTeacherTableView:(MyTeacherTableView *)myTableView didHandleWithModel:(TeacherModel *)teacher{
    if ([teacher.status integerValue]==1) {
        if (!kIsEmptyString(teacher.third_id)) {
            ChatViewController *chatVC = [[ChatViewController alloc]init];
            chatVC.conversationType = ConversationType_PRIVATE;
            chatVC.targetId = teacher.third_id;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }else if ([teacher.status integerValue]==3){
        [MobClick event:kStaticsGetCouponsEvent];
        ExperienceCouponViewController *experienceCouponVC = [[ExperienceCouponViewController alloc] init];
        experienceCouponVC.model = teacher;
        [self.navigationController pushViewController:experienceCouponVC animated:YES];
    }else{
        BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
        if (paySwitch) {
            ChatViewController *chatVC = [[ChatViewController alloc]init];
            chatVC.conversationType = ConversationType_PRIVATE;
            chatVC.targetId = teacher.third_id;
            [self.navigationController pushViewController:chatVC animated:YES];
        }else{
            [MobClick event:kStaticsToBuyEvent];
            BuyCoachViewController *buyVC = [[BuyCoachViewController alloc] init];
            buyVC.teacher = teacher;
            [self.navigationController pushViewController:buyVC animated:YES];
        }
    }
}

#pragma mark 去辅导
-(void)myTeacherTableView:(MyTeacherTableView *)myTableView didGotoCoachWithTeacher:(TeacherModel *)teacher{
    if (!kIsEmptyString(teacher.third_id)) {
        ChatViewController *chatVC = [[ChatViewController alloc]init];
        chatVC.conversationType = ConversationType_PRIVATE;
        chatVC.targetId = teacher.third_id;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark 查看老师详情
-(void)myTeacherTableView:(MyTeacherTableView *)myTableView didSelectedTeacher:(TeacherModel *)teacher{
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.webTitle = teacher.name;
    detailsVC.urlStr = [NSString stringWithFormat:@"%@?token=%@&t_id=%@",kTeacherDetailsUrl,kUserTokenValue,teacher.t_id];
    detailsVC.teacherDetails = teacher;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark MyConversationViewControllerDelegate
#pragma mark 跳转到聊天页
-(void)myConversationViewControllerDidPushToChatWithTargetID:(NSString *)targetId{
    // 会话页面:直接使用或者继承RCConversationViewController
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = targetId;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark 查看未读消息
-(void)myConversationViewControllerShowMessageUnreadCount:(NSInteger)count{
    dispatch_async(dispatch_get_main_queue(),^{
        self.menuRedBadge.hidden = count==0;
    });
}

#pragma mark 收到聊天消息回调
-(void)didReceiveMessageNotification:(NSNotification *)notification{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[ @(ConversationType_PRIVATE)]];
    MyLog(@"didReceiveMessageNotification ,收到消息：%d",unreadMsgCount);
    dispatch_async(dispatch_get_main_queue(),^{
        self.menuRedBadge.hidden = unreadMsgCount==0;
    });
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initHomeView{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.menuRedBadge];
    self.menuRedBadge.hidden = YES;
    [self.view addSubview:self.serviceBtn];
    [self.view addSubview:self.messageBtn];
    [self.view addSubview:self.redBadge];
    self.redBadge.hidden = YES;
    [self.view addSubview:self.teacherTableView];
    [self.view addSubview:self.myFeedbackTableView];
    self.myFeedbackTableView.hidden = YES;
    
    BOOL paySwith = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
    if (!paySwith) {
        self.view.userInteractionEnabled = YES;
        [self.view addSubview:self.dragImgView];
    }
}

#pragma mark 加载数据
-(void)loadMyTeachersData{
    [[HttpRequest sharedInstance] postWithURLString:kMyTeachersAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            TeacherModel *model = [[TeacherModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        self.myTeachersArray = tempArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.teacherTableView.mj_header endRefreshing];
            self.teacherTableView.teachersArray = self.myTeachersArray;
            [self.teacherTableView reloadData];
        });
        
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.teacherTableView.mj_header endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 辅导反馈数据
-(void)loadMyCoachFeedbacksData{
    [[HttpRequest sharedInstance] postWithURLString:kGuideFeedbackAPI parameters:@{@"token":kUserTokenValue,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@15} success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            CoachFeedbackModel *model = [[CoachFeedbackModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page==1) {
            self.myFeedbacksArray = tempArr;
        }else{
            [self.myFeedbacksArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myFeedbackTableView.mj_footer.hidden = tempArr.count<15;
            [self.myFeedbackTableView.mj_header endRefreshing];
            [self.myFeedbackTableView.mj_footer endRefreshing];
            self.myFeedbackTableView.myFeedbackArray = self.myFeedbacksArray;
            [self.myFeedbackTableView reloadData];
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myFeedbackTableView.mj_header endRefreshing];
            [self.myFeedbackTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 最新辅导反馈数据
-(void)loadNewFeedbackListData{
    self.page = 1;
    [self loadMyCoachFeedbacksData];
}

#pragma mark 更多辅导反馈数据
-(void)loadMoreFeedbackListData{
    self.page++;
    [self loadMyCoachFeedbacksData];
}

#pragma mark 获取未读消息
-(void)loadUnreadMessageData{
    [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kUnreadMessageAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSNumber *state = [data valueForKey:@"state"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.redBadge.hidden = ![state boolValue];
        });
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark --Getters
#pragma mark 菜单
-(SlideMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, KStatusHeight,IS_IPAD?360:(IS_IPHONE_5?240:280), kNavHeight-KStatusHeight) btnTitleFont:[UIFont regularFontWithSize:IS_IPHONE_5?14.0f:16.0f] color:[UIColor colorWithHexString:@"#9495A0"] selColor:[UIColor commonColor_black]];
        _menuView.btnCapWidth = 10;
        _menuView.lineWidth = 16.0;
        _menuView.selectTitleFont = [UIFont mediumFontWithSize:20.0f];
        _menuView.myTitleArray = [NSMutableArray arrayWithArray:@[@"我的老师",@"辅导消息",@"辅导反馈"]];
        _menuView.currentIndex = 0;
        _menuView.delegate = self;
    }
    return _menuView;
}

#pragma mark 未读消息
-(UIView *)menuRedBadge{
    if (!_menuRedBadge) {
        _menuRedBadge = [[UIView alloc] initWithFrame:CGRectMake((self.menuView.width/3.0)*2.0-15, self.menuView.top+(IS_IPAD?15:8), 10, 10)];
        _menuRedBadge.backgroundColor = [UIColor redColor];
        [_menuRedBadge setBorderWithCornerRadius:5 type:UIViewCornerTypeAll];
    }
    return _menuRedBadge;
}

#pragma mark 客服
-(UIButton *)serviceBtn{
    if (!_serviceBtn) {
        _serviceBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-130, KStatusHeight+12, 40, 40):CGRectMake(kScreenWidth-77, KStatusHeight+7, 30, 30)];
        [_serviceBtn setImage:[UIImage drawImageWithName:@"tutor_service" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [_serviceBtn addTarget:self action:@selector(pushToCustomerServiceVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _serviceBtn;
}

#pragma mark 消息
-(UIButton *)messageBtn{
    if (!_messageBtn) {
        _messageBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(self.serviceBtn.right+15, KStatusHeight+12, 40, 40):CGRectMake(self.serviceBtn.right+5, KStatusHeight+7, 30, 30)];
        [_messageBtn setImage:[UIImage drawImageWithName:@"tutor_message" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [_messageBtn addTarget:self action:@selector(checkMessagesAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageBtn;
}

#pragma mark 未读消息
-(UIView *)redBadge{
    if (!_redBadge) {
        _redBadge = [[UIView alloc] initWithFrame:CGRectMake(self.messageBtn.right-10, self.messageBtn.top+2, 10, 10)];
        _redBadge.backgroundColor = [UIColor redColor];
        [_redBadge setBorderWithCornerRadius:5 type:UIViewCornerTypeAll];
    }
    return _redBadge;
}

#pragma mark 我的老师
-(MyTeacherTableView *)teacherTableView{
    if (!_teacherTableView) {
        _teacherTableView = [[MyTeacherTableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-kTabHeight) style:UITableViewStylePlain];
        _teacherTableView.viewDelegate = self;
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMyTeachersData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _teacherTableView.mj_header=header;
    }
    return _teacherTableView;
}

#pragma mark 辅导消息
-(MyConversationViewController *)conversationVC{
    if (!_conversationVC) {
        _conversationVC = [[MyConversationViewController alloc] init];
        _conversationVC.view.frame = CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kTabHeight-kNavHeight);
        _conversationVC.controlerDelegate = self;
    }
    return _conversationVC;
}

#pragma mark 辅导反馈
-(MyFeedbackTableView *)myFeedbackTableView{
    if (!_myFeedbackTableView) {
        _myFeedbackTableView = [[MyFeedbackTableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-kTabHeight) style:UITableViewStylePlain];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewFeedbackListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _myFeedbackTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreFeedbackListData)];
        footer.automaticallyRefresh = NO;
        _myFeedbackTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myFeedbackTableView;
}

#pragma mark 圆点
-(DragImageView *)dragImgView{
    if (!_dragImgView) {
        _dragImgView = [[DragImageView alloc] initWithFrame:CGRectMake(kScreenWidth-63, kScreenHeight/2.0, 63, 71)];
        _dragImgView.image = [UIImage imageNamed:@"invite_friends"];
        kSelfWeak;
        [_dragImgView setActionBlock:^{
            CoachCouponViewController *coachCouponVC = [[CoachCouponViewController alloc] init];
            [weakSelf.navigationController pushViewController:coachCouponVC animated:YES];
        }];
    }
    return _dragImgView;
}

-(NSMutableArray *)myTeachersArray{
    if (!_myTeachersArray) {
        _myTeachersArray = [[NSMutableArray alloc] init];
    }
    return _myTeachersArray;
}

-(NSMutableArray *)myFeedbacksArray{
    if (!_myFeedbacksArray) {
        _myFeedbacksArray = [[NSMutableArray alloc] init];
    }
    return _myFeedbacksArray;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadMsgNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

@end
