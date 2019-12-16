//
//  MyConversationViewController.m
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyConversationViewController.h"
#import "ChatViewController.h"
#import "BlankView.h"

@interface MyConversationViewController ()

@property (nonatomic,strong) BlankView  *blankView;

@end

@implementation MyConversationViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        //设置需要显示哪些类型的会话
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setConversationListConfig];
}


#pragma mark -- Public Methods
#pragma mark 点击会话跳转
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath{
    MyLog(@"onSelectedTableRow");
    if ([self.controlerDelegate respondsToSelector:@selector(myConversationViewControllerDidPushToChatWithTargetID:)]) {
        [self.controlerDelegate myConversationViewControllerDidPushToChatWithTargetID:model.targetId];
    }
}

#pragma mark  即将更新未读消息数的回调
-(void)notifyUpdateUnreadMessageCount{
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE)]];
    MyLog(@"notifyUpdateUnreadMessageCount:%d",count);
    if ([self.controlerDelegate respondsToSelector:@selector(myConversationViewControllerShowMessageUnreadCount:)]) {
        [self.controlerDelegate myConversationViewControllerShowMessageUnreadCount:count];
    }
    
    [self refreshConversationTableViewIfNeeded];
}

#pragma mark -- Private Methods
#pragma mark 设置会话相关属性
-(void)setConversationListConfig{
    MyLog(@"setConversationListConfig");
    
    
    //设置头像样式和大小
    [self setConversationAvatarStyle:RC_USER_AVATAR_CYCLE];
    [self setConversationPortraitSize:CGSizeMake(50, 50)];
    
    //设置会话列表
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"#EAEBF0"];
    self.conversationListTableView.tableFooterView = [UIView new];
    
    // 设置在NavigatorBar中显示连接中的提示
    self.showConnectingStatusOnNavigatorBar = NO;
    //显示网络连接不可用的提示
    self.isShowNetworkIndicatorView = NO;
    //
    self.emptyConversationView = self.blankView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?120:80, kScreenWidth, 200) img:@"blank_coach" msg:@"暂无辅导消息"];
    }
    return _blankView;
}

@end
