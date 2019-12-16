//
//  MyTeacherTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/7.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyTeacherTableViewCell.h"


@interface MyTeacherTableViewCell ()

@property (strong, nonatomic) UIView          *bgView;
@property (strong, nonatomic) UIImageView     *subjectBgView;      //科目背景
@property (strong, nonatomic) UIButton        *subjectBtn;         //科目
@property (strong, nonatomic) UILabel         *titleLabel;         //标题

@property (strong, nonatomic) UILabel         *nameLabel;          //姓名
@property (strong, nonatomic) UILabel         *tagsLabel;          //请假或代课
@property (strong, nonatomic) UILabel         *descLabel;          //描述


@end

@implementation MyTeacherTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(18, 10, kScreenWidth-36,IS_IPAD?148:108)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5.0;
        _bgView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _bgView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
        _bgView.layer.shadowRadius = 5.0;
        _bgView.layer.shadowOpacity = 0.15;
        [self.contentView addSubview:_bgView];
        
        //科目
        _subjectBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(32, 25, 60, 30):CGRectMake(32, 25, 30, 18)];
       [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
        [self.contentView addSubview:_subjectBtn];
        
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subjectBtn.right+8.0, 25, kScreenWidth-self.subjectBtn.right-50,IS_IPAD?30:18)];
        _titleLabel.textColor = [UIColor commonColor_black];
        _titleLabel.font = [UIFont mediumFontWithSize:17.0f];
        [self.contentView addSubview:_titleLabel];
        
        //头像
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(32,self.subjectBtn.bottom+16,IS_IPAD?50:38,IS_IPAD?50:38)];
        [_headImageView setBorderWithCornerRadius:IS_IPAD?25:19 type:UIViewCornerTypeAll];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_headImageView];
        
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+8, self.subjectBtn.bottom+16, 160,IS_IPAD?30:18)];
        _nameLabel.textColor = [UIColor commonColor_black];
        _nameLabel.font = [UIFont regularFontWithSize:15.0f];
        [self.contentView addSubview:_nameLabel];
        
        //请假或代课
        _tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+8, self.subjectBtn.bottom+16, 38,IS_IPAD?28:16)];
        _tagsLabel.backgroundColor = [UIColor colorWithHexString:@"#EBF1FF"];
        [_tagsLabel setBorderWithCornerRadius:2.0 type:UIViewCornerTypeAll];
        _tagsLabel.textAlignment = NSTextAlignmentCenter;
        _tagsLabel.textColor = [UIColor colorWithHexString:@"#809AD3"];
        _tagsLabel.font = [UIFont regularFontWithSize:11.0f];
        [self.contentView addSubview:_tagsLabel];
        
        //描述
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+8.0, self.nameLabel.bottom,kScreenWidth-self.headImageView.right-110.0,IS_IPAD?32:20.0)];
        _descLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _descLabel.font = [UIFont regularFontWithSize:12];
        [self.contentView addSubview:_descLabel];
        
        _coachBtn = [[HomeCoachButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-150, 56,128, 63):CGRectMake(kScreenWidth-101, 56, 87, 42)];
        [self.contentView addSubview:_coachBtn];
        
    }
    return self;
}

-(void)setMyTeacher:(TeacherModel *)myTeacher{
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[myTeacher.subject integerValue]-1];
    UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getShortBackgroundImageForSubject:subjectStr];
    [self.subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",kUserGradeValue];
    
    if (kIsEmptyString(myTeacher.cover)) {
        [self.headImageView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:myTeacher.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = myTeacher.name;
    if ([myTeacher.state integerValue]==1) {
        self.tagsLabel.text = @"请假";
        self.tagsLabel.hidden = NO;
    }else if ([myTeacher.state integerValue]==2){
        self.tagsLabel.text = @"代课";
        self.tagsLabel.hidden = NO;
    }else{
        self.tagsLabel.hidden = YES;
    }
    
    if (kIsArray(myTeacher.label)) {
        self.descLabel.text = [myTeacher.label componentsJoinedByString:@"、"];
    }
    
    self.coachBtn.model = myTeacher;
    if ([myTeacher.state integerValue]==1) {
        self.coachBtn.userInteractionEnabled = NO;
    }else{
        self.coachBtn.userInteractionEnabled = YES;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
