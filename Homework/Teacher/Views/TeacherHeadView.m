//
//  TeacherHeadView.m
//  Homework
//
//  Created by vision on 2019/9/16.
//  Copyright © 2019 vision. All rights reserved.
//

#import "TeacherHeadView.h"

@interface TeacherHeadView ()

@property (nonatomic,strong) UIButton      *subjectBtn;
@property (nonatomic,strong) UILabel       *titleLab;
@property (strong, nonatomic) UIButton     *timeIconBtn;         //辅导时间icon
@property (strong, nonatomic) UILabel      *timeLabel;           //辅导时间
@property (strong, nonatomic) UILabel      *tempTimeLabel;       //辅导时间2

@end

@implementation TeacherHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.subjectBtn];
        [self addSubview:self.titleLab];
        [self addSubview:self.timeIconBtn];
        [self addSubview:self.timeLabel];
        [self addSubview:self.tempTimeLabel];
    }
    return self;
}

#pragma mark 添加数据
-(void)setTeacher:(TeacherModel *)teacher{
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[teacher.subject integerValue]-1];
    UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getShortBackgroundImageForSubject:subjectStr];
    [_subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [_subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
    
    self.titleLab.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",kUserGradeValue];
    
    GuideTimeModel *timeModel = [[GuideTimeModel alloc] init];
    [timeModel setValues:teacher.guide_time];
    NSMutableArray *workdays = [[HomeworkManager sharedHomeworkManager] parseWeeksDataWithDays:timeModel.workday];
    NSString *workDayStr = [workdays componentsJoinedByString:@" "];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",workDayStr,timeModel.work_time];
    NSString *off_day = [NSString stringWithFormat:@"%@",timeModel.off_day];
    NSMutableArray *offdays = [[HomeworkManager sharedHomeworkManager] parseWeeksDataWithDays:off_day];
    NSString *offDayStr = [offdays componentsJoinedByString:@" "];
    self.tempTimeLabel.text = [NSString stringWithFormat:@"%@ %@",offDayStr,timeModel.off_time];
}

#pragma mark -- Getters
#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(20, 15, 48, 24):CGRectMake(20, 10, 32, 16)];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.subjectBtn.right+5,8,kScreenWidth-60,IS_IPAD?32:20)];
        _titleLab.textColor = [UIColor commonColor_black];
        _titleLab.font = [UIFont mediumFontWithSize:18.0f];
    }
    return _titleLab;
}

#pragma mark 辅导时间标题
-(UIButton *)timeIconBtn{
    if (!_timeIconBtn) {
        _timeIconBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, self.titleLab.bottom+15,IS_IPAD?120:80, IS_IPAD?28:16)];
        [_timeIconBtn setImage:[UIImage imageNamed:@"tutor_teacher_time"] forState:UIControlStateNormal];
        [_timeIconBtn setTitleColor:[UIColor colorWithHexString:@"#FF8B00"] forState:UIControlStateNormal];
        [_timeIconBtn setTitle:@"辅导时间：" forState:UIControlStateNormal];
        _timeIconBtn.titleLabel.font = [UIFont regularFontWithSize:13.0f];
        _timeIconBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    }
    return _timeIconBtn;
}

#pragma mark 辅导时间
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeIconBtn.right, self.titleLab.bottom+15, kScreenWidth-self.timeIconBtn.right-20,IS_IPAD?28:16)];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#000000"];
        _timeLabel.font = [UIFont regularFontWithSize:IS_IPHONE_5?10.0f:12.0f];
    }
    return _timeLabel;
}

#pragma mark 辅导时间
-(UILabel *)tempTimeLabel{
    if (!_tempTimeLabel) {
        _tempTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeIconBtn.right, self.timeLabel.bottom+5, kScreenWidth-136, IS_IPAD?28:16)];
        _tempTimeLabel.textColor = [UIColor colorWithHexString:@"#000000"];
        _tempTimeLabel.font = [UIFont regularFontWithSize:13.0f];
    }
    return _tempTimeLabel;
}



@end
