//
//  Generated by pegged 0.4.1.
//  Fork: https://github.com/hydrixos/pegged
//

#import "PEGParser.h"

#import "Compiler.h"


// A block implementing a certain parsing rule
typedef BOOL (^PEGParserRule)(PEGParser *parser);

// A block implementing a certain parser action
typedef void (^PEGParserAction)(PEGParser *self, NSString *text);

/*!
 @abstract Internally used class for storing captured text results for actions.
 */
@interface PEGParserCapture : NSObject

@property (assign) NSUInteger begin;
@property (assign) NSUInteger end;
@property (copy) PEGParserAction action;

@end

@implementation PEGParserCapture
@end


/*!
 @abstract Internal parser methods
 */
@interface PEGParser ()
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
- (void)performAction:(PEGParserAction)action;

// Handling action results
- (void)pushResult:(id)match;
- (id)popResult;

- (void)beginCollectingResults;
- (NSArray *)endCollectingResults;


// Matching operations
- (void)addRule:(PEGParserRule)rule withName:(NSString *)name;

- (BOOL)lookAhead:(PEGParserRule)rule;
- (BOOL)invert:(PEGParserRule)rule;
- (BOOL)matchRule:(NSString *)ruleName;
- (BOOL)matchOne:(PEGParserRule)rule;
- (BOOL)matchMany:(PEGParserRule)rule;
- (BOOL)matchDot;
- (BOOL)matchString:(char *)s;
- (BOOL)matchClass:(unsigned char *)bits;

@end


@implementation PEGParser

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


- (BOOL) invert:(PEGParserRule)rule
{
    return ![self matchOne:rule];
}


- (BOOL) lookAhead:(PEGParserRule)rule
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


- (BOOL) matchOne:(PEGParserRule)rule
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


- (BOOL) matchMany:(PEGParserRule)rule
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
		
		for (PEGParserRule rule in rules)
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

- (void) performAction:(PEGParserAction)action
{
    PEGParserCapture *capture = [PEGParserCapture new];
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
    for (PEGParserCapture *capture in _captures)
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

static PEGParserRule __AND = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'AND'\n"))
    if (![parser matchString:"&"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Action = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Action'\n"))
    if (![parser matchString:"{"]) return NO;
    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\337\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchString:"}"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __BEGIN = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'BEGIN'\n"))
    if (![parser matchString:"<"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __CLOSE = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'CLOSE'\n"))
    if (![parser matchString:")"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Char = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Char'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\\"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\204\000\000\000\000\000\000\070\000\100\024\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\\"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\\"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    [parser matchOne:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }];
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\\x"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\003\176\000\000\000\176\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\003\176\000\000\000\176\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchString:"\\"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchDot]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __Class = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Class'\n"))
    if (![parser matchString:"["]) return NO;
    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchString:"]"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchRule:@"Range"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchString:"]"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Code = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Code'\n"))
    if (![parser matchString:"{{"]) return NO;
    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\337\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchString:"}}"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Comment = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Comment'\n"))
    if (![parser matchString:"#"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchRule:@"EndOfLine"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchDot]) return NO;
    return YES;    }];
    if (![parser matchRule:@"EndOfLine"]) return NO;
    return YES;
};

static PEGParserRule __DOT = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'DOT'\n"))
    if (![parser matchString:"."]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Declaration = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Declaration'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"OPTION"]) return NO;
    if (![parser matchString:"case-insensitive"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }];
    if (![parser matchRule:@"EndOfDecl"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ self.compiler.caseInsensitive = YES;     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"OPTION"]) return NO;
    if (![parser matchString:"match-debug"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }];
    if (![parser matchRule:@"EndOfDecl"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ self.compiler.matchDebug = YES;     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"PROPERTY"]) return NO;
    [parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"PropParamaters"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedPropertyParameters:text];     }];    return YES;    }];
    if (![parser matchRule:@"PropIdentifier"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedPropertyType:text];     }];    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchString:"*"]) return NO;
    return YES;    }];
    [parser endCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }];
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedPropertyStars:text];     }];    if (![parser matchRule:@"PropIdentifier"]) return NO;
    if (![parser matchRule:@"EndOfDecl"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedPropertyName:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"ExtraCode"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __Definition = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Definition'\n"))
    if (![parser matchRule:@"Identifier"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler startRule:text];     }];    if (![parser matchRule:@"LEFTARROW"]) return NO;
    if (![parser matchRule:@"Expression"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedRule];     }];    return YES;
};

