//
//  FilterView.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FilterView.h"

@interface FilterView ()

@property (nonatomic,strong) UILabel            *dateLabel;
@property (nonatomic,strong) UIButton           *dateSelButton;
@property (nonatomic,strong) UILabel            *subjectLabel;
@property (nonatomic,strong) UIButton           *subjectSelBtn;

@end

@implementation FilterView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.dateSelButton];
        [self addSubview:self.subjectLabel];
        [self addSubview:self.subjectSelBtn];
    }
    return self;
}



#pragma mark -- event response
-(void)filterAction:(UIButton *)sender{
    if ([self.viewDelegate respondsToSelector:@selector(filerViewDidClickWithIndex:)]) {
        [self.viewDelegate filerViewDidClickWithIndex:sender.tag];
    }
}

#pragma mark -- Setters
#pragma mark 日期
-(void)setDateStr:(NSString *)dateStr{
    _dateStr = dateStr;
    [self.dateSelButton setTitle:dateStr forState:UIControlStateNormal];
}

#pragma mark 科目
-(void)setSubjectStr:(NSString *)subjectStr{
    _subjectStr = subjectStr;
    [self.subjectSelBtn setTitle:subjectStr forState:UIControlStateNormal];
}

#pragma mark -- getters
#pragma mark 日期
-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, IS_IPAD?50:30, IS_IPAD?32:20)];
        _dateLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _dateLabel.font = [UIFont regularFontWithSize:13.0f];
        _dateLabel.text = @"日期";
    }
    return _dateLabel;
}

#pragma mark 选择日期
-(UIButton *)dateSelButton{
    if (!_dateSelButton) {
        _dateSelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.dateLabel.right, 5,IS_IPAD?186:138,IS_IPAD?40:30)];
        _dateSelButton.backgroundColor = [UIColor colorWithHexString:@"#F7F8F9"];
        [_dateSelButton setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        [_dateSelButton setImage:[UIImage imageNamed:@"record_arrow_choose"] forState:UIControlStateNormal];
        _dateSelButton.titleLabel.font = [UIFont regularFontWithSize:13.0f];
        _dateSelButton.layer.cornerRadius = 4.0;
        _dateSelButton.titleEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
        _dateSelButton.imageEdgeInsets = UIEdgeInsetsMake(0, _dateSelButton.width-20, 0, 0);
        _dateSelButton.tag = 0;
        [_dateSelButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dateSelButton;
}

#pragma mark 科目
-(UILabel *)subjectLabel{
    if (!_subjectLabel) {
        _subjectLabel = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-180, 10, 50, 32):CGRectMake(kScreenWidth-120, 10, 30,IS_IPAD?32:20)];
        _subjectLabel.textColor = [UIColor commonColor_black];
        _subjectLabel.font = [UIFont regularFontWithSize:14.0f];
        _subjectLabel.text = @"科目";
    }
    return _subjectLabel;
}

#pragma mark 选择科目
-(UIButton *)subjectSelBtn{
    if (!_subjectSelBtn) {
        _subjectSelBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(self.subjectLabel.right, 5, 100, 42):CGRectMake(self.subjectLabel.right, 5, 70, 30)];
        _subjectSelBtn.backgroundColor = [UIColor colorWithHexString:@"#F7F8F9"];
        [_subjectSelBtn setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        [_subjectSelBtn setImage:[UIImage imageNamed:@"record_arrow_choose"] forState:UIControlStateNormal];
        _subjectSelBtn.titleLabel.font = [UIFont regularFontWithSize:13.0f];
        _subjectSelBtn.layer.cornerRadius = 4.0;
        _subjectSelBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
        _subjectSelBtn.imageEdgeInsets = UIEdgeInsetsMake(0,IS_IPAD?80:50, 0, 0);
        _subjectSelBtn.tag = 1;
        [_subjectSelBtn addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subjectSelBtn;
}


@end
