//
//  Action.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//
#import "Node.h"

@class Rule;

@interface Action : Node

+ (id) actionWithCode:(NSString *)code returnValue:(BOOL)returnValue;

- (id) initWithCode:(NSString *)code returnValue:(BOOL)returnValue;

@end