static PEGParserRule __END = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'END'\n"))
    if (![parser matchString:">"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Effect = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Effect'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Code"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedCode:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Action"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedAction:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"BEGIN"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler beginCapture];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"END"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler endCapture];     }];    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __EndOfDecl = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'EndOfDecl'\n"))
    if (![parser matchString:";"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }];
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"EndOfLine"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Comment"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __EndOfFile = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'EndOfFile'\n"))
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchDot]) return NO;
    return YES;    }]) return NO;
    return YES;
};

static PEGParserRule __EndOfLine = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'EndOfLine'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\r\n"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\n"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\r"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __Expression = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Expression'\n"))
    if (![parser matchRule:@"Sequence"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"SLASH"]) return NO;
    if (![parser matchRule:@"Sequence"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedAlternate];     }];    return YES;    }];
    return YES;
};

static PEGParserRule __ExtraCode = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'ExtraCode'\n"))
    if (![parser matchString:"%%"]) return NO;
    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\377\377\377\377\337\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchString:"%%"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedExtraCode: text];     }];    return YES;
};

static PEGParserRule __Grammar = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Grammar'\n"))
    if (![parser matchRule:@"Spacing"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"Declaration"]) return NO;
    return YES;    }];
    if (![parser matchRule:@"Spacing"]) return NO;
    if (![parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"Definition"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchRule:@"EndOfFile"]) return NO;
    return YES;
};

static PEGParserRule __HorizSpace = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'HorizSpace'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:" "]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\t"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __IdentCont = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'IdentCont'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"IdentStart"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\377\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __IdentStart = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'IdentStart'\n"))
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\000\000\000\000\376\377\377\207\376\377\377\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;
};

static PEGParserRule __Identifier = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Identifier'\n"))
    [parser beginCapture];
    if (![parser matchRule:@"IdentStart"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"IdentCont"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __LEFTARROW = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'LEFTARROW'\n"))
    if (![parser matchString:"<-"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Literal = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Literal'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\200\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchClass:(unsigned char *)"\000\000\000\000\200\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchRule:@"Char"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\200\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    [parser beginCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchClass:(unsigned char *)"\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchRule:@"Char"]) return NO;
    return YES;    }];
    [parser endCapture];
    if (![parser matchClass:(unsigned char *)"\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __NOT = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'NOT'\n"))
    if (![parser matchString:"!"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __OPEN = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'OPEN'\n"))
    if (![parser matchString:"("]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __OPTION = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'OPTION'\n"))
    if (![parser matchString:"@option"]) return NO;
    if (![parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }]) return NO;
    return YES;
};

static PEGParserRule __PLUS = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'PLUS'\n"))
    if (![parser matchString:"+"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __PROPERTY = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'PROPERTY'\n"))
    if (![parser matchString:"@property"]) return NO;
    if (![parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }]) return NO;
    return YES;
};

static PEGParserRule __Prefix = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Prefix'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"AND"]) return NO;
    if (![parser matchRule:@"Suffix"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedLookAhead];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"NOT"]) return NO;
    if (![parser matchRule:@"Suffix"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedNegativeLookAhead];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"AND"]) return NO;
    if (![parser matchRule:@"Action"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedLookAhead:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"NOT"]) return NO;
    if (![parser matchRule:@"Action"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedNegativeLookAhead:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Suffix"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Effect"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __Primary = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Primary'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Identifier"]) return NO;
    if (![parser lookAhead:^(PEGParser *parser){
    if ([parser matchRule:@"LEFTARROW"]) return NO;
    return YES;    }]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedIdentifier:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"OPEN"]) return NO;
    if (![parser matchRule:@"Expression"]) return NO;
    if (![parser matchRule:@"CLOSE"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Literal"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedLiteral:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Class"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedClass:text];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"DOT"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedDot];     }];    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __PropIdentifier = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'PropIdentifier'\n"))
    [parser beginCapture];
    if (![parser matchRule:@"IdentStart"]) return NO;
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"IdentCont"]) return NO;
    return YES;    }];
    [parser endCapture];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }];
    return YES;
};

static PEGParserRule __PropParamaters = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'PropParamaters'\n"))
    [parser beginCapture];
    if (![parser matchString:"("]) return NO;
    if (![parser matchMany:^(PEGParser *parser){
    if (![parser matchClass:(unsigned char *)"\377\377\377\377\377\375\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"]) return NO;
    return YES;    }]) return NO;
    if (![parser matchString:")"]) return NO;
    [parser endCapture];
    if (![parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"HorizSpace"]) return NO;
    return YES;    }]) return NO;
    return YES;
};

