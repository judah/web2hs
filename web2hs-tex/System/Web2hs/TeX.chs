module System.Web2hs.TeX (
            texWithOptions,
            Options(..),
            tex,
            initex,
            ) where

import System.Web2hs.FileCache
import System.Web2hs.History
import Paths_web2hs_tex (getDataFileName)

import Foreign.C
import Foreign.Ptr
import Foreign.Marshal.Alloc
import Foreign.Storable

#include "tex.h"

{#fun TEX as c_tex
    { id `Ptr ()' } -> `History' fromCInt #}


data Options = Options
                { explicitFormatFile :: Maybe FilePath
                    -- ^ If this is @Just f@, then TeX will read its initial state
                    -- from the given format file.  The file may be specified
                    -- either as an absolute path or as a filename (e.g.,
                    -- \"plain.fmt\").
                    -- 
                    -- If this is @Nothing@, then TeX will run as INITEX
                    -- and explicitly initialize its state instead of
                    -- preloading a format file.
                , firstLine :: String
                    -- ^ The first line of input.  Maybe be \"foo\" or \"foo.tex\"
                    -- to process an input file.  If this is empty, TeX will read
                    -- the first line from the terminal.
                } deriving Show

texWithOptions :: FileCache -> Options -> IO History
texWithOptions userFC Options {..} = do
    poolPath <- getDataFileName "tex.pool"
    allocaBytes {#sizeof options#} $ \optionsP -> do
    withCString poolPath $ \cPoolPath -> do
    maybeWithCString explicitFormatFile $ \cFmt -> do
    withCString firstLine $ \cFirstLine -> do
    {#set options.pool_path#} optionsP cPoolPath
    {#set options.explicit_format#} optionsP cFmt
    {#set options.first_line#} optionsP
                            (castPtr cFirstLine :: Ptr CUChar)
    fmtFC <- getInstalledFormats
    let fc = fmtFC `orSearch` userFC
    withFileCache fc $ c_tex optionsP
    

maybeWithCString :: Maybe String -> (CString -> IO a) -> IO a
maybeWithCString Nothing = ($ nullPtr)
maybeWithCString (Just s) = withCString s

getInstalledFormats :: IO FileCache
getInstalledFormats = fmap (singleton "plain.fmt") $ getDataFileName "plain.fmt"


tex :: FileCache -> String -> IO History
tex fc firstLine = texWithOptions fc Options
                        { explicitFormatFile = Just "plain.fmt"
                        , firstLine = firstLine
                        }

initex :: FileCache -> String -> IO History
initex fc firstLine = texWithOptions fc Options
                        { explicitFormatFile = Nothing
                        , firstLine = firstLine
                        }
