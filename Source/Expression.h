//
//  Expression.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//
#import "Node.h"

@interface Expression : Node

@property (readonly) NSArray *nodes;

- (void) addAlternative:(Node *)node;

@end
