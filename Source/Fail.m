//
//  Fail.m
//  pegged
//
//  Created by Friedrich Gräter on 28.06.13.
//
//

#import "Fail.h"

@implementation Fail

#pragma mark - Node Methods

- (NSString *)compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendFormat: @"[parser setErrorWithMessage: @\"%@\" location:parser.index length:1];\n", _message];
	[code appendFormat: @"return NO;\n"];
	
    return code;
}


#pragma mark - Public Methods

+ (id)failWithMessage:(NSString *)message
{
    return [[[self class] alloc] initWithMessage: message];
}


- (id)initWithMessage:(NSString *)message
{
    self = [super init];
    
    if (self) {
        _message = [message copy];
    }
    
    return self;
}

@end
