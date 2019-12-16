//
//  NonServiceTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "NonServiceTableViewCell.h"

@interface NonServiceTableViewCell ()

@property (nonatomic,strong) UIImageView  *tipsImgView;
@property (nonatomic,strong) UIButton     *applyButton; //马上请家教
@property (nonatomic,strong) UIButton     *seeButton;   //先看看

@end

@implementation NonServiceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        [self.contentView addSubview:self.tipsImgView];
        [self.contentView addSubview:self.applyButton];
        [self.contentView addSubview:self.seeButton];
    }
    return self;
}

#pragma mark 点击事件
-(void)nonServiceBtnAction:(UIButton *)sender{
    if ([self.cellDelegate respondsToSelector:@selector(nonServiceCellDidClickBtnAction)]) {
        [self.cellDelegate nonServiceCellDidClickBtnAction];
    }
}

#pragma mark 辅导说明
-(UIImageView *)tipsImgView{
    if (!_tipsImgView) {
        _tipsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 5, kScreenWidth-36, (kScreenWidth-36)*(132.0/678.0))];
        _tipsImgView.image = [UIImage imageNamed:@"my_no_coaching_record"];
    }
    return _tipsImgView;
}

#pragma mark 马上请家教
-(UIButton *)applyButton{
    if (!_applyButton) {
        _applyButton = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-180, 42,150, 40):CGRectMake(kScreenWidth-120, 32, 93, 25)];
        [_applyButton setTitle:@"马上请家教" forState:UIControlStateNormal];
        [_applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _applyButton.backgroundColor = [UIColor bm_colorGradientChangeWithSize:_applyButton.size direction:IHGradientChangeDirectionLevel startColor:[UIColor colorWithHexString:@"#FF6644"] endColor:[UIColor colorWithHexString:@"#EC0023"]];
        _applyButton.titleLabel.font = [UIFont mediumFontWithSize:14.0f];
        _applyButton.layer.cornerRadius = IS_IPAD?20:12.5;
        [_applyButton addTarget:self action:@selector(nonServiceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyButton;
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
