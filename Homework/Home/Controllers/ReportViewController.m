//
//  ReportViewController.m
//  Homework
//
//  Created by vision on 2019/5/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "ReportViewController.h"
#import "ReportSubmitViewController.h"
#import "ReportModel.h"

@interface ReportViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *reportTableView;

@property (nonatomic,strong) NSMutableArray *reportsArray;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"匿名投诉";
    
    [self initReportView];
    [self loadReportsCateData];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reportsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    ReportModel *model = self.reportsArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = kIsEmptyString(model.remark)?@"":[NSString stringWithFormat:@"(%@)",model.remark];
    cell.detailTextLabel.font = [UIFont regularFontWithSize:12];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#808080"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ReportModel *model = self.reportsArray[indexPath.row];
    return kIsEmptyString(model.remark)?(IS_IPAD?80:59):(IS_IPAD?100:80);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ReportModel *model = self.reportsArray[indexPath.row];
    ReportSubmitViewController *reportSubmitVC = [[ReportSubmitViewController alloc] init];
    reportSubmitVC.report = model;
    reportSubmitVC.tid = self.tid;
    reportSubmitVC.rcId = self.rcId;
    [self.navigationController pushViewController:reportSubmitVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化界面
-(void)initReportView{
    [self.view addSubview:self.reportTableView];
}

#pragma mark 加载数据
-(void)loadReportsCateData{
    NSDictionary *params = @{@"token":kUserTokenValue};
    [[HttpRequest sharedInstance] postWithURLString:kReportReasonsAPI parameters:params success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            ReportModel *model = [[ReportModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        self.reportsArray = tempArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.reportTableView reloadData];
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 举报内容
-(UITableView *)reportTableView{
    if (!_reportTableView) {
        _reportTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _reportTableView.dataSource = self;
        _reportTableView.delegate = self;
        _reportTableView.tableFooterView = [[UIView alloc] init];
    }
    return _reportTableView;
}

-(NSMutableArray *)reportsArray{
    if (!_reportsArray) {
        _reportsArray = [[NSMutableArray alloc] init];
    }
    return _reportsArray;
}

@end
