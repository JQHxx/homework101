//
//  MyTeacherTableViewCell.h
//  Homework
//
//  Created by vision on 2019/9/7.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCoachButton.h"
#import "TeacherModel.h"


@interface MyTeacherTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView     *headImageView;      //头像
@property (strong, nonatomic) HomeCoachButton *coachBtn;           //去领取、去辅导、去续费

@property (nonatomic,strong) TeacherModel *myTeacher;

@end


