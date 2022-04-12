//
//  API_URL.h
//  mymercedes
//
//  Created by Alexander Koulabuhov on 21/08/15.
//  Copyright (c) 2015 Daimler AG. All rights reserved.
//

#define userGUIDParamIdentifier @"{UserGUID}"
#define carIdParamIdentifier @"{CarId}"

#pragma mark - Identity Server
static NSString * const kIdentityServerURL = @"https://id.mercedes-benz.ru/core/";
static NSString * const kIdentityServerURLDebug = @"https://identity-server.mercedes-benz-test.ru/core/";
static NSString * const kIdentityServerAuthorizationString = @"Basic TTBiMTFlNFBQTDFDNFQxME46UXhRbk5DYmh0UEVmc0tqbTFqeUh1UlQya0Q2RXd2UU5NSm9wYWFqbUVxamYqTngwOFhHS1owYV9RaCotNjJwcQ==";
static NSString * const kIdentityServerAuthorizationStringDebug = @"Basic Q3VzdG9tR3JhbnRUeXBlQ2xpZW50SWQ6Q3VzdG9tR3JhbnRUeXBlQ2xpZW50U2VjcmV0";
// Token logic
static NSString * const kIdentityServerGetToken = @"connect/token";

#pragma mark - Mobile App CMS
static NSString * const kBaseCMSURL = @"https://mobile-app.mercedes-benz.ru/api/v2/";
static NSString * const kBaseCMSURLDebug = /* GET */ @"https://mobileappcms.mercedes-benz-test.ru/api/v2/";
// Endpoints
static NSString * const kBaseURLsDictionary = @"BaseUrls";
static NSString * const kCrashLogs = @"CrashLogs";
// News and Alerts
static NSString * const kNewsAlertsList = /* GET */ @"News";
static NSString * const kKeyVisual = /* GET */ @"KeyVisuals";
static NSString * const kNewsByRegion = /* PUT */ @"Customers/{UserGUID}/RegionNews";
// Sections information
static NSString * const kFailureIndicators = /* GET */ @"FailureIndicators";
static NSString * const kDrivingAcademyInfo = /* GET */ @"DrivingAcademy";
// User Registration and removing
static NSString * const kUserCheckEmail = /* GET */ @"Account/CheckEmail";
static NSString * const kUserRegister = /* POST */ @"Account/Register";
static NSString * const kUserGetGUID = /* POST */ @"Account/SilentRegistration";
static NSString * const kUserAuthorize = /* POST */ @"Account/Login";
static NSString * const kUserTokenAdd = /* POST */ @"Account/Tokens";
static NSString * const kUserRecoverPassword = /* POST */ @"Account/ResetPassword";
static NSString * const kUserDelete = /* DELETE */ @"Customers/{UserGUID}";
static NSString * const kUserTokenDel = /* POST */ @"Account/Logout";
static NSString * const kUserAuthorizeBiometric = /* POST */ @"Account/LoginBiometric";
// User Personal data
static NSString * const kUserDataUpd = /* PUT */ @"Customers/{UserGUID}";
static NSString * const kUserDealerUpd = /* PUT */ @"Customers/{UserGUID}/Dealer";
static NSString * const kUserCarInsurance = /* PUT */ @"Customers/{UserGUID}/Cars/Insurance/";
static NSString * const kUserGetPushNotifications = /* PUT */ @"Customers/{UserGUID}/Push";
static NSString * const KUserCarSendEquipmentsToEmail = /* POST */ @"Customers/{UserGUID}/Cars/{CarId}/Notification";
// Managers
static NSString * const kManagersAll = /* GET */ @"Managers";
static NSString * const kManagerDetails = /* GET */ @"Managers/";
static NSString * const kUserManagerAdd = /* POST */ @"Customers/{UserGUID}/Managers";
static NSString * const kUserManagerDel = /* DELETE */ @"Customers/{UserGUID}/Managers/";
static NSString * const kManagerRate = /* POST */ @"Customers/{UserGUID}/Managers/Rate/";
// Car rent
static NSString * const kRentClass = /* GET */ @"Rent/MBClasses";
static NSString * const kRentPrice = /* GET */ @"Rent/ByClassId/";
static NSString * const kRentOrder = /* POST */ @"Customers/{UserGUID}/RentOrders";
// Car models
static NSString * const kAutoBrand = /* GET */ @"Brands";
static NSString * const kAutoClasses = /* GET */ @"MBClasses/amg/";
static NSString * const kAutoClassBodyType = /* GET */ @"MbClasses/ByOldClassId/";
static NSString * const kAutoModels = /* GET */ @"MbModels/AmgByClassId/";
// Services
static NSString * const kTestDriveOrder = /* POST */ @"TestDriveOrders";
static NSString * const kServiceTypes = /* GET */ @"GetServiceTypes";
static NSString * const kServiceOrder = /* POST */ @"Customers/{UserGUID}/ServiceOrders";
static NSString * const kCreditOrder = /* POST */ @"CreditOrders";
static NSString * const kCreditFeedback = /* POST */ @"CreditFeedback";
static NSString * const kUsedCarOrder = /* POST */ @"UsedMBCarOrders";
static NSString * const kUsedOtherCarOrder = /* POST */ @"UsedOtherCarOrders";
// Road accidents
static NSString * const kRoadAccidentType = /* GET */ @"RoadAccidentTypes";
static NSString * const kRoadAccidentOrder = /* POST */ @"Customers/{UserGUID}/RoadAccidentOrders";
static NSString * const kRoadAccidentRCF = /* POST */ @"Customers/{UserGUID}/RoadAccidentFeedback/";
static NSString * const kUserCarVINCheck = /* POST */ @"Customers/{UserGUID}/RoadAccidentCheck";
// System
static NSString * const kVinPrefixes = @"VinPrefixes";
static NSString * const kDealers = @"Dealers";
static NSString * const kSendMail = /* POST */ @"Mail";
static NSString * const kAppSettings = @"AppSettings";
static NSString * const kTelemetry = /* POST */ @"Telemetry";
static NSString * const kValidateRegistration = @"Account/ValidateRegistration";

