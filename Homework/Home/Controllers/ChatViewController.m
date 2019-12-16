//
//  ChatViewController.m
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ChatViewController.h"
#import "ReportViewController.h"
#import "TeacherDetailsViewController.h"
#import "BuyCoachViewController.h"
#import "CustomerServiceViewController.h"
#import "CustomMessageCell.h"
#import "MXActionSheet.h"
#import "CustomMessage.h"
#import "CustomReminderView.h"
#import "CoachEvaluateView.h"
#import "TeacherModel.h"
#import "NSDate+Extend.h"
#import <UMAnalytics/MobClick.h>
#import <RongCallKit/RongCallKit.h>

@interface ChatViewController ()<RCMessageCellDelegate,RCIMReceiveMessageDelegate>{
    BOOL  paySwitch;
}

@property (nonatomic,strong) UIView         *navView;
@property (nonatomic,strong) UIButton       *moreBtn;
@property (nonatomic,strong) UILabel        *titleLab;

@property (nonatomic,strong) UIView         *footerView;
@property (nonatomic,strong) UILabel        *tipsLab;
@property (nonatomic,strong) UIButton       *coachBtn;

//编辑状态下的工具栏
@property (nonatomic,strong) UIView         *bottomBarView;

@property (nonatomic,strong) TeacherModel    *teacher;

@property (nonatomic, copy ) NSString    *guide_id;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
       
    [self initChatView];
    [self setChatConfig];
    [self refreshUserInfo];
    
    BOOL isAudioCallEnable = [[RCCall sharedRCCall] isAudioCallEnabled:ConversationType_PRIVATE];
    BOOL isVideoCallEnable = [[RCCall sharedRCCall] isVideoCallEnabled:ConversationType_PRIVATE];
    MyLog(@"isAudioCallEnable:%d，isVideoCallEnable：%d",isAudioCallEnable,isVideoCallEnable);
    
    if (self.isReportIn) {
        self.allowsMessageCellSelection = YES;
        self.messageSelectionToolbar.hidden = YES;
        self.footerView.hidden = YES;
        self.moreBtn.hidden = YES;
        [self.view addSubview:self.bottomBarView];
    }else{
        self.allowsMessageCellSelection = NO;
        if (self.bottomBarView) {
            [self.bottomBarView removeFromSuperview];
            self.bottomBarView = nil;
        }
    }
    
    if (self.conversationDataRepository.count==0) {
        NSString *msg = [NSString stringWithFormat:@"%@同学，你好，请点击开始辅导按钮，让陈老师来帮你答疑解惑吧~",[NSUserDefaultsInfos getValueforKey:kUserNickname]];
        [self insertReminderMsgContent:msg extra:@""];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"聊天"];
    
    if ([HomeworkManager sharedHomeworkManager].isUpdateChat) {
        [self refreshUserInfo];
        [HomeworkManager sharedHomeworkManager].isUpdateChat = NO;
    }
    
    [self.conversationMessageCollectionView setFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-self.chatSessionInputBarControl.height-(IS_IPAD?80:62)-kNavHeight)];
    
    NSInteger num = [self.conversationMessageCollectionView numberOfItemsInSection:0];
    if (num>0) {
       NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
       NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
       [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"聊天"];
    
    self.allowsMessageCellSelection = NO;
}

