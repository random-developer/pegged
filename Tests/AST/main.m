//
//  main.m
//  pegged
//
//  Created by Matt Diephouse on 12/17/09.
//  This code is in the public domain.
//

#import "ASTNode.h"
#import "ASTParser.h"

BOOL checkError(NSString *equation)
{
	BOOL hadError = NO;
	
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	
	NSArray  *parts			= [equation componentsSeparatedByString:@"="];
	NSString *expression	= [parts objectAtIndex:0];
	
	NSArray *expectedError			= [[parts lastObject] componentsSeparatedByString: @","];
	if (expectedError.count != 3) {
		NSLog(@"Invalid input: %@", equation);
		return YES;
	}

	NSString *expectedErrorName		= [expectedError[0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	NSNumber *expectedErrorLocation	= [formatter numberFromString:expectedError[1]];
	NSNumber *expectedErrorLength	= [formatter numberFromString:expectedError[2]];
	
	ASTParser *parser     = [ASTParser new];
	ASTNode *node;
	
	BOOL matched = [parser parseString:expression result:&node];
	
	if (matched || ![parser.lastError.localizedDescription isEqual: expectedErrorName] || ![parser.lastError.userInfo[ASTParserErrorStringLocationKey] isEqual: expectedErrorLocation] || ![parser.lastError.userInfo[ASTParserErrorStringLengthKey] isEqual: expectedErrorLength]) {
		NSLog(@"Expected error: '%@' at (%@,%@). Got '%@' at (%@,%@).", expectedErrorName, expectedErrorLocation, expectedErrorLength, parser.lastError.localizedDescription, parser.lastError.userInfo[ASTParserErrorStringLocationKey], parser.lastError.userInfo[ASTParserErrorStringLengthKey]);
		hadError = YES;
	}

	return hadError;
}

BOOL checkValue(NSString *equation)
{
	BOOL hadError = NO;
	
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	
	NSArray  *parts			= [equation componentsSeparatedByString:@"="];
	NSString *expression	= [parts objectAtIndex:0];

	NSArray *resultDescription	= [[parts lastObject] componentsSeparatedByString: @","];
	if (resultDescription.count != 3) {
		NSLog(@"Invalid input: %@", equation);
		return YES;
	}
	
	NSNumber *result				= [formatter numberFromString:resultDescription[0]];
	NSNumber *parsingRangeLocation	= [formatter numberFromString:resultDescription[1]];
	NSNumber *parsingRangeLength	= [formatter numberFromString:resultDescription[2]];
		
	ASTParser *parser     = [ASTParser new];
	ASTNode *node;
	
	BOOL matched = [parser parseString:expression result:&node];
	
	if (!matched || (result.integerValue != node.evaluate) || (parsingRangeLocation.integerValue != node.parsingRange.location) || (parsingRangeLength.integerValue != node.parsingRange.length))
	{
		NSLog(@"-- %@ (%li,%li) should result in %li. Got %@ (%li,%li).\n", expression, parsingRangeLocation.integerValue, parsingRangeLength.integerValue, node.evaluate, result, node.parsingRange.location, node.parsingRange.length);
		hadError = YES;
	}

	return hadError;
}

int main (int argc, const char * argv[])
{
    if (argc < 2)
        return 1;
	
	if (argc > 3)
		return 1;
	
	BOOL matchErrors = (argc == 3) && !strcmp(argv[2], "-e");

    @autoreleasepool {
    
        NSError *error = nil;
        NSString *file     = [NSString stringWithUTF8String:argv[1]];
        NSString *contents = [[NSString alloc] initWithContentsOfFile: file
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
                
        BOOL hadError = NO;

        for (NSString *equation in [contents componentsSeparatedByString:@"\n"]) {
			if (![[equation stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length])
				continue;
				
            if (matchErrors)
				hadError |= checkError(equation);
			else
				hadError |= checkValue(equation);
        }
              
        
        return hadError;
    }
}
