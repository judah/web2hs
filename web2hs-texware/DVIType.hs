{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Foreign.C
import Foreign.Ptr
import System.Environment

import System.Web2hs.FileCache

foreign import ccall "DVI_type" dvi_type
    :: CString -> IO ()

main = do
    [dviFile] <- getArgs
    fc <- readLSR "/usr/local/texlive/2011basic/texmf-dist/ls-R"
    withFileCache fc $ withCString dviFile dvi_type
