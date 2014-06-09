//
//  Condition.m
//  pegged
//
//  Created by Matt Diephouse on 1/8/10.
//  This code is in the public domain.
//

#import "Condition.h"

@implementation Condition

#pragma mark - Terminal Methods

- (NSString *)condition
{
    return [NSString stringWithFormat:@"(%@)", _expression];
}


#pragma mark - Public Methods

+ (id)conditionWithExpression:(NSString *)expression
{
    return [[[self class] alloc] initWithExpression:expression];
}


- (id)initWithExpression:(NSString *)expression
{
    self = [super init];
    
    if (self)
    {
        _expression = [expression copy];
    }
    
    return self;
}


@end
