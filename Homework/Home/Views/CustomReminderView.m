//
//  CustomReminderView.m
//  Homework
//
//  Created by vision on 2019/10/14.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CustomReminderView.h"
#import "QWAlertView.h"
#import <UMAnalytics/MobClick.h>

@interface CustomReminderView ()

@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *tipsLab;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *confirmBtn;

@property (nonatomic, copy ) ConfirmBlock confirmBlock;

@end

@implementation CustomReminderView


#pragma mark Public Methods
+(void)showReminderViewWithFrame:(CGRect)frame info:(NSDictionary *)info confirmAction:(ConfirmBlock)confrim{
    CustomReminderView *reminderView = [[CustomReminderView alloc] initWithFrame:frame info:info confirmAction:confrim];
    [reminderView reminderViewShow];
}

-(instancetype)initWithFrame:(CGRect)frame info:(NSDictionary *)info confirmAction:(ConfirmBlock)confrim{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.0;
        
        self.confirmBlock = confrim;
        
        [self addSubview:self.titleLab];
        [self addSubview:self.tipsLab];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.confirmBtn];
        
        self.titleLab.text = info[@"title"];
        self.tipsLab.text = info[@"tips"];
        CGFloat tipsH = [self.tipsLab.text boundingRectWithSize:CGSizeMake(frame.size.width-40, frame.size.height) withTextFont:self.tipsLab.font].height;
        self.tipsLab.frame = CGRectMake(10,self.titleLab.bottom+15, self.width-40,tipsH);
        
        [self.cancelBtn setTitle:info[@"cancel"] forState:UIControlStateNormal];
        self.cancelBtn.frame = CGRectMake(35, self.tipsLab.bottom+25,IS_IPAD?120:96,IS_IPAD?44:32);
        [self.confirmBtn setTitle:info[@"confirm"] forState:UIControlStateNormal];
        self.confirmBtn.frame = CGRectMake(self.cancelBtn.right+(IS_IPAD?32:24), self.tipsLab.bottom+25,IS_IPAD?120:96,IS_IPAD?44:32);
    }
    return self;
}

#pragma mark -- Event response
-(void)confrimAction{
    [MobClick event:kStaticsChatBuyEvent];
    [[QWAlertView sharedMask] dismiss];
    self.confirmBlock();
}

-(void)cancelAction{
    [MobClick event:kStaticsNoneBuyEvent];
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
    }
    return _tipsLab;
}

#pragma mark 取消
-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, self.tipsLab.bottom+25,IS_IPAD?120:96,IS_IPAD?44:32)];
        [_cancelBtn setTitleColor:[UIColor commonColor_red] forState:UIControlStateNormal];
        _cancelBtn.layer.cornerRadius = IS_IPAD?22:16;
        _cancelBtn.layer.borderColor = [UIColor commonColor_red].CGColor;
        _cancelBtn.layer.borderWidth = 1.0;
        _cancelBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

#pragma mark 确定
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.cancelBtn.right+24, self.tipsLab.bottom+25,IS_IPAD?120:96,IS_IPAD?44:32)];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = [UIColor commonColor_red];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        _confirmBtn.layer.cornerRadius = IS_IPAD?22:16;
        [_confirmBtn addTarget:self action:@selector(confrimAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

@end
