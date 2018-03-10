//
//  Compiler.h
//  pegged
//
//  Created by Matt Diephouse on 12/18/09.
//  This code is in the public domain.
//
@class Rule;

@interface Compiler : NSObject
{
    NSMutableArray *_stack;
    NSMutableDictionary *_rules;
    Rule *_startRule;
    Rule *_currentRule;
    
	NSMutableArray *_imports;
    NSMutableArray *_interfaces;
	NSMutableArray *_classes;
	NSMutableArray *_protocols;
    NSMutableArray *_properties;
    NSString *_propertyParameters;
    NSString *_propertyStars;
    NSString *_propertyType;
    
    BOOL _caseInsensitive;
    BOOL _enablePrintf;
    
    NSString *_className;
    NSString *_headerPath;
    NSString *_sourcePath;
    NSString *_extraCode;
}

@property (assign) BOOL caseInsensitive;
@property (assign) BOOL enablePrintf;

@property (copy) NSString *className;
@property (copy) NSString *headerPath;
@property (copy) NSString *sourcePath;
@property (copy) NSString *extraCode;
@property (copy) NSString *initializationCode;
@property (copy) NSString *language;

+ (NSString *) unique:(NSString *)identifier;

- (void) compile;

- (void) append;
- (void) beginCapture;
- (void) endCapture;

- (void) parsedAction:(NSString *)code returnValue:(BOOL)returnValue;
- (void) parsedAlternate;
- (void) parsedClass:(NSString *)class;
- (void) parsedCode:(NSString *)code;
- (void) parsedDot;
- (void) parsedFail:(NSString *)fail;
- (void) parsedIdentifier:(NSString *)identifier capturing:(BOOL)capturing asserted:(BOOL)asserted;
- (void) parsedLiteral:(NSString *)literal asserted:(BOOL)asserted;
- (void) parsedLookAhead;
- (void) parsedLookAhead:(NSString *)code;
- (void) parsedNegativeLookAhead;
- (void) parsedNegativeLookAhead:(NSString *)code;
- (void) parsedPlus;
- (void) parsedPrintf:(NSString *)code;
- (void) parsedQuestion;
- (void) parsedRegex:(NSString *)regex;
- (void) parsedRule;
- (void) parsedStar;
- (void) startRule:(NSString *)name;

- (void) parsedImport:(NSString *)import;
- (void) parsedInterfaceBlock:(NSString *)code;

- (void) parsedClassPrototype:(NSString *)classIdentifier;
- (void) parsedProtocolPrototype:(NSString *)protocolIdentifier;

- (void) parsedPropertyParameters:(NSString *)parameters;
- (void) parsedPropertyStars:(NSString *)stars;
- (void) parsedPropertyType:(NSString *)type;
- (void) parsedPropertyName:(NSString *)name;
- (void) parsedExtraCode:(NSString*)code;

- (void) parsedInitBlock:(NSString *)code;
@end
