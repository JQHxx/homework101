//
//  PhotosCollectionViewCell.m
//  Homework
//
//  Created by vision on 2019/5/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "PhotosCollectionViewCell.h"

@implementation PhotosCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-3.0)];
        _imgBtn.contentMode = UIViewContentModeScaleAspectFit;
        _imgBtn.clipsToBounds = YES;
        [self.contentView addSubview:_imgBtn];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.width - 23, 5, 18, 18);
        [_deleteBtn setImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.contentView addSubview:_deleteBtn];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _imgBtn.frame = CGRectMake(0, 0, self.width, self.height-3);
    _deleteBtn.frame = CGRectMake(self.width - 23, 5, 18, 18);
}

@end
