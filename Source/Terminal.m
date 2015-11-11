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

- (NSString *)compile:(NSString *)parserClassName language:(NSString *)language
{
    NSMutableString *code = [NSMutableString string];
    
    if([language isEqualToString: @"swift"]) {
        [code appendFormat:@"if (%@%@) {\n\treturn false\n}\n",
         self.inverted ? @"" : @"!", [self condition: language]];
        
        NSString *acceptanceCode = [self compileIfAccepted: language];
        
        if (acceptanceCode)
            [code appendFormat: @"else {\n\t%@ }\n", [self compileIfAccepted: language]];
    } else {
        [code appendFormat:@"if (%@%@)\n\treturn NO;\n",
         self.inverted ? @"" : @"!", [self condition: language]];
        
        NSString *acceptanceCode = [self compileIfAccepted: language];
        
        if (acceptanceCode)
            [code appendFormat: @"else\n\t%@\n", [self compileIfAccepted: language]];
    }
    
    return code;
}


- (NSString *)condition:(NSString*)language
{
    return nil;
}

- (NSString *)compileIfAccepted:(NSString*)language
{
	return nil;
}

@end
