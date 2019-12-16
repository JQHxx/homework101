//
//  GuideTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "GuideTableViewCell.h"

@interface GuideTableViewCell (){
    BOOL paySwitch;
}

@property (nonatomic,strong) UIView      *bgView;
@property (nonatomic,strong) UIImageView *headImgView;
@property (nonatomic,strong) UILabel     *titleLabel;
@property (nonatomic,strong) UILabel     *descLabel;

@end

@implementation GuideTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
        
        
        self.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.guideButton];
        
        if (!paySwitch) {
           [self.contentView addSubview:self.rechargeButton];
        }
        
    }
    return self;
}

-(void)setServiceModel:(GuideServiceModel *)serviceModel{
    _serviceModel = serviceModel;
    
    if (kIsEmptyString(serviceModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:serviceModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    //科目
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[serviceModel.subject integerValue]-1];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@-%@",serviceModel.grade,subjectStr,serviceModel.name];
    
    NSString *endTimeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:serviceModel.end_time format:@"yyyy年MM月dd日"];
    NSString *descStr = [NSString stringWithFormat:@"%@（到期时间：%@）",serviceModel.name,endTimeStr];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:descStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#9495A0"] range:NSMakeRange(3, descStr.length-3)];
    self.descLabel.attributedText = attributeStr;
}

#pragma mark -- Getters
#pragma mark 背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(18, 6, kScreenWidth-36,IS_IPAD?88:66)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        _bgView.layer.shadowRadius = 5.0;
        _bgView.layer.shadowOpacity = 0.15;
    }
    return _bgView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(IS_IPHONE_5?23:33, 20,IS_IPAD?60:38, IS_IPAD?60:38)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?30:19.0 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+9, 20, kScreenWidth-130,IS_IPAD?26:14)];
        _titleLabel.font = [UIFont regularFontWithSize:12.0f];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    }
    return _titleLabel;
}

#pragma mark 描述
-(UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+9,self.titleLabel.bottom+5, kScreenWidth-self.headImgView.right-20, IS_IPAD?26:14)];
        _descLabel.font = [UIFont regularFontWithSize:12.0f];
        _descLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    }
    return _descLabel;
}

#pragma mark 辅导
-(UIButton *)guideButton{
    if (!_guideButton) {
        _guideButton = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-150, 15, 120, 36):CGRectMake(kScreenWidth-90,12, 65, 25)];
        _guideButton.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_guideButton.size direction:IHGradientChangeDirectionLevel startColor:[UIColor colorWithHexString:@"#FF6161"] endColor:[UIColor colorWithHexString:@"#FF6D98"]];
        [_guideButton setTitle:@"辅导" forState:UIControlStateNormal];
        [_guideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _guideButton.titleLabel.font = [UIFont mediumFontWithSize:IS_IPHONE_5?12:14.0f];
        _guideButton.layer.cornerRadius = 12.5;
    }
    return _guideButton;
}

#pragma mark 续费
-(UIButton *)rechargeButton{
    if (!_rechargeButton) {
        _rechargeButton = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-115, self.guideButton.bottom+10, 80, 32): CGRectMake(kScreenWidth-65,self.guideButton.bottom+15, 40, 20)];
        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:@"去续费>" attributes:attribtDic];
        [_rechargeButton setAttributedTitle:attribtStr forState:UIControlStateNormal];
        [_rechargeButton setTitleColor:[UIColor colorWithHexString:@"#6D6D6D"] forState:UIControlStateNormal];
        _rechargeButton.titleLabel.font = [UIFont regularFontWithSize:10.0f];
    }
    return _rechargeButton;
}

@end
