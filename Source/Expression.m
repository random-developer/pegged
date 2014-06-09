//
//  Expression.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Expression.h"

#import "Compiler.h"

@interface Expression ()
{
	NSMutableArray *_nodes;
}

@end

@implementation Expression

#pragma mark - Public Methods

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _nodes = [NSMutableArray new];
    }
    
    return self;
}


#pragma mark - Node Methods

- (NSString *)compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    NSString *selector = self.inverted ? @"invert" : @"matchOne";
    
    [code appendFormat:@"if (![parser %@WithCaptures:localCaptures startIndex:startIndex block:^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", selector, parserClassName];
    
	for (Node *node in self.nodes) {
        [code appendFormat:@"\tif ([parser matchOneWithCaptures:localCaptures startIndex:startIndex block:^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", parserClassName];
        [code appendString:[[[node compile:parserClassName] stringByAddingIndentationWithCount: 2] stringByRemovingTrailingWhitespace]];
        [code appendString:@"\n\t\treturn YES;"];
        [code appendString:@"\n\t}])\n\t\treturn YES;\n\n"];
    }
	
    [code appendString:@"\treturn NO;\n"];
    [code appendString:@"}])\n\treturn NO;\n\n"];
    
    return code;
}


#pragma mark - Public Methods

- (void)addAlternative:(Node *)node
{
    [_nodes addObject:node];
}


@end
