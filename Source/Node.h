//
//  Node.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

@interface Node : NSObject

@property (assign) BOOL inverted;

+ (id) node;

- (NSString *) compile:(NSString *)parserClassName;
- (void) invert;

@end
