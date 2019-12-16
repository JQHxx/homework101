//
//  CoachEvaluateView.m
//  Homework
//
//  Created by vision on 2019/10/15.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CoachEvaluateView.h"
#import "QWAlertView.h"
#import "XHStarRateView.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"

@interface CoachEvaluateView ()<XHStarRateViewDelegate>

@property (nonatomic,strong) UILabel    *titleLab;
@property (nonatomic,strong) UIView     *starBgView;
@property (nonatomic,strong) UITextView  *evaluateTextView;
@property (nonatomic,strong) UIButton    *anonymousBtn;
@property (nonatomic,strong) UIButton    *cancelBtn;
@property (nonatomic,strong) UIButton    *submitBtn;

@property (nonatomic,assign) NSInteger score;

@property (nonatomic, copy ) SubmitBlock submitBlock;

@end

@implementation CoachEvaluateView

-(instancetype)initWithFrame:(CGRect)frame submitAction:(SubmitBlock)submitBlock{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setBorderWithCornerRadius:8.0 type:UIViewCornerTypeAll];
        
        self.submitBlock = submitBlock;
        
        self.score = 5;
        
        [self addSubview:self.titleLab];
        [self addSubview:self.starBgView];
        [self addSubview:self.evaluateTextView];
        [self addSubview:self.anonymousBtn];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.submitBtn];
        
    }
    return self;
}

+(void)showEvaluateViewWithFrame:(CGRect)frame submitAction:(SubmitBlock)submitBlock{
    CoachEvaluateView *view = [[CoachEvaluateView alloc] initWithFrame:frame submitAction:submitBlock];
    [view evaluateViewShow];
}

#pragma mark XHStarRateViewDelegate
-(void)starRateView:(XHStarRateView *)starRateView currentScore:(CGFloat)currentScore{
    self.score = currentScore;
}


#pragma mark -- Event response
#pragma mark 设置匿名
-(void)setAnonymousAction:(UIButton *)sender{
    sender.selected = !sender.selected;
}

#pragma mark 提交评价
-(void)submitEvaluateAction{
    if (kIsEmptyString(self.evaluateTextView.text)) {
        [self makeToast:@"请先输入评价" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    [[QWAlertView sharedMask] dismiss];
    self.submitBlock(self.score, self.evaluateTextView.text, self.anonymousBtn.selected);
}

#pragma mark 取消评价
-(void)cancelEvaluateAction{
    [[QWAlertView sharedMask] dismiss];
}

#pragma mark -- private methods
-(void)evaluateViewShow{
    [[QWAlertView sharedMask] show:self withType:QWAlertViewStyleAlert];
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, self.width-40,IS_IPAD?32:20)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont mediumFontWithSize:18];
        _titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLab.text = @"评价";
    }
    return _titleLab;
}

#pragma mark 评分
-(UIView *)starBgView{
    if (!_starBgView) {
        _starBgView = [[UIView alloc] initWithFrame:CGRectMake(20, self.titleLab.bottom+10, self.width-40, 54)];
        _starBgView.backgroundColor = [UIColor colorWithHexString:@"#F6F6FA"];
        [_starBgView setBorderWithCornerRadius:27 type:UIViewCornerTypeAll];
        
        XHStarRateView *starRateView = [[XHStarRateView alloc] initWithFrame:CGRectMake(20, 10,IS_IPAD?320:205,34) numberOfStars:5 rateStyle:WholeStar isAnination:NO delegate:self];
        starRateView.currentScore = self.score;
        [_starBgView addSubview:starRateView];
    }
    return _starBgView;
}

#pragma mark  评论内容
-(UITextView *)evaluateTextView{
    if (!_evaluateTextView) {
        _evaluateTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, self.starBgView.bottom+15, self.width-40,IS_IPAD?136:116)];
        _evaluateTextView.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _evaluateTextView.backgroundColor = [UIColor colorWithHexString:@"#F6F6FA"];
        _evaluateTextView.layer.cornerRadius = 8.0;
        _evaluateTextView.font = [UIFont regularFontWithSize:14.0f];
        _evaluateTextView.zw_labHeight = 30.0;
        _evaluateTextView.zw_placeHolder = @"请输入文字评价";
        _evaluateTextView.zw_limitCount = 50;
    }
    return _evaluateTextView;
}

#pragma mark 取消
-(UIButton *)anonymousBtn{
    if (!_anonymousBtn) {
        _anonymousBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.evaluateTextView.bottom+10,IS_IPAD?120:96,IS_IPAD?44:32)];
        [_anonymousBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
        [_anonymousBtn setImage:[UIImage imageNamed:@"coupon_gray"] forState:UIControlStateNormal];
        [_anonymousBtn setImage:[UIImage imageNamed:@"coupon_red"] forState:UIControlStateSelected];
        [_anonymousBtn setTitle:@"匿名提交" forState:UIControlStateNormal];
        _anonymousBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        _anonymousBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [_anonymousBtn addTarget:self action:@selector(setAnonymousAction:) forControlEvents:UIControlEventTouchUpInside];
        _anonymousBtn.selected = YES;
    }
    return _anonymousBtn;
}


#pragma mark 取消
-(UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, self.anonymousBtn.bottom+20,IS_IPAD?120:96,IS_IPAD?44:32)];
        [_cancelBtn setTitleColor:[UIColor commonColor_red] forState:UIControlStateNormal];
        _cancelBtn.layer.cornerRadius = IS_IPAD?22:16;
        _cancelBtn.layer.borderColor = [UIColor commonColor_red].CGColor;
        _cancelBtn.layer.borderWidth = 1.0;
        [_cancelBtn setTitle:@"放弃" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        [_cancelBtn addTarget:self action:@selector(cancelEvaluateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

#pragma mark 确定
-(UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.cancelBtn.right+(IS_IPAD?40:24), self.anonymousBtn.bottom+20,IS_IPAD?120:96,IS_IPAD?44:32)];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.backgroundColor = [UIColor commonColor_red];
        _submitBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        _submitBtn.layer.cornerRadius = IS_IPAD?22:16;
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitEvaluateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

@end
