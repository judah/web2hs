{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Foreign.C
import Foreign.Ptr
import System.Environment

foreign import ccall "TANGLE" tangle
    :: CString -> CString -> CString -> CString -> IO ()

main = do
    [webFile,changeFile,pascalFile,poolFile] <- getArgs
    withCString webFile $ \cWebFile -> do
    withCString changeFile $ \cChangeFile -> do
    withCString pascalFile $ \cPascalFile -> do
    withCString poolFile $ \cPoolFile -> do
    tangle cWebFile cChangeFile cPascalFile cPoolFile