#pragma mark - Easy Car Finder Authorization
static NSString * const kBaseECFIDURL = @"https://identityserver.mercedes-benz.ru/";
static NSString * const kBaseECFIDURLDebug = @"https://identity-server-as-users.mercedes-benz-test.ru/";
// Get Token
static NSString * const kIdentityECFGetToken = @"core/connect/token";
static NSString * const kIdentityECFLogin = TEST_SERVER ? @"testnewroleecf" : @"ecf_api_remain";
static NSString * const kIdentityECFPass = TEST_SERVER ? @"fel239iX!!Q" : @"L!OWJNxB4Oi1wP";
static NSString * const kIdentityECFAuthorizationString = TEST_SERVER ?
@"Basic cmVzb3VyY2VzLjIyNTY3NTY3NzU2NzM4NzczMjMtNm4yOTVmNDQ1N2dmZzY1NzU2aGZnaDU2NTk3Z2g1NjUuZW4uMjMuZWNmLm1lcmNlZGVzLWJlbnoucnU6OEpmclJJZjdodzRfZzhoZTVqMUpUa3JHMGdtdEowZTgwR2pr" :
@"Basic cmVzb3VyY2VzLjIyMTQ2OTcxNjY0Mjg4OTAyNTYtNm4yOTV3NDUxeTV1cjhnbDViNThpNnkzNDVqdDI2MTUuZW4uMjMuZWNmLm1lcmNlZGVzLWJlbnoucnU6N0pmclJJZjdodzRfZzhoZTVqMUpUa3JHMGdtdEowZTgwR2pr";

#pragma mark - Easy Car Finder
static NSString * const kBaseECFURL = @"https://cars.mercedes-benz.ru/";
static NSString * const kBaseECFURLDebug = @"https://cars.mercedes-benz-test.ru/";
// Get Classes, Cars, Details, ListImage, Send mail and Create order
static NSString * const kECFClasses = @"api/model/getlist";
static NSString * const kECFFilters = @"api/Filter/GetFilter";
static NSString * const kECFCarsForClass = @"api/cars/getlist";
static NSString * const kECFCarsArray = @"api/cars/getcars";
static NSString * const kECFCarImageThumb = @"Image/CarExteriorListImageTv/";
static NSString * const kECFMail = @"api/cars/SendEmail";
static NSString * const kECFOrder = @"api/order/create";
static NSString * const kOrderStatus = @"api/Cars/OrderStatus"; // api/Cars/OrderStatus?orderNumber=0752408584&dealerOrderNumber=9875039

