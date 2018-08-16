//
//  MYCAirplayManager.h
//  AirplayTest
//
//  Created by 马雨辰 on 2018/8/9.
//  Copyright © 2018年 马雨辰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYCAirplayDevice.h"
#import <UIKit/UIKit.h>

@class MYCAirplayManager;

@protocol MYCAirplayManagerDelegate <NSObject>

/**
 搜索到了可支持的设备完成

 在执行 searchAirplayDevice 搜索到设备后调用
 
 @param deviceList 设备列表
 */
-(void)MYCAirplayManager:(MYCAirplayManager *)airplayManager searchedAirplayDevice:(NSMutableArray <MYCAirplayDevice *>*)deviceList;




/**
 搜索设备完成
 @param deviceList 设备列表（如果为空，则表明没有搜索到支持Airplay的设备）
 */
-(void)MYCAirplayManager:(MYCAirplayManager *)airplayManager searchAirplayDeviceFinish:(NSMutableArray <MYCAirplayDevice *>*)deviceList;





/**
 设备已经连通后回调此代理
 */
-(void)MYCAirplayManager:(MYCAirplayManager *)airplayManager selectedDeviceOnLine:(MYCAirplayDevice *)airplayDevice;


/**
 设备已经断开后回调此代理
 */
-(void)MYCAirplayManager:(MYCAirplayManager *)airplayManager selectedDeviceDisconnect:(MYCAirplayDevice *)airplayDevice;

@end



@interface MYCAirplayManager : NSObject

+ (MYCAirplayManager *)sharedManager;

@property(nonatomic,assign)BOOL socketIsOnLine;//socket是否在线

/**
 用户选中的设备
 */
@property(nonatomic,strong)MYCAirplayDevice *selectedDevice;

/**
 支持Airplay的设备列表
 */
@property(nonatomic,strong)NSMutableArray <MYCAirplayDevice *>*deviceList;


@property(nonatomic,assign)id<MYCAirplayManagerDelegate>delegate;



/**
 搜索可支持Airplay的设备
 @param timeout 超时时间
 */
-(void)searchAirplayDeviceWithTimeOut:(CGFloat )timeout;

/**
 激活socket
 @param device 链接的设备
 */
-(void)activateSocketToDevice:(MYCAirplayDevice *)device;


/**
 断开socket
 */
-(void)closeSocket;

/**
 在Airplay设备上播放视频

 @param airplayDeivce 播放设备
 @param videoUrlStr 视频url
 */
-(void)playVideoOnAirplayDevice:(MYCAirplayDevice *)airplayDeivce videoUrlStr:(NSString *)videoUrlStr;


/**
 快进到某个播放时间
 @param playTime 播放时间（秒）
 */
-(void)seekPlayTime:(CGFloat)playTime;


/**
 暂停视频播放
 */
-(void)pauseVideoPlay;



/**
 继续播放视频（暂停状态下）
 */
-(void)playVideo;



/**
 退出播放
 */
-(void)stop;



@end
