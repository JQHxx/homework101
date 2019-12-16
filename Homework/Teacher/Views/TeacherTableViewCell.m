//
//  TeacherTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/11.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherTableViewCell.h"

@interface TeacherTableViewCell ()

@property (strong, nonatomic) UIView       *bgView;             //背景
@property (strong, nonatomic) UIButton     *subjectBtn;          //科目
@property (strong, nonatomic) UILabel      *titleLabel;          //标题
@property (strong, nonatomic) UIButton     *timeIconBtn;         //辅导时间icon
@property (strong, nonatomic) UILabel      *timeLabel;           //辅导时间
@property (strong, nonatomic) UILabel      *tempTimeLabel;       //辅导时间2
@property (strong, nonatomic) UIImageView  *headImageView;       //头像
@property (strong, nonatomic) UILabel      *nameLabel;           //姓名
@property (strong, nonatomic) UILabel      *durationLabel;        //辅导时长
@property (strong, nonatomic) UILabel      *scoreLabel;           //评分
@property (strong, nonatomic) UIImageView  *recommandImgView;     //推荐



@end

@implementation TeacherTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.subjectBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.timeIconBtn];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.tempTimeLabel];
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.durationLabel];
        [self.contentView addSubview:self.scoreLabel];
        [self.contentView addSubview:self.connectButton];
        [self.contentView addSubview:self.recommandImgView];
        self.recommandImgView.hidden = YES;
    }
    return self;
}


#pragma mark 数据展示
-(void)applyDataForCellWithTeacher:(TeacherModel *)model{
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[model.subject integerValue]-1];
    UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getLongBackgroundImageForSubject:subjectStr];
    [self.subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",kUserGradeValue];
    
    //辅导时间
    GuideTimeModel *timeModel = [[GuideTimeModel alloc] init];
    [timeModel setValues:model.guide_time];
    if (!kIsEmptyString(timeModel.workday)) {
        NSMutableArray *workdays = [[HomeworkManager sharedHomeworkManager] parseWeeksDataWithDays:timeModel.workday];
        NSString *workDayStr = [workdays componentsJoinedByString:@" "];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",workDayStr,timeModel.work_time];
        NSString *off_day = [NSString stringWithFormat:@"%@",timeModel.off_day];
        NSMutableArray *offdays = [[HomeworkManager sharedHomeworkManager] parseWeeksDataWithDays:off_day];
        NSString *offDayStr = [offdays componentsJoinedByString:@" "];
        self.tempTimeLabel.text = [NSString stringWithFormat:@"%@ %@",offDayStr,timeModel.off_time];
    }
    
    if (kIsEmptyString(model.cover)) {
        _headImageView.image = [UIImage imageNamed:@"my_default_head"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    NSString *str1 = [NSString stringWithFormat:@"老师：%@",model.name];
    NSMutableAttributedString *attributedStr1 = [[NSMutableAttributedString alloc] initWithString:str1];
    [attributedStr1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#9495A0"] range:NSMakeRange(3, str1.length-3)];
    self.nameLabel.attributedText = attributedStr1;
    
    NSString *str2 = [NSString stringWithFormat:@"辅导时长：%ld天",[model.tutoring_time integerValue]];
    NSMutableAttributedString *attributedStr2 = [[NSMutableAttributedString alloc] initWithString:str2];
    [attributedStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#9495A0"] range:NSMakeRange(5, str2.length-5)];
    self.durationLabel.attributedText = attributedStr2;
    
    NSString *str4 = [NSString stringWithFormat:@"评分：%ld分",[model.score integerValue]];
    NSMutableAttributedString *attributedStr4 = [[NSMutableAttributedString alloc] initWithString:str4];
    [attributedStr4 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#9495A0"] range:NSMakeRange(3, str4.length-3)];
    self.scoreLabel.attributedText = attributedStr4;
    
    self.recommandImgView.hidden = ![model.recommend boolValue];
}

#pragma mark  -- Getters
#pragma mark 背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(18, 10, kScreenWidth-36,IS_IPAD?240:160)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        _bgView.layer.shadowRadius = 5.0;
        _bgView.layer.shadowOpacity = 0.15;
    }
    return _bgView;
}

#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(18, 10, 66, 24):CGRectMake(18, 10, 44, 16)];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,self.subjectBtn.bottom+10,kScreenWidth-60,IS_IPAD?30:18)];
        _titleLabel.textColor = [UIColor commonColor_black];
        _titleLabel.font = [UIFont mediumFontWithSize:18.0f];
    }
    return _titleLabel;
}

#pragma mark 辅导时间标题
-(UIButton *)timeIconBtn{
    if (!_timeIconBtn) {
        _timeIconBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, self.titleLabel.bottom+10,IS_IPAD?120:(IS_IPHONE_5?70.0f:75),IS_IPAD?28:16)];
        [_timeIconBtn setImage:[UIImage imageNamed:@"tutor_teacher_time"] forState:UIControlStateNormal];
        [_timeIconBtn setTitleColor:[UIColor colorWithHexString:@"#FF8B00"] forState:UIControlStateNormal];
        [_timeIconBtn setTitle:@"辅导时间：" forState:UIControlStateNormal];
        _timeIconBtn.titleLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
        _timeIconBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    }
    return _timeIconBtn;
}

