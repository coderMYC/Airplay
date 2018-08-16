//
//  ViewController.m
//  AirplayTest
//
//  Created by 马雨辰 on 2018/8/7.
//  Copyright © 2018年 马雨辰. All rights reserved.
//

#import "ViewController.h"
#import "MYCAirplayManager.h"

@interface ViewController ()<MYCAirplayManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [MYCAirplayManager sharedManager].delegate = self;
    
    
    CGFloat width = 100;
    CGFloat height = 30;
    CGFloat x1 = 40;
    CGFloat x2 = 150;
    CGFloat y1 = 40;
    CGFloat interval = 30;
    
    UIButton *button = [[UIButton alloc]init];
    button.frame = CGRectMake(x1, y1 + interval, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"查找设备" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(searchButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x1, (y1 + interval) *  2, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"连接设备" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(activateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x2, (y1 + interval) *  2, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"断开设备" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeSocketButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x1, (y1 + interval) *  3,width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"开始播放" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    

    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x2, (y1 + interval) *  3, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"退出播放" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(stopButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x2, (y1 + interval) *  4, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"继续播放" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x1, (y1 + interval) *  4, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"暂停" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [[UIButton alloc]init];
    button.frame = CGRectMake(x1, (y1 + interval) *  5, width,height);
    button.backgroundColor = [UIColor yellowColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"快进" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(progressButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
}

-(void)searchButtonClick
{
    [[MYCAirplayManager sharedManager] searchAirplayDeviceWithTimeOut:15];
}

-(void)activateButtonClick
{
    [[MYCAirplayManager sharedManager] activateSocketToDevice:[MYCAirplayManager sharedManager].deviceList.firstObject];
}

-(void)closeSocketButtonClick
{
    [[MYCAirplayManager sharedManager] closeSocket];
}

-(void)startButtonClick
{
    [[MYCAirplayManager sharedManager] playVideoOnAirplayDevice:[MYCAirplayManager sharedManager].deviceList.firstObject videoUrlStr:@"http://v3.cztv.com/cztv/vod/2018/06/28/7c45987529ea410dad7c088ba3b53dac/h264_1500k_mp4.mp4"];
}


-(void)progressButtonClick
{
    [[MYCAirplayManager sharedManager] seekPlayTime:100.0];
}

-(void)pauseButtonClick
{
    [[MYCAirplayManager sharedManager] pauseVideoPlay];
}

-(void)playButtonClick
{
    [[MYCAirplayManager sharedManager] playVideo];
}



-(void)stopButtonClick
{
    [[MYCAirplayManager sharedManager] stop];
}


#pragma mark -- MYCAirplayManagerDelegate

- (void)MYCAirplayManager:(MYCAirplayManager *)airplayManager searchedAirplayDevice:(NSMutableArray<MYCAirplayDevice *> *)deviceList
{
    NSLog(@"已经获取到设备列表");
}

-(void)MYCAirplayManager:(MYCAirplayManager *)airplayManager searchAirplayDeviceFinish:(NSMutableArray<MYCAirplayDevice *> *)deviceList
{
    NSLog(@"搜索设备操作完成");
}

-(void)MYCAirplayManager:(MYCAirplayManager *)airplayManager selectedDeviceOnLine:(MYCAirplayDevice *)airplayDevice
{
    NSLog(@"设备已连接---%@",airplayDevice.displayName);
}

- (void)MYCAirplayManager:(MYCAirplayManager *)airplayManager selectedDeviceDisconnect:(MYCAirplayDevice *)airplayDevice
{
    NSLog(@"设备已断开---%@",airplayDevice.displayName);
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
