//
//  BuyCoachViewController.h
//  Homework
//
//  Created by vision on 2019/9/17.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BaseViewController.h"
#import "TeacherModel.h"


@interface BuyCoachViewController : BaseViewController

@property (nonatomic,strong) TeacherModel *teacher;
@property (nonatomic,assign) BOOL       isInviteBuy;

@end


