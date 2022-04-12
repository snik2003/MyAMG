//
//  API_WRAPPER.m
//  mymercedes
//
//  Created by Alexander Koulabuhov on 19/08/15.
//  Copyright (c) 2015 Daimler AG. All rights reserved.
//

#import "API_WRAPPER.h"
#import "MMKeyChainWrapper.h"
#import "APIEndpoints.h"
#import "MMDevice.h"
#import "MyAMG-Swift.h"

#define deviceType @"iPhone"
#define disallowedUrlSymbols @"!*'();:@&=+$,/?%#[]\" "
#define uploadingImagesJPEGQuality 0.7

#define isRegistered NO

#ifdef DEBUG
static const BOOL DEBUG_MODE = YES;
static const BOOL DEBUG_OUTPUT = YES;
static const BOOL DEBUG_TRIM_RESPONSE = NO;
#else
static const BOOL DEBUG_MODE = NO;
static const BOOL DEBUG_OUTPUT = NO;
static const BOOL DEBUG_TRIM_RESPONSE = NO;
#endif

static NSURLSession * session;

static NSString * boundary = @"------A1eX4Nd3RK0u1abUKh0vBoundary2Jn8hJgv7g";

@implementation API_WRAPPER

+(void)load{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
    //                                        @"X-Device": [MMDevice platformString],
    //                                        @"X-App-Version": [MMDevice applicationVersionString]};
    //configuration.timeoutIntervalForRequest = 30;
    //configuration.timeoutIntervalForResource = 30;
    session = [NSURLSession sessionWithConfiguration:configuration];
}

#pragma mark - Methods

+(void)srvGetGUID:(void (^)(NSData * data))success failure:(void (^)(NSError * error))failure{
    
    NSURL * url = [self composeURLForEndpointURL:amgUserGetGUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvValidateRegistration:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL *url = [self composeURLForEndpointURL:amgValidateRegistration project:API_PROJECT_MY_AMG];
    
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url
                                  authorizationHeaderString:[self identityAuthorizationString] suffix:nil
                                                 HTTPMethod:HTTPMethodPOST
                                                 parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvClassesNamesByBrandId:(int)brandId includeVans:(BOOL)includeVans success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:kAutoClasses project:API_PROJECT_MOBILE_APP_CMS];
    
    NSDictionary * parameters = @{@"vans": @(includeVans)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetModelsForClassId:(int)classId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:kAutoModels project:API_PROJECT_MOBILE_APP_CMS];
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url
                                   authorizationHeaderString:[self identityAuthorizationString]
                                                      suffix:[@(classId) stringValue]
                                                  HTTPMethod:HTTPMethodGET
                                                  parameters:nil];
    [self startRequest:request success:success failure:failure];
}

+(void)srvDealersCities:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    NSURL * url = [self composeURLForEndpointURL:kDealersCities project:API_PROJECT_DEALERS];
    NSDictionary * parameters = @{@"includeSTOA": @(YES)};
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvDealersInCity:(int)cityId excludeVans:(BOOL)excludeVans success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    
    NSURL * url = [self composeURLForEndpointURL:kDealers project:API_PROJECT_MOBILE_APP_CMS];
    NSMutableDictionary * parameters = [@{@"includeSTOA": @(YES),
                                          @"excludeVans": @(excludeVans)} mutableCopy];
    if (cityId != 0) {
        [parameters setObject:@(cityId) forKey:@"cityId"];
    }
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadInSaleECFClassesWithToken:(NSString *)token dealerId:(int)dealerId orCity:(int)cityId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kECFClasses project:API_PROJECT_ECF];
    
    NSDictionary * parameters = @{};
    if (cityId == 0) {
        parameters = dealerId == 0 ? nil : @{@"dealerId": @(dealerId)};
    } else {
        parameters = @{@"cityId": @(cityId)};
    }
    
    NSString *kAuthorizationString = [NSString stringWithFormat:@"Bearer %@",token];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:kAuthorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadInSaleUsedClassesForDealer:(int)dealerId orCity:(int)cityId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:kUsedClasses project:API_PROJECT_USED];
    
    NSDictionary * parameters = @{};
    if (cityId == 0) {
        parameters = dealerId == 0 ? nil : @{@"dealerId": @(dealerId)};
    } else {
        parameters = @{@"cityId": @(cityId)};
    }
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvShowroomsOfDealer:(int)dealerId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    NSURL * url = [self composeURLForEndpointURL:kDealersShowroom project:API_PROJECT_DEALERS];
    if (dealerId == 0) {
        NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
        [self startRequest:request success:success failure:failure];
    } else {
        NSDictionary * parameters = @{@"dealerId": @(dealerId)};
        NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
        [self startRequest:request success:success failure:failure];
    }
}

