#!/bin/sh
set -x
set -e

CBITS=../cbits
OUTPUTS=outputs
CC=clang
GHC=ghc
RUNGHC=runghc

$RUNGHC TestParser.hs pascal/dvitype.p $OUTPUTS/dvitype_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/dvitype_web.c -o $OUTPUTS/dvitype_web.o
#$GHC -e main $OUTPUTS/builtins.o $OUTPUTS/primes_web.o Primes.hs \
#    -odir $OUTPUTS -hidir $OUTPUTS

