//
//  GuideServiceModel.h
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GuideServiceModel : NSObject

@property (nonatomic,strong) NSNumber *t_id;
@property (nonatomic, copy ) NSString *name;
@property (nonatomic, copy ) NSString *cover;
@property (nonatomic, copy ) NSString *teacher_name;
@property (nonatomic, copy ) NSString *third_id;
@property (nonatomic, copy ) NSString  *grade;
@property (nonatomic,strong) NSNumber *subject;
@property (nonatomic,strong) NSNumber *end_time;  //到期时间
@property (nonatomic,strong) NSDictionary *guide_time;


@end


