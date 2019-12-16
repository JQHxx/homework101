//
//  ChatViewController.h
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@protocol ChatViewControllerDelegate <NSObject>

-(void)chatViewControllerDidSlectedConversions:(NSArray<RCMessageModel *> *)chatRecords;

@end


@interface ChatViewController : RCConversationViewController

@property (nonatomic, weak ) id<ChatViewControllerDelegate>controllerDelegate;
@property (nonatomic,assign) BOOL  isReportIn;

@end

