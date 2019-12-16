//
//  ReportSubmitViewController.h
//  Homework
//
//  Created by vision on 2019/5/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BaseViewController.h"
#import "ReportModel.h"

@interface ReportSubmitViewController : BaseViewController

@property (nonatomic,strong) ReportModel *report;
@property (nonatomic,strong) NSNumber *tid;
@property (nonatomic, copy ) NSString *rcId;

@end

