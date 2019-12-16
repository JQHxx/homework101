//
//  MyFeedbackTableViewCell.h
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachFeedbackModel.h"

@interface MyFeedbackTableViewCell : UITableViewCell

@property (nonatomic,strong) CoachFeedbackModel *feedbackModel;

+(CGFloat)getMyFeedbackCellHeightWithModel:(CoachFeedbackModel *)model;

@end



