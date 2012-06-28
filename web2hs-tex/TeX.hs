module Main where

import System.Web2hs.FileCache
import System.Web2hs.TeX

import System.Environment

main = do
    userFC <- getUserFileCache
    args <- fmap unwords getArgs
    tex userFC args
