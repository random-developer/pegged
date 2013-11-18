//
//  ASTNode.m
//  pegged
//
//  Created by Friedrich Gräter.
//  This code is in the public domain.
//

#import "ASTNode.h"
#import "NSString+PrettyPrinting.h"

@implementation ASTNode

+ (id)astNodeWithValue:(NSInteger)value
{
	ASTNode *node = [ASTNode new];
	
	node.name = @"Value";
	node.value = value;
	
	return node;
}

+ (id)astNodeWithName:(NSString *)name operator:(NSString *)operator children:(NSArray *)children
{
	ASTNode *node = [ASTNode new];
	node.name = name;
	
	node.operator = operator;
	node.children = children;
	
	return node;
}

+ (id)astNodeWithName:(NSString *)name operator:(NSString *)operator left:(ASTNode *)left right:(ASTNode *)right
{
	return [self astNodeWithName:name operator:operator children:@[left, right]];
}

- (NSInteger)evaluate
{
	if (!self.operator)
		return self.value;
	
	if (!self.children.count)
		return 0;
	
	NSInteger currentValue = [(ASTNode *)self.children[0] evaluate];
	
	for (NSInteger index = 1; index < self.children.count; index ++) {
		if ([self.operator isEqual: @"+"])
			currentValue += [(ASTNode *)self.children[index] evaluate];
		if ([self.operator isEqual: @"-"])
			currentValue -= [(ASTNode *)self.children[index] evaluate];
		if ([self.operator isEqual: @"*"])
			currentValue *= [(ASTNode *)self.children[index] evaluate];
		if ([self.operator isEqual: @"/"])
			currentValue /= [(ASTNode *)self.children[index] evaluate];
	}
	
	return currentValue;
}

- (NSString *)description
{
	if (!self.operator)
		return [NSString stringWithFormat: @"%li", self.value];

	NSMutableArray *descriptions = [NSMutableArray new];
	
	for (ASTNode *node in self.children)
		[descriptions addObject: [[node description] stringByAddingIndentationWithCount: 1]];
	
	return [NSString stringWithFormat: @"%@ from %lu, %lu with %@:\n%@", self.name, self.parsingRange.location, self.parsingRange.length, self.operator, [descriptions componentsJoinedByString: @"\n"]];
}

- (void)setSourceString:(NSString *)string range:(NSRange)range
{
	_parsingRange = range;
}

@end
