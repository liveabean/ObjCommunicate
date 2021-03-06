
//  SearchViewController.m
//  UI
//
//  Created by WeixiYu on 15/7/15.
//  Copyright (c) 2015年 liveabean. All rights reserved.
//

#import "SearchViewController.h"
#import "GCDAsyncSocket.h"
#import "KeyboardToolbar.h"
#import "SearchResultsViewController.h"

@interface SearchViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,KeyboardDelegate,UIAlertViewDelegate>{
    NSArray *canteens;
    NSMutableString *sendStr;
    NSString *receiveStr;
    NSDateFormatter *dateFormat;
    GCDAsyncSocket *socket;;
}
//UIView
@property (weak, nonatomic) IBOutlet UIPickerView *location;
@property (weak, nonatomic) IBOutlet UITextField *fromDate;
@property (weak, nonatomic) IBOutlet UITextField *toDate;
@property (assign,nonatomic) NSInteger selectedCanteen;
@property (strong,nonatomic) UIDatePicker *datePicker;
@property (strong,nonatomic) UIAlertView *alert;


//测试能否正确判断
- (IBAction)startSearch:(id)sender;
//测试能否正常进入下一个页面
@end


@implementation SearchViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //Test
    self.fromDate.text=@"2015/1/1";
    self.toDate.text=@"2015/8/2";
    self.selectedCanteen=3;
    
    self.navigationController.navigationBarHidden=YES;
    
    canteens=@[@"全部",@"荔山餐厅",@"实验餐厅",@"荔天餐厅",@"听荔教工餐厅",@"文山湖餐厅",@"凯风清真餐厅",@"老西南(晨风餐厅)",@"小西南餐厅",@"文科楼西北谷餐厅",@"南区饭堂"];
    self.selectedCanteen=0;
    
    //获得当前时间
    NSDate *nowDate=[[NSDate alloc]init];
    dateFormat=[[NSDateFormatter alloc]init];
    dateFormat.dateFormat=@"yyyy/MM/dd";
    
    //初始化sendStr
    sendStr=[[NSMutableString alloc]init];
    [sendStr appendString:@"chaxun:2012160063:"];
    NSString *initStr=[dateFormat stringFromDate:nowDate];
    [sendStr appendFormat:@"%@:%@:0",initStr,initStr];

    //创建datePicker
    self.datePicker=[[UIDatePicker alloc]init];
    self.datePicker.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"zh"];
    self.datePicker.datePickerMode=UIDatePickerModeDate;
    self.datePicker.maximumDate=nowDate;
    //创建keyboardToolbar
    KeyboardToolbar *keyToolBar=[KeyboardToolbar toolBar];
    keyToolBar.kbDelegate=self;
    
    //fromDateField
    self.fromDate.inputView=self.datePicker;
    self.fromDate.inputAccessoryView=keyToolBar;
    
    //toDateField
    self.toDate.inputView=self.datePicker;
    self.toDate.inputAccessoryView=keyToolBar;
}



#pragma mark sendStr 的方法 
// sendStr----chaxun:2012160063:2015/7/16:2015/7/19:1
// sendArr----  0      1           2       3       4
-(void)setSendStrFromDate:(NSString *)str{
    [self replaceSendStrAt:2 withStr:str];
}
-(void)setSendStrToDate:(NSString *)str{
    [self replaceSendStrAt:3 withStr:str];
}
-(void)setSendStrLocation:(NSInteger)index{
    [self replaceSendStrAt:4 withStr:[NSString stringWithFormat:@"%ld",(long)index]];
}
//封装了设置sendStr的方法
-(void)replaceSendStrAt:(NSInteger)index withStr:(NSString *)str{
    ///采用这种方式 而不是-(void) replaceCharactersInRange:range withString:nsstring使用nsstring替换range指定的字符
    //原因是：时间的长度不一定，比如2015/7/12 和 2015/11/12 而且这种提高服用性
    NSString *send = [NSString stringWithFormat:@"%@",sendStr];
    NSArray *sendArr = [send componentsSeparatedByString:NSLocalizedString(@":", nil)]; //NSString可以转换成NSArray
    [sendStr setString:@""];
    for (int i=0; i<sendArr.count; i++) {
        [sendStr appendFormat:@"%@:",i==index?str:sendArr[i]];
    }
    //sendStr 的末尾多了  @”：“
   [sendStr deleteCharactersInRange:NSMakeRange([sendStr length]-1, 1)];
//    NSLog(@"%@",sendStr);
}




#pragma mark 时间选择的方法
#pragma mark KeyboarToolbarDelegate
-(void)keyboardToolbar:(KeyboardToolbar *)toolbar itemDidSelected:(UIBarButtonItem *)item{

    //将datePicker转化为yyyy/MM/dd格式的字符串
    NSDate *date=self.datePicker.date;
    NSString *dateStr=[dateFormat stringFromDate:date];
    
//判断哪个UITextField的输入
    //fromDate
    if (self.fromDate.isFirstResponder) {
        self.fromDate.text=dateStr;
        self.fromDate.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //测试
        NSLog(@"fromDate:%@",self.fromDate.text);
        //测试
        //[self setSendStrFromDate:self.fromDate.text];
        
        //自动换行
        self.datePicker.minimumDate=date;
        [self.fromDate resignFirstResponder];
        [self.toDate becomeFirstResponder];
    }else {//toDate
        self.toDate.text=dateStr;
        self.toDate.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        [self.toDate resignFirstResponder];
        self.datePicker.minimumDate=nil;
        //测试
        NSLog(@"toDate:%@",self.toDate.text);
    }
}


