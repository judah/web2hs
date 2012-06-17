#!/bin/sh
set -x
set -e

CBITS=../web2hs-lib/cbits
OUTPUTS=outputs
CC=clang
GHC=ghc

web2hs pascal/primes.p $OUTPUTS/primes_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/primes_web.c -o $OUTPUTS/primes_web.o
$GHC --make $OUTPUTS/builtins.o $OUTPUTS/primes_web.o Primes.hs \
    -main-is Primes.main \
    -o $OUTPUTS/Primes -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Primes

