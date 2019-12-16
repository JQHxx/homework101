//
//  TeacherTableView.m
//  Homework
//
//  Created by vision on 2019/9/23.
//  Copyright © 2019 vision. All rights reserved.
//

#import "TeacherTableView.h"
#import "TeacherTableViewCell.h"
#import "BlankView.h"

#define kCellHeight (IS_IPAD?260:180.0)

@interface TeacherTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) BlankView  *blankView;

@end

@implementation TeacherTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableFooterView = [[UIView alloc] init];
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.blankView];
        self.blankView.hidden = YES;
        
        
    }
    return self;
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.teachersArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MyTeacherTableViewCell";
    TeacherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TeacherTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TeacherModel *model = self.teachersArr[indexPath.row];
    [cell applyDataForCellWithTeacher:model];
    
    cell.connectButton.tag = indexPath.row;
    [cell.connectButton addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TeacherModel *model = self.teachersArr[indexPath.row];
    if ([self.viewDelegate respondsToSelector:@selector(teacherTableView:didSelectCellWithModel:)]) {
        [self.viewDelegate teacherTableView:self didSelectCellWithModel:model];
    }
}

#pragma mark -- Event response
#pragma mark 联系老师
-(void)toConnectTeacherAction:(UIButton *)sender{
    TeacherModel *model = self.teachersArr[sender.tag];
    if ([self.viewDelegate respondsToSelector:@selector(teacherTableView:didContactTeacher:)]) {
        [self.viewDelegate teacherTableView:self didContactTeacher:model];
    }
}

-(void)setTeachersArr:(NSMutableArray *)teachersArr{
    _teachersArr = teachersArr;
    self.blankView.hidden = teachersArr.count>0;
}


#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?100:60, kScreenWidth, 200) img:@"blank_teacher" msg:@"暂无老师"];
    }
    return _blankView;
}

@end
