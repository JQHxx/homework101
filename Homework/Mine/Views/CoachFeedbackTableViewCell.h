//
//  CoachFeedbackTableViewCell.h
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachFeedbackModel.h"

@interface CoachFeedbackTableViewCell : UITableViewCell

@property (nonatomic,strong) CoachFeedbackModel *feedbackModel;

+(CGFloat)getMyFeedbackCellHeightWithModel:(CoachFeedbackModel *)model;

@end


