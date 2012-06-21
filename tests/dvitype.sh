#!/bin/sh
set -x
set -e

INPUTS=inputs
OUTPUTS=outputs
GHC=ghc

web2hs-tangle web/dvitype.web web/dvitype.ch $OUTPUTS/dvitype.p $OUTPUTS/dvitype.pool
web2hs --dump-pascal=$OUTPUTS/dvitype-dump.p $OUTPUTS/dvitype.p $OUTPUTS/dvitype_web.c
$GHC -optc -g -debug -package web2hs-lib \
    $OUTPUTS/dvitype_web.c DVIType.hs \
    -main-is DVIType.main \
    -o $OUTPUTS/DVIType -odir $OUTPUTS -hidir $OUTPUTS

