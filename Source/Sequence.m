//
//  Sequence.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Sequence.h"

#import "Compiler.h"

@interface Sequence ()
{
	NSMutableArray *_nodes;
}

@end

@implementation Sequence

#pragma mark - NSObject Methods

- (id)init
{
    self = [super init];
    
    if (self) {
        _nodes = [NSMutableArray new];
    }
    
    return self;
}


#pragma mark - Node Methods

- (NSString *)compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    if (self.inverted)
        [code appendFormat:@"return [parser invertWithCaptures:localCaptures startIndex:startIndex block:^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", parserClassName];
    
    for (Node *node in self.nodes) {
        [code appendString:[[[node compile:parserClassName] stringByAddingIndentationWithCount: (self.inverted ? 1 : 0)] stringByRemovingTrailingWhitespace]];
		[code appendString: @"\n\n"];
	}
    
    if (self.inverted) {
        [code appendString:@"\treturn YES;\n"];
        [code appendString:@"}];\n"];
    }
    
    return code;
}


#pragma mark - Public Methods

- (void)append:(Node *)node
{
    [_nodes addObject:node];
}

@end
