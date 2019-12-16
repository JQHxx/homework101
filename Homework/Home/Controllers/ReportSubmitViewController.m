//
//  ReportSubmitViewController.m
//  Homework
//
//  Created by vision on 2019/5/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ReportSubmitViewController.h"
#import "ChatViewController.h"
#import "PhotosCollectionViewCell.h"
#import "SDPhotoBrowser.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"
#import "UserInfoViewController.h"

#define kMaxPhotosCount  8
#define kImgHeight  (IS_IPHONE_5?(kScreenWidth-60)/3.0:(kScreenWidth-60)/4.0)

@interface ReportSubmitViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SDPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ChatViewControllerDelegate>

@property (nonatomic,strong) UIScrollView      *rootScrollView;
@property (nonatomic,strong) UILabel           *cateLabel;            //投诉类型
@property (nonatomic,strong) UIView            *chatView;         //聊天证据
@property (nonatomic,strong) UILabel           *chatValueLab;       //聊天证据条数
@property (nonatomic,strong) UILabel           *tipsLabel;            //图片说明
@property (nonatomic,strong) UILabel           *countLabel;            //图片数
@property (nonatomic,strong) UICollectionView  *photosCollectionView; //图片
@property (nonatomic,strong) UITextView        *descTextView;       //内容描述
@property (nonatomic,strong) UIButton          *submitBtn;          //提交

@property (nonatomic,strong) NSMutableArray    *chatRecordsArray;
@property (nonatomic,strong) NSMutableArray    *photosUrlArray;
@property (nonatomic,strong) NSMutableArray    *photosArray;


@end

@implementation ReportSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"匿名投诉";
    
    [self initReportSubmitView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"匿名投诉提交"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"匿名投诉提交"];
}

