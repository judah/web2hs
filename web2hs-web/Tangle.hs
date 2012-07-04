module Main where

import System.Web2hs.History

import Foreign.C
import Foreign.Ptr
import System.Environment

foreign import ccall "TANGLE" tangle
    :: CString -> CString -> CString -> CString -> IO CInt

main = do
    [webFile,changeFile,pascalFile,poolFile] <- getArgs
    withCString webFile $ \cWebFile -> do
    withCString changeFile $ \cChangeFile -> do
    withCString pascalFile $ \cPascalFile -> do
    withCString poolFile $ \cPoolFile -> do
    history <- fmap fromCInt
                $ tangle cWebFile cChangeFile cPascalFile cPoolFile
    exitWithHistory history
