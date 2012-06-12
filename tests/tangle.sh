#!/bin/sh
set -x
set -e

CBITS=../cbits
OUTPUTS=outputs
CC=clang
GHC=ghc
RUNGHC=runghc

$RUNGHC TestParser.hs pascal/tangle.p $OUTPUTS/tangle_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/tangle_web.c -o $OUTPUTS/tangle_web.o
#$GHC --make $OUTPUTS/builtins.o $OUTPUTS/tangle_web.o Tangle.hs \
#    -main-is Tangle.hs \
#    -o $OUTPUTS/Tangle -odir $OUTPUTS -hidir $OUTPUTS
#$OUTPUTS/Tangle inputs/tex.pool

