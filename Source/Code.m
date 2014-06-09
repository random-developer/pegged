//
//  Code.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Code.h"

@implementation Code

#pragma mark - Node Methods

- (NSString *)compile:(NSString *)failLabel
{
    return [NSString stringWithFormat:@"%@;\n", self.code];
}


#pragma mark - Public Methods

+ (id)codeWithString:(NSString *)code
{
    return [[[self class] alloc] initWithString:code];
}


- (id)initWithString:(NSString *)code
{
    self = [super init];
    
    if (self)
    {
        _code = [code copy];
    }
    
    return self;
}

@end
