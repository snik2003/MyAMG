//
//  API_ENDPOINTS.m
//  mymercedes
//
//  Created by Александр Кулабухов on 15/09/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import "API_BASE_URL.h"
#import "APIEndpoints.h"

static NSString * const kAPI_BASE_URL_ExceptionName = @"API_BASE_URL";

/*
 * Lazy initialized in-memory cache for Url's
 */
static NSMutableDictionary *p_baseUrlMemoryCache;

@interface API_BASE_URL()

+(NSString *)p_defaultBaseUrlForProject:(API_PROJECT)project;

@end

@implementation API_BASE_URL


+(NSString *)baseUrlForProject:(API_PROJECT)project {
    
    NSString *baseUrl = [self p_defaultBaseUrlForProject:project];
    
    if (!baseUrl) {
        @throw [NSException exceptionWithName:kAPI_BASE_URL_ExceptionName reason:@"No default URL for project" userInfo:nil];
    }
    
    return baseUrl;
}

+(NSString *)p_defaultBaseUrlForProject:(API_PROJECT)project {
    
    if (TEST_SERVER) {
        switch (project) {
            case API_PROJECT_ECF:
                return kBaseECFURLDebug;
            case API_PROJECT_ECF_IDENTITY:
                return kBaseECFIDURLDebug;
            case API_PROJECT_USED:
                return kBaseUsedURLDebug;
            case API_PROJECT_DEALERS:
                return kBaseDealersURLDebug;
            case API_PROJECT_SERVICE:
                return kBaseServiceURLDebug;
            case API_PROJECT_TEST_DRIVE:
                return kBaseTestDriveURLDebug;
            case API_PROJECT_RCF_FEEDBACK:
                return kBaseRCFURLDebug;
            case API_PROJECT_PARTS_PRICE:
                return kBasePartsURLDebug;
            case API_PROJECT_SERVICE_PRICE:
                return kBaseSPURLDebug;
            case API_PROJECT_MOBILE_APP_CMS:
                return kBaseCMSURLDebug;
            case API_PROJECT_PROGRAM_3_PLUS:
                return kBase3PlusURLDebug;
            case API_PROJECT_IDENTITY_SERVER:
                return kIdentityServerURLDebug;
            case API_PROJECT_SERVICE_CERTIFICATE:
                return kBaseSCURLDebug;
            case API_PROJECT_TEST_DRIVE_MOBILE_STARS:
                return kBaseTestDriveOutURLDebug;
            case API_PROJECT_OCR:
                return kBaseOCRAPIURL;
            case API_PROJECT_PROGRAM_LOYALITY:
                return kBaseLoyalityURLDebug;
            case API_PROJECT_CONTACTS_DB:
                return kContactsURLDebug;
            case API_PROJECT_MY_AMG:
                return amgCMSURLDebug;
            case API_PROJECTS_COUNT:
                @throw [NSException exceptionWithName:kAPI_BASE_URL_ExceptionName reason:@"API_PROJECTS_COUNT isn't a valid project id" userInfo:nil];
        }
    }
    else {
        switch (project) {
            case API_PROJECT_ECF:
                return kBaseECFURL;
            case API_PROJECT_ECF_IDENTITY:
                return kBaseECFIDURL;
            case API_PROJECT_USED:
                return kBaseUsedURL;
            case API_PROJECT_DEALERS:
                return kBaseDealersURL;
            case API_PROJECT_SERVICE:
                return kBaseServiceURL;
            case API_PROJECT_TEST_DRIVE:
                return kBaseTestDriveURL;
            case API_PROJECT_RCF_FEEDBACK:
                return kBaseRCFURL;
            case API_PROJECT_PARTS_PRICE:
                return kBasePartsURL;
            case API_PROJECT_SERVICE_PRICE:
                return kBaseSPURL;
            case API_PROJECT_MOBILE_APP_CMS:
                return kBaseCMSURL;
            case API_PROJECT_PROGRAM_3_PLUS:
                return kBase3PlusURL;
            case API_PROJECT_IDENTITY_SERVER:
                return kIdentityServerURL;
            case API_PROJECT_SERVICE_CERTIFICATE:
                return kBaseSCURL;
            case API_PROJECT_TEST_DRIVE_MOBILE_STARS:
                return kBaseTestDriveOutURL;
            case API_PROJECT_OCR:
                return kBaseOCRAPIURL;
            case API_PROJECT_PROGRAM_LOYALITY:
                return kBaseLoyalityURL;
            case API_PROJECT_CONTACTS_DB:
                return kContactsURL;
            case API_PROJECT_MY_AMG:
                return amgCMSURL;
            case API_PROJECTS_COUNT:
                @throw [NSException exceptionWithName:kAPI_BASE_URL_ExceptionName reason:@"API_PROJECTS_COUNT isn't a valid project id" userInfo:nil];
        }
    }
}

@end
