//
//  HomeworkManager.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HomeworkManager.h"
#import "UIImage+Extend.h"
#import "SBJSON.h"
#import <SDImageCache.h>
#import <UShareUI/UShareUI.h>
#import <UMAnalytics/MobClick.h>

@implementation HomeworkManager

singleton_implementation(HomeworkManager)

-(NSArray *)grades{
    return @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
}

-(NSArray *)subjects{
    return @[@"语文",@"数学",@"英语",@"物理",@"化学",@"生物",@"历史",@"政治",@"地理"];
}

#pragma mark 根据年级获取科目
-(NSArray *)getCourseForGrade:(NSString *)grade{
    NSArray *arr =nil;
    if ([grade isEqualToString:@"初一"]||[grade isEqualToString:@"初二"]||[grade isEqualToString:@"初三"]) {
        arr = self.subjects;
    }else{
        arr = @[@"语文",@"数学",@"英语"];
    }
    return arr;
}

#pragma mark  根据科目获取背景图片
-(UIImage *)getLongBackgroundImageForSubject:(NSString *)subject{
    NSString *imgName = nil;
    if ([subject isEqualToString:@"语文"]) {
        imgName = @"subject_chinese_long";
    }else if ([subject isEqualToString:@"数学"]){
        imgName = @"subject_mathematics_long";
    }else if ([subject isEqualToString:@"英语"]){
        imgName = @"subject_english_long";
    }else{
        imgName = @"subject_other_long";
    }
    return [UIImage imageNamed:imgName];
}

#pragma mark  根据科目获取背景图片
-(UIImage *)getShortBackgroundImageForSubject:(NSString *)subject{
    NSString *imgName = nil;
    if ([subject isEqualToString:@"语文"]) {
        imgName = @"subject_chinese_short";
    }else if ([subject isEqualToString:@"数学"]){
        imgName = @"subject_mathematics_short";
    }else if ([subject isEqualToString:@"英语"]){
        imgName = @"subject_english_short";
    }else{
        imgName = @"subject_other_short";
    }
    return [UIImage imageNamed:imgName];
}

#pragma mark 解析星期
-(NSMutableArray *)parseWeeksDataWithDays:(NSString *)days{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSArray *daysArr = [days componentsSeparatedByString:@","];
    for (NSNumber *day in daysArr) {
        NSString *tempWeek = nil;
        if ([day integerValue]==1) {
            tempWeek = @"周一";
        }else if ([day integerValue]==2){
            tempWeek = @"周二";
        }else if ([day integerValue]==3){
            tempWeek = @"周三";
        }else if ([day integerValue]==4){
            tempWeek = @"周四";
        }else if ([day integerValue]==5){
            tempWeek = @"周五";
        }else if ([day integerValue]==6){
            tempWeek = @"周六";
        }else if ([day integerValue]==7){
            tempWeek = @"周日";
        }
        [tempArr addObject:tempWeek];
    }
    
    return tempArr;
}

#pragma mark 时间戳转化为时间
- (NSString *)timeWithTimeIntervalNumber:(NSNumber *)timeNum format:(NSString *)format{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeNum integerValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

#pragma mark 将某个时间转化成 时间戳
-(NSNumber *)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];    //将字符串按formatter转成nsdate
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}

#pragma mark 获取缓存数据
- (CGFloat)getTotalCacheSize{
    NSUInteger imageCacheSize = [[SDImageCache sharedImageCache] totalDiskSize];
    //获取自定义缓存大小
    //用枚举器遍历 一个文件夹的内容
    //1.获取 文件夹枚举器
    NSString *myCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:myCachePath];
    __block NSUInteger count = 0;
    //2.遍历
    for (NSString *fileName in enumerator) {
        NSString *path = [myCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        count += fileDict.fileSize;//自定义所有缓存大小
    }
    // 得到是字节  转化为M
    CGFloat totalSize = ((CGFloat)imageCacheSize+count)/1024/1024;
    return totalSize;
}

