module Main where

import System.Web2hs.FileCache
import System.Web2hs.TeX

import System.Console.CmdArgs
import Control.Monad (mplus,guard)

data Args = Args
                { initex :: Bool
                , formatFile :: Maybe FilePath
                , unusedArgs :: [String]
                } deriving (Show,Typeable,Data)


getArgs :: IO Args
getArgs = cmdArgs $ Args
                { initex = def &= explicit &= name "initex"
                            &= help "Don't load an initial format file"
                , formatFile = def &= explicit &= name "fmt"
                            &= typFile
                            &= help "preload this format file (e.g., 'plain')"
                , unusedArgs = def &= args
                            &= typ "COMMANDS"
                } &= program "web2hs-tex"
                
-- Rules for fmt file loading:
-- 1. If the first line of input is "&foo", load foo.fmt.
-- 2. Otherwise, if the user specified a format file on the command-line, use it.
-- 3. Otherwise, if the user specified --initex, don't load a format file.
-- 4. Otherwise, load plain.fmt.

main = do
    fc <- getUserFileCache
    Args {..} <- getArgs
    let firstLine = unwords unusedArgs
    let explicitFormatFile = formatFile 
                            `mplus` (guard (not initex) >> Just "plain.fmt")
    print Options {..}
    texWithOptions fc Options {..}
