//
//  SelCouponsView.m
//  Homework
//
//  Created by vision on 2019/10/15.
//  Copyright © 2019 vision. All rights reserved.
//

#import "SelCouponsView.h"
#import "SelCouponTableViewCell.h"


@interface SelCouponsView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIView  *bgView;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UITableView *couponTableView;
@property (nonatomic,strong) UIButton *confirmBtn;


@end

@implementation SelCouponsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.closeBtn];
        [self addSubview:self.bgView];
        [self addSubview:self.titleLab];
        [self addSubview:self.couponTableView];
        [self addSubview:self.confirmBtn];
    }
    return self;
}

#pragma mark  -- UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.couponsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SelCouponTableViewCell *cell = [[SelCouponTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CoachCouponModel *model = self.couponsArray[indexPath.row];
    [cell displayCellWithModel:model oid:self.o_id];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?100:70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CoachCouponModel *model = self.couponsArray[indexPath.row];
    if ([model.cash_id integerValue]==[self.o_id integerValue]) {
        for (CoachCouponModel *coupon in self.couponsArray) {
            if ([coupon.id integerValue]==[model.id integerValue]) {
                coupon.isSelected = [NSNumber numberWithBool:YES];
            }else{
                coupon.isSelected = [NSNumber numberWithBool:NO];
            }
        }
        [self.couponTableView reloadData];
        self.selCouponModel = model;
    }
}

-(void)setCouponsArray:(NSMutableArray *)couponsArray{
    _couponsArray = couponsArray;
    
    if (self.selCouponModel&&[self.selCouponModel.id integerValue]>0) {
        for (CoachCouponModel *coupon in self.couponsArray) {
            if ([coupon.id integerValue]==[self.selCouponModel.id integerValue]) {
                coupon.isSelected = [NSNumber numberWithBool:YES];
            }else{
                coupon.isSelected = [NSNumber numberWithBool:NO];
            }
        }
    }else{
        for (CoachCouponModel *coupon in self.couponsArray) {
            coupon.isSelected = [NSNumber numberWithBool:NO];
        }
    }
    
    [self.couponTableView reloadData];
}

-(void)setO_id:(NSNumber *)o_id{
    _o_id = o_id;
}

#pragma mark -- Event response
#pragma mark 确定
-(void)confrimAction{
    if (!self.selCouponModel) {
        [self makeToast:@"请先选择优惠券" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if ([self.viewDelegate respondsToSelector:@selector(selCouponsViewDidSelectCoupon:)]) {
        [self.viewDelegate selCouponsViewDidSelectCoupon:self.selCouponModel];
    }
}

#pragma mark 关闭
-(void)closeAction{
    if ([self.viewDelegate respondsToSelector:@selector(selCouponsViewCloseAction)]) {
        [self.viewDelegate selCouponsViewCloseAction];
    }
}

#pragma mark -- getters
#pragma mark 关闭
-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width-30, 0, 30, 30)];
        [_closeBtn setImage:[UIImage imageNamed:@"coupon_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark 背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.closeBtn.bottom+10, self.width, self.height-40)];
        _bgView.backgroundColor = [UIColor whiteColor];
        [_bgView setBorderWithCornerRadius:8.0 type:UIViewCornerTypeAll];
    }
    return _bgView;
}

#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20,self.closeBtn.bottom + 30, self.width-40,IS_IPAD?32:20)];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont mediumFontWithSize:18];
        _titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLab.text = @"我的优惠券";
    }
    return _titleLab;
}

#pragma mark 优惠券
-(UITableView *)couponTableView{
    if (!_couponTableView) {
        _couponTableView = [[UITableView alloc] initWithFrame:IS_IPAD?CGRectMake(40, self.titleLab.bottom+10, 520, 400):CGRectMake(20, self.titleLab.bottom+10, 260, 225) style:UITableViewStylePlain];
        _couponTableView.dataSource = self;
        _couponTableView.delegate = self;
        _couponTableView.tableFooterView = [[UIView alloc] init];
        _couponTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _couponTableView.backgroundColor = [UIColor whiteColor];
    }
    return _couponTableView;
}

#pragma mark 确定
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake((self.width-300)/2.0, self.couponTableView.bottom+20, 300, 48):CGRectMake((self.width-140)/2.0, self.couponTableView.bottom+20, 140, 32)];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = [UIColor commonColor_red];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:15];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        _confirmBtn.layer.cornerRadius = IS_IPAD?24:16;
        [_confirmBtn addTarget:self action:@selector(confrimAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

@end
