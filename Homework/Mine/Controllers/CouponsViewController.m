//
//  CouponsViewController.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "CouponsViewController.h"
#import "ChatViewController.h"
#import "SlideMenuView.h"
#import "CouponTableViewCell.h"
#import "TicketTableViewCell.h"
#import "BlankView.h"
#import "CouponModel.h"

@interface CouponsViewController ()<SlideMenuViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) SlideMenuView   *menuView;
@property (nonatomic,strong) UITableView     *couponTableView;
@property (nonatomic,strong) BlankView       *blankView;

@property (nonatomic,assign) NSInteger       type;


@property (nonatomic,strong) NSMutableArray  *couponsArray;
@property (nonatomic,strong) NSMutableArray  *ticketsArray;


@end

@implementation CouponsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的优惠券";
    
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.couponTableView];
    [self.couponTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    self.type = 0;
    
    [self loadCouponsData];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.ticketsArray.count+self.couponsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<self.ticketsArray.count) {
        static NSString *cellIdentifier = @"TicketTableViewCell";
        TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[TicketTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ExpTicketModel *model = self.ticketsArray[indexPath.row];
        cell.ticketModel = model;
        
        if ([model.is_use integerValue]==0) {
            cell.useBtn.tag = indexPath.row;
            [cell.useBtn addTarget:self action:@selector(useGuideExpCouponAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }else{
        static NSString *cellIdentifier = @"CouponTableViewCell";
        CouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[CouponTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CouponModel *model = self.couponsArray[indexPath.row-self.ticketsArray.count];
        cell.couponModel = model;
        
        if ([model.is_use integerValue]==0) {
            cell.useBtn.tag = indexPath.row+self.ticketsArray.count;
            [cell.useBtn addTarget:self action:@selector(useCouponAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  IS_IPAD?166:116;
}

#pragma mark 选择菜单
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    self.type = index;
    [self loadCouponsData];
}

#pragma mark -- Event response
#pragma mark 使用体验券
-(void)useGuideExpCouponAction:(UIButton *)sender{
    ExpTicketModel *model = self.ticketsArray[sender.tag];
    
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = model.third_id;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark 使用优惠券
-(void)useCouponAction:(UIButton *)sender{
    [HomeworkManager sharedHomeworkManager].isUpdateTeacher = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -- Private methods
#pragma mark 加载数据
-(void)loadCouponsData{
    [[HttpRequest sharedInstance] postWithURLString:kMyCouponsAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        
        //体验券
        NSArray *couponsArr = [data valueForKey:@"coupon"];
        NSMutableArray *ticketTempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in couponsArr) {
            ExpTicketModel *model = [[ExpTicketModel alloc] init];
            [model setValues:dict];
            if (self.type==0) {
               [ticketTempArr addObject:model];
            }else{
                if ([model.is_use integerValue]==0) {
                    [ticketTempArr addObject:model];
                }
            }
        }
        self.ticketsArray = ticketTempArr;
        
        //优惠券
        NSArray *cashData = [data valueForKey:@"cash"];
        NSMutableArray *couponTempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in cashData) {
            CouponModel *model = [[CouponModel alloc] init];
            [model setValues:dict];
            
            if (self.type==0) {
               [couponTempArr addObject:model];
            }else{
                if ([model.is_use integerValue]==0) {
                    [couponTempArr addObject:model];
                }
            }
        }
        self.couponsArray = couponTempArr;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.couponTableView reloadData];
            self.blankView.hidden = ticketTempArr.count+couponTempArr.count>0;
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 菜单栏
-(SlideMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?56:40) btnTitleFont:[UIFont regularFontWithSize:13.0f] color:[UIColor colorWithHexString:@"#9B9B9B"] selColor:[UIColor commonColor_red]];
        _menuView.lineWidth = 14.0;
        _menuView.myTitleArray = [NSMutableArray arrayWithArray:@[@"全部优惠券",@"可用券"]];
        _menuView.currentIndex = 0;
        _menuView.delegate = self;
        _menuView.backgroundColor = [UIColor colorWithHexString:@"#F6F6FA"];
    }
    return _menuView;
}

#pragma mark 优惠券列表
-(UITableView *)couponTableView{
    if (!_couponTableView) {
        _couponTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.menuView.bottom, kScreenWidth, kScreenHeight-self.menuView.bottom) style:UITableViewStylePlain];
        _couponTableView.dataSource = self;
        _couponTableView.delegate = self;
        _couponTableView.tableFooterView = [[UIView alloc] init];
        _couponTableView.showsVerticalScrollIndicator = NO;
        _couponTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _couponTableView.backgroundColor = [UIColor whiteColor];
    }
    return _couponTableView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?120:60, kScreenWidth, 200) img:@"blank_coupon" msg:@"暂无优惠券"];
    }
    return _blankView;
}

-(NSMutableArray *)couponsArray{
    if (!_couponsArray) {
        _couponsArray = [[NSMutableArray alloc] init];
    }
    return _couponsArray;
}

-(NSMutableArray *)ticketsArray{
    if (!_ticketsArray) {
        _ticketsArray = [[NSMutableArray alloc] init];
    }
    return _ticketsArray;
}

@end
