//
//  MMFormPhoneTextField.m
//  mymercedes
//
//  Created by Александр Кулабухов on 15/07/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import "MMFormPhoneTextField.h"
#import "UITextField+SelectionRanges.h"

static NSString * const kMMFormPhoneTextFieldMaskSymbolsString = @"()- ";
static NSString * const kMMFormPhoneTextFieldNumbersString = @"0123456789";
static NSString * const kMMFormPhoneTextFieldPhonePrefix = @"+7 ";

@interface MMFormPhoneTextField()

@property (nonatomic, strong) NSString *previousText;

@end

@implementation MMFormPhoneTextField

@dynamic phone;

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.text = kMMFormPhoneTextFieldPhonePrefix;
    _previousText = self.text;
    
    [self addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
}

-(void)textChanged {
    
    if ([self.text length] < [kMMFormPhoneTextFieldPhonePrefix length]) {
        self.text = kMMFormPhoneTextFieldPhonePrefix;
        return;
    }

    BOOL deletingLastSymbol = [_previousText hasPrefix:self.text] && ([self.text length] == [_previousText length] - 1);
    
    if (deletingLastSymbol) {
        
        NSString *temporaryString = self.text;
        
        NSString *lastCharSymbol = [NSString stringWithFormat:@"%c", [_previousText characterAtIndex:[_previousText length] - 1]];
        BOOL deletedSpecialChar = [kMMFormPhoneTextFieldMaskSymbolsString rangeOfString:lastCharSymbol].location != NSNotFound;
        
        if (deletedSpecialChar) {
            // If we deleting special symbol, delete all special chars until number appeared
            temporaryString = [self numbersStringFromString:temporaryString];
            if (temporaryString.length > 1) {
                temporaryString = [temporaryString substringToIndex:[temporaryString length] - 1];
            }
        }
        
        self.text = temporaryString;
    }
    
    NSString *formattedText = [self formatPhone:self.text];
    
    if (![formattedText isEqualToString:self.text]) {
        self.text = formattedText;
    }
    
    _previousText = self.text;
}

-(BOOL)isPhoneValid {
    return self.text.length == 18;
}

-(NSString *)phone {
    return [@"7" stringByAppendingString:[self numbersStringFromString:self.text]];
}

#pragma mark - Phone formatters

-(NSString *)numbersStringFromString:(NSString *)source {
    
    NSString *prefix = [kMMFormPhoneTextFieldPhonePrefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([source hasPrefix:prefix]) {
        source = [source substringFromIndex:2];
    }
    
    source = [[source componentsSeparatedByCharactersInSet:
               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
              componentsJoinedByString:@""];
    
    return source;
}


-(NSString*)formatPhone:(NSString *)source {
    
    if (source.length == 0) {
        return kMMFormPhoneTextFieldPhonePrefix;
    }
    
    NSMutableString *formattedPhone = [kMMFormPhoneTextFieldPhonePrefix mutableCopy];
    
    NSString *sourceNumbers = [self numbersStringFromString:source];
    
    if ([sourceNumbers length] > 10) {
        sourceNumbers = [sourceNumbers substringToIndex:10];
    }
    
    for (int i = 0; i < [sourceNumbers length]; i++) {
        
        if (i == 0) {
            [formattedPhone appendString:@"("];
        }
        
        [formattedPhone appendFormat:@"%c", [sourceNumbers characterAtIndex: i]];
        
        if (i == 2) {
            [formattedPhone appendString:@") "];
        }
        
        if (i == 5 || i == 7) {
            [formattedPhone appendString:@"-"];
        }
    }
    
    return formattedPhone;
}

-(void)dealloc {
    [self removeTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
}

@end
