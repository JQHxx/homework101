//
//  GradeViewController.m
//  Homework
//
//  Created by vision on 2019/9/7.
//  Copyright © 2019 vision. All rights reserved.
//

#import "GradeViewController.h"
#import "AdvantageViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"

@interface GradeViewController (){
    NSMutableArray *tempBtnsArr;
    
}

@property (nonatomic,strong) UILabel    *titleLabel;
@property (nonatomic,strong) UIButton   *nextBtn;
@property (nonatomic,strong) NSArray    *gradesArr;
@property (nonatomic,assign) NSInteger  selectedGrade;

@end

@implementation GradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gradesArr = @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
    tempBtnsArr = [[NSMutableArray alloc] init];
    self.selectedGrade = 0;
    
    [self initGradeView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"选择年级"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"选择年级"];
}

#pragma mark -- Event response
#pragma mark 选择年级
-(void)chooseGradeAction:(UIButton *)sender{
    for (NSInteger i=0; i<tempBtnsArr.count; i++) {
        UIButton *btn = tempBtnsArr[i];
        if (sender.tag==i) {
            btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionLevel startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = [UIColor colorWithHexString:@"#EFF1F3"];
            [btn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
        }
    }
    self.selectedGrade = sender.tag+1;
    if (self.selectedGrade>0) {
        [self.nextBtn setImage:[UIImage drawImageWithName:@"landing_nextstep_2" size:self.nextBtn.size] forState:UIControlStateNormal];
        self.nextBtn.userInteractionEnabled = YES;
    }
}

#pragma mark 下一步
-(void)gradeForNextStepAction:(UIButton *)sender{
    [[HttpRequest sharedInstance] postWithURLString:kSetUserInfoAPI parameters:@{@"token":kUserTokenValue,@"grade":[NSNumber numberWithInteger:self.selectedGrade]} success:^(id responseObject) {
        [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
        [NSUserDefaultsInfos putKey:kUserGrade andValue:self.gradesArr[self.selectedGrade-1]];
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
            if (paySwitch) {
                AppDelegate *appDelegate = kAppDelegate;
                MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
                appDelegate.window.rootViewController = myTabbarVC;
                myTabbarVC.selectedIndex = 1;
            }else{
                AdvantageViewController *advantageVC = [[AdvantageViewController alloc] init];
                advantageVC.grade = self.gradesArr[self.selectedGrade-1];
                advantageVC.webTitle = @"优势介绍";
                advantageVC.urlStr = kAdvantageIntroUrl;
                [self.navigationController pushViewController:advantageVC animated:YES];
            }
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initGradeView{
    [self.view addSubview:self.titleLabel];
    
    NSArray *titles  = @[@"小学",@"初中"];
    for (NSInteger i=0; i<titles.count; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(40, self.titleLabel.bottom+38+i*(IS_IPAD?174:162), 3,IS_IPAD?20:14)];
        line.backgroundColor = [UIColor colorWithHexString:@"#FF4757"];
        [line setBorderWithCornerRadius:1.5 type:UIViewCornerTypeAll];
        [self.view addSubview:line];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(line.right+6, self.titleLabel.bottom+35+i*(IS_IPAD?177:165), 120,IS_IPAD?30:20)];
        lab.text = titles[i];
        lab.textColor = [UIColor colorWithHexString:@"#303030"];
        lab.font = [UIFont mediumFontWithSize:16.0f];
        [self.view addSubview:lab];
    }
    
    CGFloat btnW = (kScreenWidth-80-2*19)/3.0;
    
    for (NSInteger i=0; i<self.gradesArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i<6) {
            btn.frame = CGRectMake(40+(i%3)*(btnW+19), self.titleLabel.bottom+74+(i/3)*(IS_IPAD?68:56), btnW,IS_IPAD?50:38);
        }else{
            btn.frame = CGRectMake(40+(i%3)*(btnW+19), self.titleLabel.bottom+(IS_IPAD?268:240), btnW,IS_IPAD?50:38);
        }
        btn.tag = i;
        btn.titleLabel.font = [UIFont regularFontWithSize:16.0f];
        [btn setTitle:self.gradesArr[i] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithHexString:@"#EFF1F3"];
        [btn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
        btn.layer.cornerRadius = IS_IPAD?25:19.0;
        [btn addTarget:self action:@selector(chooseGradeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        [tempBtnsArr addObject:btn];
    }
    
    [self.view addSubview:self.nextBtn];
    
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, kNavHeight+33, kScreenWidth-80,IS_IPAD?42:30)];
        _titleLabel.font = [UIFont mediumFontWithSize:24.0f];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _titleLabel.text = @"请选择年级";
    }
    return _titleLabel;
}


#pragma mark 下一步
-(UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-130, kScreenHeight-220, 100, 100):CGRectMake(kScreenWidth-85, kScreenHeight-128, 60, 60)];
        [_nextBtn setImage:[UIImage drawImageWithName:@"landing_nextstep_1" size:_nextBtn.size] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(gradeForNextStepAction:) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.userInteractionEnabled = NO;
    }
    return _nextBtn;
}



@end
