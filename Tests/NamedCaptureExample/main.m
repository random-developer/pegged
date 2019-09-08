//
//  main.m
//  NamedCaptures
//

#import <Foundation/Foundation.h>
#import "NamedCaptureParser.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NamedCaptureParser *parser = [NamedCaptureParser new];
        NSString *expression = @"string identifier REGEX_regex Z group";
        BOOL retval = [parser parseString:expression result:NULL];
        if (!retval) {
            printf("error parsing input.\n");
            return -1;
        }

        /* verify fields are correct */
        NSDictionary <NSString *, NSString *> *f = parser.allFields;
        if (f.allKeys.count != 6) {
            printf("Expected 6 keys, found %lu\n", f.allKeys.count);
            return -1;
        }

        [f enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            if (![field hasPrefix:@"*"]) {
                if (![field isEqualToString:value]) {
                    printf("Error: field '%s' = '%s'\n", field.UTF8String, value.UTF8String);
                    exit(-1);
                }
            }
        }];
    }
    return 0;
}
