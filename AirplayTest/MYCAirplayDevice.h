//
//  MYCAirplayDevice.h
//  AirplayTest
//
//  Created by 马雨辰 on 2018/8/13.
//  Copyright © 2018年 马雨辰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYCAirplayDevice : NSObject

@property(nonatomic,strong)NSNetService *netService;

/**
 设备显示名称(如 客厅的电视 )
 */
@property(nonatomic,copy)NSString *displayName;


@property(nonatomic,copy)NSString *hostName;

@property(nonatomic,assign)UInt16 port;

@property(nonatomic,copy)NSString *type;

@property(nonatomic,copy)NSString *domain;


-(void)refreshInfo;


@end

