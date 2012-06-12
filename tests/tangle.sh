#!/bin/sh
set -x
set -e

CBITS=../cbits
OUTPUTS=outputs

runghc TestParser.hs pascal/tangle.p $OUTPUTS/tangle_web.c
clang -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
clang -c -I$CBITS $OUTPUTS/tangle_web.c -o $OUTPUTS/tangle_web.o
ghc --make $OUTPUTS/builtins.o $OUTPUTS/tangle_web.o Pooltype.hs \
    -o $OUTPUTS/Tangle -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Tangle inputs/tex.pool