#pragma mark -- RCMessageCellDelegate
#pragma mark 消息Cell点击的回调
-(void)didTapMessageCell:(RCMessageModel *)model{
    if ([model.content isKindOfClass:[CustomMessage class]]) {
        CustomMessage *message = (CustomMessage *)model.content;
        if ([message.extra isEqualToString:@"msg_buy"]||[message.extra isEqualToString:@"msg_invite_buy"]) { //去购买
            BuyCoachViewController *buyVC = [[BuyCoachViewController alloc] init];
            buyVC.teacher = self.teacher;
            buyVC.isInviteBuy = [message.extra isEqualToString:@"msg_invite_buy"];
            [self.navigationController pushViewController:buyVC animated:YES];
        }else if([message.extra isEqualToString:@"msg_evaluate"]){ //去评价
            [CoachEvaluateView showEvaluateViewWithFrame:IS_IPAD?CGRectMake(0, 0, 400, 480):CGRectMake(0, 0, 285, 355) submitAction:^(NSInteger score, NSString *evaluate, BOOL anonymous) {
                NSDictionary *dict = @{@"token":kUserTokenValue,@"t_id":self.teacher.t_id,@"score":[NSNumber numberWithInteger:score],@"state":[NSNumber numberWithBool:anonymous],@"content":evaluate,@"guide_id":self.guide_id};
                [[HttpRequest sharedInstance] postWithURLString:kEvaluateTeacherAPI parameters:dict success:^(id responseObject) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:@"评价已提交" duration:1.0 position:CSToastPositionCenter];
                    });
                } failure:^(NSString *errorStr) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                    });
                }];
            }];
        }
        MyLog(@"didTapMessageCell：%@",message.content);
    }else{
        [super didTapMessageCell:model];
    }
}

#pragma mark 输入工具栏尺寸（高度）发生变化的回调
-(void)chatInputBar:(RCChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame{
    [super chatInputBar:self.chatSessionInputBarControl shouldChangeFrame:frame];
    
    MyLog(@"chatInputBar-----shouldChangeFrame----y:%.f,height:%.f",frame.origin.y,frame.size.height);
    
    CGRect aFrame = self.conversationMessageCollectionView.frame;
    aFrame.size.height -= IS_IPAD?80:62;
    self.conversationMessageCollectionView.frame = aFrame;
    
    NSInteger num = [self.conversationMessageCollectionView numberOfItemsInSection:0];
    if (num>0) {
        NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
        NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
        [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
    self.footerView.frame = CGRectMake(0,frame.origin.y-(IS_IPAD?80:62), kScreenWidth, IS_IPAD?80:62);
}

#pragma mark 扩展功能板的点击回调
-(void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    MyLog(@"pluginBoardView---------clickedItemWithTag:%ld",tag);
    if (paySwitch) {
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    }else{
        if ([self.teacher.user_pay integerValue]!=1&&[self.teacher.coupon_id integerValue]==0) {
            [self gotoBuyCoachReminderAction];
        }else{
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        }
    }
}

#pragma mark  RCIMReceiveMessageDelegate
-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)message.content;
        if ([msg.extra isEqualToString:@"end_coach"]) { //结束辅导
            MyLog(@"对方结束辅导");
            [self endThisCoachWithIsOtherEnd:YES];
        }
    }
}

#pragma mark -- Event Response
#pragma mark 返回
-(void)chatBackAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 更多
-(void)chatMoreAction:(UIButton *)sender{
    NSArray *buttonTitles = @[@"投诉",@"老师详情",@"联系客服",@"分享"];
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:buttonTitles selectedBlock:^(NSInteger index) {
        if (index==1) { //投诉
            ReportViewController *reportVC = [[ReportViewController alloc] init];
            reportVC.rcId = self.targetId;
            reportVC.tid = self.teacher.t_id;
            [self.navigationController pushViewController:reportVC animated:YES];
        }else if (index==2){ //老师详情
            TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
            detailsVC.webTitle = self.teacher.name;
            detailsVC.urlStr = [NSString stringWithFormat:@"%@?token=%@&t_id=%@",kTeacherDetailsUrl,kUserTokenValue,self.teacher.t_id];
            detailsVC.teacherDetails = self.teacher;
            [self.navigationController pushViewController:detailsVC animated:YES];
        }else if (index==3){ //联系客服
            CustomerServiceViewController *serviceVC = [[CustomerServiceViewController alloc] init];
            serviceVC.conversationType = ConversationType_CUSTOMERSERVICE;
            serviceVC.targetId = kRCCustomerServiceID;
            RCCustomerServiceInfo *serviceInfo = [[RCCustomerServiceInfo alloc] init];
            serviceInfo.name = [NSUserDefaultsInfos getValueforKey:kUserNickname];
            serviceInfo.portraitUrl = [NSUserDefaultsInfos getValueforKey:kUserHeadPic];
            serviceInfo.userId = [NSUserDefaultsInfos getValueforKey:kRongCloudID];
            serviceInfo.referrer = kRCChanelID;
            serviceVC.csInfo = serviceInfo;
            [self.navigationController pushViewController:serviceVC animated:YES];
        }else if (index==4){ //分享
            [[HomeworkManager sharedHomeworkManager] shareToOtherUsersFromController:self];
        }
    }];
}

