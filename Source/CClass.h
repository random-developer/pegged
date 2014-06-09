//
//  CClass.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//
#import "Terminal.h"

@interface CClass : Terminal

@property (assign) BOOL caseInsensitive;
@property (readonly) NSString *string;

+ (id) cclassFromString:(NSString *)class;
- (id) initWithString:(NSString *)class;

@end
