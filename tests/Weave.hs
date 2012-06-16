{-# LANGUAGE ForeignFunctionInterface #-}
module Weave where

import Foreign.C
import Foreign.Ptr
import System.Environment

foreign import ccall "WEAVE" weave
    :: CString -> CString -> CString -> IO ()

main = do
    [webFile,changeFile,texFile] <- getArgs
    withCString webFile $ \cWebFile -> do
    withCString changeFile $ \cChangeFile -> do
    withCString texFile $ \cTexFile -> do
    weave cWebFile cChangeFile cTexFile
