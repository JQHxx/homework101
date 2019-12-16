//
//  MineHeaderView.h
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface MineHeaderView : UIView

@property (nonatomic,strong) UIButton    *setupBtn;
@property (nonatomic,strong) UIButton    *editButton;

@property (nonatomic,strong) UserModel   *userModel;

@end

