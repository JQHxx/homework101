//
//  HomeworkManager.h
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"


@interface HomeworkManager : NSObject

singleton_interface(HomeworkManager)

@property (nonatomic ,assign) BOOL  isUpdateHome;
@property (nonatomic ,assign) BOOL  isUpdateMessage;
@property (nonatomic ,assign) BOOL  isUpdateUserInfo;
@property (nonatomic ,assign) BOOL  isUpdateChat;
@property (nonatomic ,assign) BOOL  isUpdateTeacher;

@property (nonatomic , copy ) NSArray  *grades;  //年级
@property (nonatomic , copy ) NSArray  *subjects;  //科目

/*
 *根据年级获取科目
 *
 * @param grade 年级
 * @return 科目数组
 *
 */
-(NSArray *)getCourseForGrade:(NSString *)grade;

/*
*根据科目获取背景图片
*
* @param subject 科目
* @return 科目背景图
*
*/
-(UIImage *)getLongBackgroundImageForSubject:(NSString *)subject;

/*
*根据科目获取背景图片
*
* @param subject 科目
* @return 科目背景图
*
*/
-(UIImage *)getShortBackgroundImageForSubject:(NSString *)subject;

/*
 *解析星期
 *
 * @param days 天
 * @return 星期数组
 */
-(NSMutableArray *)parseWeeksDataWithDays:(NSString *)days;


/**
 *@bref 其他数据转json数据
 */
-(NSString *)getValueWithParams:(id)params;

/*
 *@bref 对图片base64加密
 */
- (NSMutableArray *)imageDataProcessingWithImgArray:(NSMutableArray *)imgArray;

/**
 *@bref 时间戳转化为时间
 */
- (NSString *)timeWithTimeIntervalNumber:(NSNumber *)timeNum format:(NSString *)format;

/**
 *@bref 将某个时间转化成 时间戳
 */
-(NSNumber *)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format;

/**
* 获取缓存数据
*/
- (CGFloat)getTotalCacheSize;

/***
 * @bref  限制emoji表情输入
 */
-(BOOL)strIsContainEmojiWithStr:(NSString*)str;
/***
 * @bref  限制第三方键盘（常用的是搜狗键盘）的表情
 */
- (BOOL)hasEmoji:(NSString*)string;

-(BOOL)isNineKeyBoard:(NSString *)string;

//分享好友
-(void)shareToOtherUsersFromController:(UIViewController *)controller;

@end


