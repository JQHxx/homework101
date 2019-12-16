//
//  BaseViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomerServiceViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "MXActionSheet.h"

@interface BaseViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>{
    UIView        *navView;
    UIButton      *backBtn;
    UILabel       *titleLabel;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.interactivePopGestureRecognizer.enabled=YES;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self customNavBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!kIsEmptyString(self.baseTitle)) {
        [MobClick beginLogPageView:self.baseTitle];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
    if (!kIsEmptyString(self.baseTitle)) {
        [MobClick endLogPageView:self.baseTitle];
    }
    
    [SVProgressHUD dismiss];
}

#pragma mark 状态栏样式
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark -- Delegate
#pragma mark  UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Event response
#pragma mark 左侧返回方法
-(void)leftNavigationItemAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 导航栏右侧按钮事件
-(void)rightNavigationItemAction{
    
}


#pragma mark --Private Methods
#pragma mark 自定义导航栏
-(void)customNavBar{
    navView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    
    backBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(10, KStatusHeight+9, 50, 50):CGRectMake(5,KStatusHeight + 2, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"return_black"size:IS_IPAD?CGSizeMake(13, 23):CGSizeMake(12, 18)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    titleLabel =[[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake((kScreenWidth-280)/2.0, KStatusHeight+16, 280, 36):CGRectMake((kScreenWidth-180)/2, KStatusHeight+12, 180, 22)];
    titleLabel.textColor=[UIColor commonColor_black];
    titleLabel.font=[UIFont mediumFontWithSize:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    
    self.rightBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
    [self.rightBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:self.rightBtn];
}

#pragma mark  上传照片
-(void)addPhotoForView:(UIView *)view {
    NSArray *buttonTitles = @[@"拍照",@"从手机相册选择",];
    [MXActionSheet showWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:buttonTitles selectedBlock:^(NSInteger index) {
         self.imgPicker=[[UIImagePickerController alloc]init];
         self.imgPicker.delegate=self;
         self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        if (index==1) {
           if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) //判断设备相机是否可用
           {
               self.imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
               [self presentViewController:self.imgPicker animated:YES completion:nil];
           }else{
               [self.view makeToast:@"您的相机不可用" duration:1.0 position:CSToastPositionCenter];
               return ;
           }
        }else if (index==2){
            self.imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imgPicker animated:YES completion:nil];
        }
        
    }];
}

#pragma mark  跳转到联系客服
-(void)pushToCustomerServiceVC{
    CustomerServiceViewController *serviceVC = [[CustomerServiceViewController alloc] init];
    serviceVC.conversationType = ConversationType_CUSTOMERSERVICE;
    serviceVC.targetId = kRCCustomerServiceID;
    RCCustomerServiceInfo *serviceInfo = [[RCCustomerServiceInfo alloc] init];
    NSString *name = [NSUserDefaultsInfos getValueforKey:kUserNickname];
    serviceInfo.name = kIsEmptyString(name)?[NSUserDefaultsInfos getValueforKey:kLoginPhone]:name;
    serviceInfo.portraitUrl = [NSUserDefaultsInfos getValueforKey:kUserHeadPic];
    serviceInfo.userId = [NSUserDefaultsInfos getValueforKey:kRongCloudID];
    serviceInfo.referrer = kRCChanelID;
    serviceVC.csInfo = serviceInfo;
    [self.navigationController pushViewController:serviceVC animated:YES];
}


#pragma mark -- setters and getters
#pragma mark 设置是否隐藏导航栏
-(void)setIsHiddenNavBar:(BOOL)isHiddenNavBar{
    _isHiddenNavBar = isHiddenNavBar;
    navView.hidden = isHiddenNavBar;
}

#pragma mark 设置是否隐藏返回按钮
-(void)setIsHiddenBackBtn:(BOOL)isHiddenBackBtn{
    _isHiddenBackBtn = isHiddenBackBtn;
    backBtn.hidden = isHiddenBackBtn;
}

#pragma makr 设置导航栏左侧按钮图片
-(void)setLeftImageName:(NSString *)leftImageName{
    _leftImageName=leftImageName;
    if (!kIsEmptyString(leftImageName)) {
        backBtn.hidden=NO;
        if ([_leftImageName isEqualToString:@"return"]) {
           [backBtn setImage:[UIImage drawImageWithName:_leftImageName size:IS_IPAD?CGSizeMake(13, 23):CGSizeMake(12, 18)] forState:UIControlStateNormal];
        }else{
          [backBtn setImage:[UIImage drawImageWithName:_leftImageName size:IS_IPAD?CGSizeMake(32, 32):CGSizeMake(24, 24)] forState:UIControlStateNormal];
        }
    }
}
#pragma mark 设置导航栏左侧按钮文字
- (void)setLeftTitleName:(NSString *)leftTitleName{
    _leftTitleName = leftTitleName;
    [backBtn setTitle:leftTitleName forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
    backBtn.titleLabel.font=[UIFont regularFontWithSize:16];
    backBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

#pragma mark 设置导航栏右侧按钮图片
-(void)setRightImageName:(NSString *)rightImageName{
    _rightImageName=rightImageName;
    if (!kIsEmptyString(rightImageName)) {
        [self.rightBtn setImage:[UIImage drawImageWithName:rightImageName size:IS_IPAD?CGSizeMake(34, 28):CGSizeMake(24, 20)] forState:UIControlStateNormal];
    }else{
        [self.rightBtn setImage:nil forState:UIControlStateNormal];
    }
}

-(void)setRightBtnWithImge:(NSString *)imgName imgSize:(CGSize)imageSize{
    if (!kIsEmptyString(imgName)) {
        [self.rightBtn setImage:[UIImage drawImageWithName:imgName size:imageSize] forState:UIControlStateNormal];
    }else{
        [self.rightBtn setImage:nil forState:UIControlStateNormal];
    }
}

#pragma mark 设置导航栏右侧按钮文字
-(void)setRigthTitleName:(NSString *)rigthTitleName{
    _rigthTitleName=rigthTitleName;
    self.rightBtn.enabled = !kIsEmptyString(rigthTitleName);
    
    [self.rightBtn setTitle:rigthTitleName forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor commonColor_black] forState:UIControlStateNormal];
    if (rigthTitleName.length>=4) {
        CGSize size = [rigthTitleName boundingRectWithSize:CGSizeMake(kScreenWidth, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:16]];
        self.rightBtn.frame = CGRectMake(kScreenWidth-size.width-10,KStatusHeight +5, size.width, 32);
    }
    self.rightBtn.titleLabel.font=[UIFont regularFontWithSize:16];
    self.rightBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
}

#pragma mark 设置标题
-(void)setBaseTitle:(NSString *)baseTitle{
    _baseTitle=baseTitle;
    titleLabel.text=baseTitle;
}

@end
