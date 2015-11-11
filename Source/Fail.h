//
//  Fail.h
//  pegged
//
//  Created by Friedrich Gräter on 28.06.13.
//
//

#import "Node.h"

@interface Fail : Node
{
    NSString *_message;
}

+ (id) failWithMessage:(NSString *)message;
- (id) initWithMessage:(NSString *)message;

@end