#pragma mark 开始辅导 结束辅导
-(void)coachBtnAction:(UIButton *)sender{
    if ([sender.currentTitle isEqualToString:@"开始辅导"]) {
        [MobClick event:kStaticsStartCaochEvent];
        if ([self.teacher.user_pay integerValue]==1||[self.teacher.coupon_id integerValue]>0||paySwitch) { //已购买或者体验券
            RCInformationNotificationMessage *warningMsg =[RCInformationNotificationMessage notificationWithMessage:@"本次辅导开始" extra:@"start_coach"];
            [self sendMessage:warningMsg pushContent:nil];
            NSDictionary *params;
            if ([self.teacher.user_pay integerValue]==1) {
                params = @{@"token":kUserTokenValue,@"t_id":self.teacher.t_id};
            }else{
                params = @{@"token":kUserTokenValue,@"t_id":self.teacher.t_id,@"coupon_id":self.teacher.coupon_id};
            }
            [[HttpRequest sharedInstance] postWithURLString:kStartCoachAPI parameters:params success:^(id responseObject) {
                self.teacher.coupon_id = [NSNumber numberWithInteger:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self insertReminderMsgContent:@"你已经开始辅导，请通过语音、文字、图片发送您需要辅导的内容吧" extra:@""];
                    self.tipsLab.text = @"辅导结束后，请主动点击结束辅导。\n结束辅导后，将上传辅导记录。";
                    [self.coachBtn setTitle:@"结束辅导" forState:UIControlStateNormal];
                });
            } failure:^(NSString *errorStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                });
            }];
        }else{
            [self gotoBuyCoachReminderAction];
        }
    }else{
         NSDictionary *info = @{@"title":@"结束辅导",@"tips":@"老师已经完成了本次辅导？\n那就确定结束上传辅导记录吧~",@"cancel":@"继续辅导",@"confirm":@"确定结束"};
        [CustomReminderView showReminderViewWithFrame:IS_IPAD?CGRectMake(0, 0, 400, 260):CGRectMake(0, 0, 285, 200) info:info confirmAction:^{
            [self endThisCoachWithIsOtherEnd:NO];
        }];
    }
}

#pragma mark 确定选择
-(void)confirmChooseChatRecordsAction:(UIButton *)sender{
    self.isReportIn = NO;
    self.allowsMessageCellSelection = NO;
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.controllerDelegate respondsToSelector:@selector(chatViewControllerDidSlectedConversions:)]) {
        [self.controllerDelegate chatViewControllerDidSlectedConversions:self.selectedMessages];
    }
}

#pragma mark -- Priavte Methods
#pragma mark 初始化界面
-(void)initChatView{
    [self.view addSubview:self.navView];
    [self.view addSubview:self.footerView];
    self.footerView.hidden = YES;
}

