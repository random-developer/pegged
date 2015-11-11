//
//  Property.h
//  pegged
//
//  Created by Matt Diephouse on 1/10/10.
//  This code is in the public domain.
//

@interface Property : NSObject

@property (copy) NSString *name;
@property (copy) NSString *parameters;
@property (copy) NSString *stars;
@property (copy) NSString *type;

- (NSString *) declaration;
- (NSString *) import;
- (NSString *) property;
- (NSString *) synthesize;
- (NSString *) variable;

@end
