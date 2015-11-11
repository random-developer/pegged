//
//  NSString+PrettyPrinting.h
//  pegged
//
//  Created by Friedrich Gräter on 27.06.13.
//
//

/*!
 @abstract Methods for pretty printing of strings.
 */
@interface NSString (PrettyPrinting)

/*!
 @abstract Creates a copy of the current string that adds indentation of a certain count to all lines of the string.
 */
- (NSString *)stringByAddingIndentationWithCount:(NSInteger)count;

/*!
 @abstract Creates a copy of the current string that has no trailing whitespaces.
 */
- (NSString *)stringByRemovingTrailingWhitespace;

@end
