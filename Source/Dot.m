//
//  Dot.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Dot.h"


@implementation Dot

#pragma mark - Terminal Methods

- (NSString *)condition: (NSString*)language
{
    if([language isEqualToString: @"swift"]) {
        return @"parser.matchDot()";
    } else {
        return @"[parser matchDot]";
    }
}

@end
