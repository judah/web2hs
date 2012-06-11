#!/bin/sh
set -x
set -e

CBITS=../cbits
OUTPUTS=outputs

runghc TestParser.hs pascal/dvitype.p $OUTPUTS/dvitype_web.c
gcc -c -I$CBITS $CBITS/builtins.c -o $OUTPUTS/builtins.o
gcc -c -I$CBITS $OUTPUTS/dvitype_web.c -o $OUTPUTS/dvitype_web.o
#ghc -e main $OUTPUTS/builtins.o $OUTPUTS/primes_web.o Primes.hs \
#    -odir $OUTPUTS -hidir $OUTPUTS

