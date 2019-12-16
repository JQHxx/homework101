//
//  MyConversationViewController.h
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@protocol MyConversationViewControllerDelegate <NSObject>

-(void)myConversationViewControllerDidPushToChatWithTargetID:(NSString *)targetId;

-(void)myConversationViewControllerShowMessageUnreadCount:(NSInteger)count;

@end

@interface MyConversationViewController : RCConversationListViewController

@property (nonatomic, weak )id<MyConversationViewControllerDelegate>controlerDelegate;

@end

