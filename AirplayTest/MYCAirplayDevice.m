//
//  MYCAirplayDevice.m
//  AirplayTest
//
//  Created by 马雨辰 on 2018/8/13.
//  Copyright © 2018年 马雨辰. All rights reserved.
//

#import "MYCAirplayDevice.h"

@implementation MYCAirplayDevice

-(void)refreshInfo
{
    self.displayName = self.netService.name;
    self.hostName = self.netService.hostName;
    self.port = self.netService.port;
    self.type = self.netService.type;
    self.domain = self.netService.domain;
}

@end
