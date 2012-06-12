{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Foreign.C
import Foreign.Ptr
import System.Environment

foreign import ccall "TANGLE" tangle
    :: CString -> CString -> CString -> CString -> IO ()

main = do
    [webFile,changeFile,pascalFile,poolFile] <- getArgs
    withCString webFile $ \cWebFile ->
    withCString changeFile $ \cChangeFile ->
    withCString pascalFile $ \cPascalFile ->
    withCString poolFile $ \cPoolFile ->
    pooltype cWebFile cChangeFile cPascalFile cPoolFile
