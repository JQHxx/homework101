//
//  MessageModel.h
//  HWForTeacher
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageModel : NSObject

@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSNumber *send_time;
@property (nonatomic, copy ) NSString *content;

@end

