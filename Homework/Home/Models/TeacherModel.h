//
//  TeacherModel.h
//  Homework
//
//  Created by vision on 2019/9/7.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TeacherModel : NSObject

@property (nonatomic,strong) NSNumber *t_id;
@property (nonatomic, copy ) NSString *name;      //姓名
@property (nonatomic, copy ) NSString *cover;     //头像
@property (nonatomic,strong) NSNumber *subject;   //科目
@property (nonatomic, copy ) NSArray *grade;      //年级
@property (nonatomic, copy ) NSArray *label;      //标签
@property (nonatomic,strong) NSNumber *create_time;
@property (nonatomic,strong) NSNumber *score;           //评分
@property (nonatomic,strong) NSNumber *tutoring_time;   //辅导时长
@property (nonatomic,strong) NSDictionary *guide_time;   //辅导时间
@property (nonatomic,strong) NSNumber *recommend;         //推荐
@property (nonatomic, copy ) NSString *third_id;
@property (nonatomic,strong) NSNumber *state;       //0 正常 1请假 2代课
@property (nonatomic,strong) NSNumber *status;       //1已经购买2购买了已经到期3未领取体验券4体验券已经过期5体验券已经使用6优惠券已经领取未使用
@property (nonatomic,strong) NSNumber *day_num; //剩余天数
@property (nonatomic,strong) NSNumber *guide_status; //0未辅导 1辅导中
@property (nonatomic,strong) NSNumber *coupon_id;  //体验券id 不为0代表有体验卷
@property (nonatomic,strong) NSNumber *user_pay;  // 1购买了2购买过期了

@end


@interface GuideTimeModel : NSObject

@property (nonatomic, copy ) NSString *workday;        //工作日
@property (nonatomic, copy ) NSString *work_time;      //工作日辅导时间
@property (nonatomic, copy ) NSString *off_day;        //周末
@property (nonatomic, copy ) NSString *off_time;       //休息日

@end


