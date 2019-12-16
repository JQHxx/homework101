//
//  ExperienceBuyViewController.m
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ExperienceBuyViewController.h"
#import "BuySuccessViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"
#import "GuideExpModel.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MXActionSheet.h"


#define kBtnWidth (kScreenWidth-80-19*2)/3.0

@interface ExperienceBuyViewController (){
    UIButton  *selBtn;
}

@property (nonatomic,strong) UIButton    *timeBtn;
@property (nonatomic,strong) UIButton    *buyBtn;

@property (nonatomic,strong) GuideExpModel *expModel;

@property (nonatomic,assign) NSInteger   subjectInt;

@end

@implementation ExperienceBuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subjectInt = 1;
    
    [self initExperienceBuyView];
    [self loadGuideExpData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     [MobClick beginLogPageView:@"体验购买"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccessAction) name:kPayBackNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"体验购买"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPayBackNotification object:nil];
}

#pragma mark -- event response
#pragma mark 选择科目
-(void)chooseSubjectAction:(UIButton *)sender{
    if (selBtn) {
        selBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
        [selBtn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
    }
    sender.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(kBtnWidth, 38) direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    selBtn = sender;
    
    self.subjectInt = selBtn.tag+1;
    
}

#pragma mark 购买
-(void)buyAction:(UIButton *)sender{
    NSArray *buttonTitles = @[@"支付宝支付",@"微信支付"];
    NSNumber *userId = [NSUserDefaultsInfos getValueforKey:kUserId];
    
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:buttonTitles selectedBlock:^(NSInteger index) {
        if (index==1) {
             [MobClick event:@"__submit_payment" attributes:@{@"userid":userId,@"orderid":[NSNumber numberWithInteger:self.subjectInt],@"item":@"体验购买",@"amount":self.expModel.price}];
            NSDictionary *params = @{@"token":kUserTokenValue, @"cate":@1,@"subject":[NSNumber numberWithInteger:self.subjectInt],@"from":@"ios",@"money":self.expModel.price,@"discounts_id":self.expModel.id};
            [[HttpRequest sharedInstance] postWithURLString:kExperiencePayAPI parameters:params success:^(id responseObject) {
                NSString *payInfo =[responseObject objectForKey:@"data"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                        NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                        if (resultStatus==9000) {
                            MyLog(@"支付成功");
                            //[self paySuccessAction];
                        }else{
                            NSString *memo=[resultDic valueForKey:@"memo"];
                            MyLog(@"resultDic:%@,alipay--error:%@",resultDic,memo);
                        }
                    }];
                });
            }failure:^(NSString *errorStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                });
            }];
        }else if (index==2){
             [MobClick event:@"__submit_payment" attributes:@{@"userid":userId,@"orderid":[NSNumber numberWithInteger:self.subjectInt],@"item":@"体验购买",@"amount":self.expModel.price}];
            NSDictionary *params= @{@"token":kUserTokenValue,@"cate":@2,@"subject":[NSNumber numberWithInteger:self.subjectInt],@"from":@"ios",@"money":self.expModel.price,@"discounts_id":self.expModel.id};
            [[HttpRequest sharedInstance] postWithURLString:kExperiencePayAPI parameters:params success:^(id responseObject) {
                NSDictionary *payInfo = [responseObject objectForKey:@"data"];
                PayReq* req             = [[PayReq alloc] init];
                req.openID              = [payInfo valueForKey:@"appid"];
                req.partnerId           = [payInfo valueForKey:@"partnerid"];
                req.prepayId            = [payInfo valueForKey:@"prepayid"];
                req.nonceStr            = [payInfo valueForKey:@"noncestr"];
                req.timeStamp           = [[payInfo valueForKey:@"timestamp"] intValue];
                req.package             = [payInfo valueForKey:@"package"];
                req.sign                = [payInfo valueForKey:@"sign"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [WXApi sendReq:req];
                });
            }failure:^(NSString *errorStr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
                });
            }];
        }
    }];
}

#pragma mark 先看看
-(void)seeAction:(UIButton *)sender{
    AppDelegate *appDelegate = kAppDelegate;
    MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
    appDelegate.window.rootViewController = myTabbarVC;
    myTabbarVC.selectedIndex = 1;
}

#pragma mark NSNotification
-(void)paySuccessAction{
    NSNumber *userId = [NSUserDefaultsInfos getValueforKey:kUserId];
    [MobClick event:@"__finish_payment" attributes:@{@"userid":userId,@"orderid":[NSNumber numberWithInteger:self.subjectInt],@"item":@"体验购买",@"amount":self.expModel.price}];
    
    BuySuccessViewController *buySuccessVC = [[BuySuccessViewController alloc] init];
    buySuccessVC.isExpBuyIn = YES;
    buySuccessVC.subject = self.subjectInt;
    [self.navigationController pushViewController:buySuccessVC animated:YES];
}