+(void)srvOrderStatus:(NSString *)dealerOrderNumber orderNumber:(NSString *)orderNumber success:(void (^)(NSData *))success failure:(void (^)(NSError * error)) failure{
    NSURL * url = [self composeURLForEndpointURL:kOrderStatus project:API_PROJECT_ECF];
    
    NSDictionary * parameters = @{@"dealerOrderNumber": dealerOrderNumber,
                                  @"orderNumber": orderNumber};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvPartSearch:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kPartsSearch project:API_PROJECT_PARTS_PRICE];
    
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBasePartsLogin password:kBasePartsPass debugLogin:kBasePartsLoginDebug debugPassword:kBasePartsPassDebug];
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString
                                                      suffix:nil
                                                  HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvPartsSearch:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kPartsMaskSearch project:API_PROJECT_PARTS_PRICE];
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBasePartsLogin password:kBasePartsPass debugLogin:kBasePartsLoginDebug debugPassword:kBasePartsPassDebug];
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString
                                                      suffix:nil
                                                  HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvPartSearchHistoryForUser:(NSString *)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kPartsSearchHistory project:API_PROJECT_PARTS_PRICE];
    NSDictionary * parameters = @{@"guid": userUUID};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvPartAddArticle:(NSDictionary *)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kPartsHistoryAdd project:API_PROJECT_PARTS_PRICE];
    
    //NSDictionary * parameters = @{@"Guid": currentUserGUID,
      //                            @"Article": article};
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBasePartsLogin password:kBasePartsPass debugLogin:kBasePartsLoginDebug debugPassword:kBasePartsPassDebug];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadServiceTypesForShowroomId:(NSNumber *)showRoomId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kServiceTypes project:API_PROJECT_SERVICE];
    
    NSDictionary * parameters;
    if (showRoomId) {
        parameters = @{@"showRoomId": showRoomId};
    }
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetCarAdditionalInfo:(int)carId userGUID:(NSString *)userGUID success:(void (^)(NSData * data))success failure:(void(^)(NSError* error))failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserCarAdditionalInfo userGUID:userGUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:[@(carId) stringValue] HTTPMethod:HTTPMethodGET parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetUserData:(NSString *)userGUID success:(void (^)(NSData *data))success failure: (void (^)(NSError *error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserDataUpd userGUID:userGUID project:API_PROJECT_MY_AMG];
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvUpdateUser:(NSDictionary*)parameters userGUID:(NSString *)userGUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserDataUpd userGUID:userGUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPUT parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvDeleteUserWithId:(NSString*)userGUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    NSURL * url = [self composeURLForEndpointURL:amgUserDelete userGUID:userGUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodDELETE parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvAuthorizeUserWithEmail:(NSString *)email password:(NSString *)password success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSURL * url = [self composeURLForEndpointURL:kIdentityServerGetToken project:API_PROJECT_IDENTITY_SERVER];
    NSData * body = [self composeHTTPBodyWithParameters:@[@"grant_type=custom_password",
                                                          [NSString stringWithFormat:@"username=%@", email],
                                                          [NSString stringWithFormat:@"password=%@", password],
                                                          @"scope=profile"]];
    NSMutableURLRequest * request = [[self composeHTTPPOSTRequestWithUrl:url body:body] mutableCopy];
    [request setValue: TEST_SERVER ? kIdentityServerAuthorizationStringDebug : kIdentityServerAuthorizationString forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (DEBUG_OUTPUT) {
                    NSLog(@"🚫🔑 Authorization error: %@", error.localizedDescription);
                }
                failure(error);
            }
            else {
                NSError * jsonParsingError;
                NSDictionary * tokenData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                NSString * responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (!jsonParsingError && tokenData[@"access_token"]) {
                    
                    if (DEBUG_OUTPUT) {
                        NSLog(@"🔓Authorized: %@", responseString);
                        NSLog(@"-------------------------------------------");
                    }
                    
                    [self saveTokenData:tokenData authorizationType:APIAuthorizationTypeClient];
                    success();
                }
                else {
                    if (DEBUG_OUTPUT) {
                        NSLog(@"🚫🔑 Authorization error, response not parsed, or there is no token:\n%@", responseString);
                        NSLog(@"-------------------------------------------");
                    }
                    if (jsonParsingError) {
                        failure(jsonParsingError);
                    }
                    else {
                        failure([NSError errorWithDomain:@"MMError" code:400 userInfo:tokenData]);
                    }
                }
            }
        });
    }];
    
    [dataTask resume];
}

+(void)srvAuthorizeECF:(void(^)(NSDictionary *tokenData))success failure:(void(^)(NSError *error))failure {
    NSURL * url = [self composeURLForEndpointURL:kIdentityECFGetToken project:API_PROJECT_ECF_IDENTITY];
    NSData * body = [self composeHTTPBodyWithParameters:@[@"grant_type=password",
                                                          [NSString stringWithFormat:@"username=%@", kIdentityECFLogin],
                                                          [NSString stringWithFormat:@"password=%@", kIdentityECFPass],
                                                          @"scope=resourceProfile"]];
    NSMutableURLRequest * request = [[self composeHTTPPOSTRequestWithUrl:url body:body] mutableCopy];
    [request setValue: kIdentityECFAuthorizationString forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (DEBUG_OUTPUT) {
                    NSLog(@"🚫🔑 ECF Authorization error: %@", error.localizedDescription);
                }
                failure(error);
            }
            else {
                NSError * jsonParsingError;
                NSDictionary * tokenData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                NSString * responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (!jsonParsingError && tokenData[@"access_token"]) {
                    
                    if (DEBUG_OUTPUT) {
                        NSLog(@"🔓ECF Authorized: %@", responseString);
                        NSLog(@"-------------------------------------------");
                    }
                    
                    success(tokenData);
                }
                else {
                    if (DEBUG_OUTPUT) {
                        NSLog(@"🚫🔑 ECF Authorization error, response not parsed, or there is no token:\n%@", responseString);
                        NSLog(@"-------------------------------------------");
                    }
                    if (jsonParsingError) {
                        failure(jsonParsingError);
                    }
                    else {
                        failure([NSError errorWithDomain:@"MMError" code:400 userInfo:tokenData]);
                    }
                }
            }
        });
    }];
    
    [dataTask resume];
}

