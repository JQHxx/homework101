//
//  CouponTableViewCell.h
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponModel.h"

@interface CouponTableViewCell : UITableViewCell

@property (nonatomic,strong) CouponModel *couponModel;

@property (nonatomic,strong) UIButton    *useBtn;

@end