#pragma mark -- UICollectionViewDataSource and UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photosArray.count==kMaxPhotosCount?kMaxPhotosCount:self.photosArray.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReportPhotosCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row == self.photosArray.count&&self.photosArray.count<kMaxPhotosCount) {
        [cell.imgBtn setImage:[UIImage drawImageWithName:@"report_add_photo" size:CGSizeMake(kImgHeight, kImgHeight)] forState:UIControlStateNormal];
        cell.deleteBtn.hidden = YES;
    } else {
        UIImage *photoImg = self.photosArray[indexPath.row];
        [cell.imgBtn setImage:photoImg forState:UIControlStateNormal];
        cell.imgBtn.imageEdgeInsets = UIEdgeInsetsZero;
        cell.deleteBtn.hidden = NO;
    }
    
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deletePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.imgBtn.tag = indexPath.row;
    [cell.imgBtn addTarget:self action:@selector(didSelectPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark  SDPhotoBrowserDelegate
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    // 不建议用此种方式获取小图，这里只是为了简单实现展示而已
    PhotosCollectionViewCell *cell = (PhotosCollectionViewCell *)[self collectionView:self.photosCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imgBtn.currentImage;
}

#pragma mark  UIImagePickerControllerDelegate
#pragma mark 选择结束
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self.photosArray addObject:curImage];
    
    NSData *imageData = [UIImage zipNSDataWithImage:curImage];
    //将图片数据转化为64为加密字符串
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:0];

    [[HttpRequest sharedInstance] postWithURLString:kUploadPicAPI parameters:@{@"pic":encodeResult} success:^(id responseObject) {
        NSString *data = [responseObject objectForKey:@"data"];
        [self.photosUrlArray addObject:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateReportSubmitView];
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark ChatViewControllerDelegate
-(void)chatViewControllerDidSlectedConversions:(NSArray *)chatRecords{
    self.chatValueLab.text = [NSString stringWithFormat:@"%ld条聊天记录",chatRecords.count];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (RCMessageModel *message in chatRecords) {
        NSString *contentStr= nil;
        if ([message.objectName isEqualToString:@"RC:TxtMsg"]) {
            RCTextMessage *msg = (RCTextMessage *)message.content;
            contentStr = msg.content;
        }else if ([message.objectName isEqualToString:@"RC:ImgMsg"]){
            RCImageMessage *msg = (RCImageMessage *)message.content;
            contentStr = msg.imageUrl;
        }else if ([message.objectName isEqualToString:@"RC:VcMsg"]){
            RCVoiceMessage *msg = (RCVoiceMessage *)message.content;
            contentStr = [[NSString alloc] initWithData:msg.wavAudioData encoding:NSUTF8StringEncoding];
        }
        NSDictionary *dict = @{@"messageUId":message.messageUId,@"targetId":message.targetId,@"senderUserId":message.senderUserId,@"receivedTime":[NSNumber numberWithLongLong:message.receivedTime],@"sentTime":[NSNumber numberWithLongLong:message.sentTime], @"content":contentStr};
        MyLog(@"_______________chat__________________:%@",dict);
        [tempArr addObject:dict];
    }
    self.chatRecordsArray = tempArr;
}

#pragma mark -- Event Response
#pragma mark 提交
-(void)submitAnonymousReportAction{
    if (self.photosUrlArray.count==0) {
        [self.view makeToast:@"请先上传截图" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(self.descTextView.text)) {
        [self.view makeToast:@"投诉内容不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    NSString *chatRecors = [[HomeworkManager sharedHomeworkManager] getValueWithParams:self.chatRecordsArray];
    NSString *photoJsonStr = [[HomeworkManager sharedHomeworkManager] getValueWithParams:self.photosUrlArray];
   
    NSDictionary *params = @{@"token":kUserTokenValue,@"t_id":self.tid,@"com_id":self.report.id,@"pics":photoJsonStr,@"content":self.descTextView.text,@"chat_content":chatRecors};
    [[HttpRequest sharedInstance] postWithURLString:kReportSubmitAPI parameters:params success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"您的投诉提交成功" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (BaseViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[ChatViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 选择聊天记录
-(void)chooseChatRecordsAction:(UIButton *)sender{
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = self.rcId;
    chatVC.isReportIn = YES;
    chatVC.controllerDelegate = self;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark 删除图片
-(void)deletePhotoBtnClick:(UIButton *)sender{
    [self.photosUrlArray removeObjectAtIndex:sender.tag];
    [self.photosArray removeObjectAtIndex:sender.tag];
    [self updateReportSubmitView];
}

#pragma mark 查看大图
-(void)didSelectPhotoAction:(UIButton *)sender{
    if (sender.tag == self.photosArray.count&&self.photosArray.count==kMaxPhotosCount) {
        return;
    }
    if (sender.tag<self.photosArray.count) {
        SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
        photoBrowser.delegate = self;
        photoBrowser.currentImageIndex = sender.tag;
        photoBrowser.imageCount = self.photosArray.count;
        photoBrowser.sourceImagesContainerView = self.photosCollectionView;
        photoBrowser.canScroll = YES;
        [photoBrowser show];
    }else{
        [self addReportPhoto];
    }
}

#pragma mark 添加图片
-(void)addReportPhoto{
    [self addPhotoForView:self.photosCollectionView];
}

#pragma mark -- Private Methods
#pragma mark 初始化界面
-(void)initReportSubmitView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.cateLabel];
    [self.rootScrollView addSubview:self.chatView];
    [self.rootScrollView addSubview:self.tipsLabel];
    [self.rootScrollView addSubview:self.photosCollectionView];
    [self.rootScrollView addSubview:self.descTextView];
    [self.view addSubview:self.submitBtn];
}

#pragma mark 界面更新UI
-(void)updateReportSubmitView{
    [self.photosCollectionView reloadData];
    self.photosCollectionView.frame = CGRectMake(24, self.tipsLabel.bottom+5, kScreenWidth-48, (1+(IS_IPHONE_5?self.photosArray.count/3:self.photosArray.count/4))*(kImgHeight+4));
    self.descTextView.frame = CGRectMake(24, self.photosCollectionView.bottom+10, kScreenWidth-48, 150);
    self.rootScrollView.contentSize =CGSizeMake(kScreenWidth, self.descTextView.bottom+10);
}

#pragma mark -- Getters
#pragma mark 滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _rootScrollView;
}

#pragma mark 投诉类型
-(UILabel *)cateLabel{
    if (!_cateLabel) {
        _cateLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 20, kScreenWidth-60,IS_IPAD?42:30)];
        _cateLabel.font = [UIFont regularFontWithSize:16.0f];
        _cateLabel.textColor = [UIColor commonColor_black];
        _cateLabel.text = self.report.name;
    }
    return _cateLabel;
}

#pragma mark 聊天证据
-(UIView *)chatView{
    if (!_chatView) {
        _chatView = [[UIView alloc] initWithFrame:CGRectMake(0, self.cateLabel.bottom, kScreenWidth,IS_IPAD?70:55)];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(24, 5, 180,IS_IPAD?26:15)];
        titleLab.text = @"聊天证据(可选)";
        titleLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
        titleLab.font = [UIFont regularFontWithSize:13];
        [_chatView addSubview:titleLab];
        
        self.chatValueLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-200, 5, 140,IS_IPAD?26:15)];
        self.chatValueLab.text = @"0条聊天证据";
        self.chatValueLab.textColor = [UIColor colorWithHexString:@"#FF6262"];
        self.chatValueLab.font = [UIFont regularFontWithSize:13];
        self.chatValueLab.textAlignment = NSTextAlignmentRight;
        [_chatView addSubview:self.chatValueLab];
        
        UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.chatValueLab.right+5,IS_IPAD?10:5, 9, 16)];
        arrowImgView.image = [UIImage imageNamed:@"my_arrow_black"];
        [_chatView addSubview:arrowImgView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,self.chatValueLab.bottom+20, kScreenWidth, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_chatView addSubview:line];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-180, 5, 180, 30)];
        [btn addTarget:self action:@selector(chooseChatRecordsAction:) forControlEvents:UIControlEventTouchUpInside];
        [_chatView addSubview:btn];
    }
    return _chatView;
}

