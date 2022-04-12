//
//  MMPhotoTextRecognizer.m
//  mymercedes
//
//  Created by Alexander Koulabuhov on 22/06/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import "MMPhotoTextRecognizer.h"
#import "API_WRAPPER.h"

#define MMPhotoRecognizerInnerServerErrorText @"Произошла внутренняя ошибка сервера. Пожалуйста, повторите запрос позже"
#define MMPhotoRecognizerNotValidatedText @"VIN не распознан. Сфотографируйте повторно или введите вручную"
#define MMPhotoRecognizerNotFoundText @"VIN не найден на фото. Пожалуйста, попробуйте сфотографировать еще раз"

#define MMPhotoRecognizerWrongSymbolsArray @[@"?", @"!", @"(", @")", @"|", @"\\", @"/"]
#define MMPhotoRecognizerRightSymbolsArray @[@"2", @"1", @"1", @"1", @"1", @"1", @"1"]
#define MMPhotoRecognizerAllowedSymbols @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

@implementation MMPhotoTextRecognizer

+(void)recognizeVIN:(UIImage *)image completion:(void(^)(MMPhotoTextRecognizerResult result, NSString *vin, NSString *errorMessage))completion {
    
    [API_WRAPPER ocrRecognizeImage:image success:^(NSData *data) {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"OCRAPI JSON = %@",results);
        
        if (!results) {
            NSLog(@"OCRAPI: JSON Parsing error");
            completion(MMPhotoTextRecognizerResultFailed, nil, MMPhotoRecognizerInnerServerErrorText);
            return;
        }
        
        if (![results[@"OCRExitCode"] isEqual:@(1)]) {
            NSLog(@"OCRAPI: wrong exit code - %@, should be 1", results[@"OCRExitCode"]);
            completion(MMPhotoTextRecognizerResultFailed, nil, MMPhotoRecognizerNotFoundText);
            return;
        }
        
        NSArray *parsed = results[@"ParsedResults"];
        
        if (!parsed || (NSNull *)parsed == [NSNull null] || [parsed count] != 1) {
            NSLog(@"OCRAPI: results not parsed correctly");
            completion(MMPhotoTextRecognizerResultNotValidated, nil, MMPhotoRecognizerNotValidatedText);
            return;
        }
        
        NSDictionary *resultObject = parsed[0];
        NSString *parsedText = resultObject[@"ParsedText"];
        parsedText = [[parsedText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
        parsedText = [parsedText uppercaseString];
        
        NSInteger minPrefixLocation = NSNotFound;
        NSArray *prefixes = @[@"3AM", @"3MB", @"4JG", @"5DH", @"8AB", @"8AC", @"9BM", @"ADB", @"KPA", @"KPD", @"KPG", @"LB1", @"LE4", @"LEN", @"MEC", @"MHL", @"NAB", @"NMB", @"RLM", @"TAW", @"TCC", @"VAG", @"VF9", @"VS9", @"VSA", @"WCD", @"WD0", @"WD1", @"WD2", @"WD3", @"WD4", @"WD5", @"WD6", @"WD7", @"WD8", @"WD9", @"WDA", @"WDB", @"WDC", @"WDD", @"WDF", @"WDP", @"WDR", @"WDW", @"WDX", @"WDY", @"WDZ", @"WEB", @"WKK", @"WME", @"WMX", @"XDN", @"Z9M"];
        
        for (NSString *prefix in prefixes) {
            NSRange range = [parsedText rangeOfString:prefix];
            if (range.location != NSNotFound && range.location < minPrefixLocation) {
                minPrefixLocation = range.location;
            }
        }
        
        if (minPrefixLocation == NSNotFound) {
            NSLog(@"OCRAPI: no vin prefix found - %@", parsedText);
            completion(MMPhotoTextRecognizerResultNotValidated, nil, MMPhotoRecognizerNotValidatedText);
            return;
        }
        
        parsedText = [parsedText substringFromIndex:minPrefixLocation];
        
        if (parsedText.length > 17) {
            parsedText = [parsedText substringToIndex:17];
        }
        
        for (NSString *wrongSymbol in MMPhotoRecognizerWrongSymbolsArray) {
            NSInteger foundIndex = [MMPhotoRecognizerWrongSymbolsArray indexOfObject:wrongSymbol];
            parsedText = [parsedText stringByReplacingOccurrencesOfString:wrongSymbol withString:MMPhotoRecognizerRightSymbolsArray[foundIndex]];
        }
        
        NSCharacterSet *wrongCharactersSet = [[NSCharacterSet characterSetWithCharactersInString:MMPhotoRecognizerAllowedSymbols] invertedSet];
        parsedText = [[parsedText componentsSeparatedByCharactersInSet:wrongCharactersSet] componentsJoinedByString:@""];
        
        if (parsedText.length < 17) {
            NSLog(@"OCRAPI: text too short < 17 symb");
            completion(MMPhotoTextRecognizerResultNotValidated, nil, MMPhotoRecognizerNotValidatedText);
            return;
        }
        
        [self checkVinIsValid:parsedText completion:^(BOOL isValid) {
            if (isValid) {
                NSLog(@"OCRAPI: successfully recognized - %@", parsedText);
                completion(MMPhotoTextRecognizerResultOK, parsedText, nil);
            }
            else {
                NSLog(@"OCRAPI: not validated - %@", parsedText);
                completion(MMPhotoTextRecognizerResultNotValidated, nil, [NSString stringWithFormat:@"VIN был распознан:\n%@,\n но не прошел проверку на валидность.",parsedText]);
            }
        }];
        
    } failure:^{
        completion(MMPhotoTextRecognizerResultFailed, nil, @"Ошибка при соединении с сервером. Проверьте соединение с интернетом или повторите запрос позже");
    }];
}

+(void)checkVinIsValid:(NSString *)vinString completion:(void(^)(BOOL isValid))completionBlock {
    
    NSArray* defaultPrefixes = @[@"3AM", @"3MB", @"4JG", @"5DH", @"8AB", @"8AC", @"9BM", @"ADB", @"KPA", @"KPD", @"KPG", @"LB1", @"LE4", @"LEN", @"MEC", @"MHL", @"NAB", @"NMB", @"RLM", @"TAW", @"TCC", @"VAG", @"VF9", @"VS9", @"VSA", @"WCD", @"WD0", @"WD1", @"WD2", @"WD3", @"WD4", @"WD5", @"WD6", @"WD7", @"WD8", @"WD9", @"WDA", @"WDB", @"WDC", @"WDD", @"WDF", @"WDP", @"WDR", @"WDW", @"WDX", @"WDY", @"WDZ", @"WEB", @"WKK", @"WME", @"WMX", @"XDN", @"Z9M"];
    
    void(^checkVin)(NSArray <NSString *> *) = ^(NSArray <NSString *> *prefixes) {
        
        if (![prefixes isKindOfClass:[NSArray class]] || prefixes.count == 0 || ![prefixes[0] isKindOfClass:[NSString class]]) {
            prefixes = defaultPrefixes;
        }
        
        NSString *vinStr = [vinString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(vinStr.length == 0) {
            completionBlock(YES);
            return;
        }
        if(vinStr.length != 17) {
            completionBlock(NO);
            return;
        }
        
        NSString *onlyNumbersPart = [vinStr substringWithRange:NSMakeRange(3, 6)];
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([onlyNumbersPart rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
            completionBlock(NO);
            return;
        }
        
        NSString* vinPfx = [[vinStr substringToIndex:3] uppercaseString];
        for(NSString* pfx in prefixes) {
            if([vinPfx compare:pfx] == NSOrderedSame) {
                completionBlock(YES);
                return;
            }
        }
        
        completionBlock(NO);
    };
    
    checkVin(defaultPrefixes);
}


@end