#pragma mark --其他数据转json数据
-(NSString *)getValueWithParams:(id)params{
    SBJsonWriter *writer=[[SBJsonWriter alloc] init];
    NSString *value=[writer stringWithObject:params];
    MyLog(@"value:%@",value);
    return value;
}

#pragma mark 对图片base64加密
- (NSMutableArray *)imageDataProcessingWithImgArray:(NSMutableArray *)imgArray{
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSInteger i = 0; i < imgArray.count; i++) {
        NSData *imageData = [UIImage zipNSDataWithImage:imgArray[i]];
        //将图片数据转化为64为加密字符串
        NSString *encodeResult = [imageData base64EncodedStringWithOptions:0];
        [photoArray addObject:encodeResult];
    }
    return photoArray;
}

#pragma mark -- 限制emoji表情输入
-(BOOL)strIsContainEmojiWithStr:(NSString*)str{
    __block BOOL returnValue =NO;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         const unichar hs = [substring characterAtIndex:0];
         if(0xd800<= hs && hs <=0xdbff){
             if(substring.length>1){
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs -0xd800) *0x400) + (ls -0xdc00) +0x10000;
                 if(0x1d000<= uc && uc <=0x1f77f){
                     returnValue =YES;
                 }
             }
         }else if(substring.length>1){
             const unichar ls = [substring characterAtIndex:1];
             if(ls ==0x20e3)
             {
                 returnValue =YES;
             }
         }else{
             // non surrogate
             if(0x2100<= hs && hs <=0x27ff&& hs !=0x263b)
             {
                 returnValue =YES;
             }
             else if(0x2B05<= hs && hs <=0x2b07)
             {
                 returnValue =YES;
             }
             else if(0x2934<= hs && hs <=0x2935)
             {
                 returnValue =YES;
             }
             else if(0x3297<= hs && hs <=0x3299)
             {
                 returnValue =YES;
             }
             else if(hs ==0xa9|| hs ==0xae|| hs ==0x303d|| hs ==0x3030|| hs ==0x2b55|| hs ==0x2b1c|| hs ==0x2b1b|| hs ==0x2b50|| hs ==0x231a)
             {
                 returnValue =YES;
             }
         }
     }];
    return returnValue;
}
#pragma mark -- 限制第三方键盘（常用的是搜狗键盘）的表情
- (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

#pragma mark -- 判断当前是不是在使用九宫格输入
-(BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}

#pragma mark 分享好友
-(void)shareToOtherUsersFromController:(UIViewController *)controller{
    [MobClick event:kStaticsShareEvent];
    //分享面板配置
    [UMSocialShareUIConfig shareInstance].shareContainerConfig.shareContainerCornerRadius = 8.0;
    [UMSocialShareUIConfig shareInstance].shareTitleViewConfig.shareTitleViewTitleString = @"分享好友";  //面板标题
    [UMSocialShareUIConfig shareInstance].shareTitleViewConfig.shareTitleViewFont = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    [UMSocialShareUIConfig shareInstance].shareTitleViewConfig.shareTitleViewPaddingTop = 10.0;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPadingBottom = 10.0;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageMaxItemSpaceBetweenIconAndName = 10.0;
    [UMSocialShareUIConfig shareInstance].shareCancelControlConfig.isShow = NO;  //不显示取消
    

    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        //创建网页内容对象
        UIImage *image = [UIImage imageNamed:@"logo180"];
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"送你来作业101和我一起学习吧" descr:@"领取在线1对1家教辅导优惠大礼包，随时随地开启学霸模式！" thumImage:image];
        shareObject.webpageUrl = kShareLandingURL;
        messageObject.shareObject = shareObject;
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:controller completion:^(id result, NSError *error ) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [kKeyWindow makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
                });
            } else {
                if (error.code == 2009) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [kKeyWindow makeToast:@"您已取消分享" duration:1.0 position:CSToastPositionCenter];
                    });
                }
                MyLog(@"分享失败， error:%@",error.localizedDescription);
            }
        }];
    }];
}

@end
