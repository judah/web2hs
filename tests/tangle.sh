#!/bin/sh
set -x
set -e

CBITS=../cbits
INPUTS=inputs
OUTPUTS=outputs
CC=clang
GHC=ghc
RUNGHC=runghc

tangle -underline web/tangle.web web/tangle.ch
mv tangle.p $OUTPUTS/tangle.p
$RUNGHC TestParser.hs $OUTPUTS/tangle.p $OUTPUTS/tangle_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/tangle_web.c -o $OUTPUTS/tangle_web.o
$GHC --make $OUTPUTS/builtins.o $OUTPUTS/tangle_web.o Tangle.hs \
    -main-is Tangle.main \
    -o $OUTPUTS/Tangle -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Tangle $INPUTS/primes.web $INPUTS/primes.ch $OUTPUTS/primes-test.p $OUTPUTS/primes-test.pool
$OUTPUTS/Tangle web/tangle.web web/tangle.ch $OUTPUTS/tangle-test.p $OUTPUTS/tangle-test.pool

diff $OUTPUTS/tangle-test.p $OUTPUTS/tangle.p && echo "Outputs are same."
