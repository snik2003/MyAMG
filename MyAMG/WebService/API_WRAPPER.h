//
//  API_WRAPPER.h
//  mymercedes
//
//  Created by Alexander Koulabuhov on 19/08/15.
//  Copyright (c) 2015 Daimler AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "API_BASE_URL.h"

static NSString * const kAPIWrapperAuthorizationHasBeenDeniedNotificationIdentifier = @"kAPIWrapperAuthorizationHasBeenDeniedNotificationIdentifier";
static NSString * const kAPIWrapperAuthorizationHasBeenDeniedReasonKey = @"kAPIWrapperAuthorizationHasBeenDeniedReasonKey";
static NSString * const kAPIWrapperAuthorizationHasBeenDeniedReasonAccountDeleted = @"deleted";
static NSString * const kAPIWrapperAuthorizationHasBeenDeniedReasonTokenExpired = @"expired";

@interface API_WRAPPER : NSObject

typedef enum APIAuthorizationType : NSInteger {
    APIAuthorizationTypeSystem = 0,
    APIAuthorizationTypeClient = 1
} APIAuthorizationType;

typedef enum HTTPMethod {
    HTTPMethodGET,
    HTTPMethodPOST,
    HTTPMethodPUT,
    HTTPMethodDELETE,
} HTTPMethod;

+(NSURL *)composeURLForEndpointURL:(NSString *)endpoint project:(API_PROJECT)project;

+(NSURLRequest*)composeHTTPRequestWithUrl:(NSURL*)url suffix:(NSString*)suffix HTTPMethod:(HTTPMethod)httpMethod parameters:(NSDictionary*)parameters;
+(NSURLRequest*)composeHTTPRequestWithUrl:(NSURL*)url HTTPMethod:(HTTPMethod)httpMethod parameters:(NSDictionary*)parameters;
+(NSURLRequest*)composeHTTPPOSTRequestWithUrl:(NSURL*)url body:(NSData*)body;

+(void)startRequest:(NSURLRequest*)request success:(void (^)(NSData*))success failure:(void (^)(NSError*))failure;

// авторизация
+(void)srvGetGUID:(void (^)(NSData * data))success failure:(void (^)(NSError * error))failure;
+(void)srvValidateRegistration:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;

