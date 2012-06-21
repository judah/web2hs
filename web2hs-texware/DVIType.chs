module Main where

import Foreign.C
import Foreign.Ptr
import Foreign.Marshal.Alloc
import Foreign.Storable
import System.Environment
import System.Console.CmdArgs

import System.Web2hs.FileCache

#include "dvitype.h"

{#fun DVI_type as dvi_type
    { `String'
    , id `Ptr ()'
    } -> `()' #}

-- TODO: page start spec
-- TODO: resolution written as exact fraction?
-- TODO: tell user when ignoring their input

data Options = Options
                { dviFile :: String
                , outMode :: Int
                , maxPages :: Int
                , resolution :: Float
                , newMag :: Int
                } deriving (Show,Typeable,Data)

getOptions = cmdArgs $ Options
                { dviFile = def &= argPos 0 &= typ "DVIFILE"
                , outMode = 4 &= explicit &= name "output-level"
                            &= help "verbosity (0-4; default=4)"
                , maxPages = 1000000 &= explicit &= name "max-pages"
                            &= help "maximum number of pages (default=1000000)"
                , resolution = 300 &= explicit &= name "resolution"
                            &= help "Assumed device resolution in ppi (default=300)"
                , newMag = 1000 &= explicit &= name "magnification"
                            &= help "New magnification (default=1000)"
                }
                &= program "dvitype"

                

main = do
    fc <- getUserFileCache
    Options {..} <- getOptions
    allocaBytes {#sizeof options#} $ \optionsP -> do
    {#set options.out_mode#} optionsP $ fromIntegral outMode
    {#set options.max_pages#} optionsP $ fromIntegral maxPages
    {#set options.resolution#} optionsP $ realToFrac resolution
    {#set options.new_mag#} optionsP $ fromIntegral newMag
    withFileCache fc $ dvi_type dviFile optionsP
