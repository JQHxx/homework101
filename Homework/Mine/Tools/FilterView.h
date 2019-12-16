//
//  FilterView.h
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewDelegate <NSObject>

-(void)filerViewDidClickWithIndex:(NSInteger)index;

@end

@interface FilterView : UIView

@property (nonatomic, weak) id<FilterViewDelegate>viewDelegate;

@property (nonatomic, copy ) NSString *dateStr;
@property (nonatomic, copy ) NSString *subjectStr;


@end

