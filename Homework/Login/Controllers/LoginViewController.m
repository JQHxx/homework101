//
//  LoginViewController.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "LoginViewController.h"
#import "GradeViewController.h"
#import "BaseWebViewController.h"
#import "APPInfoManager.h"
#import <RongIMKit/RongIMKit.h>
#import "AppDelegate.h"
#import "MyTabBarController.h"
#import "LogoutReminderView.h"
#import <UMPush/UMessage.h>
#import "UserModel.h"

@interface LoginViewController ()<UITextFieldDelegate>{
    BOOL      phoneHasInput;
    BOOL      codeHasInput;
    BOOL      agreementHasSelected;
}

@property (nonatomic,strong) UILabel     *titleLab;
@property (nonatomic,strong) UILabel     *phoneLab;
@property (nonatomic,strong) UITextField *phoneTextField;
@property (nonatomic,strong) UILabel     *codeLab;
@property (nonatomic,strong) UITextField *codeTextFiled;
@property (nonatomic,strong) UIButton    *getCodeBtn;
@property (nonatomic,strong) UILabel     *tipslabel;
@property (nonatomic,strong) UIButton    *nextBtn;
@property (nonatomic,strong) UIButton    *agreeBtn;
@property (nonatomic,strong) UIButton    *serviceBtn;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    agreementHasSelected = YES;
    
    [self initLoginView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"登录"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"登录"];
}

#pragma mark -- Event Response
#pragma mark 监听文字输入
-(void)textFieldDidChange:(UITextField *)textField{
    if (textField==self.phoneTextField) {
        phoneHasInput = textField.text.length==11;
    }else{
        codeHasInput = textField.text.length==6;
    }
    
    if (phoneHasInput&&codeHasInput&&agreementHasSelected) {
        [self.nextBtn setImage:[UIImage drawImageWithName:@"landing_nextstep_2" size:_nextBtn.size] forState:UIControlStateNormal];
        self.nextBtn.userInteractionEnabled = YES;
    }else{
        [self.nextBtn setImage:[UIImage drawImageWithName:@"landing_nextstep_1" size:_nextBtn.size] forState:UIControlStateNormal];
        self.nextBtn.userInteractionEnabled = NO;
    }
}

#pragma mark 获取验证码
-(void)getVertifyCodeAction:(UIButton *)sender{
    if (kIsEmptyString(self.phoneTextField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSDictionary *paramsDict = @{@"mobile":self.phoneTextField.text};
    [[HttpRequest sharedInstance] postWithURLString:kGetCodeSign parameters:paramsDict success:^(id responseObject) {
        __block int timeout=60; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(timeout<=0){ //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                    [self.getCodeBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
                    self.getCodeBtn.userInteractionEnabled = YES;
                });
            }else{
                int seconds = timeout % 61;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [self.getCodeBtn setTitle:[NSString stringWithFormat:@"重新获取(%@s)",strTime] forState:UIControlStateNormal];
                    self.getCodeBtn.userInteractionEnabled = NO;
                });
                timeout--;
            }
        });
        dispatch_resume(_timer);
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 下一步
-(void)loginForNextStepAction:(UIButton *)sender{
    if (kIsEmptyString(self.phoneTextField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (kIsEmptyString(self.codeTextFiled.text)) {
        [self.view makeToast:@"验证码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSString *deviceId = [[APPInfoManager sharedAPPInfoManager] deviceIdentifier];
    NSString *versionStr = [[APPInfoManager sharedAPPInfoManager] appBundleVersion];
    NSDictionary *params = @{@"mobile":self.phoneTextField.text,@"code":self.codeTextFiled.text,@"platform":@"ios",@"deviceId":deviceId,@"version":versionStr};
    [[HttpRequest sharedInstance] postWithURLString:kLoginAPI parameters:params success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        BOOL isLogout = [[data valueForKey:@"state"] boolValue];
        if (isLogout) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [LogoutReminderView showReminderViewWithFrame:CGRectMake(0, 0, 285, 200)];
            });
        }else{
            UserModel *user = [[UserModel alloc] init];
            [user setValues:data];
            
            [NSUserDefaultsInfos putKey:kUserId andValue:user.s_id];
            [NSUserDefaultsInfos putKey:kUserToken andValue:user.token];
            [NSUserDefaultsInfos putKey:kPaySwitch andValue:user.pay_switch];
            
            if (!kIsEmptyString(user.cover)) {
                [NSUserDefaultsInfos putKey:kUserHeadPic andValue:user.cover];
            }
            if (!kIsEmptyString(user.name)) {
                [NSUserDefaultsInfos putKey:kUserNickname andValue:user.name];
            }
            
            if (!kIsEmptyString(user.third_token)) {
                [NSUserDefaultsInfos putKey:kRongCloudID andValue:user.third_id];
                [NSUserDefaultsInfos putKey:kRongCloudToken andValue:user.third_token];
                [[RCIM sharedRCIM] connectWithToken:user.third_token success:^(NSString *userId) {
                    MyLog(@"******************登录融云成功******************** userID：%@", userId);
                } error:^(RCConnectErrorCode status) {
                    MyLog(@"******************登录融云失败********************, error:%ld", status);
                } tokenIncorrect:^{
                    MyLog(@"******************token失效********************");
                }];
            }
            
            //绑定友盟推送别名
            NSString *tempStr = isTrueEnvironment?@"zs_new":@"cs_new";
            NSString *aliasStr=[NSString stringWithFormat:@"%@%@",tempStr,user.s_id];
            [UMessage setAlias:aliasStr type:kUMAlaisType response:^(id  _Nullable responseObject, NSError * _Nullable error) {
                if (error) {
                    MyLog(@"绑定别名失败，error:%@",error.localizedDescription);
                }else{
                    MyLog(@"绑定别名成功,result:%@",responseObject);
                }
            }];
            
            if (kIsEmptyString(user.grade)) {
                [MobClick event:@"__register" attributes:@{@"userid":user.s_id}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    GradeViewController *gradeVC = [[GradeViewController alloc] init];
                    [self.navigationController pushViewController:gradeVC animated:YES];
                });
            }else{
                [MobClick event:@"__login" attributes:@{@"userid":user.s_id}];
                [NSUserDefaultsInfos putKey:kUserGrade andValue:user.grade];
                [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *appDelegate = kAppDelegate;
                    MyTabBarController *myTabbarVC = [[MyTabBarController alloc] init];
                    appDelegate.window.rootViewController = myTabbarVC;
                });
            }
        }
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 选择协议
-(void)hasAgreementSelectedAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    agreementHasSelected = sender.selected;
}

