//
//  SelCouponTableViewCell.h
//  Homework
//
//  Created by vision on 2019/10/15.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachCouponModel.h"

@interface SelCouponTableViewCell : UITableViewCell


-(void)displayCellWithModel:(CoachCouponModel *)couponModel oid:(NSNumber *)oid;

@end


