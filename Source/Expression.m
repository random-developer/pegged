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

- (NSString *)compile:(NSString *)parserClassName language:(NSString*)language
{
    NSMutableString *code = [NSMutableString string];
    NSString *selector = self.inverted ? @"invert" : @"matchOne";
    
    if([language isEqualToString: @"swift"]) {
        [code appendFormat:@"if (!parser.%@WithCaptures(&localCaptures, startIndex:startIndex, block:{(parser: %@, startIndex: Int, inout localCaptures: Int) -> Bool in\n", selector, parserClassName];
        
        for (Node *node in self.nodes) {
            [code appendFormat:@"\tif (parser.matchOneWithCaptures(&localCaptures, startIndex:startIndex, block:{(parser: %@, startIndex: Int, inout localCaptures: Int) -> Bool in\n", parserClassName];
            [code appendString:[[[node compile:parserClassName language: language] stringByAddingIndentationWithCount: 2] stringByRemovingTrailingWhitespace]];
            [code appendString:@"\n\t\treturn true"];
            [code appendString:@"\n\t})) {\n\t\treturn true\n}\n"];
        }
        
        [code appendString:@"\treturn false\n"];
        [code appendString:@"})) {\n\treturn false\n}\n"];
    } else {
        [code appendFormat:@"if (![parser %@WithCaptures:localCaptures startIndex:startIndex block:^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", selector, parserClassName];
        
        for (Node *node in self.nodes) {
            [code appendFormat:@"\tif ([parser matchOneWithCaptures:localCaptures startIndex:startIndex block:^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", parserClassName];
            [code appendString:[[[node compile:parserClassName language: language] stringByAddingIndentationWithCount: 2] stringByRemovingTrailingWhitespace]];
            [code appendString:@"\n\t\treturn YES;"];
            [code appendString:@"\n\t}])\n\t\treturn YES;\n\n"];
        }
        
        [code appendString:@"\treturn NO;\n"];
        [code appendString:@"}])\n\treturn NO;\n\n"];
    }
    
    return code;
}


#pragma mark - Public Methods

- (void)addAlternative:(Node *)node
{
    [_nodes addObject:node];
}


@end
