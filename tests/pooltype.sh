#!/bin/sh
set -x
set -e

CBITS=../cbits
OUTPUTS=outputs
CC=clang
GHC=ghc
RUNGHC=runghc

$RUNGHC TestParser.hs pascal/pooltype.p $OUTPUTS/pooltype_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/pooltype_web.c -o $OUTPUTS/pooltype_web.o
$GHC --make $OUTPUTS/builtins.o $OUTPUTS/pooltype_web.o Pooltype.hs \
    -main-is Pooltype.main \
    -o $OUTPUTS/Pooltype -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Pooltype inputs/tex.pool

