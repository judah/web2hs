#!/bin/sh
set -x
set -e

CBITS=../cbits
INPUTS=inputs
OUTPUTS=outputs
CC=clang
GHC=ghc
RUNGHC=runghc

$RUNGHC TestParser.hs pascal/tangle.p $OUTPUTS/tangle_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/tangle_web.c -o $OUTPUTS/tangle_web.o
$GHC --make $OUTPUTS/builtins.o $OUTPUTS/tangle_web.o Tangle.hs \
    -main-is Tangle.main \
    -o $OUTPUTS/Tangle -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Tangle $INPUTS/primes.web $INPUTS/primes.ch $OUTPUTS/primes.p $OUTPUTS/primes.pool
$OUTPUTS/Tangle $INPUTS/tangle.web $INPUTS/tangle.ch $OUTPUTS/tangle.p $OUTPUTS/tangle.pool

