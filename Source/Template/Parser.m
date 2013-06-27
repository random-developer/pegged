//
//  Generated by pegged $Version.
//  Fork: https://github.com/hydrixos/pegged
//

#import "Parser.h"

//!$Imports

// A block implementing a certain parsing rule
typedef BOOL (^$ParserClassRule)($ParserClass *parser);

// A block implementing a certain parser action
typedef void (^$ParserClassAction)($ParserClass *self, NSString *text);

/*!
 @abstract Internally used class for storing captured text results for actions.
 */
@interface $ParserClassCapture : NSObject

@property (assign) NSUInteger begin;
@property (assign) NSUInteger end;
@property (copy) $ParserClassAction action;

@end

@implementation $ParserClassCapture
@end


/*!
 @abstract Internal parser methods
 */
@interface $ParserClass ()
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
	
	NSMutableArray *_actionResults;
	NSMutableArray *_lastResultCollectionStart;
}

// Parser state information
@property (readonly) NSUInteger captureStart;
@property (readonly) NSUInteger captureEnd;
@property (readonly) NSString* string;

// Actions
- (void)beginCapture;
- (void)endCapture;
- (void)performAction:($ParserClassAction)action;

// Handling action results
- (void)pushResult:(id)match;
- (id)popResult;

- (void)beginCollectingResults;
- (NSArray *)endCollectingResults;


// Matching operations
- (void)addRule:($ParserClassRule)rule withName:(NSString *)name;

- (BOOL)lookAhead:($ParserClassRule)rule;
- (BOOL)invert:($ParserClassRule)rule;
- (BOOL)matchRule:(NSString *)ruleName;
- (BOOL)matchOne:($ParserClassRule)rule;
- (BOOL)matchMany:($ParserClassRule)rule;
- (BOOL)matchDot;
- (BOOL)matchString:(char *)s;
- (BOOL)matchClass:(unsigned char *)bits;

@end


@implementation $ParserClass

@synthesize captureStart=yybegin, captureEnd=yyend, string=_string;

//==================================================================================================
#pragma mark -
#pragma mark Rules
//==================================================================================================


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef matchDEBUG
#define yydebug(args) { fprintf args; }
#define yyprintf(args)	{ fprintf args; fprintf(stderr," @ %s",[[_string substringFromIndex:_index] UTF8String]); }
#else
#define yydebug(args)
#define yyprintf(args)
#endif

- (void) beginCapture
{
    if (_capturing) yybegin = _index;
}


- (void) endCapture
{
    if (_capturing) yyend = _index;
}


- (BOOL) invert:($ParserClassRule)rule
{
    return ![self matchOne:rule];
}


- (BOOL) lookAhead:($ParserClassRule)rule
{
    NSUInteger index=_index;
    BOOL capturing = _capturing;
    _capturing = NO;
    BOOL matched = rule(self);
    _capturing = capturing;
    _index=index;
    return matched;
}


- (BOOL) matchDot
{
    if (_index >= _limit) return NO;
    ++_index;
    return YES;
}


- (BOOL) matchOne:($ParserClassRule)rule
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


- (BOOL) matchMany:($ParserClassRule)rule
{
    if (![self matchOne:rule])
        return NO;
    while ([self matchOne:rule])
        ;
    return YES;
}


- (BOOL) matchRule:(NSString *)ruleName
{
    NSArray *rules = [_rules objectForKey:ruleName];
    if (![rules count])
        NSLog(@"Couldn't find rule name \"%@\".", ruleName);
		
		for ($ParserClassRule rule in rules)
			if ([self matchOne:rule])
				return YES;
    return NO;
}


- (BOOL) matchString:(char *)s
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

- (BOOL) matchClass:(unsigned char *)bits
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

- (void) performAction:($ParserClassAction)action
{
    $ParserClassCapture *capture = [$ParserClassCapture new];
    capture.begin  = yybegin;
    capture.end    = yyend;
    capture.action = action;
    [_captures addObject:capture];
}

- (NSString *) yyText:(NSUInteger)begin to:(NSUInteger)end
{
    NSInteger len = end - begin;
    if (len <= 0)
        return @"";
    return [_string substringWithRange:NSMakeRange(begin, len)];
}

- (void) yyDone
{
    for ($ParserClassCapture *capture in _captures)
    {
        capture.action(self, [self yyText:capture.begin to:capture.end]);
    }
}

- (void) yyCommit
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
	[_lastResultCollectionStart removeAllObjects];
	[_actionResults removeAllObjects];
}

//!$ParserDefinitions

- (BOOL) _parse
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


//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _rules = [NSMutableDictionary new];
        _captures = [NSMutableArray new];
		_lastResultCollectionStart = [NSMutableArray new];
		_actionResults = [NSMutableArray new];
		
		//!$ParserDeclarations
    }
    
    return self;
}


//==================================================================================================
#pragma mark -
#pragma mark Handling action results
//==================================================================================================
- (void)pushResult:(id)result
{
	[_actionResults addObject: result];
}

- (id)popResult
{
	id result = [_actionResults lastObject];
	[_actionResults removeLastObject];
	return result;
}

- (void)beginCollectingResults
{
	[_lastResultCollectionStart addObject: @(_actionResults.count -1)];
}

- (NSArray *)endCollectingResults
{
	NSInteger index = [_lastResultCollectionStart.lastObject integerValue];
	[_lastResultCollectionStart removeLastObject];
	
	NSArray *subarray = [_actionResults subarrayWithRange: NSMakeRange(index, _actionResults.count)];
	[_actionResults removeObjectsInRange: NSMakeRange(index, _actionResults.count)];
	
	return subarray;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void) addRule:($ParserClassRule)rule withName:(NSString *)name
{
    NSMutableArray *rules = [_rules objectForKey:name];
    if (!rules)
    {
        rules = [NSMutableArray new];
        [_rules setObject:rules forKey:name];
    }
    
    [rules addObject:rule];
}

- (BOOL) parseString:(NSString *)string
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

@end
