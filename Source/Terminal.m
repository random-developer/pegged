//
//  Terminal.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Terminal.h"

#import "Compiler.h"

@implementation Terminal

#pragma mark - Public Methods

- (NSString *)compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendFormat:@"if (%@%@)\n\treturn NO;\n",
     self.inverted ? @"" : @"!", [self condition]];
    
	NSString *acceptanceCode = self.compileIfAccepted;
	
	if (acceptanceCode)
		[code appendFormat: @"else\n\t%@\n", self.compileIfAccepted];
	
    return code;
}


- (NSString *)condition
{
    return nil;
}

- (NSString *)compileIfAccepted
{
	return nil;
}

@end
