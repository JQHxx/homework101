//
//  TeacherViewController.m
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#import "TeacherViewController.h"
#import "TeacherDetailsViewController.h"
#import "BaseWebViewController.h"
#import "ChatViewController.h"
#import "ExperienceBuyViewController.h"
#import "CoachCouponViewController.h"
#import "SDCycleScrollView.h"
#import "SlideMenuView.h"
#import "TeacherTableView.h"
#import "MJRefresh.h"

#import "BannerModel.h"
#import "TeacherModel.h"

#define kCellHeight (IS_IPAD?260:180.0)

@interface TeacherViewController ()<UIScrollViewDelegate,SDCycleScrollViewDelegate,SlideMenuViewDelegate,TeacherTableViewDelegate>{
    NSArray       *subjects;
    NSInteger     subjectIndex;
}

@property (nonatomic, strong) UIView             *navbarView;
@property (nonatomic, strong) UIScrollView       *rootScrollView;
@property (nonatomic, strong) SDCycleScrollView  *bannerScrollView;
@property (nonatomic, strong) SlideMenuView      *subjectMenuView;
@property (nonatomic, strong) SlideMenuView      *tempMenuView;
@property (nonatomic, strong) TeacherTableView   *myTableView;

@property (nonatomic,strong) NSMutableArray      *bannersArray;
@property (nonatomic,strong) NSMutableArray      *teachersArray;

@end

@implementation TeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;

    NSString *grade = [NSUserDefaultsInfos getValueforKey:kUserGrade];
    subjects = [[HomeworkManager sharedHomeworkManager] getCourseForGrade:grade];
    subjectIndex = 1;
    
    [self initTeacherView];
    [self loadTeachersData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"老师"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"老师"];
}

#pragma mark -- Delegate
#pragma mark TeacherTableViewDelegate
#pragma mark 老师详情
-(void)teacherTableView:(TeacherTableView *)tableView didSelectCellWithModel:(TeacherModel *)teacher{
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.webTitle = teacher.name;
    detailsVC.urlStr = [NSString stringWithFormat:@"%@?token=%@&t_id=%@",kTeacherDetailsUrl,kUserTokenValue,teacher.t_id];
    detailsVC.teacherDetails = teacher;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark 联系老师
-(void)teacherTableView:(TeacherTableView *)tableView didContactTeacher:(TeacherModel *)teacher{
    MyLog(@"联系老师");
    if (!kIsEmptyString(teacher.third_id)) {
        ChatViewController *chatVC = [[ChatViewController alloc]init];
        chatVC.conversationType = ConversationType_PRIVATE;
        chatVC.targetId = teacher.third_id;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.rootScrollView) {
        if (scrollView.contentOffset.y>self.bannerScrollView.bottom) {
            self.tempMenuView.hidden = NO;
            self.subjectMenuView.hidden = YES;
        }else{
            self.tempMenuView.hidden = YES;
            self.subjectMenuView.hidden = NO;
        }
    }
}

#pragma mark -- SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    if (menuView==self.subjectMenuView) {
        self.tempMenuView.currentIndex = index;
    }else{
        self.subjectMenuView.currentIndex = index;
    }
    subjectIndex = index+1;
    [self loadTeachersData];
}

#pragma mark SDCycleScrollViewDelegate
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    [MobClick event:kStaticsBannerEvent];
    BannerModel *banner = self.bannersArray[index];
    NSInteger bannerCate = [banner.banner_cate integerValue];
    if (bannerCate==1) { //内链
        BaseWebViewController *webVC = [[BaseWebViewController alloc] init];
        webVC.urlStr = banner.banner_url;
        webVC.webTitle = banner.banner_name;
        [self.navigationController pushViewController:webVC animated:YES];
    }else if(bannerCate==2){ //外链
        NSString *url=banner.banner_url;
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:url];
        [application openURL:URL options:@{} completionHandler:^(BOOL success) {
            MyLog(@"iOS10 Open %@: %d",url,success);
        }];
    }else {
        if ([banner.custom isEqualToString:@"experience"]) {
            ExperienceBuyViewController *expVC = [[ExperienceBuyViewController alloc] init];
            expVC.selGrade = [NSUserDefaultsInfos getValueforKey:kUserGrade];
            [self.navigationController pushViewController:expVC animated:YES];
        }else if ([banner.custom isEqualToString:@"invite"]){
            BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
            if (!paySwitch) {
                CoachCouponViewController *coachCouponVC = [[CoachCouponViewController alloc] init];
                [self.navigationController pushViewController:coachCouponVC animated:YES];
            }
        }
    }
}

