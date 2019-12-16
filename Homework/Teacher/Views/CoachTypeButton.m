//
//  CoachTypeButton.m
//  Homework
//
//  Created by vision on 2019/9/17.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CoachTypeButton.h"

@interface CoachTypeButton ()


@property (nonatomic,strong) UILabel     *timeLab;
@property (nonatomic,strong) UILabel     *titleLab;
@property (nonatomic,strong) UILabel     *priceLab;
@property (nonatomic,strong) UILabel     *originPriceLab;


@end

@implementation CoachTypeButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenDisabled = NO;
        self.adjustsImageWhenHighlighted = NO;
        [self setBackgroundImage:[UIImage imageNamed:@"buy_price"] forState:UIControlStateNormal];
        
        [self addSubview:self.timeLab];
        [self addSubview:self.titleLab];
        [self addSubview:self.priceLab];
        [self addSubview:self.originPriceLab];
        
    }
    return self;
}

-(void)setTypeModel:(CoachTypeModel *)typeModel{
    NSString *timeStr = [NSString stringWithFormat:@"%@个月",typeModel.validity_month];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:timeStr];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:16.0f] range:NSMakeRange(timeStr.length-2, 2)];
    self.timeLab.attributedText = attributedStr;
    
    self.titleLab.text = typeModel.name;
    
    self.priceLab.text = [NSString stringWithFormat:@"¥%.2f",[typeModel.price doubleValue]];
    
    double oPrice = [typeModel.original_price doubleValue];
    if (oPrice>0.0) {
        NSString *textStr = [NSString stringWithFormat:@"原价：¥%.2f", oPrice];
        NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:textStr attributes:attribtDic];
        self.originPriceLab.attributedText = attribtStr;
    }else{
        self.originPriceLab.text = @"";
    }
}

-(void)setBtnHasSelected:(BOOL)btnHasSelected{
    _btnHasSelected = btnHasSelected;
    if (btnHasSelected) {
        [self setBackgroundImage:[UIImage imageNamed:@"buy_price2"] forState:UIControlStateNormal];
        self.priceLab.textColor = [UIColor commonColor_red];
        self.originPriceLab.textColor = [UIColor commonColor_red];
    }else{
        [self setBackgroundImage:[UIImage imageNamed:@"buy_price"] forState:UIControlStateNormal];
        self.priceLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        self.originPriceLab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
    }
    
}

#pragma mark -- Getters
#pragma mark 有效期
-(UILabel *)timeLab{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(10,IS_IPAD?90:(IS_IPHONE_5?25:35), self.width-20,IS_IPAD?38:26)];
        _timeLab.textColor = [UIColor whiteColor];
        _timeLab.font = [UIFont mediumFontWithSize:IS_IPHONE_5?22.0f:26.0f];
        _timeLab.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLab;
}

#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10,self.timeLab.bottom,self.width-20,IS_IPAD?32:20)];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont regularFontWithSize:11.0f];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

#pragma mark 价格
-(UILabel *)priceLab{
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] initWithFrame:CGRectMake(10,self.titleLab.bottom+(IS_IPAD?40:(IS_IPHONE_5?5:14)), self.width-20,IS_IPAD?30:18)];
        _priceLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _priceLab.font = [UIFont mediumFontWithSize:IS_IPHONE_5?14.0f:18.0f];
        _priceLab.textAlignment = NSTextAlignmentCenter;
    }
    return _priceLab;
}

#pragma mark 原价
-(UILabel *)originPriceLab{
    if (!_originPriceLab) {
        _originPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(10,self.priceLab.bottom, self.width-20,IS_IPAD?26:14)];
        _originPriceLab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        _originPriceLab.font = [UIFont regularFontWithSize:9.0f];
        _originPriceLab.textAlignment = NSTextAlignmentCenter;
    }
    return _originPriceLab;
}



@end
