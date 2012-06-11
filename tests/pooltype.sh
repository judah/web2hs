#!/bin/sh
set -x
set -e

CBITS=../cbits
OUTPUTS=outputs

runghc TestParser.hs pascal/pooltype.p $OUTPUTS/pooltype_web.c
gcc -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
gcc -c -I$CBITS $OUTPUTS/pooltype_web.c -o $OUTPUTS/pooltype_web.o
ghc --make $OUTPUTS/builtins.o $OUTPUTS/pooltype_web.o Pooltype.hs \
    -o $OUTPUTS/Pooltype -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Pooltype inputs/tex.pool

