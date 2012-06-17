#!/bin/sh
set -x
set -e

OUTPUTS=outputs
GHC=ghc

web2hs pascal/primes.p $OUTPUTS/primes_web.c
$GHC --make -package web2hs-lib \
    $OUTPUTS/primes_web.c Primes.hs \
    -main-is Primes.main \
    -o $OUTPUTS/Primes -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Primes

