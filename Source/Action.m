//
//  Action.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Action.h"

@interface Action ()
{
    NSString *_code;
	BOOL _hasReturnValue;
}

@end

@implementation Action

#pragma mark - Node Methods

- (NSString *)compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendFormat:@"[parser performActionUsingCaptures:*localCaptures startIndex:startIndex block:^id(%@ *self, NSString *text, NSString **errorCode) {\n", parserClassName];
    [code appendString:[[_code stringByAddingIndentationWithCount: 1] stringByRemovingTrailingWhitespace]];
	if (!_hasReturnValue)
		[code appendString: @"\n\n\treturn nil;\n"];
	else
		[code appendString: @"\n"];
    [code appendString:@"}];\n"];
    	
    return code;
}


#pragma mark - Public Methods

+ (id)actionWithCode:(NSString *)code returnValue:(BOOL)returnValue
{
    return [[[self class] alloc] initWithCode:code returnValue:returnValue];
}


- (id)initWithCode:(NSString *)code returnValue:(BOOL)returnValue
{
    self = [super init];
    
    if (self)
    {
        _code = [code copy];
		_hasReturnValue = returnValue;
    }
    
    return self;
}

@end
