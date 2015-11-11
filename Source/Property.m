//
//  Property.m
//  pegged
//
//  Created by Matt Diephouse on 1/10/10.
//  This code is in the public domain.
//

#import "Property.h"

@implementation Property

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _name = @"";
        _parameters = @"";
        _stars = @"";
        _type = @"";
    }
    
    return self;
}

- (BOOL)_typeIsPrivateClass
{
    if (![_type length] || ![_stars length])
        return NO;
    
    if ([_type length] == 1)
        return YES;
    
    if ([_type characterAtIndex:0] == 'N' && [_type characterAtIndex:1] == 'S')
        return NO;
    
    return YES;
}


#pragma mark - Public Methods

- (NSString *)declaration
{
    return [self _typeIsPrivateClass] ? [NSString stringWithFormat:@"@class %@;\n", _type] : @"";
}


- (NSString *)import
{
    return [self _typeIsPrivateClass] ? [NSString stringWithFormat:@"#import \"%@.h\"\n", _type] : @"";
}


- (NSString *)property
{
    return [NSString stringWithFormat:@"@property %@ %@ %@%@;\n", _parameters, _type, _stars, _name];
}


- (NSString *)synthesize
{
    return [NSString stringWithFormat:@"@synthesize %@ = _%@;\n", _name, _name];
}


- (NSString *)variable
{
    return [NSString stringWithFormat:@"    %@ %@_%@;\n", _type, _stars, _name];
}

@end
