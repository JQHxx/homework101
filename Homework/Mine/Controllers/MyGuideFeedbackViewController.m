//
//  MyGuideFeedbackViewController.m
//  Homework
//
//  Created by vision on 2019/9/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyGuideFeedbackViewController.h"
#import "FilterView.h"
#import "CoachFeedbackTableViewCell.h"
#import "CoachFeedbackModel.h"
#import "NSDate+Extend.h"
#import "BRPickerView.h"
#import "BlankView.h"
#import <MJRefresh/MJRefresh.h>

@interface MyGuideFeedbackViewController ()<UITableViewDelegate,UITableViewDataSource,FilterViewDelegate>

@property (nonatomic,strong) FilterView   *filterView;
@property (nonatomic,strong) UITableView  *myFeedbackTableView;
@property (nonatomic,strong) BlankView    *blankView;

@property (nonatomic,strong) NSMutableArray  *myFeedbacksArray;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic, copy ) NSString  *selDateStr;
@property (nonatomic, copy ) NSString  *selSubjectStr;

@end

@implementation MyGuideFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"我的辅导反馈";
    
    self.page = 1;
    self.selDateStr = [NSDate currentDateTimeWithFormat:@"yyyy年MM月dd日"];
    self.selSubjectStr = @"全部";
    
    [self initMyGuideFeedbackView];
    [self loadMyGuideFeedbackData];
}

#pragma mark --UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myFeedbacksArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CoachFeedbackTableViewCell";
    CoachFeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[CoachFeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CoachFeedbackModel *model = self.myFeedbacksArray[indexPath.row];
    cell.feedbackModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CoachFeedbackModel *model = self.myFeedbacksArray[indexPath.row];
    return [CoachFeedbackTableViewCell getMyFeedbackCellHeightWithModel:model];
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
-(void)initMyGuideFeedbackView{
    [self.view addSubview:self.filterView];
    [self.view addSubview:self.myFeedbackTableView];
    [self.myFeedbackTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
}

#pragma mark 加载数据
-(void)loadMyGuideFeedbackData{
    //时间
    NSNumber *timeStamp = [[HomeworkManager sharedHomeworkManager] timeSwitchTimestamp:self.selDateStr format:@"yyyy年MM月dd日"];
    //科目
    NSArray *subjects  = [HomeworkManager sharedHomeworkManager].subjects;
    NSInteger selIndex = [self.selSubjectStr isEqualToString:@"全部"]?0:[subjects indexOfObject:self.selSubjectStr]+1;
    NSDictionary *params = @{@"token":kUserTokenValue,@"search_time":timeStamp,@"subject":[NSNumber numberWithInteger:selIndex],@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@15};
    [[HttpRequest sharedInstance] postWithURLString:kGuideFeedbackAPI parameters:params success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            CoachFeedbackModel *model = [[CoachFeedbackModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        
        if (self.page==1) {
            self.myFeedbacksArray = tempArr;
        }else{
            [self.myFeedbacksArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myFeedbackTableView.mj_footer.hidden = tempArr.count<15;
            self.blankView.hidden = self.myFeedbacksArray.count>0;
            [self.myFeedbackTableView.mj_header endRefreshing];
            [self.myFeedbackTableView.mj_footer endRefreshing];
            [self.myFeedbackTableView reloadData];
            
        });
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myFeedbackTableView.mj_header endRefreshing];
            [self.myFeedbackTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 最新辅导反馈数据
-(void)loadNewMyFeedbackListData{
    self.page = 1;
    [self loadMyGuideFeedbackData];
}

#pragma mark 更多辅导反馈数据
-(void)loadMoreMyFeedbackListData{
    self.page++;
    [self loadMyGuideFeedbackData];
}

#pragma mark -- Getters
#pragma mark 筛选
-(FilterView *)filterView{
    if (!_filterView) {
        _filterView = [[FilterView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?60:45)];
        _filterView.viewDelegate = self;
        _filterView.dateStr = self.selDateStr;
        _filterView.subjectStr = self.selSubjectStr;
    }
    return _filterView;
}

#pragma mark 辅导反馈
-(UITableView *)myFeedbackTableView{
    if (!_myFeedbackTableView) {
        _myFeedbackTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.filterView.bottom, kScreenWidth, kScreenHeight-self.filterView.bottom) style:UITableViewStylePlain];
        _myFeedbackTableView.delegate = self;
        _myFeedbackTableView.dataSource = self;
        _myFeedbackTableView.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        _myFeedbackTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMyFeedbackListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _myFeedbackTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMyFeedbackListData)];
        footer.automaticallyRefresh = NO;
        _myFeedbackTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myFeedbackTableView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 200) img:@"blank_feedback" msg:@"暂无辅导反馈"];
    }
    return _blankView;
}

-(NSMutableArray *)myFeedbacksArray{
    if (!_myFeedbacksArray) {
        _myFeedbacksArray = [[NSMutableArray alloc] init];
    }
    return _myFeedbacksArray;
}




@end
