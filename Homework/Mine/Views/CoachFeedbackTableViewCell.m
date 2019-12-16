//
//  CoachFeedbackTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CoachFeedbackTableViewCell.h"

@interface CoachFeedbackTableViewCell ()

@property (nonatomic,strong) UIImageView  *headImgView;
@property (nonatomic,strong) UILabel      *nameLabel;
@property (nonatomic,strong) UIView       *bgView;
@property (nonatomic,strong) UIButton     *timeBtn;
@property (nonatomic,strong) UILabel      *titleLabel;
@property (nonatomic,strong) UIImageView  *advanImgView;
@property (nonatomic,strong) UILabel      *advanLabel;
@property (nonatomic,strong) UIImageView  *disadvanImgView;
@property (nonatomic,strong) UILabel      *disadvanLabel;


@end

@implementation CoachFeedbackTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.timeBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.advanImgView];
        [self.contentView addSubview:self.advanLabel];
        [self.contentView addSubview:self.disadvanImgView];
        [self.contentView addSubview:self.disadvanLabel];
    }
    return self;
}

-(void)setFeedbackModel:(CoachFeedbackModel *)feedbackModel{
    if (kIsEmptyString(feedbackModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:feedbackModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    self.nameLabel.text = feedbackModel.teacher_name;
    
    NSString *timeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:feedbackModel.end_time format:@"yyyy-MM-dd"];
    [self.timeBtn setTitle:timeStr forState:UIControlStateNormal];
    
    //科目
    self.titleLabel.text = [NSString stringWithFormat:@"%@辅导反馈",feedbackModel.subject];
    
    NSString *advanStr = [NSString stringWithFormat:@"优点：%@",feedbackModel.merit];
    CGFloat advanHeight = [advanStr boundingRectWithSize:CGSizeMake(kScreenWidth-166, CGFLOAT_MAX) withTextFont:self.advanLabel.font].height;
    self.advanLabel.frame = CGRectMake(self.advanImgView.right+8, self.timeBtn.bottom+15, kScreenWidth-166, advanHeight);
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:advanStr];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:15.0f] range:NSMakeRange(0, 3)];
    self.advanLabel.attributedText = attributedStr;
    
    self.disadvanImgView.frame = IS_IPAD?CGRectMake(86, self.advanLabel.bottom+15, 24, 24):CGRectMake(86, self.advanLabel.bottom+15, 20, 20);
    
    NSString *disadvanStr = [NSString stringWithFormat:@"缺点：%@",feedbackModel.defect];
    CGFloat disadvanHeight = [disadvanStr boundingRectWithSize:CGSizeMake(kScreenWidth-166, CGFLOAT_MAX) withTextFont:self.disadvanLabel.font].height;
    self.disadvanLabel.frame = CGRectMake(self.disadvanImgView.right+8, self.advanLabel.bottom+15, kScreenWidth-166, disadvanHeight);
    NSMutableAttributedString *attributedStr1 = [[NSMutableAttributedString alloc] initWithString:disadvanStr];
    [attributedStr1 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:15.0f] range:NSMakeRange(0, 3)];
    self.disadvanLabel.attributedText = attributedStr1;
    
    self.bgView.frame = CGRectMake(68, self.nameLabel.bottom+5, kScreenWidth-120, advanHeight+disadvanHeight+(IS_IPAD?95:85));
}

+(CGFloat)getMyFeedbackCellHeightWithModel:(CoachFeedbackModel *)model{
    CGFloat aWidth = kScreenWidth-166;
    CGFloat advanHeight = [model.merit boundingRectWithSize:CGSizeMake(aWidth, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15.0f]].height;
    CGFloat disadvanHeight = [model.defect boundingRectWithSize:CGSizeMake(aWidth, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15.0f]].height;
    return advanHeight+disadvanHeight+(IS_IPAD?145:135);
}

#pragma mark -- getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
        [_headImgView setBorderWithCornerRadius:20.0 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 昵称
-(UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, 10, 240,IS_IPAD?28:16)];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _nameLabel.font = [UIFont regularFontWithSize:12.0f];
    }
    return _nameLabel;
}

#pragma mark 头像背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 6.0f;
    }
    return _bgView;
}

#pragma mark 时间
-(UIButton *)timeBtn{
    if (!_timeBtn) {
        _timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(86, self.nameLabel.bottom+24,IS_IPAD?150:110, IS_IPAD?30:18)];
        [_timeBtn setImage:[UIImage imageNamed:@"tutor_feedback_time"] forState:UIControlStateNormal];
        [_timeBtn setTitle:@"0000-00-00" forState:UIControlStateNormal];
        [_timeBtn setTitleColor:[UIColor colorWithHexString:@"#FF8B00"] forState:UIControlStateNormal];
        _timeBtn.titleLabel.font = [UIFont regularFontWithSize:15.0f];
        _timeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        _timeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    }
    return _timeBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeBtn.right+5, self.nameLabel.bottom+24,kScreenWidth-self.timeBtn.right-60,IS_IPAD?30:18)];
        _titleLabel.textColor = [UIColor commonColor_black];
        _titleLabel.font = [UIFont regularFontWithSize:15.0f];
    }
    return _titleLabel;
}

-(UIImageView *)advanImgView{
    if (!_advanImgView) {
        _advanImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(86, self.timeBtn.bottom+15, 24, 24):CGRectMake(86, self.timeBtn.bottom+15, 20, 20)];
        _advanImgView.image = [UIImage imageNamed:@"tutor_feedback_advantage"];
    }
    return _advanImgView;
}

#pragma mark 优点
-(UILabel *)advanLabel {
    if (!_advanLabel) {
        _advanLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.advanImgView.right+8, self.timeBtn.bottom+15,kScreenWidth-self.advanImgView.right-80,IS_IPAD?32:20)];
        _advanLabel.textColor = [UIColor commonColor_black];
        _advanLabel.font = [UIFont regularFontWithSize:15.0f];
        _advanLabel.numberOfLines = 0;
    }
    return _advanLabel;
}

-(UIImageView *)disadvanImgView {
    if (!_disadvanImgView) {
        _disadvanImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(86, self.advanImgView.bottom+15, 24, 24):CGRectMake(86, self.advanImgView.bottom+15, 20, 20)];
        _disadvanImgView.image = [UIImage imageNamed:@"tutor_feedback_shortcoming"];
    }
    return _disadvanImgView;
}

#pragma mark 欠缺
-(UILabel *)disadvanLabel {
    if (!_disadvanLabel) {
        _disadvanLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.disadvanImgView.right+8, self.advanImgView.bottom+15, kScreenWidth-self.disadvanImgView.right-80,IS_IPAD?32:20)];
        _disadvanLabel.textColor = [UIColor commonColor_black];
        _disadvanLabel.font = [UIFont regularFontWithSize:15.0f];
        _disadvanLabel.numberOfLines = 0;
    }
    return _disadvanLabel;
}

@end
