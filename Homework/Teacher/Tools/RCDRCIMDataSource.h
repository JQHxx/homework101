//
//  RCDRCIMDataSource.h
//  Teasing
//
//  Created by vision on 2019/6/18.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

#define RCDDataSource [RCDRCIMDataSource sharedRCDRCIMDataSource]

@interface RCDRCIMDataSource : NSObject<RCIMUserInfoDataSource>


singleton_interface(RCDRCIMDataSource)


@end

