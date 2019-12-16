//
//  AppDelegate.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "AppDelegate.h"
#import "GuidanceViewController.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import "ZYLoadingViewController.h"

#import "CustomMessage.h"
#import "APPInfoManager.h"
#import "RCDRCIMDataSource.h"

#import "IQKeyboardManager.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import <UMCommon/UMCommon.h>
#import <UMCommonLog/UMCommonLogHeaders.h>
#import <UMShare/UMShare.h>
#import <UMPush/UMessage.h>
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "UIDevice+Extend.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate,WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setAppSystemConfigWithOptions:launchOptions];
    [self replyPushNotificationAuthorization:application]; //申请通知权限
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    
  
    BOOL hasShowGuidance=[[NSUserDefaultsInfos getValueforKey:kShowGuidance] boolValue];
    if (!hasShowGuidance&&!IS_IPAD) {
        GuidanceViewController *guidanceVC=[[GuidanceViewController alloc] init];
        self.window.rootViewController=guidanceVC;
    }else{
        if ([APPInfoManager hasSignIn]) {
            ZYLoadingViewController *loadingVC = [[ZYLoadingViewController alloc] init];
            self.window.rootViewController = loadingVC;
        }else{
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:loginVC];
            self.window.rootViewController = nav;
        }
    }
  
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    MyLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if (status != ConnectionStatus_SignUp) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE)]];
        application.applicationIconBadgeNumber = unreadMsgCount;
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    MyLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    MyLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    MyLog(@"applicationDidBecomeActive");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self uploadDeviceInfo]; //上传设备信息
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    MyLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -- 推送相关
#pragma mark -iOS 10之前收到通知
#pragma mark 接收通知
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
     MyLog(@"didReceiveRemoteNotification  ----------------------  后台收到通知:%@", userInfo);
    
    //统计远程推送的事件
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    
    [UMessage setAutoAlert:NO]; //关闭提示框
    [UMessage didReceiveRemoteNotification:userInfo]; // 应用处于运行时（前台、后台）的消息处理，回传点击数据
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMsgNotification object:nil];

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark 获取设备的DeviceToken
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // 设置deviceToken，用于远程推送
     NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    
    //向友盟注册该设备的deviceToken，便于发送Push消息
    [UMessage registerDeviceToken:deviceToken];
    MyLog(@"didRegisterForRemoteNotificationsWithDeviceToken,deviceToken:%@",token);
}

#pragma mark - UNUserNotificationCenterDelegate
#pragma mark iOS10 App处于前台接收通知时
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull void (^)(UNNotificationPresentationOptions))completionHandler{
    //收到推送的内容
    UNNotificationContent *content = notification.request.content;
    //收到用户的基本信息
    NSDictionary * userInfo = content.userInfo;
    
     MyLog(@"userNotificationCenter ----- willPresentNotification");

    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        MyLog(@"iOS10 前台收到远程通知:%@",userInfo);
        //统计远程推送的事件
        [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
        
        [UMessage setAutoAlert:NO]; //关闭提示框
        [UMessage didReceiveRemoteNotification:userInfo]; // 应用处于运行时（前台、后台）的消息处理，回传点击数据
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMsgNotification object:nil];
    }else{
        // 判断为本地通知
        MyLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",content.body,content.title,content.subtitle,content.badge,content.sound,userInfo);
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

#pragma mark iOS10 通知的点击事件的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler{
    
    MyLog(@"userNotificationCenter ----- didReceiveNotificationResponse");
    //收到推送的内容
    UNNotificationContent *content = response.notification.request.content;
    //收到用户的基本信息
    NSDictionary * userInfo = content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        MyLog(@"iOS10 点击收到远程通知:%@",userInfo);
        //统计远程推送的事件
        [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
        
        [UMessage setAutoAlert:NO]; //关闭提示框
        [UMessage didReceiveRemoteNotification:userInfo]; // 应用处于运行时（前台、后台）的消息处理，回传点击数据
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMsgNotification object:nil];
    }else{
        // 判断为本地通知
        MyLog(@"iOS10 点击本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",content.body,content.title,content.subtitle,content.badge,content.sound,userInfo);
    }
}


#pragma mark - Delegate
#pragma mark 跳转应用回调 （9.0以后使用新API接口）
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if (!result) {
        NSString *hostStr=[[url host] stringByRemovingPercentEncoding];
        MyLog(@"iOS9.0以上 host:%@",hostStr);
        if ([hostStr isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                if (resultStatus==9000) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPayBackNotification object:nil];
                }else{
                    NSString *memo=[resultDic valueForKey:@"memo"];
                    MyLog(@"resultDic:%@,alipay--error:%@",resultDic,memo);
                }
            }];
            
        }else if ([hostStr isEqualToString:@"pay"]){
            [WXApi handleOpenURL:url delegate:self];
        }
    }
    return result;
}

#pragma mark WXApiDelegate
-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass: [PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                [[NSNotificationCenter defaultCenter] postNotificationName:kPayBackNotification object:nil];
            }
                break;
           case WXErrCodeUserCancel:  //用户点击取消并返回
            {
                MyLog(@"用户取消");
            }
                break;
            default:
                MyLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}


#pragma mark -- NSNotification
#pragma mark 收到消息通知
-(void)didReceiveMessageNotification:(NSNotification *)notification{
    //volume
    BOOL volumeSetting = [[NSUserDefaultsInfos getValueforKey:kPushMsgSetting] boolValue];
    MyLog(@"volumeSetting:%d",volumeSetting);
    [RCIM sharedRCIM].disableMessageAlertSound = !volumeSetting;
    
    NSNumber *left = [notification.userInfo objectForKey:@"left"];
    if ([RCIMClient sharedRCIMClient].sdkRunningMode == RCSDKRunningMode_Background && 0 == left.integerValue) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[ @(ConversationType_PRIVATE)]];
        MyLog(@"didReceiveMessageNotification ,收到消息：%d",unreadMsgCount);
        dispatch_async(dispatch_get_main_queue(),^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount;
        });
    }
}