+(void)srvCheckUserWithEmail:(NSString*)email success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgCheckEmail project:API_PROJECT_MY_AMG];
    NSDictionary * parameters = @{@"email": email};
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvCheckUserWithPhone:(NSString*)phone success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgCheckPhone project:API_PROJECT_MY_AMG];
    NSDictionary * parameters = @{@"phone": phone};
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvRemindUserPasswordWithLogin:(NSString*)login success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    NSURL *url = [self composeURLForEndpointURL:amgResetPassword project:API_PROJECT_MY_AMG];
    NSDictionary *parameters = @{@"Value": login};
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvAuthorizeUserWithLogin:(NSString*)login password:(NSString*)password token:(NSString*)token success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserAuthorize project:API_PROJECT_MY_AMG];
    NSDictionary * parameters = @{@"deviceType": deviceType,
                                  @"Login": login,
                                  @"Password": password,
                                  @"token": token ? token : [NSNull null]};
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)amgUserRegistrationWith:(NSDictionary *)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError *error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserRegister project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetSMSCodeForUser:(NSString*)userUUID phone:(NSString *)phone success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:amgGetSMSCode userGUID:userUUID project:API_PROJECT_MOBILE_APP_CMS];
    
    NSDictionary * parameters = @{@"phone": phone};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetConsentForUser:(NSString*)userGUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:amgUserGetConsent userGUID:userGUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
    [self startRequest:request success:success failure:failure];
}

