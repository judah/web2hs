module Main where

import System.Web2hs.FileCache

import Paths_web2hs_tex (getDataFileName)

foreign import ccall "TEX" c_tex :: IO ()

main = do
    userFC <- getUserFileCache
    poolFC <- fmap (singleton "tex.pool") $ getDataFileName "tex.pool"
    let fc = poolFC `orSearch` userFC
    withFileCache fc $ c_tex
