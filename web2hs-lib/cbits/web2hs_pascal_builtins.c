#include "web2hs_pascal_builtins.h"

void page_builtin() {
    // do nothing, for now
}

const int true_0c = 1;
const int false_1c = 0;



// Test whether the file is at the end-of-file.
bool pascal_eof(FILE *f) {
    if (f==NULL) return true; // file open failed

    // TODO: Register?
    int c;

    // feof only works if we've gotten an error at the last read.
    if (feof(f)) return true;

    if ((c = getc(f))==EOF) {
        return true;
    } else {
        ungetc(c,f);
        return false;
    }
}

// Test whether the file is at end-of-line; i.e., next character
// is '\n' or '\r'.
bool pascal_eoln(FILE *f) {
    int c;

    if (f==NULL) return true; // file open failed
    if (feof(f)) return true;
    c = getc(f);

    if (c != EOF)
        ungetc(c,f);

    return (c=='\n' || c == '\r' || c == EOF);
}

// Consume bytes until the next newline ('\r', '\n' or '\r\n').
void pascal_readln(FILE *f) {
    int c;
    while ((c= getc(f)) != '\n' && c != '\r' && c != EOF)  ;
    if (c=='\r' && (c = getc(f)) != '\n' && c != EOF)
        ungetc(c,f);
}

int pascal_peekc(FILE *f) {
    int c = getc(f);
    ungetc(c,f);
    return c;
}


// TODO: more efficient...
extern void pascal_write32(FILE *f, int32_t e) {
    write(fileno(f),&e,4);
}

void pascal_setpos(FILE *f, int p) {
   if (p<0) {
       fseek(f,0,SEEK_END);
   } else {
       fseek(f,p,SEEK_SET);
   }
}

int pascal_curpos(FILE *f) {
    return ftell(f);
}