#pragma mark  服务协议
-(void)choosesSrviceRulesAction:(UIButton *)sender{
    BaseWebViewController *webVC = [[BaseWebViewController alloc] init];
    webVC.urlStr = kUserAgreementURL;
    webVC.webTitle = @"服务协议";
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.phoneTextField resignFirstResponder];
    [self.codeTextFiled resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.phoneTextField == textField) {
        if ([textField.text length] < 11) {
            return YES;
        }
    }
    if (self.codeTextFiled == textField) {
        if ([textField.text length] < 6) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -- Private methods
#pragma mark 初始化
-(void)initLoginView{
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.phoneLab];
    [self.view addSubview:self.phoneTextField];
    UIView * underLine1 = [[UIView alloc] initWithFrame:CGRectMake(26,self.phoneTextField.bottom+6,kScreenWidth-52,1)];
    underLine1.backgroundColor = [UIColor colorWithHexString:@"#DCDEE5"];
    [self.view addSubview:underLine1];
    
    [self.view addSubview:self.codeLab];
    [self.view addSubview:self.codeTextFiled];
    UIView * underLine2 = [[UIView alloc] initWithFrame:CGRectMake(26,self.codeTextFiled.bottom+6,IS_IPAD?340:160,1)];
    underLine2.backgroundColor = [UIColor colorWithHexString:@"#DCDEE5"];
    [self.view addSubview:underLine2];
    
    [self.view addSubview:self.getCodeBtn];
    [self.view addSubview:self.tipslabel];
    [self.view addSubview:self.nextBtn];
    [self.view addSubview:self.agreeBtn];
    [self.view addSubview:self.serviceBtn];
}

#pragma mark -- Getters
#pragma mark title
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(40,kNavHeight+33, 160, IS_IPAD?36:24)];
        _titleLab.textColor = [UIColor commonColor_black];
        _titleLab.font = [UIFont mediumFontWithSize:24];
        _titleLab.text = @"验证码登录";
    }
    return _titleLab;
}

#pragma mark 手机号
-(UILabel *)phoneLab{
    if (!_phoneLab) {
        _phoneLab = [[UILabel alloc] initWithFrame:CGRectMake(40,self.titleLab.bottom+35, 160, IS_IPAD?30:20)];
        _phoneLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _phoneLab.font = [UIFont regularFontWithSize:15];
        _phoneLab.text = @"手机号码";
    }
    return _phoneLab;
}

-(UITextField *)phoneTextField{
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, self.phoneLab.bottom+8, kScreenWidth-160, IS_IPAD?50:40)];
        _phoneTextField.placeholder = @"请输入手机号码";
        _phoneTextField.textColor = [UIColor commonColor_black];
        _phoneTextField.font = [UIFont mediumFontWithSize:20.0f];
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.delegate = self;
        [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneTextField;
}

