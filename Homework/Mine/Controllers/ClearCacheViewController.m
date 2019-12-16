//
//  ClearCacheViewController.m
//  HWForTeacher
//
//  Created by vision on 2019/5/31.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ClearCacheViewController.h"
#import <SDImageCache.h>

@interface ClearCacheViewController (){
    UILabel   *cacheCountLabel;
}

@end

@implementation ClearCacheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"清除缓存";
    
    [self initClearCacheView];
    [self loadCacheData];
}

#pragma mark -- event response
#pragma mark 清除缓存
-(void)clearCacheAction:(UIButton *)sender{
    //删除自己缓存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
    for (NSString *p in files) {
        NSError *error;
        NSString *Path = [path stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
            //清理缓存，保留Preference，里面含有NSUserDefaults保存的信息
            if (![Path containsString:@"Preferences"]) {
                [[NSFileManager defaultManager] removeItemAtPath:Path error:&error];
            }
        }
    }
    
    //先清除内存中的图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    //清除磁盘的缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [self loadCacheData];
    }];
    
    
}


#pragma mark -- Private methods
#pragma mark 初始化界面
-(void)initClearCacheView{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-172.0)/2.0,kNavHeight+45.0, 172.0, 172.0)];
    [bgView setBorderWithCornerRadius:86.0 type:UIViewCornerTypeAll];
    bgView.backgroundColor = [UIColor bm_colorGradientChangeWithSize:bgView.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#CC71FF"] endColor:[UIColor colorWithHexString:@"#7C60FF"]];
    bgView.alpha = 0.2;
    [self.view addSubview:bgView];
    
    UIView *innerCircleView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-140.0)/2.0, kNavHeight+61, 140.0, 140.0)];
    innerCircleView.backgroundColor = [UIColor bm_colorGradientChangeWithSize:bgView.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#CC71FF"] endColor:[UIColor colorWithHexString:@"#7C60FF"]];
    [innerCircleView setBorderWithCornerRadius:58.5 type:UIViewCornerTypeAll];
    [self.view addSubview:innerCircleView];
    
    cacheCountLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2.0, kNavHeight+100, 150, 30)];
    cacheCountLabel.textColor = [UIColor whiteColor];
    cacheCountLabel.font = [UIFont mediumFontWithSize:30.0f];
    cacheCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:cacheCountLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2.0,cacheCountLabel.bottom+15, 150, 16)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont mediumFontWithSize:15.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"所有缓存";
    [self.view addSubview:label];
    
    UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(37, bgView.bottom+40, kScreenWidth-74,IS_IPAD?48:35)];
    clearBtn.backgroundColor = [UIColor systemColor];
    [clearBtn setTitle:@"清除缓存" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    clearBtn.layer.cornerRadius = 6.0;
    clearBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
    [clearBtn addTarget:self action:@selector(clearCacheAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
    
    UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectZero];
    tipsLab.font = [UIFont regularFontWithSize:12.0f];
    tipsLab.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
    tipsLab.numberOfLines = 0;
    tipsLab.text = @"清除本地缓存数据，只会移除所有媒体文件。在需要的时候所有内容将会重新从服务器下载";
    CGFloat labH = [tipsLab.text boundingRectWithSize:CGSizeMake(kScreenWidth-74, CGFLOAT_MAX) withTextFont:tipsLab.font].height;
    tipsLab.frame = CGRectMake(37, clearBtn.bottom+20, kScreenWidth-74, labH);
    [self.view addSubview:tipsLab];
}


#pragma mark 加载缓存信息
-(void)loadCacheData{
    CGFloat cacheSize = [[HomeworkManager sharedHomeworkManager] getTotalCacheSize];
    cacheCountLabel.text = [NSString stringWithFormat:@"%.1fM",cacheSize];
}


@end
