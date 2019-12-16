//
//  HomeCoachButton.m
//  Homework
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HomeCoachButton.h"

@interface HomeCoachButton ()

@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UILabel *descLab;

@end

@implementation HomeCoachButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.titleLab];
        [self addSubview:self.descLab];
    }
    return self;
}

-(void)setModel:(TeacherModel *)model{
    BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
    if (paySwitch) {
        if ([model.state integerValue]==1) { //请假
            [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_2" size:self.size] forState:UIControlStateNormal];
            self.titleLab.textColor = [UIColor colorWithHexString:@"#BBBCC3"];
            self.descLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        }else{
            [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_3" size:self.size] forState:UIControlStateNormal];
            self.titleLab.textColor = [UIColor whiteColor];
            self.descLab.textColor = [UIColor whiteColor];
        }
        self.titleLab.text = @"去辅导";
        self.descLab.text = @"无次数限制";
    }else{
        NSInteger status = [model.status integerValue];
        if (status==1) {  //已经购买
            if ([model.state integerValue]==1) { //请假
                [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_2" size:self.size] forState:UIControlStateNormal];
                self.titleLab.textColor = [UIColor colorWithHexString:@"#BBBCC3"];
                self.descLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
            }else{
                [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_3" size:self.size] forState:UIControlStateNormal];
                self.titleLab.textColor = [UIColor whiteColor];
                self.descLab.textColor = [UIColor whiteColor];
            }
            self.titleLab.text = @"去辅导";
            self.descLab.text = [model.day_num integerValue]>7? @"无次数限制":[NSString stringWithFormat:@" %ld天后到期",[model.day_num integerValue]];
        }else if (status==2){
           [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_1" size:self.size] forState:UIControlStateNormal];
           self.titleLab.text = @"去续费";
           self.titleLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
           self.descLab.text = @"无可用次数";
           self.descLab.textColor = [UIColor colorWithHexString:@"#B97070"];
        }else if (status==3){
            [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_1" size:self.size] forState:UIControlStateNormal];
            self.titleLab.text = @"去领取";
            self.titleLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
            self.descLab.text = @"可用1次";
            self.descLab.textColor = [UIColor colorWithHexString:@"#B97070"];
        }else if (status==4||status==5){
            [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_1" size:self.size] forState:UIControlStateNormal];
            self.titleLab.text = @"去购买";
            self.titleLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
            self.descLab.text = @"无可用次数";
            self.descLab.textColor = [UIColor colorWithHexString:@"#B97070"];
        }else if (status==6){
            [self setBackgroundImage:[UIImage drawImageWithName:@"tutor_teacher_state_1" size:self.size] forState:UIControlStateNormal];
            self.titleLab.text = @"去续费";
            self.titleLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
            self.descLab.text = @"可用1次";
            self.descLab.textColor = [UIColor colorWithHexString:@"#B97070"];
        }
    }
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width-20,IS_IPAD?26:14)];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont mediumFontWithSize:14.0f];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

#pragma mark 描述
-(UILabel *)descLab{
    if (!_descLab) {
        _descLab = [[UILabel alloc] initWithFrame:CGRectMake(10,self.titleLab.bottom, self.width-20,IS_IPAD?26:14)];
        _descLab.textColor = [UIColor whiteColor];
        _descLab.font = [UIFont regularFontWithSize:9.0f];
        _descLab.textAlignment = NSTextAlignmentCenter;
    }
    return _descLab;
}

@end
