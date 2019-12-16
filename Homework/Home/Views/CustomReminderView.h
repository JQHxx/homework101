//
//  CustomReminderView.h
//  Homework
//
//  Created by vision on 2019/10/14.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ConfirmBlock)(void);

@interface CustomReminderView : UIView

+(void)showReminderViewWithFrame:(CGRect)frame info:(NSDictionary *)info confirmAction:(ConfirmBlock)confrim;

@end