// получение справочных данных
+(void)srvClassesNamesByBrandId:(int)brandId includeVans:(BOOL)includeVans success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvGetModelsForClassId:(int)classId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvDealersCities:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvDealersInCity:(int)cityId excludeVans:(BOOL)excludeVans success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadInSaleECFClassesWithToken:(NSString *)token dealerId:(int)dealerId orCity:(int)cityId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadInSaleUsedClassesForDealer:(int)dealerId orCity:(int)cityId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvShowroomsOfDealer:(int)dealerId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvOrderStatus:(NSString *)dealerOrderNumber orderNumber:(NSString *)orderNumber success:(void (^)(NSData *))success failure:(void (^)(NSError * error)) failure;
+(void)srvPartSearch:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvPartsSearch:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvPartSearchHistoryForUser:(NSString *)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvPartAddArticle:(NSDictionary *)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadServiceTypesForShowroomId:(NSNumber *)showRoomId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvGetCarAdditionalInfo:(int)carId userGUID:(NSString *)userGUID success:(void (^)(NSData * data))success failure:(void(^)(NSError* error))failure;
+(void)ocrRecognizeImage:(UIImage *)image success:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvReadServiceCarClasses:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadServiceCarModification:(int)classId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadServiceCarManufactureYears:(int)modificationId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadServiceScheduleWithShowroomId:(int)showroomId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvServiceCreateOrder:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSCClasses:(void (^)(NSData *))success failure:(void (^)(NSError *))failure;
+(void)srvSCEngineTypesForClass:(int)classId success:(void (^)(NSData *))success failure:(void (^)(NSError *))failure;
+(void)srvSSTypesWithEngineTypeId:(int)engineTypeId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSCPeriodWithEngineTypeId:(int)engineTypeId SCTypeId:(int)serviceSertificateId success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSCPrice:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSCOrder:(NSDictionary*)parameters user:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvGetServicePriceClasses:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvGetServicePriceYearsForClassId:(int)classId success:(void (^)(NSData *))success failure:(void (^)())failure;
+(void)srvGetServicePriceModelsForClassId:(int)classId year:(int)year bodyType:(int)bodyType success:(void (^)(NSData *))success failure:(void (^)())failure;
+(void)srvGetServicePriceMileageItemsForModelId:(int)modelId success:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvGetServicePriceCities:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvGetServicePriceShowroomsForCityId:(int)cityId success:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvGetServicePriceCalculation:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvGetServicePriceEmail:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)()) failure;
+(void)srvReadSaleECFCarsWithToken:(NSString *)token forClassId:(int)classId dealerId:(int)dealerId cityId:(int)cityId sortOrder:(NSString*)sort success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadSaleUsedCarsForClassId:(int)classId dealerId:(int)dealerId cityId:(int)cityId sortOrder:(NSString*)sort success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadSaleDetailsForUsedCarIds:(NSArray*)carIds success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvReadSaleDetailsWithToken:(NSString *)token forNewCarIds:(NSArray*)carIds success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSendNewCarIdInfoWithToken:(NSString *)token carId:(int)carId onEmail:(NSString*)email hideSpecialOffer:(BOOL)hideSpecialOffer success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSaleAutoOrder:(NSDictionary*)parameters isNew:(BOOL)isNew success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvGetECFFiltersWithToken:(NSString *)token classId:(int)classId dealer:(int)dealerId success:(void(^)(NSData * data))success failure:(void(^)(NSError* error))failure;
+(void)srvReadECFSaleCarsWithFilter:(NSString *)token parameters:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvGetUsedFiltersForClassId:(int)classId dealer:(int)dealerId success:(void(^)(NSData * data))success failure:(void(^)(NSError* error))failure;
+(void)srvReadUsedSaleCarsWithFilter:(NSDictionary*)parameters classId:(int)classId onlyCertified:(BOOL)onlyCertified success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSaveFavouriteUserAuto:(int)carId isNew:(BOOL)isNew del:(BOOL)del forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSaveFavouriteUserAuto:(int)carId isNew:(BOOL)isNew del:(BOOL)del forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;

// личные данные
+(void)srvGetUserData:(NSString *)userGUID success:(void (^)(NSData *data))success failure: (void (^)(NSError *error)) failure;
+(void)srvUpdateUser:(NSDictionary*)parameters userGUID:(NSString *)userGUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvDeleteUserWithId:(NSString*)userGUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvSetDealer:(int)dealerId forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvAddCar:(NSDictionary*)parameters forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvUpdateCar:(NSDictionary*)parameters suffix:(NSString *)suffix forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvDeleteCar:(int)carId forUser:(NSString*)userUUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvGetConsentForUser:(NSString*)userGUID success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;

// новости
+(void)srvReadNews:(NSDictionary*)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvConfirmNewsForUser:(NSString*)userUUID parameters:(NSDictionary *)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;

// регистрация пользователя в My AMG
+(void)amgUserRegistrationWith:(NSDictionary *)parameters success:(void (^)(NSData * data))success failure: (void (^)(NSError *error)) failure;

// восстановления пароля
+(void)srvRemindUserPasswordWithLogin:(NSString*)login success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;

// логин пользователя в My AMG
+(void)srvCheckUserWithEmail:(NSString*)email success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvCheckUserWithPhone:(NSString*)phone success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvAuthorizeUserWithEmail:(NSString *)email password:(NSString *)password success:(void(^)(void))success failure:(void(^)(NSError *error))failure;
+(void)srvAuthorizeUserWithLogin:(NSString*)login password:(NSString*)password token:(NSString*)token success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;
+(void)srvAuthorizeECF:(void(^)(NSDictionary *tokenData))success failure:(void(^)(NSError *error))failure;

// верификация номера телефона
+(void)srvGetSMSCodeForUser:(NSString*)userUUID phone:(NSString *)phone success:(void (^)(NSData * data))success failure: (void (^)(NSError * error)) failure;

@end

@interface NSData (MMAdditionals)

-(BOOL)equalsTrue;
-(BOOL)containsTrue;
-(NSString*)stringValue;
-(NSString*)stringValueWithTrimmedWhiteSpacesAndNewLines;
-(id)jsonValue;
-(id)jsonValueAllowFragments:(BOOL)allowFragments;

@end
