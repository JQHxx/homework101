//
//  TicketTableViewCell.m
//  Homework
//
//  Created by vision on 2019/10/8.
//  Copyright © 2019 vision. All rights reserved.
//

#import "TicketTableViewCell.h"

@interface TicketTableViewCell ()

@property (nonatomic,strong) UIImageView *bgImgView;
@property (nonatomic,strong) UIImageView *headImgView;
@property (nonatomic,strong) UILabel     *titleLabel;
@property (nonatomic,strong) UILabel     *descLabel;
@property (nonatomic,strong) UILabel     *expireLabel;


@end

@implementation TicketTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.bgImgView];
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.expireLabel];
        [self.contentView addSubview:self.useBtn];
    }
    return self;
}

-(void)setTicketModel:(ExpTicketModel *)ticketModel{
    
    if (kIsEmptyString(ticketModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:ticketModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    self.titleLabel.text = @"辅导体验券";
    
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[ticketModel.subject integerValue]-1];
    self.descLabel.text = [NSString stringWithFormat:@"%@-%@%@在线1对1家教辅导",ticketModel.teacher_name,kUserGradeValue,subjectStr];
    
    NSString *timeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:ticketModel.end_time format:@"yyyy年MM月dd日"];
    self.expireLabel.text = [NSString stringWithFormat:@"有限期至：%@",timeStr];
    
    if ([ticketModel.is_use integerValue]==0) {
        self.useBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_useBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF6644"] endColor:[UIColor colorWithHexString:@"#EC0023"]];
        [self.useBtn setTitle:@"去使用" forState:UIControlStateNormal];
        [self.useBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        if ([ticketModel.is_use integerValue]==0) {
            [self.useBtn setTitle:@"已过期" forState:UIControlStateNormal];
        }else{
            [self.useBtn setTitle:@"已使用" forState:UIControlStateNormal];
        }
        self.useBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_useBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#EAEAEA"] endColor:[UIColor colorWithHexString:@"#CACACA"]];
        [self.useBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
    }
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, IS_IPAD?150:100)];
        _bgImgView.image = [UIImage imageNamed:@"my_coupon_background"];
    }
    return _bgImgView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(36,26,IS_IPAD?80:40,IS_IPAD?80:40)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?40:20 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+8, 26, kScreenWidth-self.headImgView.right-30,IS_IPAD?32:20)];
        _titleLabel.font = [UIFont regularFontWithSize:18.0f];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    }
    return _titleLabel;
}

#pragma mark 说明
-(UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+8,self.titleLabel.bottom+5,kScreenWidth-self.headImgView.right-30,IS_IPAD?32: 20)];
        _descLabel.textColor = [UIColor commonColor_black];
        _descLabel.font = [UIFont mediumFontWithSize:13.0f];
    }
    return _descLabel;
}

#pragma mark 有效期
-(UILabel *)expireLabel{
    if (!_expireLabel) {
        _expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, self.headImgView.bottom+20,kScreenWidth-216, IS_IPAD?24:12)];
        _expireLabel.font = [UIFont regularFontWithSize:12.0f];
        _expireLabel.textColor = [UIColor colorWithHexString:@"#863512"];
    }
    return _expireLabel;
}

 
#pragma mark 使用
-(UIButton *)useBtn{
    if (!_useBtn) {
        _useBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-180, 110, 150, 40):CGRectMake(kScreenWidth-130, 76, 95, 25)];
        _useBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_useBtn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF6644"] endColor:[UIColor colorWithHexString:@"#EC0023"]];
        [_useBtn setTitle:@"去使用" forState:UIControlStateNormal];
        [_useBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _useBtn.titleLabel.font = [UIFont mediumFontWithSize:14.0f];
        [_useBtn setBorderWithCornerRadius:12.5 type:UIViewCornerTypeAll];
    }
    return _useBtn;
}


@end