#pragma mark 设置聊天相关属性
-(void)setChatConfig{
    //发送新拍照的图片完成之后，是否将图片在本地另行存储
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [[RCIM sharedRCIM] setGlobalMessagePortraitSize:CGSizeMake(40, 40)];
    
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate = self;
    
    //更新面板图片
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:0 image:[UIImage imageNamed:@"tutor_chat_add_picture"] title:@"相册"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:1 image:[UIImage imageNamed:@"tutor_chat_add_photograph"] title:@"拍摄"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:2 image:[UIImage imageNamed:@"tutor_chat_add_voice"] title:@"语音通话"];
    [self.chatSessionInputBarControl.pluginBoardView updateItemAtIndex:3 image:[UIImage imageNamed:@"tutor_chat_add_video"] title:@"视频通话"];

    //自定义消息
    [self registerClass:[CustomMessageCell class] forMessageClass:[CustomMessage class]];
    
    self.enableNewComingMessageIcon = YES; //开启消息提醒
    self.enableUnreadMessageIcon = YES; //是否在右上角提示上方存在的未读消息
}

#pragma mark 刷新用户信息
- (void)refreshUserInfo{
    if (self.conversationType == ConversationType_PRIVATE) {
        if (![self.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            NSDictionary *params = @{@"token":kUserTokenValue,@"third_id":self.targetId};
            [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kRongCloudInfoAPI parameters:params success:^(id responseObject) {
                NSDictionary *data  = [responseObject objectForKey:@"data"];
                [self.teacher setValues:data];
                self.teacher.third_id = self.targetId;
                
                RCUserInfo * userInfo = [[RCUserInfo alloc] init];
                userInfo.userId = self.targetId;
                userInfo.name = self.teacher.name;
                userInfo.portraitUri = self.teacher.cover;
                [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.footerView.hidden = NO;
                    if ([self.teacher.guide_status boolValue]) {
                        self.tipsLab.text = @"辅导结束后，请主动点击结束辅导。\n结束辅导后，将上传辅导记录。";
                        [self.coachBtn setTitle:@"结束辅导" forState:UIControlStateNormal];
                    }else{
                        self.tipsLab.text = @"请点击开始辅导按钮！\n开始辅导后，学习顾问将会全程监控";
                        [self.coachBtn setTitle:@"开始辅导" forState:UIControlStateNormal];
                    }
                    self.titleLab.text = userInfo.name;
                    [self.conversationMessageCollectionView reloadData];
                });
            } failure:^(NSString *errorStr) {
                
            }];
        }
    }
    
    //刷新自己头像昵称
    RCUserInfo *user = [RCIM sharedRCIM].currentUserInfo;
    user.name = [NSUserDefaultsInfos getValueforKey:kUserNickname];
    user.portraitUri = [NSUserDefaultsInfos getValueforKey:kUserHeadPic];
    MyLog(@"自己的用户信息，userId:%@,trait:%@,name:%@",user.userId,user.portraitUri,user.name);
    [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
}

#pragma mark 立即购买
-(void)gotoBuyCoachReminderAction{
    NSDictionary *info = @{@"title":@"购买辅导服务",@"tips":@"您没有辅导权限，请购买",@"cancel":@"放弃",@"confirm":@"立即购买"};
    [CustomReminderView showReminderViewWithFrame:IS_IPAD?CGRectMake(0, 0, 400, 260):CGRectMake(0, 0, 285, 180) info:info confirmAction:^{
        BuyCoachViewController *buyVC = [[BuyCoachViewController alloc] init];
        buyVC.teacher = self.teacher;
        [self.navigationController pushViewController:buyVC animated:YES];
    }];
}

#pragma mark 结束辅导
-(void)endThisCoachWithIsOtherEnd:(BOOL)isOtherEnd{
    NSDictionary *params = @{@"token":kUserTokenValue,@"t_id":self.teacher.t_id,};
    [[HttpRequest sharedInstance] postWithURLString:kEndCoachAPI parameters:params success:^(id responseObject) {
        if (!isOtherEnd) {
            RCInformationNotificationMessage *warningMsg =[RCInformationNotificationMessage notificationWithMessage:@"本次辅导结束" extra:@"end_coach"];
            [self sendMessage:warningMsg pushContent:nil];
            [self insertReminderMsgContent:@"你已经完成本次辅导，快对本次辅导进行评价吧～" extra:@"msg_evaluate"];
            if ([self.teacher.user_pay integerValue]!=1&&[self.teacher.coupon_id integerValue]>0) {
                [self insertReminderMsgContent:@"本次免费体验已经完成，如果觉得老师很棒，就去购买吧～" extra:@"msg_buy"];
            }
        }else{
            [self insertReminderMsgContent:@"陈老师已经主动结束本次辅导，快对本次辅导进行评价吧～" extra:@"msg_evaluate"];
        }
        [HomeworkManager sharedHomeworkManager].isUpdateHome = YES;
        
        self.guide_id = [responseObject objectForKey:@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tipsLab.text = @"请点击开始辅导按钮！\n开始辅导后，学习顾问将会全程监控";
            [self.coachBtn setTitle:@"开始辅导" forState:UIControlStateNormal];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 导航栏背景
-(UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(10, KStatusHeight+9, 50, 50):CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [leftBtn setImage:[UIImage drawImageWithName:@"return_black"size:IS_IPAD?CGSizeMake(13, 23):CGSizeMake(12, 18)] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(chatBackAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:leftBtn];
        
        self.titleLab = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-280)/2.0, KStatusHeight+16, 280, 36):CGRectMake((kScreenWidth-240)/2, KStatusHeight+12, 240, 22)];
        self.titleLab.textColor=[UIColor commonColor_black];
        self.titleLab.font=[UIFont mediumFontWithSize:18.0f];
        self.titleLab.textAlignment=NSTextAlignmentCenter;
        
        [_navView addSubview:self.titleLab];
        
        self.moreBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
        [self.moreBtn setImage:[UIImage drawImageWithName:@"tutor_chat_more" size:IS_IPAD?CGSizeMake(27, 33):CGSizeMake(18, 22)] forState:UIControlStateNormal];
        [self.moreBtn addTarget:self action:@selector(chatMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:self.moreBtn];
        
    }
    return _navView;
}

#pragma mark 底部视图
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight-self.chatSessionInputBarControl.height-(IS_IPAD?80:62), kScreenWidth, IS_IPAD?80:62)];
        _footerView.backgroundColor = [UIColor colorWithHexString:@"#EAECF9"];
        
        _tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10,kScreenWidth-100,IS_IPAD?64:40)];
        _tipsLab.textColor=[UIColor colorWithHexString:@"#9495A0"];
        _tipsLab.font=[UIFont mediumFontWithSize:13.0f];
        _tipsLab.numberOfLines = 0;
        
        [_footerView addSubview:_tipsLab];
        
        _coachBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-100, 10, 90, 36):CGRectMake(kScreenWidth-75, 10, 65, 24)];
        _coachBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_coachBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF8C00"] endColor:[UIColor colorWithHexString:@"#FFA941"]];
        _coachBtn.layer.cornerRadius = 4.0;
        [_coachBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _coachBtn.titleLabel.font = [UIFont mediumFontWithSize:12];
        [_coachBtn addTarget:self action:@selector(coachBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_coachBtn];
    }
    return _footerView;
}

#pragma mark 插入消息
-(void)insertReminderMsgContent:(NSString *)content extra:(NSString *)extra{
    CustomMessage *msg = [CustomMessage messageWithContent:content extra:extra];
    RCMessage *savedMsg  =[[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_RECEIVE messageId:-1 content:msg];//注意messageId要设置为－1
    [self appendAndDisplayMessage:savedMsg];
}

-(UIView *)bottomBarView{
    if (!_bottomBarView) {
        _bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _bottomBarView.backgroundColor = [UIColor whiteColor];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2.0, 5, 180, 40)];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmBtn.backgroundColor = [UIColor commonColor_red];
        confirmBtn.layer.cornerRadius = 20;
        confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0];
        [confirmBtn addTarget:self action:@selector(confirmChooseChatRecordsAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBarView addSubview:confirmBtn];
    }
    return _bottomBarView;
}

-(TeacherModel *)teacher{
    if (!_teacher) {
        _teacher = [[TeacherModel alloc] init];
    }
    return _teacher;
}

@end
