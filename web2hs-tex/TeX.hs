module Main where

import System.Web2hs.FileCache

import Foreign.C
import Foreign.Ptr (nullPtr)
import System.Environment

import Paths_web2hs_tex (getDataFileName)

foreign import ccall "TEX" c_tex :: CString -> CString -> IO ()

main = do
    userFC <- getUserFileCache
    poolPath <- getDataFileName "tex.pool"
    -- Use the command-line arguments as the first line of TeX input.
    args <- fmap unwords getArgs
    withFileCache userFC $ do
    withCString poolPath $ \cPoolPath -> do
    withCString args $ \cArgs -> c_tex cPoolPath cArgs
