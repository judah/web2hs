{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Foreign.C
import Foreign.Ptr
import System.Environment

foreign import ccall "POOLtype" pooltype :: CString -> IO ()

main = do
    [file] <- getArgs
    withCString file pooltype 