#pragma mark 辅导时间
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeIconBtn.right, self.titleLabel.bottom+10, kScreenWidth-self.timeIconBtn.right-20, IS_IPAD?30:16)];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _timeLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
    }
    return _timeLabel;
}

#pragma mark 辅导时间
-(UILabel *)tempTimeLabel{
    if (!_tempTimeLabel) {
        _tempTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeIconBtn.right, self.timeLabel.bottom+5, kScreenWidth-136, IS_IPAD?30:16)];
        _tempTimeLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _tempTimeLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
    }
    return _tempTimeLabel;
}

#pragma mark 头像
-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, self.tempTimeLabel.bottom+10,IS_IPAD?50:38,IS_IPAD?50:38)];
        [_headImageView setBorderWithCornerRadius:IS_IPAD?25:19 type:UIViewCornerTypeAll];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

#pragma mark 辅导员
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+8, self.headImageView.top+5,IS_IPAD?160:95,IS_IPAD?24:12)];
        _nameLabel.textColor = [UIColor commonColor_black];
        _nameLabel.font = [UIFont regularFontWithSize:12.0f];
    }
    return _nameLabel;
}

#pragma mark 辅导时长
-(UILabel *)durationLabel{
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+10, self.headImageView.top+5,IS_IPAD?160:95,IS_IPAD?24:12)];
        _durationLabel.textColor = [UIColor commonColor_black];
        _durationLabel.font = [UIFont regularFontWithSize:12.0f];
    }
    return _durationLabel;
}

#pragma mark 评分
-(UILabel *)scoreLabel{
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+8, self.nameLabel.bottom+8,IS_IPAD?160:95, IS_IPAD?24:12)];
        _scoreLabel.textColor = [UIColor commonColor_black];
        _scoreLabel.font = [UIFont regularFontWithSize:12.0f];
    }
    return _scoreLabel;
}

-(UIButton *)connectButton{
    if (!_connectButton) {
        _connectButton = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-144, self.headImageView.top+20, 114, 40):CGRectMake(kScreenWidth-104, self.headImageView.top+25, 74, 28)];
        _connectButton.backgroundColor = [UIColor colorWithHexString:@"#FFEEF0"];
        [_connectButton setTitle:@"联系老师" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor colorWithHexString:@"#FF6262"] forState:UIControlStateNormal];
        _connectButton.titleLabel.font = [UIFont mediumFontWithSize:12.0f];
        _connectButton.layer.cornerRadius = 4.0;
    }
    return _connectButton;
}

#pragma mark 头像
-(UIImageView *)recommandImgView{
    if (!_recommandImgView) {
        _recommandImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-70, 9, 33, 30)];
        _recommandImgView.image = [UIImage imageNamed:@"tutor_teacher_recommend"];
    }
    return _recommandImgView;
}

@end

