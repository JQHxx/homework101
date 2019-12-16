//
//  CustomMessage.m
//  Teasing
//
//  Created by vision on 2019/6/6.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CustomMessage.h"

#define kEY_MSG_CONTENT     @"content"
#define kEY_MSG_EXTRA       @"extra"
#define kEY_MSG_USER        @"user"

@implementation CustomMessage

+(instancetype)messageWithContent:(NSString *)content extra:(NSString *)extra{
    CustomMessage *message = [[CustomMessage alloc] init];
    if (message) {
        message.content = content;
        message.extra  = extra;
    }
    return message;
}

#pragma mark -- RCMessagePersistentCompatible
#pragma mark 返回消息的存储策略
+(RCMessagePersistent)persistentFlag{
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark -- RCMessageContentView
#pragma mark  返回在会话列表和本地通知中显示的消息内容摘要
-(NSString *)conversationDigest{
    return  self.content;
}

#pragma mark -- NSCoding
#pragma mark 解码
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:kEY_MSG_CONTENT];
        self.extra = [aDecoder decodeObjectForKey:kEY_MSG_EXTRA];
    }
    return self;
}

#pragma mark 编码
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.content forKey:kEY_MSG_CONTENT];
    [aCoder encodeObject:self.extra forKey:kEY_MSG_EXTRA];
}

#pragma mark 将消息内容编码成json
-(NSData *)encode{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:kEY_MSG_CONTENT];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:kEY_MSG_EXTRA];
    }
    
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:kEY_MSG_USER];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

#pragma mark 将json解码生成消息内容
-(void)decodeWithData:(NSData *)data{
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        MyLog(@"dictionary------%@",dictionary);
        if (dictionary) {
            self.content = dictionary[kEY_MSG_CONTENT];
            self.extra = dictionary[kEY_MSG_EXTRA];
            NSDictionary *userDic = dictionary[kEY_MSG_USER];
            [self decodeUserInfo:userDic];
        }
    }
}

#pragma mark  消息的类型名
+ (NSString *)getObjectName {
    return RCCustomMessageTypeIdentifier;
}

@end
