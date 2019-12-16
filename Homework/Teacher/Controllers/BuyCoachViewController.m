//
//  BuyCoachViewController.m
//  Homework
//
//  Created by vision on 2019/9/17.
//  Copyright © 2019 vision. All rights reserved.
//

#import "BuyCoachViewController.h"
#import "CoachCouponViewController.h"
#import "BuySuccessViewController.h"
#import "SelCouponsView.h"
#import "TeacherHeadView.h"
#import "CoachTypeButton.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MXActionSheet.h"
#import "QWAlertView.h"
#import "CoachCouponModel.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define kPriceBtnWidth (kScreenWidth-24)/3.0

@interface BuyCoachViewController ()<SelCouponsViewDelegate>{
    CoachTypeButton  *selectedBtn;
    
    UILabel          *payPriceLab;
    UIButton         *payBtn;
}

@property (nonatomic,strong) UIImageView     *bgImgView;
@property (nonatomic,strong) UIView          *navbarView;
@property (nonatomic,strong) TeacherHeadView *headView;
@property (nonatomic,strong) UIView          *typeView;
@property (nonatomic,strong) UILabel         *typeLabel;
@property (nonatomic,strong) UILabel         *descLabel;
@property (nonatomic,strong) UIImageView     *arrowImgView;
@property (nonatomic,strong) UIButton        *receiveButton; //领取优惠券

@property (nonatomic,strong) UIButton         *selCouponButton; //选择优惠券

@property (nonatomic,strong) UIView          *bottomView; //底部视图

@property (nonatomic,strong) SelCouponsView  *couponView;

@property (nonatomic,strong) NSMutableArray   *typesArr;
@property (nonatomic,strong) CoachTypeModel   *selTypeModel;

@property (nonatomic,strong) CoachCouponModel   *selCouponModel;

@end

@implementation BuyCoachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"购买辅导";
    self.rightImageName = @"tutor_service";
    
    [self initBuyCoachView];
    [self loadCoachPriceInfo];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccessAction) name:kPayBackNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPayBackNotification object:nil];
}

#pragma mark -- Event response
#pragma mark 联系客服
-(void)rightNavigationItemAction{
    [self pushToCustomerServiceVC];
}

#pragma mark 选择辅导类型
-(void)selectCoachTypeAction:(CoachTypeButton *)sender{
    if (selectedBtn) {
        selectedBtn.btnHasSelected = NO;
    }
    sender.btnHasSelected = YES;
    selectedBtn = sender;
    
    self.selTypeModel = self.typesArr[sender.tag];
    
    [self.selCouponButton setTitle:@"选择优惠券" forState:UIControlStateNormal];
    self.selCouponButton.selected = NO;
    self.selCouponModel = [[CoachCouponModel alloc] init];
    
    [self updateCoachPriceAndType];
}

#pragma mark 领取辅导优惠券
-(void)receiveCoachCouponAction:(UIButton *)sender{
    CoachCouponViewController *coachCouponVC = [[CoachCouponViewController alloc] init];
    coachCouponVC.isTeacherIn = YES;
    [self.navigationController pushViewController:coachCouponVC animated:YES];
}

#pragma mark 选择优惠券
-(void)selectCouponsAction:(UIButton *)sender{
    [[HttpRequest sharedInstance] postWithURLString:kChooseCouponAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSArray *list = [data valueForKey:@"list"];
        if (list.count>0) {
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in list) {
                CoachCouponModel *model = [[CoachCouponModel alloc] init];
                [model setValues:dict];
                model.isSelected = [NSNumber numberWithBool:NO];
                [tempArr addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.couponView.selCouponModel = self.selCouponModel;
                self.couponView.couponsArray = tempArr;
                [[QWAlertView sharedMask] show:self.couponView withType:QWAlertViewStyleAlert];
            });
        }else{
           dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"无可用优惠券" duration:1.0 position:CSToastPositionCenter];
            });
        }
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark SelCouponsViewDelegate
#pragma mark 确定
-(void)selCouponsViewDidSelectCoupon:(CoachCouponModel *)selCoupon{
    [[QWAlertView sharedMask] dismiss];
    
    self.selCouponModel = selCoupon;
    
    NSString *titleStr = [NSString stringWithFormat:@"使用优惠券-%@",self.selCouponModel.cost];
    [self.selCouponButton setTitle:titleStr forState:UIControlStateNormal];
    self.selCouponButton.selected = YES;
}

