#!/bin/sh
set -x
set -e

OUTPUTS=outputs
GHC=ghc

web2hs pascal/pooltype.p $OUTPUTS/pooltype_web.c
$GHC --make -package web2hs-lib \
    $OUTPUTS/pooltype_web.c Pooltype.hs \
    -main-is Pooltype.main \
    -o $OUTPUTS/Pooltype -odir $OUTPUTS -hidir $OUTPUTS
$OUTPUTS/Pooltype inputs/tex.pool

