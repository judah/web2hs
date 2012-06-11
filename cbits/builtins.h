#include <stdio.h>
#include <stdbool.h>

void page_builtin();

extern const int true_0c;
extern const int false_1c;

// Test whether the file is at the end-of-file.
extern bool pascal_eof(FILE *f);

// Test whether the file is at end-of-line; i.e., next character
// is '\n' or '\r'.
extern bool pascal_eoln(FILE *f);

// Consume bytes until the next newline ('\r', '\n' or '\r\n').
extern void pascal_readln(FILE *f);
