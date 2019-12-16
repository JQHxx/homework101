//
//  LogoutReminderView.m
//  Homework
//
//  Created by vision on 2019/10/25.
//  Copyright © 2019 vision. All rights reserved.
//

#import "LogoutReminderView.h"
#import "QWAlertView.h"

@interface LogoutReminderView ()

@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *tipsLab;
@property (nonatomic,strong) UIButton *confirmBtn;

@end

@implementation LogoutReminderView


+(void)showReminderViewWithFrame:(CGRect)frame{
    LogoutReminderView *view = [[LogoutReminderView alloc] initWithFrame:frame];
    [view reminderViewShow];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.0;
        
        [self addSubview:self.titleLab];
        [self addSubview:self.tipsLab];
        [self addSubview:self.confirmBtn];
    }
    return self;
}

#pragma mark -- Event response
-(void)confrimAction{
    [[QWAlertView sharedMask] dismiss];
}

#pragma mark -- private methods
-(void)reminderViewShow{
    [[QWAlertView sharedMask] show:self withType:QWAlertViewStyleAlert];
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.width-40, 20)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont mediumFontWithSize:18];
        _titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLab.text = @"您的账号已注销";
    }
    return _titleLab;
}

#pragma mark 描述
-(UILabel *)tipsLab{
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(10,self.titleLab.bottom+15, self.width-40, 40)];
        _tipsLab.textAlignment = NSTextAlignmentCenter;
        _tipsLab.font = [UIFont regularFontWithSize:14];
        _tipsLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _tipsLab.numberOfLines = 0;
        _tipsLab.text = @"7天内如需找回，请联系客服\n电话号码：15675858101";
    }
    return _tipsLab;
}

#pragma mark 确定
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, self.tipsLab.bottom+25,self.width-60, 32)];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = [UIColor commonColor_red];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        _confirmBtn.layer.cornerRadius = 16;
        [_confirmBtn addTarget:self action:@selector(confrimAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

@end