#pragma mark -- Private methods
#pragma mark 加载老师数据
-(void)loadTeachersData{
    [[HttpRequest sharedInstance] postWithURLString:kTeacherAPI parameters:@{@"token":kUserTokenValue,@"subject":[NSNumber numberWithInteger:subjectIndex]} success:^(id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        //banner
        NSArray *banners = [data valueForKey:@"banner"];
        NSMutableArray *tempBannerArr = [[NSMutableArray alloc] init];
        NSMutableArray *tempBannerImgArr  = [[NSMutableArray alloc] init];
        BOOL paySwitch = [[NSUserDefaultsInfos getValueforKey:kPaySwitch] boolValue];
        for (NSDictionary *dict in banners) {
            BannerModel *banner = [[BannerModel alloc] init];
            [banner setValues:dict];
            if (!paySwitch||![banner.custom isEqualToString:@"experience"]) {
                [tempBannerArr addObject:banner];
                [tempBannerImgArr addObject:banner.banner_pic];
            }
        }
        self.bannersArray = tempBannerArr;
        
        //老师
        NSArray *teachers = [data valueForKey:@"teacher"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in teachers) {
            TeacherModel *model = [[TeacherModel alloc] init];
            [model setValues:dict];
            if ([model.recommend boolValue]) {
                [tempArr insertObject:model atIndex:0];
            }else{
               [tempArr addObject:model];
            }
        }
        self.teachersArray = tempArr;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootScrollView.mj_header endRefreshing];
            CGFloat topHeight;
            if (self.bannersArray.count>0) {
                self.bannerScrollView.hidden = NO;
                self.bannerScrollView.imageURLStringsGroup = tempBannerImgArr;
                topHeight = self.bannerScrollView.bottom+10;
            }else{
                self.bannerScrollView.hidden = YES;
                topHeight = kNavHeight;
            }
            self.subjectMenuView.frame = CGRectMake(0, topHeight, kScreenWidth, 40);
            
            self.myTableView.teachersArr = self.teachersArray;
            [self.myTableView reloadData];
            self.myTableView.frame = CGRectMake(0, self.subjectMenuView.bottom, kScreenWidth, kCellHeight*self.teachersArray.count);
            self.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.myTableView.top+self.myTableView.height);
        });
        
    }failure:^(NSString *errorStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootScrollView.mj_header endRefreshing];
            [self.view makeToast:errorStr duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 初始化
-(void)initTeacherView{
    [self.view addSubview:self.navbarView];
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.bannerScrollView];
    [self.rootScrollView addSubview:self.subjectMenuView];
    [self.rootScrollView addSubview:self.myTableView];
    
    [self.view addSubview:self.tempMenuView];
    self.tempMenuView.hidden = YES;
}

#pragma mark -- Setters and Getters
#pragma mark 导航栏
-(UIView *)navbarView{
    if (!_navbarView) {
        _navbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        _navbarView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(18, KStatusHeight+12, 160,IS_IPAD?36:20)];
        titleLabel.textColor=[UIColor commonColor_black];
        titleLabel.font= [UIFont mediumFontWithSize:20.0f];
        titleLabel.text = @"作业辅导";
        [_navbarView addSubview:titleLabel];
        
        UIButton *rightBtn=[[UIButton alloc] initWithFrame:IS_IPAD?CGRectMake(kScreenWidth-60, KStatusHeight+9,50,50):CGRectMake(kScreenWidth-45, KStatusHeight+2, 40, 40)];
        [rightBtn setImage:[UIImage drawImageWithName:@"tutor_service" size:IS_IPAD?CGSizeMake(30, 30):CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(pushToCustomerServiceVC) forControlEvents:UIControlEventTouchUpInside];
        [_navbarView addSubview:rightBtn];
    }
    return _navbarView;
}

#pragma mark 跟滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kTabHeight-kNavHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor = [UIColor whiteColor];
        _rootScrollView.delegate = self;
        
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadTeachersData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _rootScrollView.mj_header=header;
    }
    return _rootScrollView;
}

#pragma mark banner
-(SDCycleScrollView *)bannerScrollView{
    if (!_bannerScrollView) {
        _bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(16,0,kScreenWidth-32,(kScreenWidth-32)*(136.0/343.0)) delegate:self placeholderImage:[UIImage imageNamed:@"banner_default"]];
        _bannerScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        _bannerScrollView.autoScrollTimeInterval = 4;
        _bannerScrollView.currentPageDotColor = [UIColor systemColor];
        [_bannerScrollView setBorderWithCornerRadius:6.0 type:UIViewCornerTypeAll];
        _bannerScrollView.pageDotColor = [UIColor whiteColor];
    }
    return _bannerScrollView;
}

#pragma mark 菜单栏
-(SlideMenuView *)subjectMenuView{
    if (!_subjectMenuView) {
        _subjectMenuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, self.bannerScrollView.bottom, kScreenWidth, 40) btnTitleFont:[UIFont regularFontWithSize:14.0f] color:[UIColor commonColor_black] selColor:[UIColor commonColor_black]];
        _subjectMenuView.selectTitleFont = [UIFont mediumFontWithSize:20.0f];
        _subjectMenuView.myTitleArray =[NSMutableArray arrayWithArray:subjects];
        _subjectMenuView.currentIndex = 0;
        _subjectMenuView.delegate = self;
    }
    return _subjectMenuView;
}

#pragma mark
-(SlideMenuView *)tempMenuView{
    if (!_tempMenuView) {
        _tempMenuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,IS_IPAD?56:40) btnTitleFont:[UIFont regularFontWithSize:14.0f] color:[UIColor commonColor_black] selColor:[UIColor commonColor_black]];
        _tempMenuView.backgroundColor = [UIColor whiteColor];
        _tempMenuView.selectTitleFont = [UIFont mediumFontWithSize:20.0f];
        _tempMenuView.myTitleArray =[NSMutableArray arrayWithArray:subjects];
        _tempMenuView.currentIndex = 0;
        _tempMenuView.delegate = self;
    }
    return _tempMenuView;
}

#pragma mark 老师列表
-(TeacherTableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[TeacherTableView alloc] initWithFrame:CGRectMake(0,self.subjectMenuView.bottom, kScreenWidth, kScreenHeight-self.subjectMenuView.bottom-kTabHeight) style:UITableViewStylePlain];
        _myTableView.viewDelegate = self;
        _myTableView.scrollEnabled = NO;
    }
    return _myTableView;
}

-(NSMutableArray *)bannersArray{
    if (!_bannersArray) {
        _bannersArray = [[NSMutableArray alloc] init];
    }
    return _bannersArray;
}


-(NSMutableArray *)teachersArray{
    if (!_teachersArray) {
        _teachersArray = [[NSMutableArray alloc] init];
    }
    return _teachersArray;
}

@end
