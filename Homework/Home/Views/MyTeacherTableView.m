//
//  MyteacherTableView.m
//  Homework
//
//  Created by vision on 2019/9/9.
//  Copyright © 2019 vision. All rights reserved.
//

#import "MyTeacherTableView.h"
#import "MyTeacherTableViewCell.h"
#import "BlankView.h"

@interface MyTeacherTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) BlankView  *blankView;

@end

@implementation MyTeacherTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableFooterView = [[UIView alloc] init];
        self.showsVerticalScrollIndicator = NO;
        
        [self addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return self;
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.teachersArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdenditifier = @"MyTeacherTableViewCell";
    MyTeacherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdenditifier];
    if (cell==nil) {
        cell = [[MyTeacherTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenditifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TeacherModel *model = self.teachersArray[indexPath.row];
    cell.myTeacher = model;
    
    cell.headImageView.userInteractionEnabled = YES;
    cell.headImageView.tag = indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTeacherDetailsAction:)];
    [cell.headImageView addGestureRecognizer:tap];
    
    cell.coachBtn.tag = indexPath.row;
    [cell.coachBtn addTarget:self action:@selector(coachBtnHandleAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?168.0:128.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TeacherModel *model = self.teachersArray[indexPath.row];
    if ([self.viewDelegate respondsToSelector:@selector(myTeacherTableView:didGotoCoachWithTeacher:)]) {
        [self.viewDelegate myTeacherTableView:self didGotoCoachWithTeacher:model];
    }
    
}

#pragma mark
-(void)coachBtnHandleAction:(HomeCoachButton *)sender{
    TeacherModel *model = self.teachersArray[sender.tag];
    if ([self.viewDelegate respondsToSelector:@selector(myTeacherTableView:didHandleWithModel:)]) {
        [self.viewDelegate myTeacherTableView:self didHandleWithModel:model];
    }
}

#pragma mark 查看老师详情
-(void)showTeacherDetailsAction:(UITapGestureRecognizer *)sender{
    TeacherModel *model = self.teachersArray[sender.view.tag];
    if ([self.viewDelegate respondsToSelector:@selector(myTeacherTableView:didSelectedTeacher:)]) {
        [self.viewDelegate myTeacherTableView:self didSelectedTeacher:model];
    }
}

-(void)setTeachersArray:(NSMutableArray *)teachersArray{
    _teachersArray = teachersArray;
    self.blankView.hidden = teachersArray.count>0;
}

#pragma mark 空白页
-(BlankView *)blankView{
    if (!_blankView) {
        _blankView = [[BlankView alloc] initWithFrame:CGRectMake(0,IS_IPAD?120:60, kScreenWidth, 200) img:@"blank_teacher" msg:@"暂无辅导老师"];
    }
    return _blankView;
}


@end
