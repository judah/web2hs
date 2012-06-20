#include <stdio.h>
#include <stdbool.h>
#include <math.h>

void page_builtin();

extern const int true_0c;
extern const int false_1c;

#define ABS(x) ((x)>0 ? (x) : -(x))
#define TRUNC(x) ((x)>0 ? floor(x) : ceil(x))

// Test whether the file is at the end-of-file.
extern bool pascal_eof(FILE *f);

// Test whether the file is at end-of-line; i.e., next character
// is '\n' or '\r'.
extern bool pascal_eoln(FILE *f);

// Consume bytes until the next newline ('\r', '\n' or '\r\n').
extern void pascal_readln(FILE *f);

extern int pascal_peekc(FILE *f);

// move to position p of the file.
// If p is negative or larger than the current file size,
// move to the end of the file.
extern void pascal_setpos(FILE *f, int p);

extern int pascal_curpos(FILE *f);

extern void web2hs_find_cached(char *in, int inLen, char* out, int outLen);
