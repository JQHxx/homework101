//
//  CutomMessageCell.m
//  Homework
//
//  Created by vision on 2019/9/30.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CustomMessageCell.h"

@interface CustomMessageCell ()

/*!
 背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 文本内容的Label
 */
@property (strong, nonatomic) UILabel  *textLabel;
/*!
按钮
*/
@property (strong, nonatomic) UIButton *myBtn;



@end

@implementation CustomMessageCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark -- Private Methods
#pragma mark 初始化界面
- (void)initialize {
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    [self.bubbleBackgroundView addSubview:self.textLabel];
    [self.bubbleBackgroundView addSubview:self.myBtn];
    self.myBtn.hidden = YES;
}

#pragma mark 界面刷新
-(void)setAutoLaout{
    CustomMessage *messageModel = (CustomMessage *)self.model.content;
    if (messageModel) {
        self.textLabel.text = messageModel.content;
    }
    
    CGSize textLabelSize = [[self class] getTextLabelSize:messageModel];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    if (!kIsEmptyString(messageModel.extra)) {
        bubbleBackgroundViewSize.height += 40;
    }
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    //拉伸图片
    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.textLabel.frame = CGRectMake(20, 7, textLabelSize.width, textLabelSize.height);

        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame =
            CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
            [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        self.textLabel.frame = CGRectMake(12, 7, textLabelSize.width, textLabelSize.height);

        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
        messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
                                                      [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;

        self.bubbleBackgroundView.frame =
            CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image =
            [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                image.size.height * 0.2, image.size.width * 0.8)];
    }
    
    if (kIsEmptyString(messageModel.extra)||![messageModel.extra isEqualToString:@"msg_invite_buy"]) {
        UIImageView *imgView = (UIImageView *)self.portraitImageView;
        imgView.image = [UIImage imageNamed:@"message_head_adviser"];
        self.nicknameLabel.text = @"学习顾问李老师";
    }
    
    if (kIsEmptyString(messageModel.extra)) {
        self.myBtn.hidden = YES;
    }else{
        self.myBtn.hidden = NO;
        self.myBtn.frame = CGRectMake(14, self.textLabel.bottom+10, messageContentViewRect.size.width-28, 30);
        
        NSString *btnTitle;
        if ([messageModel.extra isEqualToString:@"msg_evaluate"]) {
            btnTitle = @"去评价";
        }else if ([messageModel.extra isEqualToString:@"msg_buy"]){
            btnTitle = @"去购买";
        }
        [self.myBtn setTitle:btnTitle forState:UIControlStateNormal];
    }
    
    
}

#pragma mark -- Event response
#pragma mark 按钮点击
-(void)cellBtnClickAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}


#pragma mark -- Public Methods
#pragma mark 设置当前消息Cell的数据模型
-(void)setDataModel:(RCMessageModel *)model{
    [super setDataModel:model];
    
    [self setAutoLaout];
}

#pragma mark 获取消息cell大小
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    CustomMessage *message = (CustomMessage *)model.content;
    CGSize size = [CustomMessageCell getBubbleBackgroundViewSize:message];

    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}


+ (CGSize)getTextLabelSize:(CustomMessage *)message {
    if ([message.content length] > 0) {
        float maxWidth = [UIScreen mainScreen].bounds.size.width -
                         (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 - 35;
        CGRect textRect = [message.content
            boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                         options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                  NSStringDrawingUsesFontLeading)
                      attributes:@{NSFontAttributeName : [UIFont regularFontWithSize:16]}
                         context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)getBubbleSize:(CGSize)textLabelSize {
    CGSize bubbleSize = CGSizeMake(textLabelSize.width, textLabelSize.height);

    if (bubbleSize.width + 12 + 20 > 50) {
        bubbleSize.width = bubbleSize.width + 12 + 20;
    } else {
        bubbleSize.width = 50;
    }
    if (bubbleSize.height + 7 + 7 > 40) {
        bubbleSize.height = bubbleSize.height + 7 + 7;
    } else {
        bubbleSize.height = 40;
    }

    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CustomMessage *)message {
    CGSize textLabelSize = [[self class] getTextLabelSize:message];
    if ([message.extra isEqualToString:@"msg_evaluate"]||[message.extra isEqualToString:@"msg_buy"]) {
        textLabelSize.height += 40;
    }
    return [[self class] getBubbleSize:textLabelSize];
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bubbleBackgroundView{
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bubbleBackgroundView.userInteractionEnabled = YES;
    }
    return _bubbleBackgroundView;
}

#pragma mark 文字
-(UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont regularFontWithSize:16.0f];
        [_textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_textLabel setTextColor:[UIColor commonColor_black]];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

#pragma mark
-(UIButton *)myBtn{
    if (!_myBtn) {
        _myBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        _myBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kScreenWidth-140, 30) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FFFCF9"] endColor:[UIColor colorWithHexString:@"#FBF2E9"]];
        _myBtn.layer.cornerRadius = 4.0;
        _myBtn.titleLabel.font = [UIFont mediumFontWithSize:14.0f];
        [_myBtn setTitleColor:[UIColor colorWithHexString:@"#FF8800"] forState:UIControlStateNormal];
        [_myBtn addTarget:self action:@selector(cellBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myBtn;
}

@end
