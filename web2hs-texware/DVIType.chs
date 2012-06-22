module Main where

import Foreign.C
import Foreign.Ptr
import Foreign.Marshal.Alloc
import Foreign.Storable
import System.Environment
import System.Console.CmdArgs
import Control.Monad (forM_)

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
                , startPage :: String
                , maxPages :: Int
                , resolution :: Float
                , newMag :: Int
                } deriving (Show,Typeable,Data)

getOptions = cmdArgs $ Options
                { dviFile = def &= argPos 0 &= typ "DVIFILE"
                , outMode = 4 &= explicit &= name "output-level"
                            &= help "verbosity (0-4; default=4)"
                , startPage = "*" &= explicit &= name "start-page"
                            &= help "start page spec (default='*')"
                , maxPages = 1000000 &= explicit &= name "max-pages"
                            &= help "maximum number of pages (default=1000000)"
                , resolution = 300 &= explicit &= name "resolution"
                            &= help "Assumed device resolution in ppi (default=300)"
                , newMag = 1000 &= explicit &= name "magnification"
                            &= help "New magnification (default=1000)"
                }
                &= program "dvitype"

startPageSpec :: String -> [Maybe Int]
startPageSpec "" = []
startPageSpec ('.':s) = startPageSpec s
startPageSpec ('*':s) = Nothing : startPageSpec s
startPageSpec s
    | [(n,"")] <- reads $ takeWhile isNum s
            = Just n : startPageSpec (dropWhile isNum s)
  where
    isNum '-' = True
    isNum d = d >= '0' && d <= '9'
startPageSpec _ = error $ unlines
                    [ "Couldn't parse starting page specification."
                    , "Type, e.g., 1.*.-5 to specify the"
                    , "first page with \\count0=1, \\count2=-5."
                    ]

-- NOTE: because of limitations in c2hs, the struct-setting code
-- is hard-coded rather than depending on dvitype.h.
setStartPage :: Ptr () -> [Maybe Int] -> IO ()
setStartPage p specs = do
    {#set options.start_vals#} p $ fromIntegral $ min 9 $ length specs - 1
    let fullSpecs = take 10 $ specs ++ repeat Nothing
    forM_ (zip [0..9] fullSpecs) setSpec
  where
    startThere, startCount :: Int -> Ptr CInt
    startThere k = p `plusPtr` ((1+k)*sizeOf (undefined :: CInt))
    startCount k = p `plusPtr` ((11+k)*sizeOf (undefined :: CInt))
    setSpec (k,Nothing) = 
        poke (startThere k) 0
    setSpec (k,Just c) = do
        poke (startThere k) 1
        poke (startCount k) (fromIntegral c)


main = do
    fc <- getUserFileCache
    Options {..} <- getOptions
    allocaBytes {#sizeof options#} $ \optionsP -> do
    {#set options.out_mode#} optionsP $ fromIntegral outMode
    setStartPage optionsP $ startPageSpec startPage
    {#set options.max_pages#} optionsP $ fromIntegral maxPages
    {#set options.resolution#} optionsP $ realToFrac resolution
    {#set options.new_mag#} optionsP $ fromIntegral newMag
    withFileCache fc $ dvi_type dviFile optionsP
