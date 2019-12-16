//
//  UserInfoViewController.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "UserInfoViewController.h"
#import "BRPickerView.h"
#import "AddressPickerView.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSArray  *titlesArr;
}

@property (nonatomic,strong) UITableView *userTableView;

@property (nonatomic,strong) UIImageView *headImgView;

@property (nonatomic,strong) NSMutableArray *userArray;

@property (nonatomic,strong) UITextField *nameTextField;
@property (nonatomic,assign) BOOL isSettingNickname;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"个人资料";
    
    titlesArr = @[@"头像",@"姓名",@"地区",@"年级"];
    
    [self.view addSubview:self.userTableView];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = titlesArr[indexPath.row];
    cell.textLabel.font = [UIFont regularFontWithSize:16.0f];
    if (indexPath.row==0) {
        self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-(IS_IPAD?100:83), 20,IS_IPAD?60:46,IS_IPAD?60:46)];
        if (kIsEmptyString(self.user.cover)) {
            [self.headImgView setImage:[UIImage imageNamed:@"my_default_head"]];
        }else{
            [self.headImgView sd_setImageWithURL:[NSURL URLWithString:self.user.cover] placeholderImage:[UIImage imageNamed:@"my_default_head"]];
        }
        [self.headImgView setBorderWithCornerRadius:IS_IPAD?30:23 type:UIViewCornerTypeAll];
        [cell.contentView addSubview:self.headImgView];
    }else if (indexPath.row==1){
        cell.detailTextLabel.text = self.user.name;
    }else if (indexPath.row==2){
        cell.detailTextLabel.text =kIsEmptyString(self.user.province)?@"":[NSString stringWithFormat:@"%@ %@",self.user.province,self.user.city];
    }else{
        cell.detailTextLabel.text = self.user.grade;
    }
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#303030"];
    cell.detailTextLabel.font = [UIFont regularFontWithSize:16.0f];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return IS_IPAD?100:86;
    }else{
       return IS_IPAD?70:59;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [self addPhotoForView:self.userTableView];
    }else if (indexPath.row==1){
        [self modifyUserName];
    }else if (indexPath.row==2){
        [self setUserArea];
    }else{
        [self modifyUserGrade];
    }
}

#pragma mark UIImagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    curImage=[curImage cropImageWithSize:CGSizeMake(330, 330)];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:curImage, nil];
    NSMutableArray *encodeImageArr = [[HomeworkManager sharedHomeworkManager] imageDataProcessingWithImgArray:arr];
    NSString *encodeResult = [[HomeworkManager sharedHomeworkManager] getValueWithParams:encodeImageArr];

    [[HttpRequest sharedInstance] postWithURLString:kUploadPicAPI parameters:@{@"pic":encodeResult} success:^(id responseObject) {
        [HomeworkManager sharedHomeworkManager].isUpdateUserInfo = YES;
        self.user.cover = [responseObject objectForKey:@"data"];
        [self modifyUserInfoWithParams:@{@"token":kUserTokenValue,@"cover":self.user.cover}];
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
    
}

#pragma mmark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isFirstResponder]) {
        if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]) {
            return NO;
        }
        
        //判断键盘是不是九宫格键盘
        if ([[HomeworkManager sharedHomeworkManager] isNineKeyBoard:string] ){
            return YES;
        }else{
            if ([[HomeworkManager sharedHomeworkManager] hasEmoji:string] || [[HomeworkManager sharedHomeworkManager] strIsContainEmojiWithStr:string]){
                return NO;
            }
        }
    }
    
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.nameTextField==textField) {
        if ([textField.text length]<8) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event Response
#pragma mark 修改姓名
-(void)modifyUserName{
    NSString *title = NSLocalizedString(@"设置姓名", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入姓名"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate=self;
        self.nameTextField = textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    kSelfWeak;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *toBeString=alertController.textFields.firstObject.text;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"姓名不能为空" duration:1.0 position:CSToastPositionCenter];
        }else if (toBeString.length>8){
            [weakSelf.view makeToast:@"姓名仅支持1-8个字符" duration:1.0 position:CSToastPositionCenter];
        }else{
            self.user.name = toBeString;
            self.isSettingNickname = YES;
            [self modifyUserInfoWithParams:@{@"token":kUserTokenValue,@"name":self.user.name}];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 设置地区
-(void)setUserArea{
    AddressPickerView *addressPickerView = [[AddressPickerView alloc] init];
    if (!kIsEmptyString(self.user.province)&&!(kIsEmptyString(self.user.city))) {
        for (NSInteger i=0;i<addressPickerView.provinces.count;i++) {
            NSDictionary *dict = addressPickerView.provinces[i];
            if ([dict[@"state"] isEqualToString:self.user.province]) {
                addressPickerView.province = dict[@"state"];
                addressPickerView.cities = dict[@"cities"];
                [addressPickerView.myPickerView selectRow:i inComponent:0 animated:YES];
            }
        }
        for (NSInteger i=0; i<addressPickerView.cities.count; i++) {
            NSDictionary *cityDict = addressPickerView.cities[i];
            if ([cityDict[@"city"] isEqualToString:self.user.city]) {
                addressPickerView.city = cityDict[@"city"];
                [addressPickerView.myPickerView selectRow:i inComponent:1 animated:YES];
            }
        }
    }
    addressPickerView.getAddressCallBack = ^(NSString * _Nonnull province, NSString * _Nonnull city) {
        self.user.province = province;
        self.user.city = city;
        NSDictionary *params = @{@"token":kUserTokenValue,@"province":self.user.province,@"city":self.user.city};
        [self modifyUserInfoWithParams:params];
    };
    [self.view addSubview:addressPickerView];
}

#pragma mark 修改年级
-(void)modifyUserGrade{
    NSArray *grades = [HomeworkManager sharedHomeworkManager].grades;
    [BRStringPickerView showStringPickerWithTitle:@"选择年级" dataSource:grades defaultSelValue:self.user.grade isAutoSelect:NO resultBlock:^(id selectValue) {
        MyLog(@"年级：%@",selectValue);
        self.user.grade = selectValue;
        
        [NSUserDefaultsInfos putKey:kUserGrade andValue:self.user.grade];
        NSArray *grades = [HomeworkManager sharedHomeworkManager].grades;
        NSInteger gradeInt = [grades indexOfObject:self.user.grade]+1;
        [self modifyUserInfoWithParams:@{@"token":kUserTokenValue,@"grade":[NSNumber numberWithInteger:gradeInt]}];
    }];
}

#pragma mark -- Private Methods
#pragma mark 修改个人信息
-(void)modifyUserInfoWithParams:(NSDictionary *)params{
    [[HttpRequest sharedInstance] postWithURLString:kSetUserInfoAPI parameters:params success:^(id responseObject) {
        [HomeworkManager sharedHomeworkManager].isUpdateUserInfo = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userTableView reloadData];
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 个人资料
-(UITableView *)userTableView{
    if (!_userTableView) {
        _userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _userTableView.dataSource = self;
        _userTableView.delegate = self;
        _userTableView.tableFooterView = [[UIView alloc] init];
    }
    return _userTableView;
}


-(NSMutableArray *)userArray{
    if (!_userArray) {
        _userArray = [[NSMutableArray alloc] init];
    }
    return _userArray;
}

@end
