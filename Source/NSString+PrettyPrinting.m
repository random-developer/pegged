//
//  NSString+PrettyPrinting.m
//  pegged
//
//  Created by Friedrich Gräter on 27.06.13.
//
//

#import "NSString+PrettyPrinting.h"

@implementation NSString (PrettyPrinting)

- (NSString *)stringByAddingIndentationWithCount:(NSInteger)count
{
	static NSRegularExpression *expression;
	expression = expression ?: [NSRegularExpression regularExpressionWithPattern:@"^" options:NSRegularExpressionAnchorsMatchLines error:NULL];
	
	NSMutableString *tabs = [NSMutableString new];
	while (count --)
		[tabs appendString: @"\t"];
	
	return [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:tabs];
}

- (NSString *)stringByRemovingTrailingWhitespace
{
	static NSRegularExpression *expression;
	expression = expression ?: [NSRegularExpression regularExpressionWithPattern:@"\\s$" options:0 error:NULL];
		
	return [expression stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
}

@end
