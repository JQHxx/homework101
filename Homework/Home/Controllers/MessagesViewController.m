//
//  MessagesViewController.m
//  Homework
//
//  Created by vision on 2019/9/29.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessagesTableViewCell.h"
#import "BlankView.h"
#import "MessageModel.h"
#import <MJRefresh/MJRefresh.h>

@interface MessagesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *messagesTableView;
@property (nonatomic,strong) BlankView  *blankView;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *messagesArr;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"消息";
    self.rigthTitleName = @"";
    self.rightBtn.userInteractionEnabled = NO;
    
    [self.view addSubview:self.messagesTableView];
    [self.messagesTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    [self loadMessagesData];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messagesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MessagesTableViewCell";
    MessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[MessagesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    MessageModel *model = self.messagesArr[indexPath.row];
    cell.messageModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = self.messagesArr[indexPath.row];
    CGFloat contentH = [model.content boundingRectWithSize:CGSizeMake(kScreenWidth-150, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:14.0f]].height;
    return contentH+100;
}

#pragma mark -- Event Response
#pragma mark 清空
-(void)rightNavigationItemAction{
    [[HttpRequest sharedInstance] postWithURLString:kEmptyMessagesAPI parameters:@{@"token":kUserTokenValue} success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"消息已清空" duration:1.0 position:CSToastPositionCenter];
        });
        [self loadNewMessagesData];
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
    
}

#pragma mark -- Private Methods
#pragma mark 加载消息数据
-(void)loadMessagesData{
    NSDictionary *params = @{@"token":kUserTokenValue,@"page":[NSNumber numberWithInteger:self.page],@"pagesize":@20};
    [[HttpRequest sharedInstance] postWithURLString:kRemoteMessagesAPI parameters:params success:^(id responseObject) {
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            MessageModel *model = [[MessageModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        if (self.page==1) {
            self.messagesArr = tempArr;
        }else{
            [self.messagesArr addObjectsFromArray:tempArr];
        }
        [HomeworkManager sharedHomeworkManager].isUpdateMessage = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagesTableView.mj_header endRefreshing];
            [self.messagesTableView.mj_footer endRefreshing];
            [self.messagesTableView reloadData];
            self.messagesTableView.mj_footer.hidden = tempArr.count<20;
            self.blankView.hidden = self.messagesArr.count>0;
            if (self.messagesArr.count>0) {
                self.rigthTitleName = @"清空";
                self.rightBtn.userInteractionEnabled = YES;
            }else{
                self.rigthTitleName = @"";
                self.rightBtn.userInteractionEnabled = NO;
            }
        });
    } failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagesTableView.mj_header endRefreshing];
            [self.messagesTableView.mj_footer endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
    
}

#pragma mark 加载最新
-(void)loadNewMessagesData{
    self.page = 1;
    [self loadMessagesData];
}

#pragma mark 加载更多
-(void)loadMoreMessagesData{
    self.page++;
    [self loadMessagesData];
}

#pragma mark -- Getters
#pragma mark 消息
-(UITableView *)messagesTableView{
    if (!_messagesTableView) {
        _messagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _messagesTableView.delegate = self;
        _messagesTableView.dataSource = self;
        _messagesTableView.tableFooterView = [[UIView alloc] init];
        _messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _messagesTableView.backgroundColor = [UIColor colorWithHexString:@"#F7F7FB"];
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewMessagesData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _messagesTableView.mj_header=header;
          
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessagesData)];
        footer.automaticallyRefresh = NO;
        _messagesTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _messagesTableView;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?120:60, kScreenWidth, 200) img:@"blank_message" msg:@"暂无消息"];
    }
    return _blankView;
}

-(NSMutableArray *)messagesArr{
    if (!_messagesArr) {
        _messagesArr = [[NSMutableArray alloc] init];
    }
    return _messagesArr;
}

@end
