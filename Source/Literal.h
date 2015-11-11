//
//  Literal.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//
#import "Terminal.h"

@interface Literal : Terminal

@property (assign) BOOL caseInsensitive;
@property (readonly) NSString *string;
@property (readonly) BOOL asserted;

+ (id) literalWithString:(NSString *)string asserted:(BOOL)asserted;
- (id) initWithString:(NSString *)string asserted:(BOOL)asserted;

@end
