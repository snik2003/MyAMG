//
//  MMKeyChainWrapper.m
//  mymercedes
//
//  Created by Alexander Koulabuhov on 01/02/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import "MMKeyChainWrapper.h"

#define CHECK_OSSTATUS_FOR_ERROR(x) (x == noErr) ? YES : NO

@implementation MMKeyChainWrapper

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key{
  
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithDictionary:
                                          @{(__bridge id)kSecClass            : (__bridge id)kSecClassGenericPassword,
                                            (__bridge id)kSecAttrService      : key,
                                            (__bridge id)kSecAttrAccount      : key,
                                            (__bridge id)kSecAttrAccessible   : (__bridge id)kSecAttrAccessibleAfterFirstUnlock
                                            }];
    return keychainQuery;
}

+ (BOOL)setObject:(id)value forKey:(NSString*)key{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    
    [self removeValueForKey:key];
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:(__bridge id)kSecValueData];
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    
    return CHECK_OSSTATUS_FOR_ERROR(result);
}

+ (BOOL)removeValueForKey:(NSString *)key{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    
    return CHECK_OSSTATUS_FOR_ERROR(result);
}

+ (id)objectForKey:(NSString*)key{
    id value = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    CFDataRef keyData = NULL;
    
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", key, e);
            value = nil;
        }
        @finally {}
    }
    
    if (keyData) {
        CFRelease(keyData);
    }
    
    return value;
}

@end
