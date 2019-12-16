//
//  MyCoachRecordViewController.m
//  Homework
//
//  Created by vision on 2019/9/11.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyCoachRecordViewController.h"
#import "CoachTableViewCell.h"
#import "FilterView.h"
#import "CoachRecordModel.h"
#import "NSDate+Extend.h"
#import "BRPickerView.h"
#import "BlankView.h"
#import <MJRefresh/MJRefresh.h>

@interface MyCoachRecordViewController ()<UITableViewDataSource,UITableViewDelegate,FilterViewDelegate>

@property (nonatomic,strong) FilterView  *filterView;
@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) BlankView    *blankView;

@property (nonatomic,strong) NSMutableArray *coachRecordsArray;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic, copy ) NSString  *selDateStr;
@property (nonatomic, copy ) NSString  *selSubjectStr;

@end

@implementation MyCoachRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的辅导记录";
    
    self.page = 1;
    self.selDateStr = [NSDate currentDateTimeWithFormat:@"yyyy年MM月dd日"];
    self.selSubjectStr = @"全部";
    
    [self initMyCoachRecordView];
    [self loadCoachRecordsData];
}

#pragma mark -- UITableViewDelegate and UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.coachRecordsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CoachTableViewCell";
    CoachTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[CoachTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CoachRecordModel *model = self.coachRecordsArray[indexPath.row];
    cell.recordModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?105:83;
}

#pragma mark -- delegate
#pragma mark FilterViewDelegate
-(void)filerViewDidClickWithIndex:(NSInteger)index{
    if (index==0) { //选择日期
        [BRDatePickerView showDatePickerWithTitle:@"日期" dateType:UIDatePickerModeDate defaultSelValue:self.selDateStr minDateStr:@"" maxDateStr:self.selDateStr isAutoSelect:NO resultBlock:^(NSString *selectValue) {
            MyLog(@"selectValue:%@",selectValue);
            self.selDateStr = selectValue;
            self.filterView.dateStr = selectValue;
        }];
    }else{ //选择科目
        NSArray *subjects  = [HomeworkManager sharedHomeworkManager].subjects;
        NSMutableArray *temparr = [[NSMutableArray alloc] initWithObjects:@"全部", nil];
        [temparr addObjectsFromArray:subjects];
        [BRStringPickerView showStringPickerWithTitle:@"科目" dataSource:temparr defaultSelValue:self.selSubjectStr isAutoSelect:NO resultBlock:^(id selectValue) {
            MyLog(@"selectValue:%@",selectValue);
            self.selSubjectStr = selectValue;
            self.filterView.subjectStr = selectValue;
        }];
    }
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initMyCoachRecordView{
    [self.view addSubview:self.filterView];
    [self.view addSubview:self.myTableView];
    [self.myTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
}

#pragma mark 加载辅导记录数据
-(void)loadCoachRecordsData{
    //时间
    NSNumber *timeStamp = [[HomeworkManager sharedHomeworkManager] timeSwitchTimestamp:self.selDateStr format:@"yyyy年MM月dd日"];
    //科目
    NSArray *subjects  = [HomeworkManager sharedHomeworkManager].subjects;
    NSInteger selIndex = [self.selSubjectStr isEqualToString:@"全部"]?0:[subjects indexOfObject:self.selSubjectStr]+1;
    NSDictionary *params = @{@"token":kUserTokenValue,@"feedback_time":timeStamp,@"subject":[NSNumber numberWithInteger:selIndex],@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@20};
    [[HttpRequest sharedInstance] postWithURLString:kGuideRecordsAPI parameters:params success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            CoachRecordModel *model = [[CoachRecordModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page==1) {
            self.coachRecordsArray = tempArr;
        }else{
            [self.coachRecordsArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myTableView.mj_footer.hidden = tempArr.count<20;
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            [self.myTableView reloadData];
            self.blankView.hidden = self.coachRecordsArray.count>0;
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myTableView.mj_header endRefreshing];
            [self.myTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 加载最新
-(void)loadNewCoachRecordsData{
    self.page=1;
    [self loadCoachRecordsData];
}

#pragma mark 加载更多
-(void)loadMoreCoachRecordsData{
    self.page++;
    [self loadCoachRecordsData];
}

#pragma mark -- Getters
#pragma mark 筛选
-(FilterView *)filterView{
    if (!_filterView) {
        _filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, 45)];
        _filterView.viewDelegate = self;
        _filterView.dateStr = self.selDateStr;
        _filterView.subjectStr = self.selSubjectStr;
    }
    return _filterView;
}

#pragma mark 辅导记录
-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.filterView.bottom, kScreenWidth, kScreenHeight-self.filterView.bottom) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCoachRecordsData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _myTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCoachRecordsData)];
        footer.automaticallyRefresh = NO;
        _myTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myTableView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"blank_coach" msg:@"暂无辅导记录"];
    }
    return _blankView;
}

#pragma mark
-(NSMutableArray *)coachRecordsArray{
    if (!_coachRecordsArray) {
        _coachRecordsArray = [[NSMutableArray alloc] init];
    }
    return _coachRecordsArray;
}

@end
