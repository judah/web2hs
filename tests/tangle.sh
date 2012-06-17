#!/bin/sh
set -x
set -e

INPUTS=inputs
OUTPUTS=outputs
GHC=ghc

tangle -underline web/tangle.web web/tangle.ch
mv tangle.p $OUTPUTS/tangle.p
web2hs $OUTPUTS/tangle.p $OUTPUTS/tangle_web.c
$GHC --make -package web2hs-lib \
    $OUTPUTS/tangle_web.c Tangle.hs \
    -main-is Tangle.main \
    -o $OUTPUTS/Tangle -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Tangle $INPUTS/primes.web $INPUTS/primes.ch $OUTPUTS/primes-test.p $OUTPUTS/primes-test.pool
$OUTPUTS/Tangle web/tangle.web web/tangle.ch $OUTPUTS/tangle-test.p $OUTPUTS/tangle-test.pool

diff $OUTPUTS/tangle-test.p $OUTPUTS/tangle.p && echo "Outputs are same."
