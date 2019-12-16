//
//  DragImageView.m
//  Homework
//
//  Created by vision on 2019/10/31.
//  Copyright © 2019 vision. All rights reserved.
//

#import "DragImageView.h"

@interface DragImageView (){
    CGPoint startLocation;
    void(^_actionBlock)(void);
}



@end

@implementation DragImageView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMeAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark 点击事件
-(void)tapMeAction:(UITapGestureRecognizer *)sender{
    if (_actionBlock) {
        _actionBlock();
    }
}

#pragma mark -- Bublic Methods
-(void)setActionBlock:(void (^)(void))block{
    _actionBlock = block;
}

#pragma mark 拖拽事件
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    MyLog(@"touchesBegan");
    CGPoint pt = [[touches anyObject] locationInView:self];
    startLocation = pt;
    [[self superview] bringSubviewToFront:self];
}
 
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    MyLog(@"touchesMoved");
    CGPoint pt = [[touches anyObject] locationInView:self];
    float dx = pt.x - startLocation.x;
    float dy = pt.y - startLocation.y;
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    //
    float halfx = CGRectGetMidX(self.bounds);
    newcenter.x = MAX(halfx, newcenter.x);
    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
    //
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MAX(halfy, newcenter.y);
    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
    //
    self.center = newcenter;
}
 
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    MyLog(@"touchesEnded");
    CGPoint point = self.center;
    if (point.x>[self superview].width/2.0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.x = [self superview].width-self.width;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.x = 0;
        }];
    }
}
 
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}





@end
