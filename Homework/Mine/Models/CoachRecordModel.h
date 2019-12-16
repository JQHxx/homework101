//
//  CoachRecordModel.h
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CoachRecordModel : NSObject

@property (nonatomic, copy ) NSString *cover;
@property (nonatomic, copy ) NSString *name;
@property (nonatomic, copy ) NSString *teacher_name;
@property (nonatomic, copy ) NSNumber *subject;
@property (nonatomic, copy ) NSString *grade;
@property (nonatomic,strong) NSNumber *start_time;
@property (nonatomic,strong) NSNumber *end_time;

@end


