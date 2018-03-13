
# Custom Additions

In addition to the standard PEG components, several items have been added to
make these parsers more useful.

## Properties

Objective-C 2.0 properties may be added to the parser from inside the grammar.
Doing so makes the properties accessible from parser actions. This is useful
when trying to capture the information.

The syntax matches the normal Objective-C 2.0 syntax:

    @property (retain) Compiler *compiler;

Along with the `@property`, a header is imported into the parser .m file for
classes outside the NS* prefix.

Properties must be declared before any rules.

## Initialization

Code may be added to the parser's init: method from inside the grammer. This is useful to,
for example, initialize properties that have been declared. There may be zero or one initialization
blocks defined; if additional blocks are defined they will replace any prior definitions.

Example:

    @init
    printf("Hello, init\n");
    @end


## Interfaces

Method definitions may be added to the parser's `@interface` from inside the grammar. This is
similar to the `@property` directive but it's a free-form block of code intended to provide method
definitions to external clients.

Example:

    @interface
    @property id helper; /* or use the @property directive */
    - (instancetype) initWithHelper:(id)helper;
    @end

This example should of course be backed up with a matching method.

## Category

Sometimes there's a use to declare a category on external classes (or otherwise place some
declarations inside the parser source file, but outside of any existing code scopes within that
file). This can be accomplished through th `@category` `...` `@end` sequence. Multiple
category blocks may be declared within the grammar; they will be concatenated.

## Implementation

Parser implementation code may be added to the parser class by enclosing it between the
`@implementation` and `@end` directives. This is useful to make additional methods available to the
parser, either for use by grammar actions or to be called by external callers (in conjunction
with exposure to the methods through `@interface`  `...` `@end`).

Objective-C requires an `@implementation` directive to have a name and optional modifiers.
The directive supported here will ignore the rest of the line following the directive.

Note that a reading of pegged's grammar will reveal an `ExtraCode` rule, allowing one to
define code to appear in the implementation as well. This is being retained for legacy purposes
but should generally not be used; that grammar is limited in that it aborts upon seeing a
single percent sign, which makes it impossible to, for example, put a `printf()` function with
formatted data in the code. Internally, `@implementation` and `ExtraCode` share the same
support, so there may only be one of these present.

Example:

    @implementation
    - (instancetype) initWithHelper:(id)helper {
        self = [self init];
        if (self)
            self.helper = helper;
        return self;
    }
    @end

## Options

Currently, only one option is supported: case-insensitive. This makes all
string and character comparisons case-insensitive.

    @option case-insensitive;

## Actions

Enclosed in curly braces, actions are executed only after the input is parsed
successfully. They are put in their own block, and have access to both the
parser itself (which provides access to the user-defined properties)  the
text of the most recent capture, and the range of that text within the total content being parsed.

    Grammar <- < .+ !. > { NSLog(@"the entire file: %@", text); }

## Code

Code can also be added directly to the compiled rules. This code will be
executed immediately, any time it is reached.

    Rule <- A {{ NSLog(@"about to trying parsing B"); }} B

## Code Tests

C statements can also be evaluated for truth, just like any other rule.

    Rule <- A !{ 0 /* this rule will never match */ } B
          / C &{ 1 /* this rule will always match */ } D

## Regular Expressions

Regular expressions may be used as terminals, and their captures may be made available
to actions (currently only supported for Objective-C parser generation). Regular expressions
used as terminals must be enclosed within balanced `=` and any embedded `=` must be
escaped with a backslash. Since regular expressions will typically be used for their ability
to capture elements within the expression, they will most often appear within `<` and `>`,
making `<=ab+=>` the expression to use to match a single `a` followed by 1 or more `b`s.

For example, the following rule:

    Rule <- <=a(b+)=> { NSLog(@"Captures: %@", capture); }

with `abbb` as input will produce the following output:

    2018-03-10 11:32:41.995 pegged[73027:11961383] Captures: (
        abbb,
        bbb
    )

Notice that there will always be a `capture[0]` which matches the entire captured text.

