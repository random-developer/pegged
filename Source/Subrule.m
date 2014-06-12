//
//  Subrule.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Subrule.h"
#import "Rule.h"

@implementation Subrule

#pragma mark - Terminal Methods

- (NSString *)condition:(NSString*)language
{
    if([language isEqualToString: @"swift"]) {
        return [NSString stringWithFormat:@"parser.matchRule(\"%@\", startIndex:startIndex, asserted: %@)", self.rule.name, _asserted ? @"true" : @"false"];
    } else {
        return [NSString stringWithFormat:@"[parser matchRule: @\"%@\" startIndex:startIndex asserted:%@]", self.rule.name, _asserted ? @"YES" : @"NO"];
    }
}

- (NSString *)compileIfAccepted:(NSString*)language
{
	if (_capturing)
        if([language isEqualToString: @"swift"]) {
            return @"localCaptures = localCaptures + 1\n";
        } else {
            return @"*localCaptures += 1;\n";
        }
	else
		return nil;
}


#pragma mark - Public Methods

+ (id)subruleWithRule:(Rule *)rule capturing:(BOOL)capturing asserted:(BOOL)asserted
{
    return [[[self class] alloc] initWithRule:rule capturing:capturing asserted:asserted];
}


- (id)initWithRule:(Rule *)rule capturing:(BOOL)capturing asserted:(BOOL)asserted
{
    self = [super init];
    
    if (self)
    {
        _rule = rule;
		_capturing = capturing;
		_asserted = asserted;
    }
    
    return self;
}

@end
