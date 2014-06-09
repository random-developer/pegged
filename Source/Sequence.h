//
//  Sequence.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//
#import "Node.h"

@interface Sequence : Node

@property (readonly) NSArray *nodes;

- (void) append:(Node *)node;

@end
