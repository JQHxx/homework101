//
//  TeacherTableView.h
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@class TeacherTableView;
@protocol TeacherTableViewDelegate <NSObject>

//查看详情
-(void)teacherTableView:(TeacherTableView *)tableView didSelectCellWithModel:(TeacherModel *)teacher;
//联系老师
-(void)teacherTableView:(TeacherTableView *)tableView didContactTeacher:(TeacherModel *)teacher;

@end

@interface TeacherTableView : UITableView

@property (nonatomic,strong) NSMutableArray      *teachersArr;

@property (nonatomic, weak ) id<TeacherTableViewDelegate>viewDelegate;

@end

