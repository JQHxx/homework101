//
//  SelCouponsView.h
//  Homework
//
//  Created by vision on 2019/10/15.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachCouponModel.h"

@protocol SelCouponsViewDelegate <NSObject>

//确定
-(void)selCouponsViewDidSelectCoupon:(CoachCouponModel *)selCoupon;
//关闭
-(void)selCouponsViewCloseAction;

@end

@interface SelCouponsView : UIView

@property (nonatomic,strong) NSNumber   *o_id;
@property (nonatomic,strong) NSMutableArray  *couponsArray;
@property (nonatomic,strong) CoachCouponModel *selCouponModel;

@property (nonatomic, weak ) id<SelCouponsViewDelegate>viewDelegate;

@end