static PEGParserRule __QUESTION = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'QUESTION'\n"))
    if (![parser matchString:"?"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Range = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Range'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Char"]) return NO;
    if (![parser matchString:"-"]) return NO;
    if (![parser matchRule:@"Char"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Char"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __SLASH = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'SLASH'\n"))
    if (![parser matchString:"/"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __STAR = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'STAR'\n"))
    if (![parser matchString:"*"]) return NO;
    if (![parser matchRule:@"Spacing"]) return NO;
    return YES;
};

static PEGParserRule __Sequence = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Sequence'\n"))
    [parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Prefix"]) return NO;
    return YES;    }];
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchRule:@"Prefix"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler append];     }];    return YES;    }];
    return YES;
};

static PEGParserRule __Space = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Space'\n"))
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:" "]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchString:"\t"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"EndOfLine"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;
};

static PEGParserRule __Spacing = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Spacing'\n"))
    [parser matchMany:^(PEGParser *parser){
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Space"]) return NO;
    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"Comment"]) return NO;
    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;    }];
    return YES;
};

static PEGParserRule __Suffix = ^(PEGParser *parser){
    yydebug((stderr, "Rule: 'Suffix'\n"))
    if (![parser matchRule:@"Primary"]) return NO;
    [parser matchOne:^(PEGParser *parser){
    if (![parser matchOne:^(PEGParser *parser){
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"QUESTION"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedQuestion];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"STAR"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedStar];     }];    return YES;    }]) return YES;
    if ([parser matchOne:^(PEGParser *parser){
    if (![parser matchRule:@"PLUS"]) return NO;
    [parser performAction:^(PEGParser *self, NSString *text){ [self.compiler parsedPlus];     }];    return YES;    }]) return YES;
    return NO;    }]) return NO;
    return YES;    }];
    return YES;
};



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
    
    BOOL matched = [self matchRule:@"Grammar"];
    
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
		
		        [self addRule:__AND withName:@"AND"];
        [self addRule:__Action withName:@"Action"];
        [self addRule:__BEGIN withName:@"BEGIN"];
        [self addRule:__CLOSE withName:@"CLOSE"];
        [self addRule:__Char withName:@"Char"];
        [self addRule:__Class withName:@"Class"];
        [self addRule:__Code withName:@"Code"];
        [self addRule:__Comment withName:@"Comment"];
        [self addRule:__DOT withName:@"DOT"];
        [self addRule:__Declaration withName:@"Declaration"];
        [self addRule:__Definition withName:@"Definition"];
        [self addRule:__END withName:@"END"];
        [self addRule:__Effect withName:@"Effect"];
        [self addRule:__EndOfDecl withName:@"EndOfDecl"];
        [self addRule:__EndOfFile withName:@"EndOfFile"];
        [self addRule:__EndOfLine withName:@"EndOfLine"];
        [self addRule:__Expression withName:@"Expression"];
        [self addRule:__ExtraCode withName:@"ExtraCode"];
        [self addRule:__Grammar withName:@"Grammar"];
        [self addRule:__HorizSpace withName:@"HorizSpace"];
        [self addRule:__IdentCont withName:@"IdentCont"];
        [self addRule:__IdentStart withName:@"IdentStart"];
        [self addRule:__Identifier withName:@"Identifier"];
        [self addRule:__LEFTARROW withName:@"LEFTARROW"];
        [self addRule:__Literal withName:@"Literal"];
        [self addRule:__NOT withName:@"NOT"];
        [self addRule:__OPEN withName:@"OPEN"];
        [self addRule:__OPTION withName:@"OPTION"];
        [self addRule:__PLUS withName:@"PLUS"];
        [self addRule:__PROPERTY withName:@"PROPERTY"];
        [self addRule:__Prefix withName:@"Prefix"];
        [self addRule:__Primary withName:@"Primary"];
        [self addRule:__PropIdentifier withName:@"PropIdentifier"];
        [self addRule:__PropParamaters withName:@"PropParamaters"];
        [self addRule:__QUESTION withName:@"QUESTION"];
        [self addRule:__Range withName:@"Range"];
        [self addRule:__SLASH withName:@"SLASH"];
        [self addRule:__STAR withName:@"STAR"];
        [self addRule:__Sequence withName:@"Sequence"];
        [self addRule:__Space withName:@"Space"];
        [self addRule:__Spacing withName:@"Spacing"];
        [self addRule:__Suffix withName:@"Suffix"];

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

- (void) addRule:(PEGParserRule)rule withName:(NSString *)name
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
