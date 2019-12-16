//
//  ExpenseTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ExpenseTableViewCell.h"

@interface ExpenseTableViewCell ()

@property (nonatomic,strong) UILabel     *timeLabel;
@property (nonatomic,strong) UIImageView *headImgView;
@property (nonatomic,strong) UIButton    *subjectBtn;
@property (nonatomic,strong) UILabel     *titleLabel;
@property (nonatomic,strong) UILabel     *nameLabel;
@property (nonatomic,strong) UILabel     *expireLabel;
@property (nonatomic,strong) UILabel     *priceLabel;
@property (nonatomic,strong) UILabel     *typeLabel;

@end

@implementation ExpenseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.headImgView];
        [self.contentView addSubview:self.subjectBtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.expireLabel];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.typeLabel];
    }
    return self;
}

-(void)setExpenseModel:(ExpenseRecordModel *)expenseModel{
    _expenseModel = expenseModel;
    
    NSString *payTimeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:expenseModel.pay_time format:@"yyyy-MM-dd HH:mm"];
    self.timeLabel.text = payTimeStr;
    if (kIsEmptyString(expenseModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:expenseModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[expenseModel.subject integerValue]-1];
    UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getShortBackgroundImageForSubject:subjectStr];
    [self.subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
    
    NSArray *grades = [HomeworkManager sharedHomeworkManager].grades;
    NSString *gradeStr = [grades objectAtIndex:[expenseModel.grade integerValue]-1];
    self.titleLabel.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",gradeStr];
    
    self.nameLabel.text = expenseModel.teacher_name;
    CGFloat nameW = [expenseModel.teacher_name boundingRectWithSize:CGSizeMake(kScreenWidth,IS_IPAD?32:20) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right + 10,self.subjectBtn.bottom+5, nameW, IS_IPAD?32:20);
    
    NSString *timeStr = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:expenseModel.end_time format:@"yyyy年MM月dd日"];
    self.expireLabel.text = [NSString stringWithFormat:@"有效期：%@",timeStr];
    self.expireLabel.frame = CGRectMake(self.nameLabel.right+5, self.subjectBtn.bottom+5, 280, IS_IPAD?32:20);
    
    self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[expenseModel.money doubleValue]];
    self.typeLabel.text = expenseModel.name;
}

#pragma mark -- Getters
#pragma mark 购买时间
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,15, 240,IS_IPAD?32:20)];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#E42A2A"];
        _timeLabel.font = [UIFont regularFontWithSize:11.0f];
    }
    return _timeLabel;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(16,self.timeLabel.bottom+10,IS_IPAD?66:40,IS_IPAD?66:40)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?33:20 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.headImgView.right + 10,self.timeLabel.bottom+10,IS_IPAD?45:30,IS_IPAD?27:18)];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subjectBtn.right+5, self.timeLabel.bottom+10, kScreenWidth-self.subjectBtn.right-100,IS_IPAD?30:18)];
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
-(UILabel *)expireLabel{
    if (!_expireLabel) {
        _expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+5, self.subjectBtn.bottom+5, 280,IS_IPAD?32:20)];
        _expireLabel.font = [UIFont regularFontWithSize:12.0f];
        _expireLabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
    }
    return _expireLabel;
}

#pragma mark 价格
-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120,self.timeLabel.bottom+10, 100,IS_IPAD?32:20)];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#E42A2A"];
        _priceLabel.font = [UIFont mediumFontWithSize:18.0f];
        _priceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _priceLabel;
}

#pragma mark 辅导类型
-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120, self.titleLabel.bottom+5,100,IS_IPAD?32:20)];
        _typeLabel.textAlignment = NSTextAlignmentRight;
        _typeLabel.font = [UIFont regularFontWithSize:11.0f];
        _typeLabel.textColor = [UIColor colorWithHexString:@"#E42A2A"];
    }
    return _typeLabel;
}

@end