#pragma mark 地点选择的方法

#pragma mark  UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;//深大餐厅
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return canteens.count;//深大餐厅个数
}
#pragma mark UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return canteens[row];
}
#pragma mark height
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
#pragma mark selectedLocation
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedCanteen=row;
//    NSLog(@"location:%@",canteens[self.selectedCanteen]);
    
//    测试：[self setSendStrLocation:[NSString stringWithFormat:@"%ld",(long)self.selectedCanteen]];
}


#pragma mark 按下开始查询的按钮
- (IBAction)startSearch:(id)sender {
    static int canteenTipTag=0;
    if([self.fromDate.text isEqual:@""]){
        [self showAlertView:0];
    }else if([self.toDate.text isEqual:@""]){
        [self showAlertView:2];
        NSLog(@"here.....");
    }else if(canteenTipTag==0&&!self.selectedCanteen){
        [self showAlertView:1];
        canteenTipTag=1;
    }else{
        [self setSendStrFromDate:self.fromDate.text];
        [self setSendStrToDate:self.toDate.text];
        [self setSendStrLocation:self.selectedCanteen];
        NSLog(@"%s:%@",__func__,sendStr);
        [self performSegueWithIdentifier:@"toSearchResults" sender:nil];
    }
}
#pragma mark 传递查询信息
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVc=segue.destinationViewController;
    if ([destVc isKindOfClass:[SearchResultsViewController class]]) {
        SearchResultsViewController *searchresult =destVc;
        searchresult.sendStr=sendStr;
    }
}

#pragma mark 对AlertView方法的封装
//这个方法用于对alertView的优化，避免多次创建alertView,减少代码量
-(void)showAlertView:(NSInteger )tag{
    //alert存在不需要创建
    if (self.alert) {
        if (tag==1) { //tag==1:location
            //warning 用if判断时要注意 if(tag)  tag只要不是0都会进入！
            self.alert.message=@"点击确定查询全部食堂的记录";
        }else if(tag==2){
            self.alert.message=@"点击确定继续填写\n   查询的结束时间填写不完整";
            NSLog(@"%s,%ld",__func__,(long)tag);
        }else{//tag==0:fromDate
            self.alert.message=@"点击确定继续填写\n   查询的开始时间填写不完整";
        }
    }
    //alert还没创建
    else{
        if (tag==1) { //tag==1:location
            self.alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"点击确定查询全部食堂的记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        }else if (tag==2){
            self.alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"点击确定继续填写\n   查询的结束时间填写不完整" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        } else{//tag==0:fromDate
            self.alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"点击确定继续填写\n   查询的开始时间填写不完整" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        }
    }
    self.alert.tag=tag;
    [self.alert show];
}


#pragma mark 判断用户点击AlertView的那个按钮
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"alertView is clicked");
    if (alertView.tag==0) {
        if (buttonIndex) {
            NSLog(@"User clicked yes in fromDate");
            [self.view endEditing:YES];
            [self.fromDate becomeFirstResponder];
        }
    }else if(alertView.tag==2){
        if (buttonIndex) {
            [self.view endEditing:YES];
            [self.toDate becomeFirstResponder];
        }
    } else {
        if (buttonIndex) {
            [self startSearch:nil];
        }
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



#pragma mark -GCDAsyncSocket
-(void)connect{
    //创建socket
    socket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error=nil;
    
    
    [socket connectToHost:@"172.31.101.139" onPort:5000 error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
}
#pragma mark-GCDAsyncSocketDelegate
//连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%s",__func__);
}
//断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (err) {
        NSLog(@"连接失败");
    } else {
        NSLog(@"正常断开");
    }
}
//发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    //发送成功要有下面这行代码才会调用代理方法 didReadData tag设置发送对应的返回
    [socket readDataWithTimeout:-1 tag:tag];
}
//读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //    NSLog(@"%@",[NSThread currentThread]);
    
    receiveStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (tag==100) {
        NSLog(@"login:%s_______%@",__func__,receiveStr);
    } else if(tag==101){
        NSLog(@"chaxun:%s____%@",__func__,receiveStr);
    }
}
-(void)logIn{
    [self connect];
    NSString *loginStr= @"login:2012160063:123456";
    NSData *data=[loginStr dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:-1 tag:100];
}
- (void)chaxun{
    /*
     注意：需要用不同的变量?
     */
    [self connect];
    NSString *searchStr= @"chaxun:2012160063:2015/7/16:2015/7/19";
    NSData *data2 = [searchStr dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data2 withTimeout:-1 tag:101];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
