//
//  MineHeaderView.m
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MineHeaderView.h"

@interface MineHeaderView ()

@property (nonatomic,strong) UIImageView *headImgView;
@property (nonatomic,strong) UILabel     *nameLabel;
@property (nonatomic,strong) UILabel     *gradeLabel;
@property (nonatomic,strong) UILabel     *balanceLabel;

@end

@implementation MineHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        [self addSubview:self.setupBtn];
        [self addSubview:self.headImgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.gradeLabel];
        [self addSubview:self.editButton];
        [self addSubview:self.balanceLabel];
        self.balanceLabel.hidden = YES;
    }
    return self;
}

-(void)setUserModel:(UserModel *)userModel{
    _userModel = userModel;
    
    if (kIsEmptyString(userModel.cover)) {
        [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:userModel.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
    }
    
    self.nameLabel.text = userModel.name;
    CGFloat nameW = [userModel.name boundingRectWithSize:CGSizeMake(kScreenWidth-self.headImgView.right-30,IS_IPAD?32:20) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+10, KStatusHeight+32, nameW,IS_IPAD?32:20);
    
    self.gradeLabel.text = userModel.grade;
    CGFloat gradeW = [userModel.grade boundingRectWithSize:CGSizeMake(240, IS_IPAD?30:18) withTextFont:self.gradeLabel.font].width;
    self.gradeLabel.frame = CGRectMake(self.nameLabel.right+5, KStatusHeight+33, gradeW+10,IS_IPAD?30:18);
    
    BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
    if (!paySwitch&&[userModel.money doubleValue]>0.01) {
        self.balanceLabel.hidden = NO;
        self.balanceLabel.text = [NSString stringWithFormat:@"我的余额：¥%.2f",[userModel.money doubleValue]];
    }else{
        self.balanceLabel.hidden = YES;
    }
}

#pragma mark -- Getters
#pragma mark 设置
-(UIButton *)setupBtn{
    if (!_setupBtn) {
        _setupBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
        [_setupBtn setImage:[UIImage drawImageWithName:@"my_install" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
    }
    return _setupBtn;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(22,KStatusHeight+27,IS_IPAD?70:58, IS_IPAD?70:58)];
        [_headImgView setBorderWithCornerRadius:IS_IPAD?35:29 type:UIViewCornerTypeAll];
    }
    return _headImgView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+12,KStatusHeight+32, 100,IS_IPAD?32:20)];
        _nameLabel.textColor = [UIColor commonColor_black];
        _nameLabel.font = [UIFont mediumFontWithSize:14.0f];
    }
    return _nameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+5,KStatusHeight+33,IS_IPAD?140:100,IS_IPAD?30:18)];
        _gradeLabel.textColor = [UIColor whiteColor];
        _gradeLabel.backgroundColor = [UIColor colorWithHexString:@"#FF3737"];
        _gradeLabel.font = [UIFont regularFontWithSize:12.0f];
        _gradeLabel.textAlignment = NSTextAlignmentCenter;
        _gradeLabel.layer.cornerRadius = 4.0;
        _gradeLabel.clipsToBounds = YES;
    }
    return _gradeLabel;
}

#pragma mark 编辑
-(UIButton *)editButton{
    if (!_editButton) {
        _editButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_editButton setTitle:@"编辑个人资料" forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor colorWithHexString:@"#9495A0"] forState:UIControlStateNormal];
        _editButton.titleLabel.font = [UIFont regularFontWithSize:12.0f];
        
        NSString *btnStr = @"编辑个人资料";
        CGFloat btnW = [btnStr boundingRectWithSize:CGSizeMake(IS_IPAD?150:100, 25) withTextFont:[UIFont regularFontWithSize:12.0f]].width;
        [_editButton setFrame:CGRectMake(self.headImgView.right+12, self.nameLabel.bottom, btnW,IS_IPAD?36:25)];
        
    }
    return _editButton;
}

#pragma mark 余额
-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180, self.nameLabel.bottom, 165,IS_IPAD?32:20)];
        _balanceLabel.textColor = [UIColor commonColor_black];
        _balanceLabel.font = [UIFont regularFontWithSize:14.0f];
        _balanceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _balanceLabel;
}

@end
