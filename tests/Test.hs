-- Usage:
-- This program repeatedly prompts for input.
-- After every line of input, this program runs Tex on it.
-- For example, if you type "foo.tex", "foo" or "\input foo.tex"
-- then TeX will process the input file "foo.tex" and produce an output
-- file "foo.dvi".
module Main where

import Data.Time.Clock
import System.Web2hs.FileCache
import System.Web2hs.TeX

timed :: String -> IO a -> IO a
timed s act = do
    start <- getCurrentTime
    x <- act
    end <- getCurrentTime
    print $ s ++ ": " ++ show (diffUTCTime end start)
    return x

main = do
    fc <- timed "filecache" getUserFileCache
    let loop = do
            s <- getLine
            timed "tex" $ tex fc s
            loop
    loop
