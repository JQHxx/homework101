//
//  GuideTableViewCell.h
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideServiceModel.h"


@interface GuideTableViewCell : UITableViewCell

@property (nonatomic,strong) UIButton    *guideButton;
@property (nonatomic,strong) UIButton    *rechargeButton;

@property (nonatomic,strong) GuideServiceModel *serviceModel;

@end

