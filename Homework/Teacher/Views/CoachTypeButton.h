//
//  CoachTypeButton.h
//  Homework
//
//  Created by vision on 2019/9/17.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachTypeModel.h"


@interface CoachTypeButton : UIButton



@property (nonatomic,strong) CoachTypeModel *typeModel;

@property (nonatomic,assign) BOOL   btnHasSelected;

@end