+(void)srvSetDealer:(int)dealerId forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kUserDealerUpd userGUID:userUUID project:API_PROJECT_MY_AMG];
    
    NSDictionary * parameters = @{@"Value": @(dealerId)};
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPUT parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvAddCar:(NSDictionary*)parameters forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserCarAdd userGUID:userUUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvUpdateCar:(NSDictionary*)parameters suffix:(NSString *)suffix forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserCarUpd userGUID:userUUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:suffix HTTPMethod:HTTPMethodPUT parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvDeleteCar:(int)carId forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgUserCarDel userGUID:userUUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:[@(carId) stringValue] HTTPMethod:HTTPMethodDELETE parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadNews:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    NSURL *url = [self composeURLForEndpointURL:amgNewsAlertsList project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvConfirmNewsForUser:(NSString*)userUUID parameters:(NSDictionary *)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:amgNewsAlertsConfirm project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadServiceCarClasses:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kServiceGetCarClasses project:API_PROJECT_SERVICE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadServiceCarModification:(int)classId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kServiceGetCarModification project:API_PROJECT_SERVICE];
    
    NSDictionary * parameters = @{@"classId": @(classId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadServiceCarManufactureYears:(int)modificationId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kServiceGetCarManufactureYears project:API_PROJECT_SERVICE];
    
    NSDictionary * parameters = @{@"modificationId": @(modificationId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadServiceScheduleWithShowroomId:(int)showroomId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kServiceSchedule project:API_PROJECT_SERVICE];
    
    // Дата отправляется на сервер для того, что бы не позволять записаться на время, меньшее
    // чем текущее время пользователя. Это требование Заказчика
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    NSString *clientDateTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary * parameters = @{
                                  @"showroomId": @(showroomId),
                                  @"clientDateTime" : clientDateTime
                                  };
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvServiceCreateOrder:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kServiceCreateOrder project:API_PROJECT_SERVICE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSCClasses:(void (^)(NSData *))success failure:(void (^)(NSError *))failure{
    NSURL * url = [self composeURLForEndpointURL:kSCClasses project:API_PROJECT_SERVICE_CERTIFICATE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSCEngineTypesForClass:(int)classId success:(void (^)(NSData *))success failure:(void (^)(NSError *))failure {
    NSURL * url = [self composeURLForEndpointURL:kSCEngine project:API_PROJECT_SERVICE_CERTIFICATE];
    NSDictionary * parameters = @{@"mbclassId": @(classId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvSSTypesWithEngineTypeId:(int)engineTypeId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kSCServceSertTypes project:API_PROJECT_SERVICE_CERTIFICATE];
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBaseSCLogin password:kBaseSCPass debugLogin:kBaseSCLoginDebug debugPassword:kBaseSCPassDebug];
    
    NSDictionary * parameters = @{@"engineTypeId": @(engineTypeId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvSCPeriodWithEngineTypeId:(int)engineTypeId SCTypeId:(int)serviceSertificateId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kSCServceSertPeriod project:API_PROJECT_SERVICE_CERTIFICATE];
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBaseSCLogin password:kBaseSCPass debugLogin:kBaseSCLoginDebug debugPassword:kBaseSCPassDebug];
    
    NSDictionary * parameters = @{@"engineTypeId": @(engineTypeId),
                                  @"scTypeId": @(serviceSertificateId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSCPrice:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kSCServceSertPrice project:API_PROJECT_SERVICE_CERTIFICATE];
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBaseSCLogin password:kBaseSCPass debugLogin:kBaseSCLoginDebug debugPassword:kBaseSCPassDebug];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSCOrder:(NSDictionary*)parameters user:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kSCServceSertOrder project:API_PROJECT_SERVICE_CERTIFICATE];
    NSString * authorizationString = [self composeBaseAuthorizationHeaderWithLogin:kBaseSCLogin password:kBaseSCPass debugLogin:kBaseSCLoginDebug debugPassword:kBaseSCPassDebug];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:authorizationString suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceClasses:(void (^)(NSData * data))success failure: (void (^)()) failure{
    NSURL * url = [self composeURLForEndpointURL:kSPClasses project:API_PROJECT_SERVICE_PRICE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceYearsForClassId:(int)classId success:(void (^)(NSData *))success failure:(void (^)())failure{
    NSURL * url = [self composeURLForEndpointURL:kSPManufactureYears project:API_PROJECT_SERVICE_PRICE];
    
    NSDictionary * parameters = @{@"mbClassId": @(classId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceModelsForClassId:(int)classId year:(int)year bodyType:(int)bodyType success:(void (^)(NSData *))success failure:(void (^)())failure{
    NSURL * url = [self composeURLForEndpointURL:kSPModels project:API_PROJECT_SERVICE_PRICE];
    
    NSDictionary * parameters = @{@"mbClassId": @(classId),
                                  @"manufactureYearId": @(year),
                                  @"bodyTypeId": bodyType > 0 ? @(bodyType) : [NSNull null]};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceMileageItemsForModelId:(int)modelId success:(void (^)(NSData * data))success failure: (void (^)()) failure {
    NSURL * url = [self composeURLForEndpointURL:kSPMileageItems project:API_PROJECT_SERVICE_PRICE];
    
    NSDictionary * parameters = @{@"mbModelId": @(modelId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceCities:(void (^)(NSData * data))success failure: (void (^)()) failure{
    NSURL * url = [self composeURLForEndpointURL:kSPCities project:API_PROJECT_SERVICE_PRICE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:nil];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceShowroomsForCityId:(int)cityId success:(void (^)(NSData * data))success failure: (void (^)()) failure{
    NSURL * url = [self composeURLForEndpointURL:kSPShowrooms project:API_PROJECT_SERVICE_PRICE];
    
    NSDictionary * parameters = @{@"cityId": @(cityId)};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceCalculation:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)()) failure{
    NSURL * url = [self composeURLForEndpointURL:kSPCalculation project:API_PROJECT_SERVICE_PRICE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetServicePriceEmail:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)()) failure{
    NSURL * url = [self composeURLForEndpointURL:kSPMail project:API_PROJECT_SERVICE_PRICE];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadSaleECFCarsWithToken:(NSString *)token forClassId:(int)classId dealerId:(int)dealerId cityId:(int)cityId sortOrder:(NSString*)sort success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSMutableDictionary * parameters = [NSMutableDictionary new];
    
    if (sort && sort.length > 0) {
        parameters[@"sort"] = sort;
    }
    
    if (dealerId != 0) {
        parameters[@"dealerid"] = @(dealerId);
    } else if (cityId != 0) {
        parameters[@"cityid"] = @(cityId);
    }
    
    parameters[@"modelid"] = @(classId);
    
    NSURL *url = [self composeURLForEndpointURL:kECFCarsForClass project:API_PROJECT_ECF];
        
    NSString *kAuthorizationString = [NSString stringWithFormat:@"Bearer %@",token];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:kAuthorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadSaleUsedCarsForClassId:(int)classId dealerId:(int)dealerId cityId:(int)cityId sortOrder:(NSString*)sort success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSMutableDictionary * parameters = [NSMutableDictionary new];
    
    if (sort && sort.length > 0) {
        parameters[@"sort"] = sort;
    }
    
    if (dealerId != 0) {
        parameters[@"dealerid"] = @(dealerId);
    } else if (cityId != 0) {
        parameters[@"cityid"] = @(cityId);
    }
    
    NSString * suffix = [NSString stringWithFormat:@"%i",classId];
    NSURL * url = [self composeURLForEndpointURL:kUsedCars project:API_PROJECT_USED];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url suffix:suffix HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadSaleDetailsWithToken:(NSString *)token forNewCarIds:(NSArray*)carIds success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kECFCarsArray project:API_PROJECT_ECF];
    
    NSDictionary * parameters = @{@"ids": carIds};
    
    NSString *kAuthorizationString = [NSString stringWithFormat:@"Bearer %@",token];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:kAuthorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadSaleDetailsForUsedCarIds:(NSArray*)carIds success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:kUsedCars project:API_PROJECT_USED];
    
    NSDictionary * parameters = @{@"carIds": [carIds componentsJoinedByString:@","]};
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSendNewCarIdInfoWithToken:(NSString *)token carId:(int)carId onEmail:(NSString*)email hideSpecialOffer:(BOOL)hideSpecialOffer success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:kECFMail project:API_PROJECT_ECF];
    NSDictionary * parameters = @{@"carId": @(carId),
                                  @"email": email,
                                  @"hideSpecialOffer": @(hideSpecialOffer)};
    
    NSString *kAuthorizationString = [NSString stringWithFormat:@"Bearer %@",token];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:kAuthorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSaleAutoOrder:(NSDictionary*)parameters isNew:(BOOL)isNew success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url;
    NSURLRequest * request;
    
    if (isNew) {
        url = [self composeURLForEndpointURL:kSaveOrderContactDB project:API_PROJECT_CONTACTS_DB];
    
        request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:TEST_SERVER ? kContactsAuthHeaderDEBUG : kContactsAuthHeader suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    } else {
        url = [self composeURLForEndpointURL:kUsedCarOrder project:API_PROJECT_MOBILE_APP_CMS];
        
        request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:nil HTTPMethod:HTTPMethodPOST parameters:parameters];
    }
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetECFFiltersWithToken:(NSString *)token classId:(int)classId dealer:(int)dealerId success:(void(^)(NSData * data))success failure:(void(^)(NSError* error))failure {
    NSURL * url = [self composeURLForEndpointURL:kECFFilters project:API_PROJECT_ECF];
    NSMutableDictionary * parameters = [@{@"modelId": @(classId)} mutableCopy];
    
    if (dealerId != 0) {
        parameters[@"dealerId"] = @(dealerId);
    }
    
    NSString *kAuthorizationString = [NSString stringWithFormat:@"Bearer %@",token];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:kAuthorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadECFSaleCarsWithFilter:(NSString *)token parameters:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    NSURL * url = [self composeURLForEndpointURL:kECFCarsForClass project:API_PROJECT_ECF];
    
    NSString *kAuthorizationString = [NSString stringWithFormat:@"Bearer %@",token];
    NSURLRequest *request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:kAuthorizationString suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvGetUsedFiltersForClassId:(int)classId dealer:(int)dealerId success:(void(^)(NSData * data))success failure:(void(^)(NSError* error))failure {
    NSURL * url = [self composeURLForEndpointURL:kUsedFilters project:API_PROJECT_USED];
    
    NSMutableDictionary * parameters = [NSMutableDictionary new];
    
    if (classId != 0) {
        parameters[@"classId"] = @(classId);
    }

    if (dealerId != 0) {
        parameters[@"dealerId"] = @(dealerId);
    }
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvReadUsedSaleCarsWithFilter:(NSDictionary*)parameters classId:(int)classId onlyCertified:(BOOL)onlyCertified success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure {
    
    NSURL * url = [self composeURLForEndpointURL:[NSString stringWithFormat:@"%@%d", kUsedCars, classId] project:API_PROJECT_USED];
    
    if (onlyCertified)
        url = [self composeURLForEndpointURL:kUsedCarsCertified project:API_PROJECT_USED];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url suffix:nil HTTPMethod:HTTPMethodGET parameters:parameters];
    
    [self startRequest:request success:success failure:failure];
}

+(void)srvSaveFavouriteUserAuto:(int)carId isNew:(BOOL)isNew del:(BOOL)del forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure{
    NSURL *url;
    
    if (isNew)
        url = del ?
        [self composeURLForEndpointURL:amgUserFavCarNewDel userGUID:userUUID project:API_PROJECT_MY_AMG] : [self composeURLForEndpointURL:amgUserFavCarNewAdd userGUID:userUUID project:API_PROJECT_MY_AMG];
    else
        url = del ? [self composeURLForEndpointURL:amgUserFavCarUsedDel userGUID:userUUID project:API_PROJECT_MY_AMG] :
        [self composeURLForEndpointURL:amgUserFavCarUsedAdd userGUID:userUUID project:API_PROJECT_MY_AMG];
    
    NSURLRequest * request = [self composeHTTPRequestWithUrl:url authorizationHeaderString:[self identityAuthorizationString] suffix:del ? [@(carId) stringValue] : nil HTTPMethod:del ? HTTPMethodDELETE : HTTPMethodPOST parameters:del ? nil : @{@"Value": @(carId)}];
    
    [self startRequest:request success:success failure:failure];
}

#pragma mark - Cache

+(void)startRequest:(NSURLRequest*)request success:(void (^)(NSData*))success failure:(void (^)(NSError*))failure{
    
    if (DEBUG_OUTPUT) {
        NSLog(@"🌍Request URL: %@\n", [request.URL absoluteString]);
        NSLog(@"🌍Headers: %@\n", request.allHTTPHeaderFields);
        if (request.HTTPBody) {
            NSLog(@"ℹ️Request Body: %@\n", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
            //printf("ℹ️Request Body: %s\n", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] UTF8String]);
        }
    }
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self genericCompletionHandler:data request:request response:response success:success failure:failure error:error];
    }];
    [dataTask resume];
}


#pragma mark - Completion Handler

+(NSString*)identityAuthorizationString {
    NSString * tokenType = [MMKeyChainWrapper objectForKey:@"token_type"];
    NSString * accessToken = [MMKeyChainWrapper objectForKey:@"access_token"];
    return [NSString stringWithFormat:@"%@ %@", tokenType ? tokenType : @"Bearer", accessToken ? accessToken : @"null"];
}

+(void)saveTokenData:(NSDictionary*)tokenData authorizationType:(APIAuthorizationType)authorizationType {
    [MMKeyChainWrapper setObject:tokenData[@"access_token"] forKey:@"access_token"];
    [MMKeyChainWrapper setObject:tokenData[@"token_type"] forKey:@"token_type"];
    [MMKeyChainWrapper setObject:@(authorizationType) forKey:@"authorization_type"];
}

+(void)saveTokenData:(NSDictionary*)tokenData {
    [self saveTokenData:tokenData authorizationType:APIAuthorizationTypeSystem];
}

+(void)authorizeWithIdentityServer:(void(^)(void))success failure:(void(^)(NSError *))failure {
    
    NSURL * url = [self composeURLForEndpointURL:kIdentityServerGetToken project:API_PROJECT_IDENTITY_SERVER];
    NSData * body = [self composeHTTPBodyWithParameters:@[@"grant_type=custom_client_credentials", @"scope=profile"]];
    NSMutableURLRequest * request = [[self composeHTTPPOSTRequestWithUrl:url body:body] mutableCopy];
    [request setValue: TEST_SERVER ? kIdentityServerAuthorizationStringDebug : kIdentityServerAuthorizationString forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (DEBUG_OUTPUT) {
                    NSLog(@"🚫🔑 Authorization error: %@", error.localizedDescription);
                }
                failure(error);
            }
            else {
                NSError * jsonParsingError;
                NSDictionary * tokenData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                NSString * responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (!jsonParsingError && tokenData[@"access_token"]) {
                    
                    if (DEBUG_OUTPUT) {
                        NSLog(@"🔓Authorized: %@", responseString);
                        NSLog(@"-------------------------------------------");
                    }
                    
                    [self saveTokenData:tokenData];
                    success();
                }
                else {
                    if (DEBUG_OUTPUT) {
                        NSLog(@"🚫🔑 Authorization error, response not parsed, or there is no token:\n%@", responseString);
                        NSLog(@"-------------------------------------------");
                    }
                    failure(jsonParsingError);
                }
            }
        });
    }];
    
    [dataTask resume];
}

+(void)genericCompletionHandler:(NSData*)data request:(NSURLRequest*)request response:(NSURLResponse*)response success:(void(^)(NSData*))success failure:(void(^)(NSError*error))failure error:(NSError*)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int status = (int)((NSHTTPURLResponse*)response).statusCode;
        
        if (error)
        {
            if (DEBUG_OUTPUT) {
                NSLog(@"🚫 Code: %d, Error: %@", status, error.localizedDescription);
            }
            failure(error);
        }
        else if (status < 200 || (status > 299 && status !=401)) {
            NSString * response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (response.length > 300 && DEBUG_TRIM_RESPONSE) {
                response = [response substringToIndex:300];
            }
            
            if (DEBUG_OUTPUT) {
                NSLog(@"🚫 Code: %d, Error: %@", status, response);
            }
            
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey : NSLocalizedString(response, @""),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString(response, @"Message")
            };
            
            //NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            failure([[NSError alloc] initWithDomain:@"AMGError" code:status userInfo:userInfo]);
        }
        else if (status == 401) {
            
            if (isRegistered) {
                NSString *reason;
                
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (response && response[@"Reason"] && ![response[@"Reason"] isEqual:[NSNull null]]) {
                    reason = response[@"Reason"];
                }
                
                if (DEBUG_OUTPUT) {
                    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"🚫🔑 Authorization denied: %@ [LOGOUT!]", response);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAPIWrapperAuthorizationHasBeenDeniedNotificationIdentifier object:self userInfo:@{kAPIWrapperAuthorizationHasBeenDeniedReasonKey: reason ? reason : kAPIWrapperAuthorizationHasBeenDeniedReasonTokenExpired}];

                return;
            }
            
            [self authorizeWithIdentityServer:^{
                
                // Token recieved update request
                NSMutableURLRequest * newRequest = [request mutableCopy];
                [newRequest setValue:[self identityAuthorizationString] forHTTPHeaderField:@"Authorization"];
                
                if (DEBUG_OUTPUT) {
                    NSLog(@"🔑🌍Repeat Request URL: %@\n", newRequest.URL.absoluteString);
                    NSLog(@"🔑ℹ️Repeat Request Body: %@\n", [[NSString alloc] initWithData:[newRequest HTTPBody] encoding:NSUTF8StringEncoding]);
                }
                
                // Create and run new data task
                NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:newRequest completionHandler:^(NSData *newData, NSURLResponse *newResponse, NSError *newError) {
                    [self genericCompletionHandler:newData request:newRequest response:newResponse success:success failure:failure error:newError];
                }];
                [dataTask resume];
                
            } failure:^(NSError * error) {
                failure(error);
            }];
        }
        else
        {
            NSString * responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (responseString.length > 250 && DEBUG_TRIM_RESPONSE)
                responseString = [responseString substringToIndex:250];
            if (DEBUG_OUTPUT) {
                NSLog(@"✅Response (%i): %@", status, responseString);
                NSLog(@"-------------------------------------------");
            }
            success(data);
        }
    });
}