#pragma mark -- Private methos
#pragma mark 加载体验购买数据
-(void)loadGuideExpData{
    [[HttpRequest sharedInstance] postWithURLString:kGuideExpPageAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        [self.expModel setValues:data];
        [self setGuideExpTimeAndPrice];
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 体验购买
-(void)initExperienceBuyView{
    UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, kNavHeight+33, kScreenWidth-80, IS_IPAD?36:24)];
    titleLabel.font = [UIFont mediumFontWithSize:IS_IPHONE_5?20.0f:24.0f];
    titleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    titleLabel.text = [NSString stringWithFormat:@"%@家教辅导优惠体验",self.selGrade];
    [self.view addSubview:titleLabel];
    
    //科目
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(40, titleLabel.bottom+24, 3, 13)];
    bgView.backgroundColor = [UIColor commonColor_red];
    [self.view addSubview:bgView];
    
    UILabel  *subjectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView.right+6, titleLabel.bottom+22,160,IS_IPAD?30:17)];
    subjectTitleLabel.font = [UIFont mediumFontWithSize:16.0f];
    subjectTitleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    subjectTitleLabel.text = @"需要辅导的科目";
    [self.view addSubview:subjectTitleLabel];
    
    NSArray *btnsArr = [[HomeworkManager sharedHomeworkManager] getCourseForGrade:self.selGrade];
    for (NSInteger i=0; i<btnsArr.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40+(i%3)*(kBtnWidth+19), subjectTitleLabel.bottom+18+(i/3)*((IS_IPAD?50:38)+18), kBtnWidth,IS_IPAD?50:38)];
        btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#F8F9FA"] endColor:[UIColor colorWithHexString:@"#EFF1F3"]];
        [btn setTitle:btnsArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#9C9DA8"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularFontWithSize:16.0f];
        btn.layer.cornerRadius = IS_IPAD?25.0f:19.0f;
        if (i==0) {
            btn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:btn.size direction:IHGradientChangeDirectionVertical startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            selBtn = btn;
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(chooseSubjectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    CGFloat btnHeight = subjectTitleLabel.bottom+((IS_IPAD?50:38)+18)*(btnsArr.count/3);
    
    //体验时间
    UIView *bgView1 = [[UIView alloc] initWithFrame:CGRectMake(40,btnHeight+25, 3, 13)];
    bgView1.backgroundColor = [UIColor commonColor_red];
    [self.view addSubview:bgView1];
    
    UILabel  *timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView1.right+6, btnHeight+23,  kScreenWidth-80,IS_IPAD?30:17)];
    timeTitleLabel.font = [UIFont mediumFontWithSize:16.0f];
    timeTitleLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    timeTitleLabel.text = @"体验时间";
    [self.view addSubview:timeTitleLabel];
    
    self.timeBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-143)/2.0, timeTitleLabel.bottom+15, 143, 123)];
    [self.timeBtn setBackgroundImage:[UIImage imageNamed:@"landing_discount_time"] forState:UIControlStateNormal];
    self.timeBtn.titleLabel.font = [UIFont mediumFontWithSize:32.0f];
    self.timeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [self.view addSubview:self.timeBtn];
    self.timeBtn.hidden = YES;
    
    self.buyBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-324)/2.0, kScreenHeight-82, 254, 63)];
    [self.buyBtn setBackgroundImage:[UIImage imageNamed:@"landing_discount_price"] forState:UIControlStateNormal];
    self.buyBtn.titleLabel.font = [UIFont mediumFontWithSize:20.0f];
    [self.buyBtn addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
    self.buyBtn.titleEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    [self.view addSubview:self.buyBtn];
    self.buyBtn.hidden = YES;
    
    UIButton *seebBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.buyBtn.right+12, kScreenHeight-60, 48, 20)];
    seebBtn.titleLabel.font = [UIFont regularFontWithSize:15.0f];
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:@"先看看" attributes:attribtDic];
    [attribtStr addAttribute:NSForegroundColorAttributeName value:[UIColor commonColor_red] range:NSMakeRange(0, 3)];
    [seebBtn setAttributedTitle:attribtStr forState:UIControlStateNormal];
    [seebBtn addTarget:self action:@selector(seeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:seebBtn];

}

#pragma mark 设置时间和价格
-(void)setGuideExpTimeAndPrice{
    self.timeBtn.hidden = self.buyBtn.hidden = NO;
    //时间
    NSString *timeStr = [NSString stringWithFormat:@"%ld天",[self.expModel.vip_time integerValue]];
    NSMutableAttributedString *timeAttrStr = [[NSMutableAttributedString alloc] initWithString:timeStr];
    [timeAttrStr addAttribute:NSFontAttributeName value:[UIFont mediumFontWithSize:74] range:NSMakeRange(0, timeStr.length-1)];
    [timeAttrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, timeStr.length)];
    
    //优惠价
    NSString *str = [NSString stringWithFormat:@"体验价 ¥%.2f 已优惠¥%.2f",[self.expModel.price doubleValue],[self.expModel.best_prices doubleValue]];
    NSRange aRange = [str rangeOfString:@"已"];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont regularFontWithSize:13.0f] range:NSMakeRange(aRange.location,str.length-aRange.location)];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, str.length)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeBtn setAttributedTitle:timeAttrStr forState:UIControlStateNormal];
        [self.buyBtn setAttributedTitle:attributedStr forState:UIControlStateNormal];
    });
}

-(GuideExpModel *)expModel{
    if (!_expModel) {
        _expModel = [[GuideExpModel alloc] init];
    }
    return _expModel;
}

@end
