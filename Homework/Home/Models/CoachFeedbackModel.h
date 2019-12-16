//
//  CoachFeedbackModel.h
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CoachFeedbackModel : NSObject

@property (nonatomic, copy ) NSString *teacher_name;
@property (nonatomic, copy ) NSString *cover;
@property (nonatomic,strong) NSString *subject;
@property (nonatomic,strong) NSNumber *end_time;
@property (nonatomic, copy ) NSString *merit;        //优点
@property (nonatomic, copy ) NSString *defect;     //缺点



@end


