//
//  MyFeedbackTableView.m
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyFeedbackTableView.h"
#import "MyFeedbackTableViewCell.h"
#import "BlankView.h"
#import "CoachFeedbackModel.h"

@interface MyFeedbackTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) BlankView  *blankView;

@end

@implementation MyFeedbackTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.tableFooterView = [[UIView alloc] init];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return self;
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myFeedbackArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenditifier = @"MyFeedbackTableViewCell";
    MyFeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
    if (cell==nil) {
        cell = [[MyFeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CoachFeedbackModel *model = self.myFeedbackArray[indexPath.row];
    cell.feedbackModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CoachFeedbackModel *model = self.myFeedbackArray[indexPath.row];
    return [MyFeedbackTableViewCell getMyFeedbackCellHeightWithModel:model];
}

-(void)setMyFeedbackArray:(NSMutableArray *)myFeedbackArray{
    _myFeedbackArray = myFeedbackArray;
    self.blankView.hidden = myFeedbackArray.count>0;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?120:60, kScreenWidth, 200) img:@"blank_feedback" msg:@"暂无辅导反馈"];
    }
    return _blankView;
}

@end
