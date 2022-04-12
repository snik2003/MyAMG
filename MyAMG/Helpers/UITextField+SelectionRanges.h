//
//  UITextField+SelectionRanges.h
//

#import <UIKit/UIKit.h>

@interface UITextField (SelectionRanges)

- (NSRange) selectionRange;
- (void) selectRange:(NSRange) range;

@end
