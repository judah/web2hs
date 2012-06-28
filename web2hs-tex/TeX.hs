module Main where

import System.Web2hs.FileCache

import Foreign.C
import Foreign.Ptr (nullPtr)
import System.Environment

import Paths_web2hs_tex (getDataFileName)

foreign import ccall "TEX" c_tex :: CString -> IO ()

main = do
    userFC <- getUserFileCache
    poolFC <- fmap (singleton "tex.pool") $ getDataFileName "tex.pool"
    let fc = poolFC `orSearch` userFC
    -- Use the command-line arguments as the first line of TeX input.
    args <- fmap unwords getArgs
    withFileCache fc $ withCString args c_tex
