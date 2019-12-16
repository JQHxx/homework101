//
//  LogoutViewController.m
//  Homework
//
//  Created by vision on 2019/10/24.
//  Copyright © 2019 vision. All rights reserved.
//

#import "LogoutViewController.h"
#import "LogoutSuccessViewController.h"
#import "CustomReminderView.h"

@interface LogoutViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UILabel     *titleLab;
@property (nonatomic,strong) UILabel     *phoneLab;
@property (nonatomic,strong) UITextField *phoneTextField;
@property (nonatomic,strong) UILabel     *codeLab;
@property (nonatomic,strong) UITextField *codeTextFiled;
@property (nonatomic,strong) UIButton    *getCodeBtn;
@property (nonatomic,strong) UIButton    *confirmBtn;


@end

@implementation LogoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLogoutView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"注销账号"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"注销账号"];
}

#pragma mark -- Event Response
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
                    [self.getCodeBtn setTitleColor:[UIColor colorWithHexString:@"#FF7568"] forState:UIControlStateNormal];
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

#pragma mark 确定注销
-(void)confirmLogoutAction:(UIButton *)sender{
    if (kIsEmptyString(self.phoneTextField.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (kIsEmptyString(self.codeTextFiled.text)) {
        [self.view makeToast:@"验证码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSDictionary *info = @{@"title":@"注销账号",@"tips":@"注销账号，将清除您在平台上的一切信息。确定注销吗？",@"cancel":@"取消",@"confirm":@"确定注销"};
    [CustomReminderView showReminderViewWithFrame:CGRectMake(0, 0, 285, 200) info:info confirmAction:^{
        NSDictionary *params = @{@"token":kUserTokenValue,@"mobile":self.phoneTextField.text,@"code":self.codeTextFiled.text};
        [[HttpRequest sharedInstance] postWithURLString:kLogoutAPI parameters:params success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LogoutSuccessViewController *logoutSuccessVC = [[LogoutSuccessViewController alloc] init];
                [self.navigationController pushViewController:logoutSuccessVC animated:YES];
            });
        } failure:^(NSString *errorStr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
            });
        }];
    }];
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
-(void)initLogoutView{
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.phoneLab];
    [self.view addSubview:self.phoneTextField];
    UIView * underLine1 = [[UIView alloc] initWithFrame:CGRectMake(26,self.phoneTextField.bottom+6,kScreenWidth-52,1)];
    underLine1.backgroundColor = [UIColor colorWithHexString:@"#DCDEE5"];
    [self.view addSubview:underLine1];
    
    [self.view addSubview:self.codeLab];
    [self.view addSubview:self.codeTextFiled];
    UIView * underLine2 = [[UIView alloc] initWithFrame:CGRectMake(26,self.codeTextFiled.bottom+6,kScreenWidth-(IS_IPAD?200:175),1)];
    underLine2.backgroundColor = [UIColor colorWithHexString:@"#DCDEE5"];
    [self.view addSubview:underLine2];
    
    [self.view addSubview:self.getCodeBtn];
    [self.view addSubview:self.confirmBtn];
}

#pragma mark -- Getters
#pragma mark title
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(40,kNavHeight+33, 160,IS_IPAD?36:24)];
        _titleLab.textColor = [UIColor commonColor_black];
        _titleLab.font = [UIFont mediumFontWithSize:24];
        _titleLab.text = @"注销账号";
    }
    return _titleLab;
}

#pragma mark 手机号
-(UILabel *)phoneLab{
    if (!_phoneLab) {
        _phoneLab = [[UILabel alloc] initWithFrame:CGRectMake(40,self.titleLab.bottom+35, 160,IS_IPAD?32:20)];
        _phoneLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _phoneLab.font = [UIFont regularFontWithSize:15];
        _phoneLab.text = @"手机号码";
    }
    return _phoneLab;
}

-(UITextField *)phoneTextField{
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, self.phoneLab.bottom+8, kScreenWidth-160,IS_IPAD?52:40)];
        _phoneTextField.placeholder = @"请输入手机号码";
        _phoneTextField.textColor = [UIColor commonColor_black];
        _phoneTextField.font = [UIFont mediumFontWithSize:20.0f];
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.delegate = self;
    }
    return _phoneTextField;
}

#pragma mark 验证码
-(UILabel *)codeLab{
    if (!_codeLab) {
        _codeLab = [[UILabel alloc] initWithFrame:CGRectMake(40,self.phoneTextField.bottom+25, 160,IS_IPAD?32:20)];
        _codeLab.textColor = [UIColor colorWithHexString:@"#9495A0"];
        _codeLab.font = [UIFont regularFontWithSize:15];
        _codeLab.text = @"验证码";
    }
    return _codeLab;
}

-(UITextField *)codeTextFiled{
    if (!_codeTextFiled) {
        _codeTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(40, self.codeLab.bottom+8, kScreenWidth-200,IS_IPAD?52:40)];
        _codeTextFiled.placeholder = @"6位验证码";
        _codeTextFiled.textColor = [UIColor commonColor_black];
        _codeTextFiled.font = [UIFont mediumFontWithSize:20.0f];
        _codeTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        _codeTextFiled.delegate = self;
    }
    return _codeTextFiled;
}

#pragma mark 获取验证码
-(UIButton *)getCodeBtn{
    if (!_getCodeBtn) {
        _getCodeBtn = [[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-150, self.codeLab.bottom+10, 125, 52):CGRectMake(kScreenWidth-125, self.codeLab.bottom+10, 100, 40)];
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

#pragma mark 确定
-(UIButton *)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-300)/2.0,kScreenHeight-85, 300, 62)];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        [self.confirmBtn addTarget:self action:@selector(confirmLogoutAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

@end