#pragma mark 图片上传说明
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(24,self.chatView.bottom, kScreenWidth-60,IS_IPAD?32:20)];
        _tipsLabel.font = [UIFont regularFontWithSize:16.0f];
        _tipsLabel.textColor = [UIColor commonColor_black];
        _tipsLabel.text = @"上传截图，提高举报准确率";
    }
    return _tipsLabel;
}

#pragma mark 图片视图
-(UICollectionView *)photosCollectionView{
    if (!_photosCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(kImgHeight, kImgHeight);
        layout.minimumLineSpacing = 4;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 0);
        
        _photosCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(24, self.tipsLabel.bottom+5, kScreenWidth-48, kImgHeight+4) collectionViewLayout:layout];
        _photosCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _photosCollectionView.scrollEnabled = NO;
        _photosCollectionView.backgroundColor = [UIColor whiteColor];
        [_photosCollectionView registerClass:[PhotosCollectionViewCell class] forCellWithReuseIdentifier:@"ReportPhotosCollectionViewCell"];
        _photosCollectionView.dataSource = self;
        _photosCollectionView.delegate = self;
    }
    return _photosCollectionView;
}

#pragma mark 投诉内容描述
-(UITextView *)descTextView{
    if (!_descTextView) {
        _descTextView = [[UITextView alloc] initWithFrame:CGRectMake(24, self.photosCollectionView.bottom+10, kScreenWidth-48,IS_IPAD?200:150)];
        _descTextView.textColor = [UIColor colorWithHexString:@"#6D6D6D"];
        _descTextView.backgroundColor = [UIColor colorWithHexString:@"#FCFCFC"];
        _descTextView.layer.borderColor = [UIColor colorWithHexString:@"#EEEFF2"].CGColor;
        _descTextView.layer.borderWidth = 1.0;
        _descTextView.font = [UIFont regularFontWithSize:14.0f];
        _descTextView.zw_limitCount = 100;
        _descTextView.zw_labHeight = 30.0;
        _descTextView.zw_placeHolder = @"请填写投诉内容";
        _descTextView.textContainerInset = UIEdgeInsetsMake(3, 0, 0, 0);
    }
    return _descTextView;
}

#pragma mark 提交
-(UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-228)/2.0, kScreenHeight-65, 228.0, 40)];
        _submitBtn.backgroundColor = [UIColor systemColor];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        _submitBtn.layer.cornerRadius = 20.0;
        _submitBtn.titleLabel.font = [UIFont mediumFontWithSize:18];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitAnonymousReportAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

-(NSMutableArray *)photosUrlArray{
    if (!_photosUrlArray) {
        _photosUrlArray = [[NSMutableArray alloc] init];
    }
    return _photosUrlArray;
}

-(NSMutableArray *)photosArray{
    if (!_photosArray) {
        _photosArray = [[NSMutableArray alloc] init];
    }
    return _photosArray;
}

-(NSMutableArray *)chatRecordsArray{
    if (!_chatRecordsArray) {
        _chatRecordsArray = [[NSMutableArray alloc] init];
    }
    return _chatRecordsArray;
}

@end
