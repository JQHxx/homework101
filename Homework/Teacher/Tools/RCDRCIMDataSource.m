//
//  RCDRCIMDataSource.m
//  Teasing
//
//  Created by vision on 2019/6/18.
//  Copyright © 2019 vision. All rights reserved.
//

#import "RCDRCIMDataSource.h"
#import "TeacherModel.h"

@implementation RCDRCIMDataSource

singleton_implementation(RCDRCIMDataSource)

#pragma mark - RCIMUserInfoDataSource
-(void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion{
    MyLog(@"getUserInfoWithUserId ----- %@", userId);
    RCUserInfo *user = [RCUserInfo new];
    if (userId == nil || [userId length] == 0) {
        user.userId = userId;
        user.portraitUri = @"";
        user.name = @"";
        completion(user);
        return;
    }
    if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        RCUserInfo * userInfo = [[RCUserInfo alloc] init];
        userInfo.userId = userId;
        userInfo.name = [NSUserDefaultsInfos getValueforKey:kUserNickname];
        userInfo.portraitUri = [NSUserDefaultsInfos getValueforKey:kUserHeadPic];
        [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
        return completion(userInfo);
    }else{
        NSDictionary *params = @{@"token":kUserTokenValue,@"rongyun_third_id":userId};
        [[HttpRequest sharedInstance] postNotShowLoadingWithURLString:kRongCloudInfoAPI parameters:params success:^(id responseObject) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            TeacherModel *teacher = [[TeacherModel alloc] init];
            [teacher setValues:data];
            
            RCUserInfo * userInfo = [[RCUserInfo alloc] init];
            userInfo.userId = userId;
            userInfo.name = teacher.name;
            userInfo.portraitUri = teacher.cover;
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
            
            return completion(userInfo);
        } failure:^(NSString *errorStr) {
            
        }];
    }
}


@end
