//
//  TeacherDetailsViewController.m
//  Homework
//
//  Created by vision on 2019/10/16.
//  Copyright © 2019 vision. All rights reserved.
//

#import "TeacherDetailsViewController.h"
#import "ExperienceCouponViewController.h"
#import "BuyCoachViewController.h"
#import "ChatViewController.h"

@interface TeacherDetailsViewController (){
    BOOL paySwitch;
}

@end

@implementation TeacherDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
    if (paySwitch) {
        self.rightImageName = @"";
        self.rightBtn.userInteractionEnabled = NO;
    }else{
        self.rightImageName = @"teacher_share";
        self.rightBtn.userInteractionEnabled = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"老师详情"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"老师详情"];
}

#pragma mark -- Event response
#pragma mark 分享
-(void)rightNavigationItemAction{
    [[HomeworkManager sharedHomeworkManager] shareToOtherUsersFromController:self];
}

#pragma mark -- Public methods
#pragma mark 监听
-(void)webListenToJumpWithUrl:(NSString *)url{
    if ([url rangeOfString:@"getcoupon"].location != NSNotFound) { //领取优惠券
        ExperienceCouponViewController *experienceCouponVC = [[ExperienceCouponViewController alloc] init];
        experienceCouponVC.model = self.teacherDetails;
        [self.navigationController pushViewController:experienceCouponVC animated:YES];
    }else if ([url rangeOfString:@"applyguide"].location != NSNotFound){ //申请辅导
        if (paySwitch) {
            ChatViewController *chatVC = [[ChatViewController alloc]init];
            chatVC.conversationType = ConversationType_PRIVATE;
            chatVC.targetId = self.teacherDetails.third_id;
            [self.navigationController pushViewController:chatVC animated:YES];
        }else{
            BuyCoachViewController *buyVC = [[BuyCoachViewController alloc] init];
            buyVC.teacher = self.teacherDetails;
            [self.navigationController pushViewController:buyVC animated:YES];
        }
    }else if ([url rangeOfString:@"contectteacher"].location != NSNotFound){ //联系老师
        if (!kIsEmptyString(self.teacherDetails.third_id)) {
            ChatViewController *chatVC = [[ChatViewController alloc]init];
            chatVC.conversationType = ConversationType_PRIVATE;
            chatVC.targetId = self.teacherDetails.third_id;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }
}

@end
