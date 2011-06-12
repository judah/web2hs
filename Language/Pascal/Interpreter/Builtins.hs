-- Built-in Pascal functions.
module Language.Pascal.Interpreter.Builtins where

import Language.Pascal.Interpreter.Base

import System.IO hiding (readIO)
import Prelude hiding (readIO)
import Control.Monad (when)
import Control.Monad.IO.Class

eof :: MonadIO m => File a -> m Bool
eof (File h) = liftIO $ hIsEOF h

reset :: MonadIO m => File a -> m ()
reset (File h) = liftIO $ hSeek h AbsoluteSeek 0

close :: MonadIO m => File a -> m ()
close (File h) = liftIO $ hClose h

class FileType a where
    openIO :: FilePath -> IOMode -> IO (File a)
    peekIO :: File a -> IO a
    readIO :: File a -> IO a

open :: (FileType a, MonadIO m) => FilePath -> IOMode -> m (File a)
open path = liftIO . open path

peekM :: (MonadIO m, FileType a) => File a -> m a
peekM = liftIO . peekIO

readM :: (MonadIO m, FileType a) => File a -> m a
readM = liftIO . readIO

get :: (MonadIO m, FileType a) => File a -> m ()
get f = readM f >> return ()

-- For now, both types will be 8-bit, since that's what TeX does.

instance FileType Char where
    openIO path mode = fmap File $ openBinaryFile path mode
    peekIO (File h) = hLookAhead h
    readIO (File h) = hGetChar h

instance FileType Int where
    openIO path mode = fmap File $ openBinaryFile path mode
    peekIO (File h) = fmap fromEnum $ hLookAhead h
    readIO (File h) = fmap fromEnum $ hGetChar h



-- TODO: write

-- For writing:
padd :: Show a => a -> Int -> String
padd x n = let s = show x
           in replicate (n - length s) ' ' ++ s

-- paddPrec :: Double -> Int -> Int -> String

-- skip to past the next newline, or the eof.
readlnIO :: File Char -> IO ()
readlnIO (File h) = loop
  where
    loop = do
        eof <- hIsEOF h
        when (not eof) $ do
        c <- hGetChar h
        when (c/='\n') $ loop
    