#pragma mark - Used Cars
static NSString * const kBaseUsedURL = @"https://used.mercedes-benz.ru/";
static NSString * const kBaseUsedURLDebug = @"https://used.mercedes-benz-test.ru/";
// Authorization
static NSString * const kBaseUsedLogin = @"MobileApp";
static NSString * const kBaseUsedPass = @"4vpXV+No-I=Y.mf";
static NSString * const kBaseUsedLoginDebug = @"MobileApp";
static NSString * const kBaseUsedPassDebug = @"4vpXV+No-I=Y.mf";
// Get Classes, Cars, Details and Details for Not MM Cars
static NSString * const kUsedClasses = @"api/Dictionary/MBClassWithCarsList";
static NSString * const kUsedFilters = @"api/CarFilter/ForMbCars";
static NSString * const kUsedFiltersOther = @"api/CarFilter/ForOtherCars";
static NSString * const kUsedCars = @"api/Cars/MBCars/";
static NSString * const kUsedCarsCertified = @"api/Cars/CarsUsedCertified/";
static NSString * const kUsedCarsOther = @"api/Cars/OtherCars";
// TradeIn methods
static NSString * const kUsedTradeInOtherBrands = @"api/Dictionary/OtherBrandList";
static NSString * const kUsedTradeInClasses = @"api/Dictionary/MBClassList";
static NSString * const kUsedTradeInTransmissions = @"api/Dictionary/TransmissionList";
static NSString * const kUsedTradeInSalons = @"api/Dictionary/SalonFurnishTypeList";
static NSString * const kUsedTradeInCity = @"api/dictionary/TradeInCityList";
static NSString * const kUsedTradeInShowRoom = @"api/dictionary/ShowRoomsTradeIn";
static NSString * const kUsedTradeInOrder = @"api/tradeinapi/PostFile";

#pragma mark - Test Drive
static NSString * const kBaseTestDriveURL = @"https://test-drive.mercedes-benz.ru/";
static NSString * const kBaseTestDriveURLDebug = @"https://test-drive.mercedes-benz-test.ru/";
// Test drive basic methods
static NSString * const kTestDriveDealersCities = @"api/GetCities";
static NSString * const kTestDriveDealersInCity = @"api/GetDealersByCityId";
static NSString * const kTestDriveClassesForDealer = @"XmlServices/ClassesForDealer";
static NSString * const kTestDriveModelForClassDealer = @"XmlServices/ModelsByClassIdForDealer/";
static NSString * const kTestDriveShowroom = @"XmlServices/ShowRoomOptions/";

#pragma mark - Test Drive Mobile Stars
static NSString * const kBaseTestDriveOutURL = @"https://td.mercedes-benz.ru/api/MSSPTestDriveApi/";
static NSString * const kBaseTestDriveOutURLDebug = @"https://mstd.mercedes-benz-test.ru/api/MSSPTestDriveApi/";
//Authorization
static NSString * const kBaseTestDriveOutLogin = @"apiMSSPUser";
static NSString * const kBaseTestDriveOutPass = @"#12aU!67eR";
static NSString * const kBaseTestDriveOutLoginDebug = @"apiMSuser";
static NSString * const kBaseTestDriveOutPassDebug = @"11!!qqQQqq";
// Test drive basic methods
static NSString * const kTestDriveOutCars = @"GetCars";
static NSString * const kTestDriveOutDateTime = @"GetDateTimes/";
static NSString * const kTestDriveOutOrder = @"SaveMSTestDriveOrder";

