//
//  MyFeedbackTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyFeedbackTableViewCell.h"

@interface MyFeedbackTableViewCell ()

@property (nonatomic,strong) UIImageView  *bgImgView;
@property (nonatomic,strong) UIView       *headBgView;
@property (nonatomic,strong) UIImageView  *headImgView;
@property (nonatomic,strong) UILabel      *nameLabel;
@property (nonatomic,strong) UIImageView  *timeIconImgView;
@property (nonatomic,strong) UILabel      *timeLabel;
@property (nonatomic,strong) UILabel      *titleLabel;
@property (nonatomic,strong) UIImageView  *advanImgView;
@property (nonatomic,strong) UILabel      *advanLabel;
@property (nonatomic,strong) UIImageView  *disadvanImgView;
@property (nonatomic,strong) UILabel      *disadvanLabel;

@end

@implementation MyFeedbackTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.bgImgView];
        [self.contentView addSubview:self.headBgView];
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.timeIconImgView];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.advanImgView];
        [self.contentView addSubview:self.advanLabel];
        [self.contentView addSubview:self.disadvanImgView];
        [self.contentView addSubview:self.disadvanLabel];
    }
    return self;
}


-(void)setFeedbackModel:(CoachFeedbackModel *)feedbackModel{
    _feedbackModel = feedbackModel;
    
    if (kIsEmptyString(feedbackModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:feedbackModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = feedbackModel.teacher_name;
    
     NSString *endTimeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:feedbackModel.end_time format:@"yyyy年MM月dd日"];
    self.timeLabel.text = endTimeStr;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@辅导反馈",feedbackModel.subject];
    
    NSString *advanStr = [NSString stringWithFormat:@"优点：%@",feedbackModel.merit];
    CGFloat advanHeight = [advanStr boundingRectWithSize:CGSizeMake(kScreenWidth-self.advanImgView.right-40, CGFLOAT_MAX) withTextFont:self.advanLabel.font].height;
    self.advanLabel.frame = CGRectMake(self.advanImgView.right+8, self.timeIconImgView.bottom+15, kScreenWidth-self.advanImgView.right-40, advanHeight);
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:advanStr];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:15.0f] range:NSMakeRange(0, 3)];
    self.advanLabel.attributedText = attributedStr;
    
    self.disadvanImgView.frame =IS_IPAD?CGRectMake(34, self.advanImgView.bottom+20, 24, 24):CGRectMake(34, self.advanLabel.bottom+15, 20, 20);
    
    NSString *disadvanStr = [NSString stringWithFormat:@"缺点：%@",feedbackModel.defect];
    CGFloat disadvanHeight = [disadvanStr boundingRectWithSize:CGSizeMake(kScreenWidth-self.disadvanImgView.right-40, CGFLOAT_MAX) withTextFont:self.disadvanLabel.font].height;
    self.disadvanLabel.frame = CGRectMake(self.disadvanImgView.right+8, self.advanLabel.bottom+15, kScreenWidth-self.disadvanImgView.right-40, disadvanHeight);
    NSMutableAttributedString *attributedStr1 = [[NSMutableAttributedString alloc] initWithString:disadvanStr];
    [attributedStr1 addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:15.0f] range:NSMakeRange(0, 3)];
    self.disadvanLabel.attributedText = attributedStr1;

    self.bgImgView.image = [UIImage resizedImage:@"tutor_feedback_background" xPos:0.1 yPos:0.5];
    self.bgImgView.frame = CGRectMake(18, 10, kScreenWidth-36, self.disadvanLabel.bottom+(IS_IPAD?30:20));
    
}

+(CGFloat)getMyFeedbackCellHeightWithModel:(CoachFeedbackModel *)model{
    CGFloat aWidth = kScreenWidth-94;
    CGFloat advanHeight = [model.merit boundingRectWithSize:CGSizeMake(aWidth, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15.0f]].height;
    CGFloat disadvanHeight = [model.defect boundingRectWithSize:CGSizeMake(aWidth, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15.0f]].height;
    
    return advanHeight+disadvanHeight+(IS_IPAD?190:172);
}

