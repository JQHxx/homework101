//
//  CoachCouponModel.h
//  Homework
//
//  Created by vision on 2019/10/8.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CoachCouponModel : NSObject

@property (nonatomic,strong) NSNumber *id;
@property (nonatomic, copy ) NSString *name;
@property (nonatomic,strong) NSNumber *cost;
@property (nonatomic,strong) NSNumber *validity;
@property (nonatomic,strong) NSNumber *cash_id; // 1月辅导 2季辅导 3年辅导
@property (nonatomic,strong) NSNumber *isSelected;

@end