#pragma mark - Request constructors

+(NSURL *)composeURLForEndpointURL:(NSString *)endpoint project:(API_PROJECT)project {
    
    return [NSURL URLWithString:[[API_BASE_URL baseUrlForProject:project] stringByAppendingString:endpoint]];
}

+(NSURL *)composeURLForEndpointURL:(NSString *)endpoint userGUID:(NSString *)userGUID project:(API_PROJECT)project {
    
    endpoint = [endpoint stringByReplacingOccurrencesOfString:userGUIDParamIdentifier withString:userGUID];
    return [NSURL URLWithString:[[API_BASE_URL baseUrlForProject:project] stringByAppendingString:endpoint]];
}

+(NSURLRequest*)composeHTTPRequestWithUrl:(NSURL*)url authorizationHeaderString:(NSString*)authorizationHeaderString suffix:(NSString*)suffix HTTPMethod:(HTTPMethod)httpMethod parameters:(NSDictionary*)parameters {
    
    for (id key in parameters) {
        if (![key isKindOfClass:[NSString class]] ||
            (![parameters[key] isKindOfClass:[NSString class]] &&
             ![parameters[key] isKindOfClass:[NSNumber class]] &&
             ![parameters[key] isKindOfClass:[NSArray class]] &&
             ![parameters[key] isKindOfClass:[NSDictionary class]] &&
             parameters[key] != [NSNull null])) {
            [NSException raise:NSGenericException format:@"HTTP Request parameter not NSArray, NSString, NSNumber, NSNull class! Parameter: %@ = %@", key, parameters[key]];
        }
    }
    
    NSMutableString * urlString = [[url absoluteString] mutableCopy];
    
    // NOTE: Append suffix
    if (suffix) {
        [urlString appendString:suffix];
    }
    
    // NOTE: Append GET Parameters
    if (httpMethod == HTTPMethodGET && parameters && parameters.count > 0) {
        
        NSArray * allKeys = parameters.allKeys;
        NSMutableArray * getParametersStrings = [NSMutableArray new];
        
        for (id key in allKeys) {
            
            id object = parameters[key];
            
            if (object == [NSNull null]) {
                continue;
            }
            
            if ([object isKindOfClass:[NSArray class]]) {
                NSArray * array = object;
                for (id arrayValue in array) {
                    [getParametersStrings addObject:[self urlEncodedParameterWithKey:key value:arrayValue]];
                }
                continue;
            }
            
            [getParametersStrings addObject:[self urlEncodedParameterWithKey:key value:object]];
        }
        
        if (getParametersStrings.count > 0) {
            [urlString appendString:@"?"];
            [urlString appendString:[getParametersStrings componentsJoinedByString:@"&"]];
        }
    }
    
    // NOTE Compose request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = [self HTTPMethodString:httpMethod];
    
    if (authorizationHeaderString) {
        [request setValue:authorizationHeaderString forHTTPHeaderField:@"Authorization"];
    }
    
    // NOTE: Compose body
    NSData * body;
    
    if (parameters && parameters.count > 0 && httpMethod != HTTPMethodGET) {
        NSError * jsonSerializationError;
        body = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&jsonSerializationError];
        if (jsonSerializationError) {
            if (DEBUG_OUTPUT) {
                NSLog(@"⚠️ Warning: JSON Serialization error. Request can be failed.");
            }
        }
        else {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            request.HTTPBody = body;
        }
    }
    
    return request;
    
}
               
