#!/bin/sh
set -x
set -e

CBITS=../web2hs-lib/cbits
INPUTS=inputs
OUTPUTS=outputs
CC=clang
GHC=ghc
RUNGHC=runghc

$RUNGHC TestParser.hs pascal/weave.p $OUTPUTS/weave_web.c
$CC -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
$CC -c -I$CBITS $OUTPUTS/weave_web.c -o $OUTPUTS/weave_web.o
$GHC --make $OUTPUTS/builtins.o $OUTPUTS/weave_web.o Weave.hs \
    -main-is Weave.main \
    -o $OUTPUTS/Weave -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Weave $INPUTS/primes.web $INPUTS/primes.ch $OUTPUTS/primes.tex
$OUTPUTS/Weave $INPUTS/tangle.web $INPUTS/tangle.ch $OUTPUTS/tangle.tex

echo  # since weave doesn't print a newline
