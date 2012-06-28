module System.Web2hs.TeX (tex) where

import System.Web2hs.FileCache
import Paths_web2hs_tex (getDataFileName)

import Foreign.C

foreign import ccall "TEX" c_tex :: CString -> CString -> IO ()

tex :: FileCache -> String -> IO ()
tex fc firstLine = do
    poolPath <- getDataFileName "tex.pool"
    withFileCache fc $ do
    withCString poolPath $ \cPoolPath -> do
    withCString firstLine $ \cFirstLine -> c_tex cPoolPath cFirstLine
