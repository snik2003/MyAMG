//
//  MMFormPhoneTextField.h
//  mymercedes
//
//  Created by Александр Кулабухов on 15/07/16.
//  Copyright © 2016 Daimler AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMFormPhoneTextField : UITextField

@property (strong, nonatomic, readonly) NSString *phone;
@property (nonatomic, assign, readonly) BOOL isPhoneValid;

-(NSString*)formatPhone:(NSString *)source;

@end
