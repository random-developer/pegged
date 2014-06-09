//
//  Compiler.m
//  pegged
//
//  Created by Matt Diephouse on 12/18/09.
//  This code is in the public domain.
//

#import "Compiler.h"

#import "Action.h"
#import "CClass.h"
#import "Code.h"
#import "Condition.h"
#import "Dot.h"
#import "Expression.h"
#import "Fail.h"
#import "Literal.h"
#import "LookAhead.h"
#import "Node.h"
#import "Quantifier.h"
#import "Property.h"
#import "Rule.h"
#import "Sequence.h"
#import "Subrule.h"
#import "Version.h"

#include <mach-o/getsect.h>

@implementation Compiler

#pragma mark - NSObject Methods

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _stack      = [NSMutableArray new];
        _rules      = [NSMutableDictionary new];
        _properties = [NSMutableArray new];
		_imports	= [NSMutableArray new];
		_classes	= [NSMutableArray new];
		_protocols  = [NSMutableArray new];
        _extraCode  = nil;
    }
    
    return self;
}


#pragma mark - Public Methods

+ (NSString *)unique:(NSString *)identifier
{
    static NSUInteger number = 0;
    return [NSString stringWithFormat:@"%@%lu", identifier, number++];
}

- (NSMutableString *)getTemplateWithName:(const char *)name
{
	size_t length;
	const void *data = getsectdata ("__DATA", name, &length);
	
	NSMutableString *template = [[NSMutableString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
	return template;
}

- (void)compile
{
    NSAssert(self.className != nil,  @"no class name given");
    NSAssert(self.headerPath != nil, @"no path for header file");
    NSAssert(self.sourcePath != nil, @"no path for source file");
    
    NSError *error = nil;
    
    NSMutableString *properties  = [NSMutableString new];
    NSMutableString *imports     = [NSMutableString new];
    NSMutableString *synthesizes = [NSMutableString new];
    NSMutableString *variables   = [NSMutableString new];
    for (Property *property in _properties)
    {
        [properties  appendString:[property property]];
        [synthesizes appendString:[property synthesize]];
        [variables   appendString:[property variable]];
    }

	[imports	 appendString:[_imports componentsJoinedByString: @"\n"]];
	
    // Generate the header
	NSMutableString *header = [self getTemplateWithName: "HDRTEMP"];

	[header replaceOccurrencesOfString:@"//!$" withString:@"$" options:0 range:NSMakeRange(0, header.length)];
	[header replaceOccurrencesOfString:@"ParserClass" withString:self.className options:0 range:NSMakeRange(0, header.length)];
	[header replaceOccurrencesOfString:@"$Version" withString:[NSString stringWithFormat: @"%lu.%lu.%lu", PEGGED_VERSION_MAJOR, PEGGED_VERSION_MINOR, PEGGED_VERSION_CHANGE] options:0 range:NSMakeRange(0, header.length)];

	if (_classes.count)
		[header replaceOccurrencesOfString:@"$OtherClasses" withString:[NSString stringWithFormat: @"@class %@;", [_classes componentsJoinedByString: @", "]] options:0 range:NSMakeRange(0, header.length)];
	else
		[header replaceOccurrencesOfString:@"$OtherClasses\n" withString:@"" options:0 range:NSMakeRange(0, header.length)];
		
	if (_protocols.count)
		[header replaceOccurrencesOfString:@"$OtherProtocols" withString:[NSString stringWithFormat: @"@protocol %@;", [_protocols componentsJoinedByString: @", "]] options:0 range:NSMakeRange(0, header.length)];
	else
		[header replaceOccurrencesOfString:@"$OtherProtocols\n" withString:@"" options:0 range:NSMakeRange(0, header.length)];
	
	[header replaceOccurrencesOfString:@"$Properties" withString:properties options:0 range:NSMakeRange(0, header.length)];
	
    [header writeToFile:self.headerPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    // Generate the source
    NSMutableString *declarations = [NSMutableString new];
    NSMutableString *definitions  = [NSMutableString new];
    if (self.caseInsensitive) {
        [imports appendString:@"\n#define __PEG_PARSER_CASE_INSENSITIVE__\n"];
    }
   
    if(self.extraCode) {
        [definitions appendFormat: @"\n\n\
#pragma mark Extra Code\n\
\n\
%@\n\
\n", self.extraCode];
    }
    
    for (NSString *name in [[_rules allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        Rule *rule = [_rules objectForKey:name];
        // Check if that the rule has been both used and defined
        if (rule.defined && !rule.used && rule != _startRule)
            fprintf(stderr, "rule '%s' defined but not used\n", [rule.name UTF8String]);
        if (rule.used && !rule.defined)
        {
            fprintf(stderr, "rule '%s' used but not defined\n", [rule.name UTF8String]);
            continue;
        }
        
        [declarations appendFormat:@"\t\t[self addRule:__%@ withName:@\"%@\"];\n", rule.name, rule.name];
        [definitions appendFormat:@"static %@Rule __%@ = ^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", self.className, rule.name, self.className];
        [definitions appendString:[[[rule compile:self.className] stringByAddingIndentationWithCount: 1] stringByRemovingTrailingWhitespace]];
        [definitions appendFormat:@"\n};\n\n"];
    }
    
	NSMutableString *source = [self getTemplateWithName: "SRCTEMP"];

	[source replaceOccurrencesOfString:@"//!$" withString:@"$" options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"Parser.h" withString:@"ParserClass.h" options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"ParserClass" withString:self.className options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"$Version" withString:[NSString stringWithFormat: @"%lu.%lu.%lu", PEGGED_VERSION_MAJOR, PEGGED_VERSION_MINOR, PEGGED_VERSION_CHANGE] options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"$Imports" withString:imports options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"$ParserDefinitions" withString:[definitions stringByRemovingTrailingWhitespace] options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"$StartRule" withString:_startRule.name options:0 range:NSMakeRange(0, source.length)];
	[source replaceOccurrencesOfString:@"$ParserDeclarations" withString:[declarations stringByRemovingTrailingWhitespace] options:0 range:NSMakeRange(0, source.length) ];
	
    [source writeToFile:self.sourcePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
}


#pragma mark - Parser Actions

- (void)append
{
    Node *second = [_stack lastObject];
    [_stack removeLastObject];
    Node *first = [_stack lastObject];
    [_stack removeLastObject];
    
    Sequence *sequence = nil;
    if ([first isKindOfClass:[Sequence class]])
        sequence = (Sequence *)first;
    else
    {
        sequence = [Sequence node];
        [sequence append:first];
    }
    [sequence append:second];
    [_stack addObject:sequence];
}


- (void)beginCapture
{
    [_stack addObject:[Code codeWithString:@"[parser beginCapture]"]];
}


- (void)endCapture
{
    [_stack addObject:[Code codeWithString:@"[parser endCapture]"]];
}


- (void)parsedAction:(NSString *)code returnValue:(BOOL)returnValue
{
    [_stack addObject:[Action actionWithCode:code returnValue:returnValue]];
}

- (void)parsedFail:(NSString *)string
{
	[_stack addObject:[Fail failWithMessage: string]];
}

- (void)parsedAlternate
{
    Node *second = [_stack lastObject];
    [_stack removeLastObject];
    Node *first = [_stack lastObject];
    [_stack removeLastObject];
    
    Expression *expression = nil;
    if ([first isKindOfClass:[Expression class]])
        expression = (Expression *)first;
    else
    {
        expression = [Expression node];
        [expression addAlternative:first];
    }
    [expression addAlternative:second];
    [_stack addObject:expression];
}


- (void)parsedClass:(NSString *)class
{
    CClass *cclass = [CClass cclassFromString:class];
    cclass.caseInsensitive = self.caseInsensitive;
    [_stack addObject:cclass];
}


- (void)parsedCode:(NSString *)code
{
    [_stack addObject:[Code codeWithString:code]];
}


- (void)parsedDot
{
    [_stack addObject:[Dot node]];
}


- (void)parsedIdentifier:(NSString *)identifier capturing:(BOOL)capturing asserted:(BOOL)asserted
{
    Rule *rule = [_rules objectForKey:identifier];
    if (!rule)
    {
        rule = [Rule ruleWithName:identifier];
        [_rules setObject:rule forKey:identifier];
    }
    
    [_stack addObject:[Subrule subruleWithRule:rule capturing:capturing asserted:asserted]];
    rule.used = YES;
}


- (void)parsedLiteral:(NSString *)literal asserted:(BOOL)asserted
{
    Literal *node = [Literal literalWithString:literal asserted:asserted];
    node.caseInsensitive = self.caseInsensitive;
    [_stack addObject:node];
}


- (void)parsedLookAhead
{
    Node *node = [_stack lastObject];
    LookAhead *lookAhead = [LookAhead lookAheadWithNode:node];
    [_stack removeLastObject];
    
    [_stack addObject:lookAhead];
}


- (void)parsedLookAhead:(NSString *)code
{
    Condition *condition = [Condition conditionWithExpression:code];
    [_stack addObject:condition];
}


- (void)parsedNegativeLookAhead
{
    Node *node = [_stack lastObject];
    LookAhead *lookAhead = [LookAhead lookAheadWithNode:node];
    [_stack removeLastObject];
    
    [node invert];
    [_stack addObject:lookAhead];
}


- (void)parsedNegativeLookAhead:(NSString *)code
{
    Condition *condition = [Condition conditionWithExpression:code];
    [condition invert];
    [_stack addObject:condition];
}


- (void)parsedPlus
{
    Node *node = [_stack lastObject];
    Quantifier *quantifier = [Quantifier quantifierWithNode:node];
    [_stack removeLastObject];
    
    quantifier.optional = NO;
    quantifier.repeats  = YES;
    [_stack addObject:quantifier];
}


- (void)parsedQuestion
{
    Node *node = [_stack lastObject];
    Quantifier *quantifier = [Quantifier quantifierWithNode:node];
    [_stack removeLastObject];
    
    quantifier.optional = YES;
    quantifier.repeats  = NO;
    [_stack addObject:quantifier];
}


- (void)parsedRule
{
    Node *definition = [_stack lastObject];
    [_stack removeLastObject];
    Rule *rule = [_stack lastObject];
    [_stack removeLastObject];
    
    if (rule.defined)
        fprintf(stderr, "rule '%s' redefined\n", [rule.name UTF8String]);
    
    rule.definition = definition;
}


- (void)parsedStar
{
    Node *node = [_stack lastObject];
    Quantifier *quantifier = [Quantifier quantifierWithNode:node];
    [_stack removeLastObject];
    
    quantifier.optional = YES;
    quantifier.repeats  = YES;
    [_stack addObject:quantifier];
}


- (void)startRule:(NSString *)name
{
    Rule *rule = [_rules objectForKey:name];
    if (!rule)
    {
        rule = [Rule ruleWithName:name];
        [_rules setObject:rule forKey:name];
    }
    
    [_stack addObject:rule];
    if (!_startRule)
        _startRule = rule;
    _currentRule = rule;
}


- (void)parsedImport:(NSString *)import
{
	[_imports addObject: [NSString stringWithFormat:@"#import %@", import]];
}

- (void)parsedClassPrototype:(NSString *)classIdentifier
{
	[_classes addObject: classIdentifier];
}

- (void)parsedProtocolPrototype:(NSString *)protocolIdentifier
{
	[_protocols addObject: protocolIdentifier];
}

- (void)parsedPropertyParameters:(NSString *)parameters
{
    _propertyParameters = [parameters copy];
}


- (void)parsedPropertyStars:(NSString *)stars
{
    _propertyStars = [stars copy];
}


- (void)parsedPropertyType:(NSString *)type
{
    _propertyType = [type copy];
}


- (void)parsedPropertyName:(NSString *)name
{
    Property *property = [Property new];
    property.name = name;
    property.parameters = _propertyParameters;
    property.stars = _propertyStars;
    property.type = _propertyType;
    [_properties addObject:property];
}

- (void)parsedExtraCode:(NSString*)code {
    self.extraCode = code;
}

@end
