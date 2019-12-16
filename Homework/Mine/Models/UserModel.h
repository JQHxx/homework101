//
//  UserModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy ) NSString  *cover;
@property (nonatomic,strong) NSNumber  *s_id;
@property (nonatomic, copy ) NSString  *name;
@property (nonatomic, copy ) NSString  *grade;

@property (nonatomic, copy ) NSString  *token;
@property (nonatomic, copy ) NSString  *third_id;
@property (nonatomic, copy ) NSString  *third_token;

@property (nonatomic, copy ) NSString  *province;
@property (nonatomic, copy ) NSString  *city;
@property (nonatomic, copy ) NSString  *country;

@property (nonatomic,strong) NSNumber  *money;

@property (nonatomic,strong) NSNumber  *pay_switch;


@end
