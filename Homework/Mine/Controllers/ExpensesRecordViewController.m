//
//  ExpensesRecordViewController.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ExpensesRecordViewController.h"
#import "ExpenseTableViewCell.h"
#import "BlankView.h"
#import "ExpenseRecordModel.h"
#import <MJRefresh/MJRefresh.h>

@interface ExpensesRecordViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *recordsTableView;
@property (nonatomic,strong) BlankView    *blankView;

@property (nonatomic,strong) NSMutableArray *recordsArray;

@property (nonatomic,assign) NSInteger page;

@end

@implementation ExpensesRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"我的消费记录";
    
    self.page = 1;
    
    [self.view addSubview:self.recordsTableView];
    [self.recordsTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    [self loadExpenseRecordsData];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recordsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ExpenseTableViewCell";
    ExpenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[ExpenseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ExpenseRecordModel *model = self.recordsArray[indexPath.row];
    cell.expenseModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?142:112;
}

#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadExpenseRecordsData{
    [[HttpRequest sharedInstance] postWithURLString:kConsumeRecordsAPI parameters:@{@"token":kUserTokenValue,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@20} success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            ExpenseRecordModel *model = [[ExpenseRecordModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page) {
            self.recordsArray = tempArr;
        }else{
            [self.recordsArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recordsTableView.mj_footer.hidden = tempArr.count<20;
            [self.recordsTableView.mj_header endRefreshing];
            [self.recordsTableView.mj_footer endRefreshing];
            [self.recordsTableView reloadData];
            self.blankView.hidden = self.recordsArray.count>0;
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.recordsTableView.mj_header endRefreshing];
            [self.recordsTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 加载最新
-(void)loadNewExpenseRecordsData{
    self.page=1;
    [self loadExpenseRecordsData];
}

#pragma mark 加载更多
-(void)loadMoreExpenseRecordsData{
    self.page++;
    [self loadExpenseRecordsData];
}


#pragma mark -- Getters
#pragma mark 消费记录
-(UITableView *)recordsTableView{
    if (!_recordsTableView) {
        _recordsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _recordsTableView.dataSource = self;
        _recordsTableView.delegate = self;
        _recordsTableView.showsVerticalScrollIndicator = NO;
        _recordsTableView.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewExpenseRecordsData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _recordsTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreExpenseRecordsData)];
        footer.automaticallyRefresh = NO;
        _recordsTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _recordsTableView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"blank_money" msg:@"暂无消费记录"];
    }
    return _blankView;
}

#pragma mark
-(NSMutableArray *)recordsArray{
    if (!_recordsArray) {
        _recordsArray = [[NSMutableArray alloc] init];
    }
    return _recordsArray;
}

@end
