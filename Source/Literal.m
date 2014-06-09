//
//  Literal.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Literal.h"


@implementation Literal

#pragma mark - Terminal Methods

- (NSString *)condition: (NSString*)language
{
    NSString *string = self.caseInsensitive ? [self.string lowercaseString] : self.string;
    if([language isEqualToString: @"swift"]) {
        return [NSString stringWithFormat:@"parser.matchString(literal: \"%@\", startIndex: startIndex, asserted: %@)", string, _asserted ? @"true" : @"false"];
    } else {
        return [NSString stringWithFormat:@"[parser matchString:\"%@\" startIndex:startIndex asserted:%@]", string, _asserted ? @"YES" : @"NO"];
    }
}


#pragma mark - Public Methods

+ (id)literalWithString:(NSString *)string asserted:(BOOL)asserted
{
    return [[[self class] alloc] initWithString:string asserted:asserted];
}


- (id)initWithString:(NSString *)string asserted:(BOOL)asserted
{
    self = [super init];
    
    if (self) {
        _string = [string copy];
		_asserted = asserted;
    }
    
    return self;
}


@end
