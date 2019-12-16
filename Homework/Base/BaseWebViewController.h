//
//  BaseWebViewController.h
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseWebViewController : BaseViewController

@property (nonatomic, copy ) NSString *webTitle;
@property (nonatomic, copy ) NSString *urlStr;

-(void)webListenToJumpWithUrl:(NSString *)url;

@end