+(NSString*)urlEncodedParameterWithKey:(NSString*)key value:(id)object {
    NSString * value;
    NSCharacterSet *allowedCharacterSet = [self URLAllowedCharacterSet];
   if ([self objectIsKindOfNSNumberClassAndBoolean:object]) {
       BOOL boolValue = [((NSNumber*)object) boolValue];
       value = boolValue ? @"true" : @"false";
   }
   else {
       value = [NSString stringWithFormat:@"%@", object];
   }
   
   NSString * keyEscapedString = [key stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
   NSString * valueEscapedString = [value stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
   
   return  [NSString stringWithFormat:@"%@=%@", keyEscapedString, valueEscapedString];
}

+(NSCharacterSet*)URLAllowedCharacterSet {
    static NSCharacterSet * characterSet = nil;
    if (characterSet == nil) {
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:disallowedUrlSymbols] invertedSet];
    }
    return characterSet;
}

+(NSURLRequest*)composeHTTPRequestWithUrl:(NSURL*)url suffix:(NSString*)suffix HTTPMethod:(HTTPMethod)httpMethod parameters:(NSDictionary*)parameters {
    
    return [self composeHTTPRequestWithUrl:url authorizationHeaderString:nil suffix:suffix HTTPMethod:httpMethod parameters:parameters];
}

