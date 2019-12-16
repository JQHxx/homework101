//
//  CustomMessage.h
//  Teasing
//
//  Created by vision on 2019/6/6.
//  Copyright © 2019 vision. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 自定义消息的类型名
 */
#define RCCustomMessageTypeIdentifier @"RC:CustomMsg"

@interface CustomMessage : RCMessageContent<NSCoding>

/*!
测试消息的内容
*/
@property(nonatomic, strong) NSString *content;
/*!
 测试消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化测试消息

 @param content 文本内容
 @return        测试消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content extra:(NSString *)extra;

@end

