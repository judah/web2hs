{-# OPTIONS_GHC -fno-cse #-}
module System.Web2hs.FileCache(
                FileCache,
                singleton,
                orSearch,
                LocatedFile(),
                locatedFilePath,
                readLSR,
                withFileCache,
                getUserFileCache,
                ) where

import qualified Data.HashMap.Strict as HashMap
import Data.HashMap.Strict (HashMap)
import Data.ByteString.Char8 as B hiding (singleton)
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
import System.FilePath ( (</>) )

-- Maps the name of a file to a (relative) path to the folder where it's located
type FileCache = HashMap ByteString LocatedFile

singleton :: String -> FilePath -> FileCache
singleton s t = HashMap.singleton (B.pack s) 
                    LocatedFile
                        { parentDir = B.empty
                        , locatedFolder = B.pack (dropFileName t)
                        , locatedFilename = B.pack (takeFileName t)
                        }

-- | Combine two caches.  If a file is in both f1 and f2, then
-- @f1 `orSearch` f2@ will contain the value in f1.
orSearch :: FileCache -> FileCache -> FileCache
orSearch = HashMap.union

-- We store the parts of the path separately (rather than concatenated)
-- so we don't need to copy parentDir and locatedFolder for each entry.
data LocatedFile = LocatedFile {
                    parentDir, locatedFolder, locatedFilename :: !ByteString
                    }

instance Show LocatedFile where
    show l = show (locatedFilePath l)

locatedFilePath :: LocatedFile -> FilePath
locatedFilePath l = unpack (parentDir l) 
                    </> unpack (locatedFolder l)
                    </> unpack (locatedFilename l)
                -- We're taking advantage of </> doing the right thing
                -- with empty strings.

readLSR :: FilePath -> IO FileCache
readLSR f = do
    contents <- L.readFile f
    evaluate $ HashMap.fromList $ parseLines (pack $ takeDirectory f)
        $ fmap (B.concat . L.toChunks)
        $ L.lines contents

parseLines :: ByteString -> [ByteString] -> [(ByteString,LocatedFile)]
parseLines parent = loop (B.pack ".") -- arbitrary default
  where
    loop _ [] = []
    loop d (b:bs)
        | B.null b = loop d bs
        | B.last b == ':' = loop (simplifyFoldername $ B.init b) bs
        | otherwise = let l = LocatedFile
                                { parentDir = parent
                                , locatedFolder = d
                                , locatedFilename = b
                                }
                      in (b,l) : loop d bs
    -- texlive puts a "./" at the front of each folder name;
    -- remove it since it's always superfluous.
    simplifyFoldername b
        | dotSlash `isPrefixOf` b = B.drop (B.length dotSlash) b
        | otherwise = b
    dotSlash = B.pack "./"

-- | Read the file caches from ~/.web2hs
getUserFileCache :: IO FileCache
getUserFileCache = do
    home <- getHomeDirectory
    lsrFiles<- fmap List.lines $ Prelude.readFile $ home </> ".web2hs"
    fcs <- mapM readLSR $ List.filter (not . List.null) lsrFiles
    evaluate $ HashMap.unions fcs


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
    :: Ptr CChar -> Ptr CChar -> CInt -> IO CInt

-- Takes in a string buffers (input and output)
-- input is a file name (null-terminated)
-- output is full path to the file (null-terminated)
-- input and output can be the same pointer.
-- Returns length of returned string (without the terminating null),
-- or zero if the the file could not be found.
web2hs_find_cached :: Ptr CChar -> Ptr CChar -> CInt -> IO CInt
web2hs_find_cached inP outP outLen = do
    file <- packCString inP
    fc <- readIORef globalFileCache
    case fmap locatedFilePath $ HashMap.lookup file fc of
        Nothing -> do
            poke outP 0
            return 0
        Just path -> do
            -- Be careful: the CString and String might have different lengths
            -- due to encoding.
            withCStringLen path $ \(p,len) -> do
            if len+1 > fromIntegral outLen -- enough to also store null terminator
                then do
                    Prelude.putStrLn $ "Length of path is too long: " ++ show path
                    poke outP 0
                    return 0
                else do
                    copyArray outP p len
                    poke (outP `plusPtr` len) (0::CChar) -- make outP null-terminated
                    return $ fromIntegral len
