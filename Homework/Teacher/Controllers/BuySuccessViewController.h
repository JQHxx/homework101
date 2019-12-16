//
//  BuySuccessViewController.h
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BaseViewController.h"
#import "TeacherModel.h"


@interface BuySuccessViewController : BaseViewController

@property (nonatomic,assign) BOOL  isExpBuyIn;
@property (nonatomic,assign) NSInteger  subject;
@property (nonatomic,strong) TeacherModel *myTeacher;

@end