#pragma mark - Dealers
static NSString * const kBaseDealersURL = @"https://dealers.mercedes-benz.ru/api/";
static NSString * const kBaseDealersURLDebug = @"https://dealers.mercedes-benz-test.ru/api/";
// Get City, Dealer and its Showrooms
static NSString * const kDealersCities = @"GetCities";
static NSString * const kDealersInCity = @"GetDealersByCityId";
static NSString * const kDealersShowroom = @"GetShowRoomsByDealerId";

#pragma mark - Service
static NSString * const kBaseServiceURL = @"https://service.mercedes-benz.ru/api/";
static NSString * const kBaseServiceURLDebug = @"https://serviceonline.mercedes-benz-test.ru/api/";
// Base methods
static NSString * const kServiceShowroom = @"GetShowRoomsByDealerId";
static NSString * const kServiceSchedule = @"GetSchedule"; //?dealerid=19
static NSString * const kServiceCreateOrder = @"createorder";
static NSString * const kServiceGetCarClasses = @"GetCarClasses";
static NSString * const kServiceGetCarModification = @"GetCarModification"; //id класса
static NSString * const kServiceGetCarManufactureYears = @"GetCarManufactureYears"; //id модификации

#pragma mark - Parts Price
static NSString * const kBasePartsURL = @"https://partsprice.mercedes-benz.ru/api/";
static NSString * const kBasePartsURLDebug = @"https://partsprice.mercedes-benz-test.ru/api/";
// Authorization
static NSString * const kBasePartsLogin = @"Yn?AK$tDDbd5mnpRMj3*$xP";
static NSString * const kBasePartsPass = @"9a7t#Gd#beZs*WYnqm_F%a2";
static NSString * const kBasePartsLoginDebug = @"Yn?AK$tDDbd5mnpRMj3*$xP";
static NSString * const kBasePartsPassDebug = @"9a7t#Gd#beZs*WYnqm_F%a2";
// Base methods
static NSString * const kPartsSearch = @"XPartsSearch/post";
static NSString * const kPartsMaskSearch = @"XPartsSearch/find";
static NSString * const kPartsHistoryAdd = @"XPartsSearch/addPartHistory";
static NSString * const kPartsSearchHistory = @"XPartsSearchHistory/get";

#pragma mark - Service Certificate (Contract in past)
static NSString * const kBaseSCURL = @"https://sc.mercedes-benz.ru/api/";
static NSString * const kBaseSCURLDebug = @"https://sc.mercedes-benz-test.ru/api/";
// Authorization
static NSString * const kBaseSCLogin = @"Yn?AK$tDDbd5mnpRMj3*$xP";
static NSString * const kBaseSCPass = @"9a7t#Gd#beZs*WYnqm_F%a2";
static NSString * const kBaseSCLoginDebug = @"Yn?AK$tDDbd5mnpRMj3*$xP";
static NSString * const kBaseSCPassDebug = @"9a7t#Gd#beZs*WYnqm_F%a2";
// Base methods
static NSString * const kSCClasses = @"Dictionary/MBClasses";
static NSString * const kSCEngine = @"Dictionary/EngineTypes";
static NSString * const kSCTextInsertion = @"Dictionary/TextInsertion";
static NSString * const kSCServceSertTypes = @"Calculation/SCType";
static NSString * const kSCServceSertPeriod = @"Calculation/Period";
static NSString * const kSCServceSertPrice = @"Calculation/Price";
static NSString * const kSCServceSertCity = @"dictionary/SCCitys";
static NSString * const kSCServceSertShowroom = @"dictionary/SCShowrooms";
static NSString * const kSCServceSertOrder = @"Calculation/SendServiceCardOrder";

#pragma mark - Service Price
static NSString * const kBaseSPURL = @"https://serviceprice.mercedes-benz.ru/api/";
static NSString * const kBaseSPURLDebug = @"https://service-price.mercedes-benz-test.ru/api/";
// Base methods
static NSString * const kSPClasses = @"MbClasses"; /*GET*/
static NSString * const kSPManufactureYears = @"ManufactureYears"; /* GET ?classId={classId} */
static NSString * const kSPBodyTypes = @"BodyTypes"; /* GET ?classId={classId}&manufactureYearId={manufactureYearId} */
static NSString * const kSPModels = @"MbModels"; /* GET ?classId={classId}&manufactureYearId={manufactureYearId}&bodyTypeId={bodyTypeId} (bodyType - Optional) */
static NSString * const kSPMileageItems = @"MileageItems"; /* GET ?engineTypeId={engineTypeId} */

