//
//  CoachTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CoachTableViewCell.h"

@interface CoachTableViewCell ()

@property (nonatomic,strong) UIImageView *headImgView;
@property (nonatomic,strong) UIButton    *subjectBtn;
@property (nonatomic,strong) UILabel     *titleLabel;
@property (nonatomic,strong) UILabel     *nameLabel;
@property (nonatomic,strong) UILabel     *timeLabel;
@property (nonatomic,strong) UILabel     *typeLabel;

@end

@implementation CoachTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.subjectBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.typeLabel];
    }
    return self;
}

-(void)setRecordModel:(CoachRecordModel *)recordModel{
    _recordModel = recordModel;
    
   if (kIsEmptyString(recordModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:recordModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[recordModel.subject integerValue]-1];
    UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getShortBackgroundImageForSubject:subjectStr];
    [self.subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",recordModel.grade];
    
    self.nameLabel.text = recordModel.teacher_name;
    CGFloat nameW = [recordModel.teacher_name boundingRectWithSize:CGSizeMake(kScreenWidth,IS_IPAD?32:20) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right + 10,self.subjectBtn.bottom+5, nameW, IS_IPAD?32:20);
    
    NSString *startTimeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:recordModel.start_time format:@"HH:mm"];
    NSString *endTimeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:recordModel.end_time format:@"HH:mm"];
    self.timeLabel.text = [NSString stringWithFormat:@"(开始时间 %@-结束时间 %@)",startTimeStr,endTimeStr];
    self.timeLabel.frame = CGRectMake(self.nameLabel.right+5, self.subjectBtn.bottom+5,IS_IPAD?360:185,IS_IPAD?32:20);
    
    self.typeLabel.text = recordModel.name;
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 21,IS_IPAD?60:40,IS_IPAD?60:40)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?30:20 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.headImgView.right + 10, 20,IS_IPAD?45:30,IS_IPAD?27:18)];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subjectBtn.right+5, 20, kScreenWidth-self.subjectBtn.right-80,IS_IPAD?30:18)];
        _titleLabel.font = [UIFont mediumFontWithSize:13.0f];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    }
    return _titleLabel;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right + 10,self.subjectBtn.bottom+5, 50,IS_IPAD?32:20)];
        _nameLabel.font = [UIFont regularFontWithSize:12.0f];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    }
    return _nameLabel;
}

#pragma mark 时间
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+5, self.subjectBtn.bottom+5,IS_IPAD?360:185,IS_IPAD?32:20)];
        _timeLabel.font = [UIFont regularFontWithSize:12.0f];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
    }
    return _timeLabel;
}

#pragma mark 辅导类型
-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame: CGRectMake(kScreenWidth-125, 20,100,IS_IPAD?30:18)];
        _typeLabel.textAlignment = NSTextAlignmentRight;
        _typeLabel.font = [UIFont regularFontWithSize:11.0f];
        _typeLabel.textColor = [UIColor colorWithHexString:@"#E42A2A"];
    }
    return _typeLabel;
}

@end
