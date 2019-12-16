//
//  HttpRequest.m
//  HomeworkForTeacher
//
//  Created by vision on 2019/9/19.
//  Copyright © 2019 vision. All rights reserved.
//

#import "HttpRequest.h"
#import "UploadParam.h"
#import "UIDevice+Extend.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import <RongIMKit/RongIMKit.h>
#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "LoginViewController.h"

@implementation HttpRequest

static id _instance = nil;
+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        [manager startMonitoring];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                {
                    // 位置网络
                    MyLog(@"位置网络");
                }
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                {
                    // 无法联网
                    MyLog(@"无法联网");
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                {
                    // 手机自带网络
                    MyLog(@"当前使用的是2G/3G/4G网络");
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                {
                    // WIFI
                    MyLog(@"当前在WIFI网络下");
                }
            }
        }];
    });
    return _instance;
}

#pragma mark -- POST请求 --
- (void)postWithURLString:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSString *))failure{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    NSString *urlStr = [NSString stringWithFormat:kHostTempURL,URLString];
    MyLog(@"url:%@,params:%@",urlStr,parameters);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        MyLog(@"html:%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        MyLog(@"url:%@, json:%@",urlStr,json);
        if ([[json objectForKey:@"error"] isKindOfClass:[NSNumber class]]) {
            NSInteger status=[[json objectForKey:@"error"] integerValue];
            NSString *message=[json objectForKey:@"msg"];
            if (status==0) {
                success(json);
            }else if (status==2){
                [HttpRequest signOut];
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                MyLog(@"postWithURLString:%@,error:%@",urlStr,message);
                failure(message);
            }
        }else{
            NSString *message = @"暂时无法访问，请稍后再试";
            failure(message);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        MyLog(@"postWithURLString:%@,error:%@",urlStr,error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        failure(error.localizedDescription);
    }];
}

#pragma mark post（不带加载）
-(void)postNotShowLoadingWithURLString:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSString *))failure{
    NSString *urlStr = [NSString stringWithFormat:kHostTempURL,URLString];
    MyLog(@"url:%@,params:%@",urlStr,parameters);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        MyLog(@"html:%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        MyLog(@"url:%@, json:%@",urlStr,json);
        if ([[json objectForKey:@"error"] isKindOfClass:[NSNumber class]]) {
            NSInteger status=[[json objectForKey:@"error"] integerValue];
            NSString *message=[json objectForKey:@"msg"];
            if (status==0) {
                success(json);
            }else if (status==2){
                [HttpRequest signOut];
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                MyLog(@"请求失败--error:%@",message);
            }
        }else{
            MyLog(@"请求失败--暂时无法访问，请稍后再试");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        MyLog(@"请求失败--error:%@",error.localizedDescription);
        failure(error.localizedDescription);
    }];
}

#pragma mark 上传文件
- (void)uploadWithURLString:(NSString *)URLString parameters:(id)parameters uploadParam:(NSArray<UploadParam *> *)uploadParams success:(void (^)(id))success failure:(void (^)(NSString *))failure{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    NSString *urlStr = [NSString stringWithFormat:kHostTempURL,URLString];
    MyLog(@"uploadWithURLString----url:%@,params:%@",urlStr,parameters);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (UploadParam *uploadParam in uploadParams) {
            [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.filename mimeType:uploadParam.mimeType];
        }
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        MyLog(@"html:%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        MyLog(@"url:%@, json:%@",urlStr,json);
        if ([[json objectForKey:@"error"] isKindOfClass:[NSNumber class]]) {
            NSInteger status=[[json objectForKey:@"error"] integerValue];
            NSString *message=[json objectForKey:@"msg"];
            if (status==0) {
                success(json);
            }else if (status==2){
                [HttpRequest signOut];
            }else{
                message=kIsEmptyString(message)?@"暂时无法访问，请稍后再试":message;
                MyLog(@"请求失败--error:%@",message);
                failure(message);
            }
        }else{
            NSString *message = @"暂时无法访问，请稍后再试";
            failure(message);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        MyLog(@"请求失败--error:%@",error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        failure(error.localizedDescription);
    }];
}

#pragma mark - 下载数据
- (void)downLoadWithURLString:(NSString *)URLString parameters:(id)parameters progerss:(void (^)(void))progress success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLSessionDownloadTask *downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress();
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    [downLoadTask resume];
}

+(void)signOut{
    [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:NO]];
    [NSUserDefaultsInfos removeObjectForKey:kRongCloudToken];
    [NSUserDefaultsInfos removeObjectForKey:kUserToken];
    
    [[RCIM sharedRCIM] disconnect];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:loginVC];
        AppDelegate *appDelegate =kAppDelegate;
        appDelegate.window.rootViewController = nav;
    });
}

@end
