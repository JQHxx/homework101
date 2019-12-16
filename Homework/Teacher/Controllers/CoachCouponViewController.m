//
//  CoachCouponViewController.m
//  Homework
//
//  Created by vision on 2019/9/20.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CoachCouponViewController.h"

#import "CoachCouponTableViewCell.h"
#import "CoachCouponModel.h"

#define kCellHeight (IS_IPAD?120:100)

@interface CoachCouponViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIImageView *bgImgView;
@property (nonatomic,strong) UITableView *couponTableView;
@property (nonatomic,strong) UILabel     *taskTitleLab;
@property (nonatomic,strong) UILabel     *taskLab;
@property (nonatomic,strong) UIButton    *shareBtn;

@property (nonatomic,strong) NSMutableArray  *couponsArray;

@end

@implementation CoachCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.isTeacherIn?@"辅导优惠券":@"邀请好友";
    self.rightImageName = @"tutor_service";
    
    [self initCoachCouponView];
    [self loadCoachCouponsData];
    
    [MobClick event:kStaticsInviteEvent];
}

#pragma mark  -- UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.couponsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CoachCouponTableViewCell *cell = [[CoachCouponTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CoachCouponModel *model = self.couponsArray[indexPath.row];
    cell.couponModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

#pragma mark 立即分享
-(void)shareAction:(UIButton *)sender{
    [[HomeworkManager sharedHomeworkManager] shareToOtherUsersFromController:self];
}

#pragma mark -- Private  methods
#pragma mark 初始化
-(void)initCoachCouponView{
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.couponTableView];
    [self.view addSubview:self.taskTitleLab];
    [self.view addSubview:self.taskLab];
    [self.view addSubview:self.shareBtn];
}

#pragma mark 加载优惠券
-(void)loadCoachCouponsData{
    [[HttpRequest sharedInstance] postWithURLString:kCoachCouponsAPI parameters:nil success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSArray *list = [data valueForKey:@"list"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in list) {
            CoachCouponModel *model = [[CoachCouponModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        self.couponsArray = tempArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.couponTableView reloadData];
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 背景
-(UIImageView *)bgImgView{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _bgImgView.image = [UIImage imageNamed:@"tutor_coupons_share_background"];
    }
    return _bgImgView;
}

#pragma mark 优惠券
-(UITableView *)couponTableView{
    if (!_couponTableView) {
        _couponTableView = [[UITableView alloc] initWithFrame:CGRectMake(26,kNavHeight+(IS_IPAD?160:(IS_IPHONE_5?80:100)), kScreenWidth-52, kCellHeight *3) style:UITableViewStylePlain];
        _couponTableView.dataSource = self;
        _couponTableView.delegate = self;
        _couponTableView.tableFooterView = [[UIView alloc] init];
        _couponTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _couponTableView.backgroundColor = [UIColor clearColor];
    }
    return _couponTableView;
}

#pragma mark 任务要求
-(UILabel *)taskTitleLab{
    if (!_taskTitleLab) {
        _taskTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(24, self.couponTableView.bottom+15, 100,IS_IPAD?28:16)];
        _taskTitleLab.text = @"任务要求";
        _taskTitleLab.textColor = [UIColor colorWithHexString:@"#FFE845"];
        _taskTitleLab.font = [UIFont mediumFontWithSize:16.0f];
    }
    return _taskTitleLab;
}

#pragma mark 任务要求
-(UILabel *)taskLab{
    if (!_taskLab) {
        _taskLab = [[UILabel alloc] initWithFrame:CGRectMake(24, self.taskTitleLab.bottom, kScreenWidth-48,IS_IPAD?120:80)];
        _taskLab.text = @"1、分享至微信朋友圈并保持24小时。\n2、获得88个点赞。\n3、截图发送给客服。\n4、客服审核，发放优惠劵。";
        _taskLab.numberOfLines = 0;
        _taskLab.textColor = [UIColor whiteColor];
        _taskLab.font = [UIFont regularFontWithSize:13.0f];
    }
    return _taskLab;
}

#pragma mark 分享
-(UIButton *)shareBtn{
    if (!_shareBtn) {
        _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(11, kScreenHeight-(IS_IPAD?80:(IS_IPHONE_5?50:60)), kScreenWidth-22,IS_IPAD?50:40)];
        [_shareBtn setTitle:@"立即分享" forState:UIControlStateNormal];
        [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont mediumFontWithSize:16];
        _shareBtn.backgroundColor = [UIColor colorWithHexString:@"#FFE845"];
        _shareBtn.layer.cornerRadius = 5.0;
        [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

-(NSMutableArray *)couponsArray{
    if (!_couponsArray) {
        _couponsArray = [[NSMutableArray alloc] init];
    }
    return _couponsArray;
}


@end