#pragma mark 关闭
-(void)selCouponsViewCloseAction{
    [[QWAlertView sharedMask] dismiss];
}


#pragma mark 立即购买
-(void)payAction:(UIButton *)sender{
    [MobClick event:kStaticsBuyNowEvent];
    NSNumber *userId = [NSUserDefaultsInfos getValueforKey:kUserId];
    
    NSArray *buttonTitles = @[@"支付宝支付",@"微信支付"];
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:buttonTitles selectedBlock:^(NSInteger index) {
        if (index==1) {
            [MobClick event:@"__submit_payment" attributes:@{@"userid":userId,@"orderid":self.selTypeModel.o_id,@"item":self.teacher.name,@"amount":self.selTypeModel.price}];
            NSDictionary *params;
            if ([self.selCouponModel.id integerValue]>0) {
                params = @{@"token":kUserTokenValue,@"t_id":self.teacher.t_id, @"cate":@1,@"guide_id":self.selTypeModel.o_id,@"from":@"ios",@"money":self.selTypeModel.price,@"cash_id":self.selCouponModel.id,@"type":self.isInviteBuy?@2:@1};
            }else{
                params = @{@"token":kUserTokenValue,@"t_id":self.teacher.t_id, @"cate":@1,@"guide_id":self.selTypeModel.o_id,@"from":@"ios",@"money":self.selTypeModel.price,@"type":self.isInviteBuy?@2:@1};
            }
            [[HttpRequest sharedInstance] postWithURLString:kGuidePayAPI parameters:params success:^(id responseObject) {
                NSString *payInfo =[responseObject objectForKey:@"data"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                        NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                        if (resultStatus==9000) {
                            MyLog(@"支付成功");
                            [self paySuccessAction];
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
            [MobClick event:@"__submit_payment" attributes:@{@"userid":userId,@"orderid":self.selTypeModel.o_id,@"item":self.teacher.name,@"amount":self.selTypeModel.price}];
            NSDictionary *params;
            if ([self.selCouponModel.id integerValue]>0) {
                params= @{@"token":kUserTokenValue,@"cate":@2,@"t_id":self.teacher.t_id,@"guide_id":self.selTypeModel.o_id,@"from":@"ios",@"money":self.selTypeModel.price,@"cash_id":self.selCouponModel.id,@"type":self.isInviteBuy?@2:@1};
            }else{
                params= @{@"token":kUserTokenValue,@"cate":@2,@"t_id":self.teacher.t_id,@"guide_id":self.selTypeModel.o_id,@"from":@"ios",@"money":self.selTypeModel.price,@"type":self.isInviteBuy?@2:@1};
            }
            
            [[HttpRequest sharedInstance] postWithURLString:kGuidePayAPI parameters:params success:^(id responseObject) {
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

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initBuyCoachView{
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.navbarView];
    
    [self.view addSubview:self.headView];
    [self.view addSubview:self.typeView];
    [self.view addSubview:self.typeLabel];
    [self.view addSubview:self.descLabel];
    [self.view addSubview:self.arrowImgView];
    [self.view addSubview:self.receiveButton];
    
    [self.view addSubview:self.bottomView];
}

#pragma mark 加载辅导价格信息
-(void)loadCoachPriceInfo{
    [[HttpRequest sharedInstance] postWithURLString:kCoachPriceAPI parameters:@{@"pay_switch":[NSUserDefaultsInfos getValueforKey:kPaySwitch]} success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            CoachTypeModel *model = [[CoachTypeModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        self.typesArr = tempArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self creatCoachPriceView];
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 支付成功
-(void)paySuccessAction{
    NSNumber *userId = [NSUserDefaultsInfos getValueforKey:kUserId];
    [MobClick event:@"__finish_payment" attributes:@{@"userid":userId,@"orderid":self.selTypeModel.o_id,@"item":self.teacher.name,@"amount":self.selTypeModel.price}];
    
    [HomeworkManager sharedHomeworkManager].isUpdateHome = YES;
    [HomeworkManager sharedHomeworkManager].isUpdateChat = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        BuySuccessViewController *buySuccessVC = [[BuySuccessViewController alloc] init];
        buySuccessVC.myTeacher = self.teacher;
        [self.navigationController pushViewController:buySuccessVC animated:YES];
    });
}

#pragma mark 创建价格界面
-(void)creatCoachPriceView{
    for (NSInteger i=0;i<self.typesArr.count;i++) {
        CoachTypeButton *btn = [[CoachTypeButton alloc] initWithFrame:CGRectMake(10+(kPriceBtnWidth+2)*i, 0, kPriceBtnWidth,kPriceBtnWidth*(292.0/242.0))];
        btn.typeModel = self.typesArr[i];
        btn.tag = i;
        [btn addTarget:self action:@selector(selectCoachTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_typeView addSubview:btn];
        if (i==1) {
            btn.btnHasSelected = YES;
            selectedBtn = btn;
        }
    }
    self.selTypeModel = self.typesArr[1];
    [self updateCoachPriceAndType];
}

#pragma mark 更新价格/辅导类型
-(void)updateCoachPriceAndType{
    self.typeLabel.text = self.selTypeModel.name;
    self.descLabel.text = [NSString stringWithFormat:@"%@个月，不限次数辅导。\n老师定时在线，随问随答，快速解决学习问题。",self.selTypeModel.validity_month];
    
    payPriceLab.text = [NSString stringWithFormat:@"¥%.2f",[self.selTypeModel.price doubleValue]];
    CGFloat priceW = [payPriceLab.text boundingRectWithSize:CGSizeMake(kScreenWidth,IS_IPAD?38:26) withTextFont:payPriceLab.font].width;
    payPriceLab.frame = CGRectMake(20, 16, priceW,IS_IPAD?38: 26);
    
    self.couponView.o_id = self.selTypeModel.o_id;
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView  = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImgView.image = [UIImage imageNamed:@"buy_background"];
    }
    return _bgImgView;
}

#pragma mark 导航栏
-(UIView *)navbarView{
    if (!_navbarView) {
        _navbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
        UIButton *backBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(10, KStatusHeight+9, 50, 50):CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [backBtn setImage:[UIImage drawImageWithName:@"return_black"size:IS_IPAD?CGSizeMake(13, 23):CGSizeMake(10, 17)] forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navbarView addSubview:backBtn];
        
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-280)/2.0, KStatusHeight+16, 280, 36):CGRectMake((kScreenWidth-180)/2, KStatusHeight+12, 180, 22)];
        titleLabel.textColor=[UIColor commonColor_black];
        titleLabel.font=[UIFont mediumFontWithSize:18];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text = @"购买辅导";
        [_navbarView addSubview:titleLabel];
        
        UIButton *rightBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
        [rightBtn setImage:[UIImage drawImageWithName:@"tutor_service" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navbarView addSubview:rightBtn];
    }
    return _navbarView;
}

#pragma mark 老师信息
-(TeacherHeadView *)headView{
    if (!_headView) {
        _headView = [[TeacherHeadView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?120:90)];
        _headView.teacher = self.teacher;
    }
    return _headView;
}

#pragma mark
-(UIView *)typeView{
    if (!_typeView) {
        _typeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headView.bottom+10, kScreenWidth, kPriceBtnWidth*(292.0/242.0))];
    }
    return _typeView;
}

#pragma mark 辅导类型
-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.typeView.bottom+10, 120,IS_IPAD?32:20)];
        _typeLabel.textColor = [UIColor colorWithHexString:@"#303030"];
        _typeLabel.font = [UIFont mediumFontWithSize:18.0f];
    }
    return _typeLabel;
}

#pragma mark 描述
-(UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.typeLabel.bottom, kScreenWidth-60,IS_IPAD?100:80)];
        _descLabel.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _descLabel.font = [UIFont regularFontWithSize:14.0f];
        _descLabel.numberOfLines =0;
    }
    return _descLabel;
}

