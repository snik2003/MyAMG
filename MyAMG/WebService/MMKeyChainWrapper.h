//
//  MMKeyChainWrapper.h
//  mymercedes
//
//  Created by Alexander Koulabuhov on 01/02/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMKeyChainWrapper : NSObject

+ (BOOL)setObject:(id)value forKey:(NSString*)key;
+ (BOOL)removeValueForKey:(NSString *)key;
+ (id)objectForKey:(NSString*)key;

@end
