{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Foreign.C
import Foreign.Ptr

foreign import ccall print_primes :: CString -> IO ()

-- main = withCString "dummy" print_pri
main = print_primes nullPtr