static NSString * const kSPCities = @"Cities"; /* GET */
static NSString * const kSPShowrooms = @"ShowRooms"; /* GET ?cityId={cityId} */

static NSString * const kSPCalculation = @"Calculation"; /* GET ?modelId={modelId}&yearId={yearId}&mileage={mileage}&carMileage={carMileage}&bodyTypeId={bodyTypeId}&showRoomId={showRoomId} */
static NSString * const kSPOrder = @"Orders";
static NSString * const kSPMail = @"Calculation/SendEmail";

#pragma mark - Service 3+
static NSString * const kBase3PlusURL = @"https://3plus.mercedes-benz.ru/api/";
static NSString * const kBase3PlusURLDebug = @"http://3plus.lia-test6.intravision.ru/api/";
// Base methods
static NSString * const k3PlusCities = @"Cities"; /* GET */
static NSString * const k3PlusShowrooms = @"ShowRooms"; /* GET ?cityId={cityId} */
static NSString * const k3PlusClasses = @"Classes"; /*GET*/
static NSString * const k3PlusOrder = @"WorkSheets";

#pragma mark - RCF Feedback
static NSString * const kBaseRCFURL = @"https://feedback.mercedes-benz.ru/api/";
static NSString * const kBaseRCFURLDebug = @"http://rcf.test.intravision.ru/api/";
// Dictionaries
static NSString * const kRCFSatisfaction = @"Satisfaction";
static NSString * const kRCFReactionType = @"ReactionType";
// Send
static NSString * const kRCFFeedback = @"Feedback";
static NSString * const kRCFDecline = @"FeedbackRefusePush";

#pragma mark - OCR API
static NSString * const kBaseOCRAPIURL = @"https://api.ocr.space/";
static NSString * const kOCRAPIKey = @"b627beec3a88957";

// Endpoint
static NSString * const kOCRAPIEndpoint = @"Parse/Image";

#pragma mark - Loyality Program
static NSString * const kBaseLoyalityURL = @"https://mobile-app.mercedes-benz.ru/api/v2/";
static NSString * const kBaseLoyalityURLDebug = @"https://mobileappcms.mercedes-benz-test.ru/api/v2/";

static NSString * const kProgramLoyalityRegister = @"loyalty/{UserGUID}/register"; // POST
static NSString * const kProgramLoyalityRegisterStatus = @"loyalty/{UserGUID}"; // GET
static NSString * const kProgramLoyalityRegisterCar = @"loyalty/{UserGUID}/cars"; // POST
static NSString * const kProgramLoyalityGetUserInfo = @"Customers/{UserGUID}"; // GET
static NSString * const kProgramLoyalityGetPrizes = @"loyalty/{UserGUID}/prizes"; // GET
static NSString * const kProgramLoyalityGetCategories = @"loyalty/{UserGUID}/prizes/categories"; // GET
static NSString * const kProgramLoyalityGetPrivileges = @"loyalty/{UserGUID}/privileges"; // GET
static NSString * const kProgramLoyalityGetVouchers = @"loyalty/{UserGUID}/privileges/vouchers"; // GET
static NSString * const kProgramLoyalityDelete = @"loyalty/{UserGUID}"; // DELETE
static NSString * const kProgramLoyalityAllowModels = @"loyalty/mbclasses"; // GET
static NSString * const kProgramLoyalityOrder = @"loyalty/{UserGUID}/prizes/order"; // POST
static NSString * const kProgramLoyalityVoucherOrder = @"loyalty/{UserGUID}/prizes/voucherorder"; // POST
static NSString * const kProgramLoyalityPointsList = @"loyalty/{UserGUID}/points/list"; // GET
static NSString * const kProgramLoyalityPoints = @"loyalty/{UserGUID}/points"; // GET
static NSString * const kProgramLoyalityOrders = @"loyalty/{UserGUID}/getOrders"; // GET
static NSString * const kProgramLoyalitySurveys = @"loyalty/{UserGUID}/surveys"; // GET
static NSString * const kProgramLoyalityGetTerms = @"loyalty/GetLoyalityTerms"; // GET
static NSString * const kProgramLoyalityGetOutTerms = @"loyalty/GetLoyalityTermsExit"; // GET
static NSString * const kProgramLoyalityGetDealers = @"loyalty/GetDealers"; // GET
static NSString * const kProgramLoyalityGetVoucherDealers = @"Dealers/Vouchers"; // GET
static NSString * const kProgramLoyalitySaveUserPhoto = @"Customers/{UserGUID}/saveUserPhoto"; //POST
static NSString * const kProgramLoyalityGetUserPhoto = @"Customers/{UserGUID}/getUserPhoto"; //GET
static NSString * const kProgramLoyalityDeleteUserPhoto = @"Customers/{UserGUID}/deleteUserPhoto"; //DELETE