#pragma mark -- getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 10, kScreenWidth-36, (kScreenWidth-36)*(233.0/351.0))];
    }
    return _bgImgView;
}

#pragma mark 头像背景
-(UIView *)headBgView{
    if (!_headBgView) {
        _headBgView = [[UIView alloc] initWithFrame:CGRectMake(33, 24,IS_IPAD?66:46,IS_IPAD?66:46)];
        _headBgView.backgroundColor = [UIColor whiteColor];
        [_headBgView setBorderWithCornerRadius:IS_IPAD?33:23 type:UIViewCornerTypeAll];
    }
    return _headBgView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(36, 27,IS_IPAD?60:40,IS_IPAD?60:40)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?30:20.0 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 昵称
-(UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+13, 37, 160,IS_IPAD?32:20)];
        _nameLabel.textColor = [UIColor commonColor_black];
        _nameLabel.font = [UIFont mediumFontWithSize:17.0f];
    }
    return _nameLabel;
}

-(UIImageView *)timeIconImgView{
    if (!_timeIconImgView) {
        _timeIconImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(35, self.headBgView.bottom+17, 24, 24):CGRectMake(35, self.headBgView.bottom+14, 18, 18)];
        _timeIconImgView.image = [UIImage imageNamed:@"tutor_feedback_time"];
    }
    return _timeIconImgView;
}

#pragma mark 时间
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeIconImgView.right+5,self.headBgView.bottom+14,IS_IPAD?175:105,IS_IPAD?30:18)];
        _timeLabel.font = [UIFont regularFontWithSize:14.0];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#FF8B00"];
    }
    return _timeLabel;
}

#pragma mark 标题
-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLabel.right+5, self.headBgView.bottom+14,kScreenWidth-self.timeLabel.right-40,IS_IPAD?30:18)];
        _titleLabel.textColor = [UIColor commonColor_black];
        _titleLabel.font = [UIFont regularFontWithSize:15.0f];
    }
    return _titleLabel;
}

-(UIImageView *)advanImgView{
    if (!_advanImgView) {
        _advanImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(34, self.timeIconImgView.bottom+20, 24, 24):CGRectMake(34, self.timeIconImgView.bottom+15, 20, 20)];
        _advanImgView.image = [UIImage drawImageWithName:@"tutor_feedback_advantage" size:_advanImgView.size];
    }
    return _advanImgView;
}

#pragma mark 优点
-(UILabel *)advanLabel {
    if (!_advanLabel) {
        _advanLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.advanImgView.right+8, self.timeIconImgView.bottom+15,kScreenWidth-self.advanImgView.right-40,IS_IPAD?32:20)];
        _advanLabel.textColor = [UIColor commonColor_black];
        _advanLabel.font = [UIFont regularFontWithSize:15.0f];
        _advanLabel.numberOfLines = 0;
    }
    return _advanLabel;
}

-(UIImageView *)disadvanImgView {
    if (!_disadvanImgView) {
        _disadvanImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake(34, self.advanImgView.bottom+20, 24, 24):CGRectMake(34, self.advanImgView.bottom+15, 20, 20)];
        _disadvanImgView.image = [UIImage drawImageWithName:@"tutor_feedback_shortcoming" size:_disadvanImgView.size];
    }
    return _disadvanImgView;
}

#pragma mark 欠缺
-(UILabel *)disadvanLabel {
    if (!_disadvanLabel) {
        _disadvanLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.disadvanImgView.right+8, self.advanImgView.bottom+15, kScreenWidth-self.disadvanImgView.right-40,IS_IPAD?32:20)];
        _disadvanLabel.textColor = [UIColor commonColor_black];
        _disadvanLabel.font = [UIFont regularFontWithSize:15.0f];
        _disadvanLabel.numberOfLines = 0;
    }
    return _disadvanLabel;
}


@end