#pragma mark 箭头
-(UIImageView *)arrowImgView{
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-14)/2.0, self.descLabel.bottom+20, 14, 17)];
        _arrowImgView.image = [UIImage imageNamed:@"buy_arrow"];
    }
    return _arrowImgView;
}

#pragma mark 领取辅导优惠券
-(UIButton *)receiveButton{
    if (!_receiveButton) {
        _receiveButton = [[UIButton alloc] initWithFrame:CGRectMake(16, self.arrowImgView.bottom, kScreenWidth-32, (kScreenWidth-16)*(140.0/718.0))];
        _receiveButton.adjustsImageWhenDisabled = NO;
        _receiveButton.adjustsImageWhenHighlighted = NO;
        [_receiveButton setImage:[UIImage imageNamed:@"buy_get_coupons"] forState:UIControlStateNormal];
        [_receiveButton addTarget:self action:@selector(receiveCoachCouponAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _receiveButton;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-(IS_IPAD?70:58), kScreenWidth,IS_IPAD?70:58)];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"#F7F9FA"];
        
        payPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 16,IS_IPAD?140:(IS_IPHONE_5?70:90),IS_IPAD?38:26)];
        payPriceLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
        payPriceLab.font = [UIFont mediumFontWithSize:IS_IPHONE_5?18.0f:24.0f];
        payPriceLab.text = [NSString stringWithFormat:@"¥%.2f",0.0];
        [_bottomView addSubview:payPriceLab];
        
        self.selCouponButton = [[UIButton alloc] initWithFrame:CGRectMake(payPriceLab.right,20,IS_IPAD?180:130,IS_IPAD?38:26)];
        [self.selCouponButton setTitleColor:[UIColor colorWithHexString:@"#303030"] forState:UIControlStateNormal];
        self.selCouponButton.titleLabel.font = [UIFont regularFontWithSize:13.0f];
        [self.selCouponButton setTitle:@"选择优惠券" forState:UIControlStateNormal];
        [self.selCouponButton setImage:[UIImage imageNamed:@"coupon_gray"] forState:UIControlStateNormal];
        [self.selCouponButton setImage:[UIImage imageNamed:@"coupon_red"] forState:UIControlStateSelected];
        self.selCouponButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [self.selCouponButton addTarget:self action:@selector(selectCouponsAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:self.selCouponButton];
        
        
        payBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-180, 0, 180, 70):CGRectMake(kScreenWidth-(IS_IPHONE_5?100:122), 0, IS_IPHONE_5?100:122,58)];
        payBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:payBtn.size direction:IHGradientChangeDirectionUpwardDiagonalLine startColor:[UIColor colorWithHexString:@"#FF3737"] endColor:[UIColor colorWithHexString:@"#FF5777"]];
        [payBtn setTitle:@"立即购买" forState:UIControlStateNormal];
        [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        payBtn.titleLabel.font = [UIFont mediumFontWithSize:IS_IPHONE_5?16.0:20.0f];
        [payBtn addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:payBtn];
    }
    return _bottomView;
}

#pragma mark 优惠券
-(SelCouponsView *)couponView{
    if (!_couponView) {
        _couponView = [[SelCouponsView alloc] initWithFrame:IS_IPAD?CGRectMake(0, 0,600, 640):CGRectMake(0,0,285,380)];
        [_couponView setBorderWithCornerRadius:8 type:UIViewCornerTypeAll];
        _couponView.viewDelegate = self;
    }
    return _couponView;
}


-(NSMutableArray *)typesArr{
    if (!_typesArr) {
        _typesArr = [[NSMutableArray alloc] init];
    }
    return _typesArr;
}

-(CoachTypeModel *)selTypeModel{
    if (!_selTypeModel) {
        _selTypeModel = [[CoachTypeModel alloc] init];
    }
    return _selTypeModel;
}

-(CoachCouponModel *)selCouponModel{
    if (!_selCouponModel) {
        _selCouponModel = [[CoachCouponModel alloc] init];
    }
    return _selCouponModel;
}

@end
