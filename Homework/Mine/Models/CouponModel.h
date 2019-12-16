//
//  CouponModel.h
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CouponModel : NSObject

@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSNumber *cash_id;
@property (nonatomic,strong) NSNumber *start_time;
@property (nonatomic,strong) NSNumber *end_time;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSNumber *is_use;
@property (nonatomic,strong) NSNumber *cost;



@end

