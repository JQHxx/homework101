//
//  SelCouponTableViewCell.m
//  Homework
//
//  Created by vision on 2019/10/15.
//  Copyright © 2019 vision. All rights reserved.
//

#import "SelCouponTableViewCell.h"

@interface SelCouponTableViewCell ()

@property (nonatomic,strong) UIImageView *bgImgView;
@property (nonatomic,strong) UIImageView *arrowImgView;
@property (nonatomic,strong) UILabel     *typeLabel;
@property (nonatomic,strong) UILabel     *priceLabel;

@end

@implementation SelCouponTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.bgImgView];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.priceLabel];
        
        [self.contentView addSubview:self.arrowImgView];
        self.arrowImgView.hidden = YES;
    }
    return self;
}

#pragma mark 更新UI
-(void)displayCellWithModel:(CoachCouponModel *)couponModel oid:(NSNumber *)oid{
    if ([oid integerValue]==[couponModel.cash_id integerValue]) {
        self.bgImgView.image = [UIImage imageNamed:@"coupon_popup_unchoose"];
        
        if ([couponModel.isSelected boolValue]) {
            self.arrowImgView.hidden = NO;
        }else{
            self.arrowImgView.hidden = YES;
        }
    }else{
        self.bgImgView.image = [UIImage imageNamed:@"coupon_popup_choose"];
    }
    self.typeLabel.text = couponModel.name;
    self.priceLabel.text = [NSString stringWithFormat:@"¥%ld",[couponModel.cost integerValue]];
}


#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(0, 10, 500, 80):CGRectMake(0, 5,245,60)];
        _bgImgView.image = [UIImage imageNamed:@"coupon_popup_choose"];
    }
    return _bgImgView;
}

#pragma mark 优惠券类型
-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(20, 35, 160, 30):CGRectMake(20,27, 100, 16)];
        _typeLabel.font = [UIFont mediumFontWithSize:16.0f];
        _typeLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
    }
    return _typeLabel;
}

#pragma mark 价格
-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(self.width-140,30,180, 40):CGRectMake(self.typeLabel.right,21, 95, 28)];
        _priceLabel.font = [UIFont mediumFontWithSize:28.0f];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _priceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _priceLabel;
}

-(UIImageView *)arrowImgView{
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(480, 0, 33, 33):CGRectMake(235, 0, 22, 22)];
        _arrowImgView.image = [UIImage imageNamed:@"coupon_red"];
    }
    return _arrowImgView;
}

@end
