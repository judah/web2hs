module Main where

import System.Web2hs.FileCache

foreign import ccall "TEX" c_tex :: IO ()

main = do
    fc <- getUserFileCache
    withFileCache fc $ c_tex
