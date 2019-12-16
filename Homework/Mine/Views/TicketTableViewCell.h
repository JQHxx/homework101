//
//  TicketTableViewCell.h
//  Homework
//
//  Created by vision on 2019/10/8.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpTicketModel.h"

@interface TicketTableViewCell : UITableViewCell

@property (nonatomic,strong) ExpTicketModel *ticketModel;

@property (nonatomic,strong) UIButton    *useBtn;

@end


