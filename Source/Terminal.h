//
//  Terminal.h
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//
#import "Node.h"

@interface Terminal : Node

- (NSString *) condition;

- (NSString *) compileIfAccepted;

@end
