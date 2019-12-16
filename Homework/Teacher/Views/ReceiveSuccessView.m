//
//  ReceiveSuccessView.m
//  Homework
//
//  Created by vision on 2019/10/8.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ReceiveSuccessView.h"

@interface ReceiveSuccessView ()

@property (nonatomic,strong) UILabel        *tipsLabel;
@property (nonatomic,strong) UIButton       *subjectBtn;
@property (nonatomic,strong) UILabel        *titleLabel;
@property (nonatomic,strong) UIImageView    *headImgView;
@property (nonatomic,strong) UILabel        *nameLabel;
@property (nonatomic,strong) UILabel        *couponLabel;

@end

@implementation ReceiveSuccessView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.tipsLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.subjectBtn];
        [self addSubview:self.titleLabel];
        [self addSubview:self.headImgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.couponLabel];
        [self addSubview:self.seeBtn];
        [self addSubview:self.useBtn];
    }
    return self;
}

#pragma mark 老师
-(void)setTeacher:(TeacherModel *)teacher{
    NSArray *subjects = [HomeworkManager sharedHomeworkManager].subjects;
    NSString *subjectStr = [subjects objectAtIndex:[teacher.subject integerValue]-1];
    UIImage *bgImage = [[HomeworkManager sharedHomeworkManager] getShortBackgroundImageForSubject:subjectStr];
    [self.subjectBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.subjectBtn setTitle:subjectStr forState:UIControlStateNormal];
    
    if (kIsEmptyString(teacher.cover)) {
        self.headImgView.image = [UIImage imageNamed:@"my_default_head"];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:teacher.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    self.nameLabel.text = teacher.name;
}



#pragma -- getters
#pragma mark 领取
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,30, self.width-20,IS_IPAD?32:20)];
        _tipsLabel.font = [UIFont mediumFontWithSize:18.0f];
        _tipsLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _tipsLabel.text = @"您已经成功领取";
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

#pragma mark 科目
-(UIButton *)subjectBtn{
    if (!_subjectBtn) {
        _subjectBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(30, self.tipsLabel.bottom+16, 45, 27):CGRectMake(30,self.tipsLabel.bottom+16, 30, 18)];
        [_subjectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subjectBtn.titleLabel.font = [UIFont mediumFontWithSize:11.0f];
    }
    return _subjectBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.subjectBtn.right+5,self.tipsLabel.bottom+16, kScreenWidth-self.subjectBtn.right-20,IS_IPAD?30:18)];
        _titleLabel.font = [UIFont regularFontWithSize:14.0f];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _titleLabel.text = [NSString stringWithFormat:@"%@在线1对1家教辅导",kUserGradeValue];
    }
    return _titleLabel;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:IS_IPAD?CGRectMake((self.width-70)/2.0, self.titleLabel.bottom+20, 70, 70):CGRectMake((self.width-56)/2.0, self.titleLabel.bottom+20, 56, 56)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?35:28 type:UIViewCornerTypeAll];
        _headImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,self.headImgView.bottom,self.width-20,IS_IPAD?42:30)];
        _nameLabel.font = [UIFont regularFontWithSize:14.0f];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

#pragma mark 免费体验券
-(UILabel *)couponLabel{
    if (!_couponLabel) {
        _couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,self.nameLabel.bottom+10,self.width-20,IS_IPAD?42:30)];
        _couponLabel.font = [UIFont mediumFontWithSize:22.0f];
        _couponLabel.textColor = [UIColor colorWithHexString:@"#FF8B00"];
        _couponLabel.text = @"免费体验券 X1";
        _couponLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _couponLabel;
}

#pragma mark 再看看
-(UIButton *)seeBtn{
    if (!_seeBtn) {
        _seeBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(40, self.couponLabel.bottom+27, 140, 44):CGRectMake(35,self.couponLabel.bottom+27, 96, 32)];
        [_seeBtn setTitle:@"再看看" forState:UIControlStateNormal];
        [_seeBtn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        _seeBtn.titleLabel.font = [UIFont mediumFontWithSize:15.0f];
        _seeBtn.layer.cornerRadius = IS_IPAD?22: 16;
        _seeBtn.layer.borderColor = [UIColor colorWithHexString:@"#FF6161"].CGColor;
        _seeBtn.layer.borderWidth =1.0;
    }
    return _seeBtn;
}

#pragma mark 立即使用
-(UIButton *)useBtn{
    if (!_useBtn) {
        _useBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(self.seeBtn.right+54, self.couponLabel.bottom+27, 140, 44):CGRectMake(self.seeBtn.right+24,self.couponLabel.bottom+27, 96, 32)];
        _useBtn.backgroundColor = [UIColor colorWithHexString:@"#FF6161"];
        [_useBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_useBtn setTitle:@"立即使用" forState:UIControlStateNormal];
        _useBtn.titleLabel.font = [UIFont mediumFontWithSize:15.0f];
        _useBtn.layer.cornerRadius = IS_IPAD?22:16;
    }
    return _useBtn;
}

@end
