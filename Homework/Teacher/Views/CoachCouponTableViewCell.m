//
//  CoachCouponTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/20.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CoachCouponTableViewCell.h"
#import "NSDate+Extend.h"

@interface CoachCouponTableViewCell ()

@property (nonatomic,strong) UIImageView *bgImgView;
@property (nonatomic,strong) UILabel     *typeLabel;
@property (nonatomic,strong) UILabel     *priceLabel;
@property (nonatomic,strong) UILabel     *expireLabel;

@end

@implementation CoachCouponTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.bgImgView];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.expireLabel];
        [self.contentView addSubview:self.priceLabel];
    }
    return self;
}

-(void)setCouponModel:(CoachCouponModel *)couponModel{
    self.typeLabel.text = couponModel.name;
    
    NSString *futureDateStr = [NSDate futureDateForDays:[couponModel.validity integerValue] format:@"yyyy-MM-dd"];
    self.expireLabel.text = [NSString stringWithFormat:@"有效期至：%@",futureDateStr];
    self.priceLabel.text = [NSString stringWithFormat:@"¥%ld",[couponModel.cost integerValue]];
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth-52,IS_IPAD?100:80)];
        _bgImgView.image = [UIImage imageNamed:@"tutor_coupons"];
    }
    return _bgImgView;
}

#pragma mark 优惠券类型
-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(18,IS_IPHONE_5?15:25,IS_IPAD?240:130,IS_IPAD?32:20)];
        _typeLabel.font = [UIFont mediumFontWithSize:IS_IPHONE_5?14.0f:20.0f];
        _typeLabel.textColor = [UIColor colorWithHexString:@"#EE3D1D"];
    }
    return _typeLabel;
}

#pragma mark 有效期
-(UILabel *)expireLabel{
    if (!_expireLabel) {
        _expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(18,self.typeLabel.bottom + 10,IS_IPAD?300:160, IS_IPAD?32:20)];
        _expireLabel.font = [UIFont mediumFontWithSize:13.0f];
        _expireLabel.textColor = [UIColor colorWithHexString:@"#863512"];
    }
    return _expireLabel;
}

#pragma mark 价格
-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-240, 40, 150, 48): CGRectMake(IS_IPHONE_5?kScreenWidth-170:kScreenWidth-170,IS_IPHONE_5?22:28,110,36)];
        _priceLabel.font = [UIFont mediumFontWithSize:IS_IPHONE_5?30.0f:36.0f];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#863512"];
        _priceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _priceLabel;
}

@end
