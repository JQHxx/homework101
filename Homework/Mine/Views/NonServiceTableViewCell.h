//
//  NonServiceTableViewCell.h
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NonServiceTableViewCellDelegate <NSObject>

-(void)nonServiceCellDidClickBtnAction;

@end



@interface NonServiceTableViewCell : UITableViewCell

@property (nonatomic, weak )id<NonServiceTableViewCellDelegate>cellDelegate;

@end


