//
//  Rule.m
//  pegged
//
//  Created by Matt Diephouse on 12/28/09.
//  This code is in the public domain.
//

#import "Rule.h"

#import "Compiler.h"
#import "Node.h"

@implementation Rule

#pragma mark - Public Methods

+ (id)ruleWithName:(NSString*)name
{
    return [[[self class] alloc] initWithName:name];
}


- (id)initWithName:(NSString*)name
{
    self = [super init];
    
    if (self)
    {
        _name = [name copy];
    }
    
    return self;
}


- (NSString *)compile:(NSString *)parserClassName language:(NSString*)language
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendString: [[self.definition compile:parserClassName language: language] stringByRemovingTrailingWhitespace]];
    if([language isEqualToString: @"swift"]) {
        [code appendString: @"\n\nreturn true\n"];
    } else {
        [code appendString: @"\n\nreturn YES;\n"];
    }
    
    return code;
}


#pragma mark - Public Properties

- (BOOL)defined
{
    return self.definition != nil;
}


@end
