//
//  CoachTypeModel.h
//  Homework
//
//  Created by vision on 2019/9/17.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CoachTypeModel : NSObject

@property (nonatomic,strong) NSNumber *o_id;
@property (nonatomic, copy ) NSString *name;
@property (nonatomic,strong) NSNumber *original_price;
@property (nonatomic,strong) NSNumber *price;
@property (nonatomic,strong) NSNumber *validity_month;

@end


