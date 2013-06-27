//
//  Generated by pegged $Version.
//  Fork: https://github.com/hydrixos/pegged
//

#import "Parser.h"

//!$Imports

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef matchDEBUG
	#define yydebug(...)		{ NSLog(__VA_ARGS__); }
	#define yyprintf(args)		{ yydebug(__VA_ARGS__); NSLog(" at %i", [self positionDescriptionForIndex: _index])); }
#else
	#define yydebug(args)
	#define yyprintf(args)
#endif


#pragma mark - Internal types

// A block implementing a certain parsing rule
typedef BOOL (^ParserClassRule)(ParserClass *parser);

// A block implementing a certain parser action
typedef void (^ParserClassAction)(ParserClass *self, NSString *text);


/*!
 @abstract Internally used class for storing captured text results for actions.
 */
@interface ParserClassCapture : NSObject

@property (assign) NSUInteger begin;
@property (assign) NSUInteger end;
@property (copy) ParserClassAction action;

@end

@implementation ParserClassCapture
@end


/*!
 @abstract Internal parser methods
 */
@interface ParserClass ()
{
	NSString *_string;
	const char *cstring;
	NSUInteger _index;
	NSUInteger _limit;
	NSMutableDictionary *_rules;
	
	BOOL _capturing;
	NSUInteger yybegin;
	NSUInteger yyend;
	NSMutableArray *_captures;
}

// Parser state information
@property (readonly) NSUInteger captureStart;
@property (readonly) NSUInteger captureEnd;
@property (readonly) NSString* string;

@end


@implementation ParserClass

@synthesize captureStart=yybegin, captureEnd=yyend, string=_string;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _rules = [NSMutableDictionary new];
        _captures = [NSMutableArray new];
		
		//!$ParserDeclarations
    }
    
    return self;
}



#pragma mark - String matching

- (void)beginCapture
{
    if (_capturing) yybegin = _index;
}

- (void)endCapture
{
    if (_capturing) yyend = _index;
}

- (BOOL)invert:(ParserClassRule)rule
{
    return ![self matchOne:rule];
}

- (BOOL)lookAhead:(ParserClassRule)rule
{
    NSUInteger index=_index;
    BOOL capturing = _capturing;
    _capturing = NO;
    BOOL matched = rule(self);
    _capturing = capturing;
    _index=index;
    return matched;
}

- (BOOL)matchDot
{
    if (_index >= _limit) return NO;
    ++_index;
    return YES;
}

- (BOOL)matchOne:(ParserClassRule)rule
{
    NSUInteger index=_index, captureCount=[_captures count];
    if (rule(self))
        return YES;
    _index=index;
    if ([_captures count] > captureCount)
    {
        NSRange rangeToRemove = NSMakeRange(captureCount, [_captures count]-captureCount);
        [_captures removeObjectsInRange:rangeToRemove];
    }
    return NO;
}

- (BOOL)matchMany:(ParserClassRule)rule
{
    if (![self matchOne:rule])
        return NO;
    while ([self matchOne:rule])
        ;
    return YES;
}

- (BOOL)matchRule:(NSString *)ruleName
{
    NSArray *rules = [_rules objectForKey:ruleName];
    if (![rules count])
        NSLog(@"Couldn't find rule name \"%@\".", ruleName);
		
		for (ParserClassRule rule in rules)
			if ([self matchOne:rule])
				return YES;
    return NO;
}

- (BOOL)matchString:(char *)s
{
    @autoreleasepool {
		NSInteger saved = _index;
		while (*s)
		{
			if (_index >= _limit) return NO;
			if (cstring[_index] != *s)
			{
				_index = saved;
				yyprintf((stderr, "  fail matchString '%s'", s));
				return NO;
			}
			++s;
			++_index;
		}
	}
    yyprintf((stderr, "  ok   matchString '%s'", s));
    return YES;
}

- (BOOL)matchClass:(unsigned char *)bits
{
    if (_index >= _limit) return NO;
    int c = [_string characterAtIndex:_index];
    if (bits[c >> 3] & (1 << (c & 7)))
    {
        ++_index;
        yyprintf((stderr, "  ok   matchClass"));
        return YES;
    }
    yyprintf((stderr, "  fail matchClass"));
    return NO;
}



#pragma mark - Action handling

- (void)performAction:(ParserClassAction)action
{
    ParserClassCapture *capture = [ParserClassCapture new];
    capture.begin  = yybegin;
    capture.end    = yyend;
    capture.action = action;
    [_captures addObject:capture];
}


#pragma mark - Rule definitions

- (void)addRule:(ParserClassRule)rule withName:(NSString *)name
{
    NSMutableArray *rules = [_rules objectForKey:name];
    if (!rules)
    {
        rules = [NSMutableArray new];
        [_rules setObject:rules forKey:name];
    }
    
    [rules addObject:rule];
}

//!$ParserDefinitions


#pragma mark - Parsing methods

- (NSString *)yyText:(NSUInteger)begin to:(NSUInteger)end
{
    NSInteger len = end - begin;
    if (len <= 0)
        return @"";
    return [_string substringWithRange:NSMakeRange(begin, len)];
}

- (void)yyDone
{
    for (ParserClassCapture *capture in _captures)
    {
        capture.action(self, [self yyText:capture.begin to:capture.end]);
    }
}

- (void)yyCommit
{
    NSString *newString = [_string substringFromIndex:_index];
    _string = newString;
#ifndef __PEG_PARSER_CASE_INSENSITIVE__
    cstring = [_string UTF8String];
#else
    cstring = [[_string lowercaseString] UTF8String];
#endif
	
    _limit -= _index;
    _index = 0;
	
    yybegin -= _index;
    yyend -= _index;
    [_captures removeAllObjects];
}

- (BOOL)_parse
{
    if (!_string)
    {
        _string = [NSString new];
        cstring = [_string UTF8String];
        _limit = 0;
        _index = 0;
    }
    yybegin= yyend= _index;
    _capturing = YES;
    
    BOOL matched = [self matchRule:@"$StartRule"];
    
    if (matched)
        [self yyDone];
    [self yyCommit];
    
    _string = nil;
    cstring = nil;
    
    return matched;
}

- (BOOL)parseString:(NSString *)string
{
    _string = [string copy];
#ifndef __PEG_PARSER_CASE_INSENSITIVE__
    cstring = [_string UTF8String];
#else
    cstring = [[_string lowercaseString] UTF8String];
#endif
	
    _limit  = [_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    _index  = 0;
    BOOL retval = [self _parse];
    _string = nil;
    cstring = nil;
    return retval;
}


#pragma mark - Helper methods

- (NSInteger)lineNumberForIndex:(NSInteger)index
{
	__block NSInteger line = 0;
	
	[_string enumerateSubstringsInRange:NSMakeRange(0, index) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		line ++;
	}];
	
	return line;
}

- (NSInteger)columnNumberForIndex:(NSInteger)index
{
	return index - [_string lineRangeForRange: NSMakeRange(index, 1)].location;
}

- (NSString *)positionDescriptionForIndex:(NSInteger)index
{
	return [NSString stringWithFormat: @"line: %li, column: %li", [self lineNumberForIndex: index], [self columnNumberForIndex: index]];
}

@end
