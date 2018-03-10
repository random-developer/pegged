//
//  Regex.m
//  pegged
//
//  This code is in the public domain.
//

#import "Regex.h"


@implementation Regex

#pragma mark - Terminal Methods

- (NSString *)condition: (NSString*)language
{
    NSString *string = self.caseInsensitive ? [self.string lowercaseString] : self.string;
    if([language isEqualToString: @"swift"]) {
        return @"Regex matching isn't in pegged's swift support currently.";
        //return [NSString stringWithFormat:@"parser.matchRegex(\"%@\", startIndex: startIndex, asserted: %@)", string, _asserted ? @"true" : @"false"];
    } else {
        return [NSString stringWithFormat:@"[parser matchRegex:\"%@\" startIndex:startIndex asserted:%@]", string, _asserted ? @"YES" : @"NO"];
    }
}


#pragma mark - Public Methods

+ (id)regexWithString:(NSString *)regex
{
    return [[[self class] alloc] initWithString:regex];
}


- (id)initWithString:(NSString *)regex
{
    self = [super init];
    
    if (self) {
        _string = [regex copy];
		_asserted = NO;
    }
    
    return self;
}


@end
