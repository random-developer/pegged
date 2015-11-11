//
//  Code.h
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//
#import "Node.h"

@interface Code : Node
{
    NSString *_code;
}

@property (copy) NSString *code;

+ (id) codeWithString:(NSString *)string;
- (id) initWithString:(NSString *)string;

@end
