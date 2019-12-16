//
//  MyteacherTableView.h
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@class MyTeacherTableView;

@protocol MyTeacherTableViewDelegate <NSObject>

//去领取、去购买、去辅导
-(void)myTeacherTableView:(MyTeacherTableView *)myTableView didHandleWithModel:(TeacherModel *)teacher;
//查看老师详情
-(void)myTeacherTableView:(MyTeacherTableView *)myTableView didSelectedTeacher:(TeacherModel *)teacher;
//去辅导
-(void)myTeacherTableView:(MyTeacherTableView *)myTableView didGotoCoachWithTeacher:(TeacherModel *)teacher;

@end

@interface MyTeacherTableView : UITableView

@property (nonatomic, weak ) id<MyTeacherTableViewDelegate>viewDelegate;

@property (nonatomic,strong) NSMutableArray *teachersArray;


@end


