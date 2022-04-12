//
//  UITextField+SelectionRanges.m
//

#import "UITextField+SelectionRanges.h"

@implementation UITextField (SelectionRanges)

- (NSRange) selectionRange {
    return NSMakeRange([self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start], [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end]);
}

- (void) selectRange:(NSRange) range {
    UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:self.beginningOfDocument offset:range.location+range.length];
    self.selectedTextRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
}

@end