+(NSURLRequest*)composeHTTPRequestWithUrl:(NSURL*)url HTTPMethod:(HTTPMethod)httpMethod parameters:(NSDictionary*)parameters {
    
    return [self composeHTTPRequestWithUrl:url authorizationHeaderString:nil suffix:nil HTTPMethod:httpMethod parameters:parameters];
}

+(NSURLRequest*)composeHTTPPOSTRequestWithUrl:(NSURL*)url body:(NSData*)body{
    return [self composeHTTPPOSTRequestWithUrl:url body:body isJSON:NO];
}

+(NSURLRequest*)composeHTTPPOSTRequestWithUrl:(NSURL*)url body:(NSData*)body isJSON:(BOOL)isJSON{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    if (isJSON) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    request.HTTPBody = body;
    if (DEBUG_OUTPUT) {
        NSLog(@"🌍Request URL: %@\n", [url absoluteString]);
    }
    return request;
}

+(NSData*)composeHTTPBodyWithParameters:(NSArray*)parameters{
    
    NSString * body = [parameters componentsJoinedByString:@"&"];
    body = [body stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    if (DEBUG_OUTPUT) {
        NSLog(@"ℹ️Request Body: %@\n", body);
        //printf("ℹ️Request Body: %s\n", [body UTF8String]);
    }
    return [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

+ (NSData *)composeHTTPBodyWithParameters:(NSDictionary *)parameters image:(UIImage *)image {
    
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:UIImageJPEGRepresentation(image, 1)];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

+(NSData*)composeHTTPBodyWithParameters:(NSArray*)parameters UIImages:(NSArray*)images customFields:(NSArray*)customFields prefixName:(NSString*)prefixName key:(NSString*)key incrementableKey:(BOOL)incremetableKey{
    NSMutableData * body = [NSMutableData new];
    
    for (int i = 0; i < parameters.count; i++)
    {
        NSMutableArray * parameter = [[parameters[i] componentsSeparatedByString:@"="] mutableCopy];
        if (parameter.count >= 2) // IF PARSED CORRECTLY
        {
            NSString * keyString = parameter[0];
            [parameter removeObjectAtIndex:0];
            NSString * valueString = [parameter componentsJoinedByString:@"="];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",keyString] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n",valueString] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    if (customFields && customFields.count > 0) {
        
        NSMutableString * customFieldsJSON = [NSMutableString new];
        [customFieldsJSON appendString:@"["];
        
        for (int i = 0; i < customFields.count; i++) {
            
            NSMutableArray * parameter = [[customFields[i] componentsSeparatedByString:@"="] mutableCopy];
            if (parameter.count >= 2) // IF PARSED CORRECTLY
            {
                NSString * keyString = parameter[0];
                [parameter removeObjectAtIndex:0];
                NSString * valueString = [[parameter componentsJoinedByString:@"="] stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
                
                [customFieldsJSON appendFormat:@"{\"FieldName\": \"%@\", \"FieldValue\": \"%@\"},", keyString, valueString];
            }
        }
        
        [customFieldsJSON replaceCharactersInRange:NSMakeRange(customFieldsJSON.length - 1, 1) withString:@"]"];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"CustomFields\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", customFieldsJSON] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //Close off the request with boundary
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return body;
}

+(NSString*)composeBaseAuthorizationHeaderWithLogin:(NSString*)login password:(NSString*)password debugLogin:(NSString*)debugLogin debugPassword:(NSString*)debugPassword{
    NSString *authStr;
    
    if (DEBUG_MODE)
        authStr = [NSString stringWithFormat:@"%@:%@", debugLogin, debugPassword];
    else
        authStr = [NSString stringWithFormat:@"%@:%@", login, password];
    
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
}


+(NSString*)HTTPMethodString:(HTTPMethod)httpMethod {
    switch (httpMethod) {
        case HTTPMethodGET:
            return @"GET";
        case HTTPMethodPOST:
            return @"POST";
        case HTTPMethodPUT:
            return @"PUT";
        case HTTPMethodDELETE:
            return @"DELETE";
    }
}

+(void)ocrRecognizeImage:(UIImage *)image success:(void (^)(NSData * data))success failure: (void (^)()) failure {
    NSURL *url = [self composeURLForEndpointURL:kOCRAPIEndpoint project:API_PROJECT_OCR];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kOCRAPIKey, @"apikey",
                                @"true", @"isOverlayRequired",
                                @"eng", @"language", nil];
    
    //NSDictionary *parameters = @{@"apikey": };
    
    NSData *body = [self composeHTTPBodyWithParameters:parameters image:image];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPBody = body;
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    [self startRequest:request success:success failure:failure];
}

#pragma mark - Helpers for constructors

+(NSDictionary*)customFieldObjectWithName:(NSString*)name value:(id)value {
    NSDictionary * customField = @{@"FieldName": name,
                                   @"FieldValue": value};
    return customField;
}

+(BOOL)objectIsKindOfNSNumberClassAndBoolean:(id)object {
    NSNumber * mayBeNumber = object;
    
    if (mayBeNumber == (void*)kCFBooleanFalse || mayBeNumber == (void*)kCFBooleanTrue) {
        return YES;
    } else {
        return NO;
    }
}

@end

#pragma mark - Helpers for managers

@implementation NSData (MMAdditionals)

-(BOOL)equalsTrue {
    NSString * string = [self stringValueWithTrimmedWhiteSpacesAndNewLines];
    return ([string isEqualToString:@"True"] || [string isEqualToString:@"true"]);
}

-(BOOL)containsTrue {
    NSString * string = [self stringValue];
    return ([string containsString:@"True"] || [string containsString:@"true"]);
}

-(NSString*)stringValue {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

-(NSString*)stringValueWithTrimmedWhiteSpacesAndNewLines {
    return [[self stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(id)jsonValue {
    return [self jsonValueAllowFragments:NO];
}

-(id)jsonValueAllowFragments:(BOOL)allowFragments {
    return [NSJSONSerialization JSONObjectWithData:self options:allowFragments ? NSJSONReadingAllowFragments : 0 error:nil];
}

@end