#pragma mark 验证码
-(UILabel *)codeLab{
    if (!_codeLab) {
        _codeLab = [[UILabel alloc] initWithFrame:CGRectMake(40,self.phoneTextField.bottom+25, 160, IS_IPAD?32:20)];
        _codeLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _codeLab.font = [UIFont regularFontWithSize:15];
        _codeLab.text = @"验证码";
    }
    return _codeLab;
}

-(UITextField *)codeTextFiled{
    if (!_codeTextFiled) {
        _codeTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(40, self.codeLab.bottom+8,IS_IPAD?300:122,IS_IPAD?50:40)];
        _codeTextFiled.placeholder = @"6位验证码";
        _codeTextFiled.textColor = [UIColor commonColor_black];
        _codeTextFiled.font = [UIFont mediumFontWithSize:20.0f];
        _codeTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        _codeTextFiled.delegate = self;
        [_codeTextFiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _codeTextFiled;
}

#pragma mark 获取验证码
-(UIButton *)getCodeBtn{
    if (!_getCodeBtn) {
        _getCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.codeTextFiled.right+40, self.codeLab.bottom+10,IS_IPAD?160:100,IS_IPAD?54:40)];
        [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCodeBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
        _getCodeBtn.layer.borderWidth = 1.0;
        _getCodeBtn.layer.borderColor = [UIColor commonColor_black].CGColor;
        _getCodeBtn.layer.cornerRadius = 4.0;
        _getCodeBtn.titleLabel.font = [UIFont regularFontWithSize:14.0f];
        
        [_getCodeBtn addTarget:self action:@selector(getVertifyCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getCodeBtn;
}

#pragma mark 提示
-(UILabel *)tipslabel{
    if (!_tipslabel) {
        _tipslabel  = [[UILabel alloc] initWithFrame:CGRectMake(40, self.codeTextFiled.bottom+15, IS_IPAD?300:180, IS_IPAD?30:20)];
        _tipslabel.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _tipslabel.font = [UIFont regularFontWithSize:12.0f];
        _tipslabel.text = @"新用户直接输入手机号码注册";
    }
    return _tipslabel;
}

#pragma mark 下一步
-(UIButton *)nextBtn{
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-130, kScreenHeight-220, 100, 100):CGRectMake(kScreenWidth-85, kScreenHeight-128, 60, 60)];
        [_nextBtn setImage:[UIImage drawImageWithName:@"landing_nextstep_1" size:_nextBtn.size] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(loginForNextStepAction:) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.userInteractionEnabled = NO;
    }
    return _nextBtn;
}

#pragma mark 服务协议
-(UIButton *)agreeBtn{
    if (!_agreeBtn) {
        NSString *str = @"我已阅读并同意《服务协议》";
        CGFloat btnW = [str boundingRectWithSize:CGSizeMake(kScreenWidth, IS_IPAD?30:20) withTextFont:[UIFont regularFontWithSize:12]].width;
        CGFloat tempW = [@"我已阅读并同意" boundingRectWithSize:CGSizeMake(kScreenWidth, IS_IPAD?30:20) withTextFont:[UIFont regularFontWithSize:12]].width;
        _agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-btnW)/2.0, kScreenHeight-55,tempW+30,IS_IPAD?30:20)];
        [_agreeBtn setImage:[UIImage drawImageWithName:@"landing_agreement_gray" size:IS_IPAD?CGSizeMake(20, 20):CGSizeMake(12, 12)] forState:UIControlStateNormal];
        [_agreeBtn setImage:[UIImage drawImageWithName:@"landing_agreement_red" size:IS_IPAD?CGSizeMake(20, 20):CGSizeMake(12, 12)] forState:UIControlStateSelected];
        [_agreeBtn setTitle:@"我已阅读并同意" forState:UIControlStateNormal];
        [_agreeBtn setTitleColor:[UIColor colorWithHexString:@"#6D6D6D"] forState:UIControlStateNormal];
        _agreeBtn.titleLabel.font = [UIFont regularFontWithSize:12.0f];
        _agreeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [_agreeBtn addTarget:self action:@selector(hasAgreementSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        _agreeBtn.selected = YES;
    }
    return _agreeBtn;
}

#pragma mark 服务协议
-(UIButton *)serviceBtn{
    if (!_serviceBtn) {
        NSString *str = @"《服务协议》";
        CGFloat btnW = [str boundingRectWithSize:CGSizeMake(kScreenWidth,IS_IPAD?30:20) withTextFont:[UIFont regularFontWithSize:12]].width;
        _serviceBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.agreeBtn.right, kScreenHeight-55, btnW, IS_IPAD?30:20)];
        [_serviceBtn setTitle:str forState:UIControlStateNormal];
        [_serviceBtn setTitleColor:[UIColor commonColor_red] forState:UIControlStateNormal];
        _serviceBtn.titleLabel.font = [UIFont regularFontWithSize:12.0f];
        [_serviceBtn addTarget:self action:@selector(choosesSrviceRulesAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _serviceBtn;
}


@end
