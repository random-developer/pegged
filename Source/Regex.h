//
//  Regex.h
//  pegged
//
//  This code is in the public domain.
//
#import "Terminal.h"

@interface Regex : Terminal

@property (assign) BOOL caseInsensitive;
@property (readonly) NSString *string;
@property (readonly) BOOL asserted;

+ (id) regexWithString:(NSString *)regex;
- (id) initWithString:(NSString *)regex;

@end
