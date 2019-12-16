//
//  CoachEvaluateView.h
//  Homework
//
//  Created by vision on 2019/10/15.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SubmitBlock)(NSInteger score,NSString *evaluate,BOOL anonymous);

@interface CoachEvaluateView : UIView

+(void)showEvaluateViewWithFrame:(CGRect)frame submitAction:(SubmitBlock)submitBlock;

@end


