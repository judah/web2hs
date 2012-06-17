#!/bin/sh
set -x
set -e

INPUTS=inputs
OUTPUTS=outputs
GHC=ghc

web2hs pascal/weave.p $OUTPUTS/weave_web.c
$GHC --make -package web2hs-lib \
    $OUTPUTS/weave_web.c Weave.hs \
    -main-is Weave.main \
    -o $OUTPUTS/Weave -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Weave $INPUTS/primes.web $INPUTS/primes.ch $OUTPUTS/primes.tex
$OUTPUTS/Weave $INPUTS/tangle.web $INPUTS/tangle.ch $OUTPUTS/tangle.tex

echo  # since weave doesn't print a newline
