//
//  Subrule.h
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//
#import "Terminal.h"

@class Rule;

@interface Subrule : Terminal
{
    Rule *_rule;
	BOOL _capturing;
	BOOL _asserted;
}

@property (strong) Rule *rule;

+ (id) subruleWithRule:(Rule *)rule capturing:(BOOL)capturing asserted:(BOOL)asserted;
- (id) initWithRule:(Rule *)rule capturing:(BOOL)capturing asserted:(BOOL)asserted;

@end
