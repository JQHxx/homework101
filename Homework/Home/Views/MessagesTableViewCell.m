//
//  MessagesTableViewCell.m
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MessagesTableViewCell.h"

@interface MessagesTableViewCell ()

@property (nonatomic,strong) UILabel     *timeLab;
@property (nonatomic,strong) UIImageView *iconImgView;
@property (nonatomic,strong) UILabel     *titleLab;
@property (nonatomic,strong) UIView      *bgView;
@property (nonatomic,strong) UILabel     *contentLab;

@end

@implementation MessagesTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        [self.contentView addSubview:self.timeLab];
        [self.contentView addSubview:self.iconImgView];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.contentLab];
    }
    return self;
}

-(void)setMessageModel:(MessageModel *)messageModel{
    self.timeLab.text = [[HomeworkManager sharedHomeworkManager] timeWithTimeIntervalNumber:messageModel.send_time format:@"yyyy-MM-dd HH:mm"];
    
    self.contentLab.text = messageModel.content;
    CGFloat contentHeight = [messageModel.content boundingRectWithSize:CGSizeMake(kScreenWidth-150, CGFLOAT_MAX) withTextFont:self.contentLab.font].height;
    self.contentLab.frame = CGRectMake(80, self.titleLab.bottom+20, kScreenWidth-150, contentHeight);
    self.bgView.frame = CGRectMake(self.iconImgView.right+10, self.titleLab.bottom+7, kScreenWidth-self.iconImgView.right-69, contentHeight+24);
    
}

#pragma mark -- Getters
#pragma mark 时间
-(UILabel *)timeLab{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, kScreenWidth-40,IS_IPAD?24:12)];
        _timeLab.textColor = [UIColor commonColor_black];
        _timeLab.font = [UIFont mediumFontWithSize:10.0f];
        _timeLab.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLab;
}

#pragma mark 图标
-(UIImageView *)iconImgView{
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.timeLab.bottom+15, 40, 40)];
        _iconImgView.image = [UIImage imageNamed:@"system_message"];
    }
    return _iconImgView;
}

#pragma mark 系统消息
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImgView.right+10, self.timeLab.bottom+17, 95,IS_IPAD?24:12)];
        _titleLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _titleLab.font = [UIFont regularFontWithSize:12.0f];
        _titleLab.text = @"系统消息";
    }
    return _titleLab;
}

#pragma mark 背景
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImgView.right+10, self.titleLab.bottom+7, kScreenWidth-self.iconImgView.right-69, 64)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 6.0;
    }
    return _bgView;
}

#pragma mark 内容
-(UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(80, self.titleLab.bottom+20, kScreenWidth-150, 40)];
        _contentLab.textColor = [UIColor commonColor_black];
        _contentLab.font = [UIFont regularFontWithSize:14.0f];
        _contentLab.numberOfLines = 0;
    }
    return _contentLab;
}


@end
