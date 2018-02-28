
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

    @init { printf("Hello, init\n"); }


## Options

Currently, only one option is supported: case-insensitive. This makes all
string and character comparisons case-insensitive.

    @option case-insensitive;

## Actions

Enclosed in curly braces, actions are executed only after the input is parsed
successfully. They are put in their own block, and have access to both the
parser itself (which provides access to the user-defined properties) and the
text of the most recent capture.

    Grammar <- < .+ !. > { NSLog(@"the entire file: %@", text); }

## Code

Code can also be added directly to the compiled rules. This code will be
executed immediately, any time it is reached.

    Rule <- A {{ NSLog(@"about to trying parsing B"); }} B

## Code Tests

C statements can also be evaluated for truth, just like any other rule.

    Rule <- A !{ 0 /* this rule will never match */ } B
          / C &{ 1 /* this rule will always match */ } D

