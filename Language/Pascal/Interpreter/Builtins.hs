-- Built-in Pascal functions.
module Language.Pascal.Interpreter.Builtins where

import Language.Pascal.Interpreter.Base

import System.IO hiding (readIO)
import Prelude hiding (readIO)
import Control.Monad (when)

openCharFile :: FilePath -> IOMode -> IO (File Char)
openCharFile path mode = fmap File $ openFile path mode

-- NOTE: This only works for 8-bit sizes.
openByteFile :: FilePath -> IOMode -> IO (File Int)
openByteFile path mode = fmap File $ openBinaryFile path mode

eofIO :: File a -> IO Bool
eofIO (File h) = hIsEOF h

resetIO :: File a -> IO ()
resetIO (File h) = hSeek h AbsoluteSeek 0

closeIO :: File a -> IO ()
closeIO (File h) = hClose h

class FileType a where
    openIO :: FilePath -> IOMode -> IO (File a)
    peekIO :: File a -> IO a
    readIO :: File a -> IO a

getIO :: FileType a => File a -> IO ()
getIO f = readIO f >> return ()

-- For now, both types will be 8-bit, since that's what TeX does.

instance FileType Char where
    openIO path mode = fmap File $ openBinaryFile path mode
    peekIO (File h) = hLookAhead h
    readIO (File h) = hGetChar h


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
    
