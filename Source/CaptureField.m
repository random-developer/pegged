//
//  CaptureField.m
//  pegged
//
//  This code is in the public domain.
//

#import "CaptureField.h"


@implementation CaptureField

#pragma mark - Node Methods

- (NSString *)compile:(NSString *)failLabel language:(NSString *)language
{
    return [NSString stringWithFormat:@"[parser setField:@\"%@\" value:parser.recentSubstring];", self.fieldName];
}


#pragma mark - Public Methods

+ (id)fieldWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}


- (id)initWithName:(NSString *)name
{
    self = [super init];

    if (self)
    {
        _fieldName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    }

    return self;
}

@end
