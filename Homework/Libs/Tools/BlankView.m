//
//  BlankView.m
//  HWForTeacher
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BlankView.h"

@implementation BlankView

-(instancetype)initWithFrame:(CGRect)frame img:(NSString *)imgName msg:(NSString *)msg{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-208)/2,40, 208, 134)];
        imgView.image=[UIImage imageNamed:imgName];
        [self addSubview:imgView];
        
        UILabel *lab=[[UILabel alloc] initWithFrame:CGRectMake(20, imgView.bottom, kScreenWidth-40, 20)];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text=msg;
        lab.font=[UIFont regularFontWithSize:14.0f];
        lab.textColor=[UIColor colorWithHexString:@"#9495A0"];
        [self addSubview:lab];
    }
    return self;
}

@end
