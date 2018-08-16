//
//  MYCAirplayManager.m
//  AirplayTest
//
//  Created by 马雨辰 on 2018/8/9.
//  Copyright © 2018年 马雨辰. All rights reserved.
//

#import "MYCAirplayManager.h"
#import "GCDAsyncSocket.h"
@interface MYCAirplayManager()<NSNetServiceBrowserDelegate,NSNetServiceDelegate,GCDAsyncSocketDelegate>

@property(nonatomic,strong)NSNetServiceBrowser *serviceBrowser;

@property(nonatomic,strong)GCDAsyncSocket *socket;

@property(nonatomic,assign)BOOL userCloseSocket;//用户主动断开socket


@end

@implementation MYCAirplayManager

static MYCAirplayManager*_shardManager;

+ (MYCAirplayManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shardManager = [[MYCAirplayManager alloc]init];
    });
    return _shardManager;
}


-(instancetype)init
{
    self = [super init];
    if(self)
    {
//        [self searchAirplayDevice];
    }
    return self;
}


/**
 搜索可支持Airplay的设备
 */
-(void)searchAirplayDeviceWithTimeOut:(CGFloat)timeout
{
    NSLog(@"搜索可支持的设备");
    //先清空临时数据
    [self clearCacheData];
    
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@"local."];
    
    double delayInSeconds = timeout;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(MYCAirplayManager:searchAirplayDeviceFinish:)])
        {
            [self.delegate MYCAirplayManager:self searchAirplayDeviceFinish:self.deviceList];
        }
    });
}



-(NSMutableArray *)deviceList
{
    if(_deviceList == nil)
    {
        _deviceList = [[NSMutableArray alloc]init];
    }
    
    return  _deviceList;
}

#pragma mark NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [aNetService setDelegate:self];
    [aNetService resolveWithTimeout:20.0];
    
    MYCAirplayDevice *airplayDevice = [[MYCAirplayDevice alloc]init];
    airplayDevice.netService = aNetService;
    
    [self.deviceList addObject:airplayDevice];

    if(!moreComing)
    {
        NSLog(@"找到设备完成");
        [self.serviceBrowser stop];
        self.serviceBrowser = nil;
    }
}


#pragma mark NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    for(NSInteger i = 0 ; i< self.deviceList.count ; i++)
    {
        MYCAirplayDevice *device = [self.deviceList objectAtIndex:i];
        
        if(sender == device.netService)
        {
            [device refreshInfo];
            break;
        }
    }
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(MYCAirplayManager:searchedAirplayDevice:)])
    {
        [self.delegate MYCAirplayManager:self searchedAirplayDevice:self.deviceList];
    }
}



#pragma mark -- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    self.socketIsOnLine = YES;

    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(MYCAirplayManager:selectedDeviceOnLine:)])
    {
        [self.delegate MYCAirplayManager:self selectedDeviceOnLine:self.selectedDevice];
    }
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    self.socketIsOnLine = NO;
    
    if(self.userCloseSocket)
    {
        self.userCloseSocket = NO;

        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(MYCAirplayManager:selectedDeviceDisconnect:)])
        {
            [self.delegate MYCAirplayManager:self selectedDeviceDisconnect:self.selectedDevice];
        }
        
        return;
    }
    
    [self activateSocketToDevice:self.selectedDevice];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"dataStr----%@",dataStr);
    
    
    [self.socket readDataWithTimeout:- 1 tag:0];
    
}


#pragma mark -- 用户操作

/**
 激活socket
 
 @param device 链接的设备
 */
-(void)activateSocketToDevice:(MYCAirplayDevice *)device
{
    
    if(self.socket == nil)
    {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    
    if(self.socketIsOnLine)
    {
        if([self.selectedDevice.hostName isEqualToString:device.hostName] && self.selectedDevice.port == device.port)
        {
            //同一台设备，同一个端口
            
            return;
        }
        else
        {
            [self.socket disconnect];
        }
    }
    
    NSError *error = nil;
    
    [self.socket connectToHost:device.hostName onPort:device.port viaInterface:nil withTimeout:-1 error:&error];
    
    self.selectedDevice = device;
}



/**
 在Airplay设备上播放视频
 
 @param airplayDeivce 播放设备
 @param videoUrlStr 视频url
 */
-(void)playVideoOnAirplayDevice:(MYCAirplayDevice *)airplayDeivce videoUrlStr:(NSString *)videoUrlStr
{
    NSString *url = videoUrlStr;
    
    NSString *body = [[NSString alloc] initWithFormat:@"Content-Location: %@\r\n"
                      "Start-Position: 0\r\n", url];
    NSUInteger length = [body length];
    
    NSString *message = [[NSString alloc] initWithFormat:@"POST /play HTTP/1.1\r\n"
                         "Content-Length: %lu\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n%@", (unsigned long)length, body];
    
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];

    [self sendData:data withTag:0];
}






/**
 快进到某个播放时间
 @param playTime 播放时间（秒）
 */
-(void)seekPlayTime:(CGFloat)playTime
{
    NSLog(@"快进点击");
    NSString *message = [[NSString alloc] initWithFormat:@"POST /scrub?position=%f HTTP/1.1\r\n\r\n"
                         "Content-Length: 0"
                         "User-Agent: MediaControl/1.0\r\n\r\n",playTime];

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendData:data withTag:3];
}




/**
 暂停正在播放的视频
 */
-(void)pauseVideoPlay
{
    NSString *message = [[NSString alloc] initWithFormat:@"POST /rate?value=0.0 HTTP/1.1\r\n\r\n"
                         "Content-Length: 0"
                         "User-Agent: MediaControl/1.0\r\n\r\n"];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendData:data withTag:2];
}



/**
 继续播放
 */
-(void)playVideo
{
    NSString *message = [[NSString alloc] initWithFormat:@"POST /rate?value=1.0 HTTP/1.1\r\n\r\n"
                         "Content-Length: 0"
                         "User-Agent: MediaControl/1.0\r\n\r\n"];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendData:data withTag:1];
}



/**
 退出播放
 */
-(void)stop
{
    NSString *message = [[NSString alloc] initWithFormat:@"POST /stop HTTP/1.1\r\n\r\n"
                         "Content-Length: 0"
                         "User-Agent: MediaControl/1.0\r\n\r\n"];

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendData:data withTag:0];
}

-(void)closeSocket
{
    self.userCloseSocket = YES;
    
    [self.socket disconnect];
}

-(void)sendData:(NSData *)data withTag:(long )tag
{
    [self.socket writeData:data withTimeout:-1 tag:tag];
    
    [self.socket readDataWithTimeout:-1 tag:tag];
    
}



-(void)clearCacheData
{
    [self.deviceList removeAllObjects];
}


@end
