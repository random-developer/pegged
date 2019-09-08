//
//  CaptureField.h
//  pegged
//
//  This code is in the public domain.
//
#import "Node.h"

@interface CaptureField : Node
{
    NSString *_fieldName;
}

@property (copy) NSString *fieldName;

+ (id) fieldWithName:(NSString *)name;
- (id) initWithName:(NSString *)name;

@end
