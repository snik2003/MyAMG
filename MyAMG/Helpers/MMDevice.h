//
//  MMDevice.h
//  mymercedes
//
//  Created by Alexander Koulabuhov on 15/01/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMDevice : NSObject

+(NSString *)platform;
+(NSString *)platformString;
+(NSString *)applicationVersionString;
+(NSString *)applicationShortVersionString;

+(NSString *)fullDeviceInfo;

@end
