{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Foreign.C
import Foreign.Ptr
import System.Environment

foreign import ccall "POOLtype" pooltype :: CString -> IO ()

-- main = withCString "dummy" print_pri
main = do
    [file] <- getArgs
    withCString file pooltype 