#pragma mark -- Private Methods
#pragma mark app配置
-(void)setAppSystemConfigWithOptions:(NSDictionary *)launchOptions{
    MyLog(@"app相关配置");
    
    //键盘工具配置
    IQKeyboardManager *keyboardManager= [IQKeyboardManager sharedManager];   // 获取类库的单例变量
    keyboardManager.enable = YES;   // 控制整个功能是否启用
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    keyboardManager.enableAutoToolbar = NO; // 控制是否显示键盘上的工具条
    
    //注册微信APPID
    [WXApi registerApp:kWechatAppKey];
    
    //融云
    //init SDK
    MyLog(@"kRongCloudAppKey------------------------------- %@",kRongCloudAppKey);
    [[RCIM sharedRCIM] initWithAppKey:kRongCloudAppKey];
    [[RCIM sharedRCIM] registerMessageType:[CustomMessage class]];
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;  //是否将用户信息和群组信息在本地持久化存储
    [RCIM sharedRCIM].enableSyncReadStatus = YES;  //是否开启多端同步未读状态的功能
    [RCIM sharedRCIM].enableMessageRecall = YES;  //是否开启消息撤回功能
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;
    [[RCIMClient sharedRCIMClient] setReconnectKickEnable:YES];  //是否踢出重连设备
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
    
    // 设置语音消息类型
    [RCIMClient sharedRCIMClient].voiceMsgType = RCVoiceMessageTypeHighQuality;
    
    BOOL isAlertSound = [RCIM sharedRCIM].disableMessageAlertSound;
    [NSUserDefaultsInfos putKey:kPushMsgSetting andValue:[NSNumber numberWithBool:!isAlertSound]];
    
    //登录融云
    if ([APPInfoManager hasSignIn]) {
        NSString *rcToken = [NSUserDefaultsInfos getValueforKey:kRongCloudToken];
        [[RCIM sharedRCIM] connectWithToken:rcToken success:^(NSString *userId) {
            MyLog(@"login success userID：%@", userId);
        } error:^(RCConnectErrorCode status) {
            MyLog(@"login fail, error:%ld", status);
        } tokenIncorrect:^{
            MyLog(@"token error");
        }];
    }
  
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];   //统计app启动事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNotification:) name:RCKitDispatchMessageNotification object:nil];  //收到消息的Notification
    
    //友盟
    //数据统计
    [UMCommonLogManager setUpUMCommonLogManager]; //开启日志系统
    [UMConfigure setLogEnabled:YES];//设置打开日志
    [UMConfigure initWithAppkey:kUMAppKey channel:@"App Store"]; //初始化
    [MobClick setScenarioType:E_UM_NORMAL];
    
//    NSString* deviceID =  [UMConfigure deviceIDForIntegration];
//    MyLog(@"集成测试的deviceID:%@",deviceID);
    
    //绑定友盟推送别名
    NSNumber *userId = [NSUserDefaultsInfos getValueforKey:kUserId];
    if (userId.integerValue>0) {
        NSString *tempStr = isTrueEnvironment?@"zs_new":@"cs_new";
        NSString *aliasStr=[NSString stringWithFormat:@"%@%@",tempStr,userId];
        [UMessage setAlias:aliasStr type:kUMAlaisType response:^(id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                MyLog(@"绑定别名失败，error:%@",error.localizedDescription);
            }else{
                MyLog(@"绑定别名成功,result:%@",responseObject);
            }
        }];
    }
    
    
    //分享
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWechatAppKey appSecret:kWechatAppSecret redirectURL:nil];
    //设置分享到QQ互联的appID
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kQQAppKey appSecret:nil redirectURL:nil];
    //设置新浪的appKey和appSecret
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:kSinaAppKey appSecret:kSinaAppSecret redirectURL:@""];
}

#pragma mark 上传设备信息
-(void)uploadDeviceInfo{
    //上传设备信息
    NSString *retrieveuuid = [[APPInfoManager sharedAPPInfoManager] deviceIdentifier];
    NSString *version = [[APPInfoManager sharedAPPInfoManager] appBundleVersion];
    NSDictionary *params = @{@"version":version,@"channel":@"appstore",@"deviceType":[UIDevice iphoneType],@"deviceId":retrieveuuid,@"sysVer":[UIDevice getSystemVersion],@"platform":@"iOS",@"nation":[UIDevice deviceCountry],@"language":[UIDevice deviceCurentLanguage],@"wifi":[NSNumber numberWithBool:[UIDevice isWifi]]};
    [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kUploadDeviceInfoAPI parameters:params success:^(id responseObject) {
        MyLog(@"上传设备信息成功");
    } failure:^(NSString *errorStr) {
        
    }];
}

#pragma mark - 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    MyLog(@"申请通知权限");
     if (@available(iOS 10.0, *)) {
        //iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                MyLog(@"申请通知权限--注册成功");
            }else{
                //用户点击不允许
                MyLog(@"申请通知权限--注册失败");
            }
        }];
        
        // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            MyLog(@"获取推送权限设置 ========%@",settings);
        }];
        
     }else if (@available(iOS 8.0, *)){
         //iOS 8 - iOS 10系统
         UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
         [application registerUserNotificationSettings:settings];
         [application registerForRemoteNotifications];
     }
    
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

@end
