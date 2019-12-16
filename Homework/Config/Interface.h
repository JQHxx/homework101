//
//  Interface.h
//  Homework
//
//  Created by vision on 2019/9/5.
//  Copyright © 2019 vision. All rights reserved.
//

#ifndef Interface_h
#define Interface_h


#endif /* Interface_h */

#define isTrueEnvironment 1

#if isTrueEnvironment
//正式环境
#define kHostURL          @"https://tpi.zuoye101.com"
#define kHostTempURL      @"https://tpi.zuoye101.com%@"

#define kRongCloudAppKey    @"y745wfm8yqb3v"



#else

//测试环境
#define kHostURL          @"https://test.zuoye101.com"
#define kHostTempURL      @"https://test.zuoye101.com%@"

#define kRongCloudAppKey    @"sfci50a7s3bwi"


#endif


/***public***/
#define kUploadPicAPI          @"/student/upload"            //上传图片
#define kUploadDeviceInfoAPI   @"/student/device"               //上传设备信息
#define kRongCloudInfoAPI      @"/student/teacher/search_teacher"       //根据融云ID获取老师信息
#define kVersionUpdateAPI      @"/student/version/app_version"      //版本更新
#define kCheckSwitchAPI        @"/student/user/search_switch"       //开关

//登录
#define kGetCodeSign           @"/admin/code/get"            //发送手机验证码
#define kLoginAPI              @"/student/user/login"        //登录
#define kGetUserInfoAPI        @"/student/user"              //获取用户信息
#define kSetUserInfoAPI        @"/student/user/setinfo"      //设置用户信息
#define kGuideExpPageAPI       @"/student/order/experience"  //辅导体验界面信息
#define kExperiencePayAPI      @"/student/order/experience_pay"    //优惠体验购买
#define kExpTeacherAPI         @"/student/teacher/experience_teacher"   //体验购买老师

//首页
#define kMyTeachersAPI         @"/student/guide/teacher"        //我的老师
#define kStartCoachAPI         @"/student/guide/start_guide"    //开始辅导
#define kEndCoachAPI           @"/student/guide/end_guide"      //结束辅导
#define kUnreadMessageAPI      @"/student/message/check_message"  //消息是否已读
#define kRemoteMessagesAPI     @"/student/message"               //消息列表
#define kEmptyMessagesAPI      @"/student/message/empty_message" //清空消息
#define kEvaluateTeacherAPI    @"/student/teacher/evaluate"      //评价

//老师
#define kTeacherAPI             @"/student/teacher"              //老师
#define kReportReasonsAPI       @"/student/complain"             //投诉信息
#define kReportSubmitAPI        @"/student/complain/report"      //提交投诉
#define kChooseCouponAPI        @"/student/cash/choose_cash"     //选择优惠券
#define kCoachPriceAPI          @"/student/cash/guide_info"       //辅导价格
#define kCoachCouponsAPI        @"/student/cash"                  //辅导优惠券
#define kReceiveCouponsAPI      @"/student/teacher/draw_coupon"   //领取辅导优惠券

//我的
#define kMineApI               @"/student"                         //我的
#define kMyCouponsAPI          @"/student/index/coupon"            //我的优惠券
#define kConsumeRecordsAPI     @"/student/index/consume_log"       //消费记录
#define kGuideRecordsAPI       @"/student/index/guide_log"         //辅导记录
#define kGuideFeedbackAPI      @"/student/index/guide_feedback"    //辅导反馈
#define kGuidePayAPI           @"/student/order/pay"                //支付

#define kLogoutAPI            @"/student/user/logout"               //注销账号


/**内购**/
#define kPurchaseOrderAPI       @"/student/apple/order"                 //创建订单
#define kPurchaseCallBackAPI    @"/student/apple"                        //订单支付回调


//h5
#define kUserAgreementURL      @"/agreement.html"           //用户协议
#define kAboutUsURL            @"/index/teacher/aboutus"   //关于我们
#define kShareLandingURL       @"/index/student/invite"     //分享落地页
#define kTeacherDetailsUrl     @"/index/teacher/detail"
#define kAdvantageIntroUrl     @"/index/teacher/advantage"

