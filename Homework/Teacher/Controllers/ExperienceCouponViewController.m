//
//  ExperienceCouponViewController.m
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ExperienceCouponViewController.h"
#import "ChatViewController.h"
#import "QWAlertView.h"
#import "ReceiveSuccessView.h"

@interface ExperienceCouponViewController ()

@property (nonatomic,strong) UIImageView    *bgImgView;
@property (nonatomic,strong) UIButton       *subjectBtn;
@property (nonatomic,strong) UILabel        *titleLabel;
@property (nonatomic,strong) UIImageView    *descImgView;
@property (nonatomic,strong) UIView         *headBgView;
@property (nonatomic,strong) UIImageView    *headImgView;
@property (nonatomic,strong) UILabel        *nameLabel;
@property (nonatomic,strong) UIButton       *receiveBtn;
@property (nonatomic,strong) UIView         *tipsView;

@property (nonatomic,strong) ReceiveSuccessView *successView;


@end

@implementation ExperienceCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"免费体验券";
    self.rightImageName = @"tutor_service";
    
    [self initExperienceCouponView];
}

#pragma mark -- Private Methods
#pragma mark 领取体验券
-(void)receiveCouponAction:(UIButton *)sender{
    [[HttpRequest sharedInstance] postWithURLString:kReceiveCouponsAPI parameters:@{@"token":kUserTokenValue,@"t_id":self.model.t_id} success:^(id responseObject) {
        [HomeworkManager sharedHomeworkManager].isUpdateHome = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QWAlertView sharedMask] show:self.successView withType:QWAlertViewStyleAlert];
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 返回
-(void)leftNavigationItemAction{
    [[QWAlertView sharedMask] dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark 立即使用
-(void)useNowAction{
    [[QWAlertView sharedMask] dismiss];
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = self.model.third_id;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化界面
-(void)initExperienceCouponView{
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.subjectBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.descImgView];
    [self.view addSubview:self.headBgView];
    [self.view addSubview:self.headImgView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.receiveBtn];
    [self.view addSubview:self.tipsView];
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _bgImgView.image = [UIImage imageNamed:@"teacher_free_experience_background"];
    }
    return _bgImgView;
}

#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(22, kNavHeight+26, 45, 27):CGRectMake(22,kNavHeight+26, 30, 18)];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
        NSString *subjectStr = [subjects objectAtIndex:[self.model.subject integerValue]-1];
        UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getShortBackgroundImageForSubject:subjectStr];
        [_subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
        [_subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subjectBtn.right+5,kNavHeight+25, kScreenWidth-self.subjectBtn.right-20,IS_IPAD?32:20)];
        _titleLabel.font = [UIFont mediumFontWithSize:19.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",kUserGradeValue];
    }
    return _titleLabel;
}

#pragma mark 描述
-(UIImageView *)descImgView{
    if (!_descImgView) {
        _descImgView = [[UIImageView alloc] initWithFrame:CGRectMake(38, self.titleLabel.bottom+68, kScreenWidth-76, (kScreenWidth-76)*(504.0/900.0))];
        _descImgView.image = [UIImage imageNamed:@"teacher_free_experience"];
    }
    return _descImgView;
}

#pragma mark 头像背景
-(UIView *)headBgView{
    if (!_headBgView) {
        _headBgView = [[UIView alloc] initWithFrame:CGRectMake(53, self.titleLabel.bottom+33, 58, 58)];
        _headBgView.backgroundColor = [UIColor colorWithHexString:@"#FFC82F"];
        [_headBgView setBorderWithCornerRadius:29 type:UIViewCornerTypeAll];
    }
    return _headBgView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(56, self.titleLabel.bottom+36, 52, 52)];
        if (kIsEmptyString(self.model.cover)) {
            _headImgView.image = [UIImage imageNamed:@"my_default_head"];
        }else{
            [_headImgView sd_setImageWithURL:[NSURL URLWithString:self.model.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
        }
        [_headImgView setBorderWithCornerRadius:26 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headBgView.right+5,self.headBgView.top, 160,IS_IPAD?42:30)];
        _nameLabel.font = [UIFont mediumFontWithSize:16.0f];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = [NSString stringWithFormat:@"老师：%@",self.model.name];
    }
    return _nameLabel;
}

#pragma mark 领取
-(UIButton *)receiveBtn{
    if (!_receiveBtn) {
        _receiveBtn = [[UIButton alloc] initWithFrame:CGRectMake(4, self.descImgView.bottom+5, kScreenWidth-7, (kScreenWidth-14)*(196.0/728.0))];
        [_receiveBtn setImage:[UIImage imageNamed:@"teacher_free_experience_button"] forState:UIControlStateNormal];
        [_receiveBtn addTarget:self action:@selector(receiveCouponAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _receiveBtn;
}

#pragma mark 领取成功
-(ReceiveSuccessView *)successView{
    if (!_successView) {
        _successView = [[ReceiveSuccessView alloc] initWithFrame:IS_IPAD?CGRectMake(0, 0, 400, 450):CGRectMake(0, 0, 285, 320)];
        [_successView setBorderWithCornerRadius:8 type:UIViewCornerTypeAll];
        _successView.teacher = self.model;
        [_successView.seeBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_successView.useBtn addTarget:self action:@selector(useNowAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _successView;
}

#pragma mark 说明
-(UIView *)tipsView{
    if (!_tipsView) {
        _tipsView = [[UIView alloc] initWithFrame:CGRectMake(0,self.receiveBtn.bottom+10, kScreenWidth, kScreenHeight-self.receiveBtn.bottom-20)];
        
        NSArray *titles = @[@"免费体验券领取规则",@"免费体验券使用规则",@"最终解释权归作业101所有"];
        NSArray *tipsArr = @[@"每个用户限领取单科老师赠送的一张免费体验券",@"免费体验券只能针对领取的老师使用"];
        CGFloat labHeight = 0.0;
        for (NSInteger i=0; i<titles.count; i++) {
            UILabel *aLab = [[UILabel alloc] initWithFrame:CGRectMake(24, labHeight, kScreenWidth-34, 16)];
            aLab.font = [UIFont mediumFontWithSize:16.0f];
            aLab.text = titles[i];
            aLab.textColor = [UIColor colorWithHexString:@"#FFE845"];
            [_tipsView addSubview:aLab];
            
            UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectZero];
            tipsLab.textColor = [UIColor whiteColor];
            tipsLab.font = [UIFont regularFontWithSize:13.0f];
            tipsLab.text = i<2?tipsArr[i]:@"";
            CGFloat tipsH = [tipsLab.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, 100) withTextFont:tipsLab.font].height;
            tipsLab.frame = CGRectMake(30, aLab.bottom+10, kScreenWidth-40, tipsH);
            [_tipsView addSubview:tipsLab];
             
            labHeight += tipsH+36;
        }
    }
    return _tipsView;
}



@end
