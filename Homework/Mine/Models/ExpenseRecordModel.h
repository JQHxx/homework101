//
//  ExpenseRecordModel.h
//  Homework
//
//  Created by vision on 2019/10/16.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExpenseRecordModel : NSObject

@property (nonatomic, copy ) NSString *name;
@property (nonatomic, copy ) NSString *teacher_name;
@property (nonatomic, copy ) NSString  *cover;
@property (nonatomic,strong) NSNumber *guide_type;
@property (nonatomic,strong) NSNumber *pay_time;  //购买时间
@property (nonatomic,strong) NSNumber *money;
@property (nonatomic,strong) NSNumber *subject;
@property (nonatomic,strong) NSNumber *grade;
@property (nonatomic,strong) NSNumber *end_time;  //到期时间

@end


