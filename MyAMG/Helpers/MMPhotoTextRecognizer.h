//
//  MMPhotoTextRecognizer.h
//  mymercedes
//
//  Created by Alexander Koulabuhov on 22/06/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MMPhotoTextRecognizerResultOK,
    MMPhotoTextRecognizerResultFailed,
    MMPhotoTextRecognizerResultNotValidated
} MMPhotoTextRecognizerResult;

@interface MMPhotoTextRecognizer : NSObject

+(void)recognizeVIN:(UIImage *)image completion:(void(^)(MMPhotoTextRecognizerResult result, NSString *text, NSString *errorMessage))completion;

@end