#pragma mark - ContactsDB
static NSString * const kContactsURL = @"https://contactsdb.mercedes-benz.ru/api/";
static NSString * const kContactsURLDebug = @"https://contactsdb.mercedes-benz-test.ru/api/";
static NSString * const kContactsAuthHeader = @"Basic YXBpVXNlcjphQ2Q4ITZoRg==";
static NSString * const kContactsAuthHeaderDEBUG = @"Basic YXBpVXNlcjpmZWwyMzlpWA==";
static NSString * const kSaveOrderContactDB = @"savecontact";

#pragma mark - My AMG 
static NSString * const amgCMSURL = @"https://mobile-app.mercedes-benz.ru/api/amg/";
static NSString * const amgCMSURLDebug =  @"https://mobileappcms.mercedes-benz-test.ru/api/amg/"; // @"http://mobileapp.test02.intravision.ru/api/amg/";

static NSString * const amgUserGetGUID = @"Account/SilentRegistration"; // POST
static NSString * const amgUserRegister = @"Account/Register"; // POST
static NSString * const amgUserAuthorize = @"Account/Login"; // POST
static NSString * const amgGetSMSCode = @"loyalty/amgGetSMSCode/{UserGUID}"; // GET
static NSString * const amgCheckEmail = @"Account/CheckEmail"; // GET
static NSString * const amgCheckPhone = @"Account/CheckPhone"; // GET
static NSString * const amgResetPassword = @"Account/ResetPassword"; // POST
static NSString * const amgUserGetConsent = @"Account/{UserGUID}/GetConsent"; // GET
static NSString * const amgValidateRegistration = @"Account/ValidateRegistration";

static NSString * const amgUserCarAdditionalInfo = @"Customers/{UserGUID}/Cars/ExtraData/"; // GET
static NSString * const amgUserCarAdd = @"Customers/{UserGUID}/Cars"; // POST
static NSString * const amgUserCarUpd = @"Customers/{UserGUID}/Cars/"; // PUT
static NSString * const amgUserCarDel = @"Customers/{UserGUID}/Cars/"; // DELETE

static NSString * const amgUserDataUpd = @"Customers/{UserGUID}"; // PUT
static NSString * const amgUserDealerUpd = @"Customers/{UserGUID}/Dealer"; // PUT
static NSString * const amgUserDelete = @"Customers/{UserGUID}"; // DELETE

static NSString * const amgNewsAlertsList = /* GET */ @"News";
static NSString * const amgNewsAlertsConfirm = /* POST */ @"News/Confirmation";

static NSString * const amgUserFavCarNewAdd = /* POST */ @"Customers/{UserGUID}/Favourite/NewCars";
static NSString * const amgUserFavCarNewDel = /* DELETE */ @"Customers/{UserGUID}/Favourite/NewCars/";
static NSString * const amgUserFavCarUsedAdd = /* POST */ @"Customers/{UserGUID}/Favourite/UsedCars";
static NSString * const amgUserFavCarUsedDel = /* DELETE */ @"Customers/{UserGUID}/Favourite/UsedCars/";
