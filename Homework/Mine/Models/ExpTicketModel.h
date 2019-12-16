//
//  ExpTicketModel.h
//  Homework
//
//  Created by vision on 2019/10/8.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExpTicketModel : NSObject

@property (nonatomic, copy ) NSString *teacher_name;
@property (nonatomic, copy ) NSString *cover;
@property (nonatomic,strong) NSNumber *subject;
@property (nonatomic,strong) NSNumber *grade;
@property (nonatomic,strong) NSNumber *is_use;
@property (nonatomic,strong) NSNumber *end_time;
@property (nonatomic,strong) NSString *third_id;

@end


