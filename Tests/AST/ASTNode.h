//
//  ASTNode.h
//  pegged
//
//  Created by Friedrich Gräter.
//  This code is in the public domain.
//

@interface ASTNode : NSObject

+ (id)astNodeWithValue:(NSInteger)value;
+ (id)astNodeWithName:(NSString *)name operator:(NSString *)operator children:(NSArray *)children;
+ (id)astNodeWithName:(NSString *)name operator:(NSString *)operator left:(ASTNode *)left right:(ASTNode *)right;

@property NSString *name, *operator;
@property NSArray *children;

@property NSInteger value;

- (NSInteger)evaluate;
- (NSString *)description;

@property NSRange parsingRange;

@end
