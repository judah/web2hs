{-# OPTIONS_GHC -fno-cse #-}
module System.Web2hs.FileCache(
                FileCache,
                LocatedFile(),
                locatedFilePath,
                readLSR,
                withFileCache,
                getUserFileCache,
                ) where

import Data.HashMap.Strict as HashMap
import Data.ByteString.Char8 as B
import qualified Data.ByteString.Lazy.Char8 as L
import qualified Data.List as List
import Control.Exception (bracket,evaluate)
import System.FilePath
import Data.IORef
import System.IO.Unsafe
import Foreign.C
import Foreign.Ptr
import Foreign.Storable
import Foreign.Marshal.Array (copyArray)
import System.Directory (getHomeDirectory)

-- Maps the name of a file to a (relative) path to the folder where it's located
type FileCache = HashMap ByteString LocatedFile

-- We store the parts of the path separately (rather than concatenated)
-- so we don't need to copy parentDir and locatedFolder for each entry.
data LocatedFile = LocatedFile {
                    parentDir, locatedFolder, locatedBasename :: !ByteString
                    }

instance Show LocatedFile where
    show l = show (locatedFilePath l)

locatedFilePath :: LocatedFile -> FilePath
locatedFilePath l = unpack (parentDir l) 
                    ++ "/" ++ unpack (locatedFolder l)
                    ++ "/" ++ unpack (locatedBasename l)

readLSR :: FilePath -> IO FileCache
readLSR f = do
    contents <- L.readFile f
    evaluate $ fromList $ parseLines (pack $ takeDirectory f)
        $ fmap (B.concat . L.toChunks)
        $ L.lines contents

parseLines :: ByteString -> [ByteString] -> [(ByteString,LocatedFile)]
parseLines parent = loop (B.pack ".") -- arbitrary default
  where
    loop _ [] = []
    loop d (b:bs)
        | B.null b = loop d bs
        | B.last b == ':' = loop (B.init b) bs
        | otherwise = let l = LocatedFile
                                { parentDir = parent
                                , locatedFolder = d
                                , locatedBasename = b
                                }
                      in (b,l) : loop d bs

-- | Read the file caches from ~/.web2hs
getUserFileCache :: IO FileCache
getUserFileCache = do
    home <- getHomeDirectory
    lsrFiles<- fmap List.lines $ Prelude.readFile $ home </> ".web2hs"
    fcs <- mapM readLSR $ List.filter (not . List.null) lsrFiles
    evaluate $ unions fcs


------------------------
-- Plan:
{-
Global variable?


-}

-- For now, using a global C pointer.

-- foreign import "& globalFileCache" c_globalFileCache :: Ptr (StablePtr FileCache)

globalFileCache :: IORef FileCache
globalFileCache = unsafePerformIO $ newIORef HashMap.empty
{-# NOINLINE globalFileCache #-}


withFileCache :: FileCache -> IO a -> IO a
withFileCache fc = bracket start end . const
  where
    start = do
        old <- readIORef globalFileCache
        writeIORef globalFileCache fc
        return old
    end = writeIORef globalFileCache

foreign export ccall web2hs_find_cached
    :: Ptr CChar -> CInt -> Ptr CChar -> CInt -> IO ()

-- Takes in a string buffers (input and output)
-- input is a file name (null-terminated)
-- output is full path to the file (null-terminated)
-- input and output can be the same pointer.
web2hs_find_cached :: Ptr CChar -> CInt -> Ptr CChar -> CInt -> IO ()
web2hs_find_cached inP inLen outP outLen = do
    file <- packCString inP
    Prelude.putStrLn $ "Finding file " ++ show file
    fc <- readIORef globalFileCache
    case fmap locatedFilePath $ HashMap.lookup file fc of
        Nothing -> do
            Prelude.putStrLn $ "File " ++ show file ++ " not found"
            poke outP 0
        Just path
            | len > fromIntegral outLen -> do
                Prelude.putStrLn $ "Length of path is too long: " ++ show path
                poke outP 0
            | otherwise -> do
                Prelude.putStrLn $ "found: " ++ show path
                -- TODO: more efficient
                withCString path $ \p -> do
                copyArray outP p len
          where
            len = Prelude.length path + 1


