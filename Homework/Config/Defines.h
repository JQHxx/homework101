//
//  Defines.h
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#ifndef Defines_h
#define Defines_h


#endif /* Defines_h */


/*************iPhone设备判断***********/
//iPhone 5判断
#define IS_IPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//iPhone 6判断
#define IS_IPHONE_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
//iPhoneX判断
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD: NO)
//iPhoneXr判断
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)
//iPhoneXs判断
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD: NO)
//iPhoneXs Max判断
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD : NO)
//iPhoneX、iPhoneXr、iPhoneXs、iPhoneXs Max判断
#define isXDevice     (IS_IPHONE_X==YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES)
//iPad 判断
#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)


/*************屏幕尺寸相关*********************/
#define kScreenHeight     [UIScreen mainScreen].bounds.size.height
#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
#define kTabHeight        (IS_IPAD?72:(isXDevice ? (49+ 34) : 49))
#define kNavHeight        (IS_IPAD?88:(isXDevice ? 88 : 64))
#define KStatusHeight     (isXDevice ? 44 : 20)


#define kRGBColor(r, g, b , a)    [UIColor colorWithRed:(r)/255.0  green:(g)/255.0 blue:(b)/255.0  alpha:a]

/*****************数据类型判断*******************/
//字符串为空判断
#define kIsEmptyString(s)       (s == nil || [s isKindOfClass:[NSNull class]] || ([s isKindOfClass:[NSString class]] && s.length == 0))
//对象为空判断
#define kIsEmptyObject(obj)     (obj == nil || [obj isKindOfClass:[NSNull class]])
//字典类型判断
#define kIsDictionary(objDict)  (objDict != nil && [objDict isKindOfClass:[NSDictionary class]])
//数组类型判断
#define kIsArray(objArray)      (objArray != nil && [objArray isKindOfClass:[NSArray class]])


/****************系统版本判断************************/
#define IOS10_OR_LATER  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

/****************其他常用宏定义************************/
//app版本号
#define APP_VERSION       [[NSBundle mainBundle].infoDictionary  objectForKey:@"CFBundleShortVersionString"]
//app名称
#define APP_DISPLAY_NAME  [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"]
//ios系统版本号
#define kIOSVersion       ([UIDevice currentDevice].systemVersion.floatValue)
// appDelegate
#define kAppDelegate    (AppDelegate *)[[UIApplication  sharedApplication] delegate]
// keyWindow
#define kKeyWindow     [UIApplication sharedApplication].keyWindow
//block weakself
#define kSelfWeak     __weak typeof(self) weakSelf = self
//block strongself
#define kSelfStrong  __strong typeof(self) strongSelf = self
//调试
#ifdef DEBUG
#define MyLog(...) NSLog(__VA_ARGS__)
#else
#define MyLog(...)
#endif

/***********************全局变量***************************/
#define kShowGuidance             @"kShowGuidance"

#define kIsLogin                  @"kIsLogin"
#define kUserId                   @"kUserId"
#define kUserToken                @"kUserToken"
#define kRongCloudID              @"kRongCloudID"         //融云用户id
#define kRongCloudToken           @"kRongCloudToken"         //融云用户token
#define kLoginPhone               @"kLoginPhone"
#define kUserGrade                @"kUserGrade"
#define kUserNickname             @"kUserNickname"
#define kUserHeadPic              @"kUserHeadPic"
#define kUserCredit               @"kUserMoney"
#define kPaySwitch                @"kPaySwitch"    //内购开关

#define kPushMsgSetting           @"kPushMsgSetting"

#define kUserTokenValue   [NSUserDefaultsInfos getValueforKey:kUserToken]
#define kUserGradeValue   [NSUserDefaultsInfos getValueforKey:kUserGrade]

#define kReloadMsgNotification       @"kReloadMsgNotification"     //刷新消息
#define kPayBackNotification         @"kPayBackNotification"      //支付成功回调通知

//友盟统计
#define kStaticsToBuyEvent          @"zy10001"     //去购买
#define kStaticsBuyNowEvent         @"zy10002"     //立即购买
#define kStaticsGetCouponsEvent     @"zy10003"     //领取优惠券
#define kStaticsBannerEvent         @"zy10004"     //点击banner
#define kStaticsStartCaochEvent     @"zy10005"     //开始辅导
#define kStaticsNoneBuyEvent        @"zy10006"     //放弃购买
#define kStaticsChatBuyEvent        @"zy10007"     //聊天页-去购买
#define kStaticsInviteEvent         @"zy10008"     //邀请好友
#define kStaticsShareEvent          @"zy10009"     //立即分享
