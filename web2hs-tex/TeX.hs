module Main where

import System.Web2hs.History
import System.Web2hs.FileCache
import System.Web2hs.TeX

import System.Console.CmdArgs
import Control.Monad (mplus,guard)

data Args = Args
                { initex :: Bool
                , formatFile :: Maybe FilePath
                , poolFile :: Maybe FilePath
                , interaction :: InteractionMode
                , unusedArgs :: [String]
                } deriving (Show,Typeable,Data)


getArgs :: IO Args
getArgs = cmdArgs $ Args
                { initex = def &= explicit &= name "initex"
                            &= help "Don't load an initial format file"
                , formatFile = def &= explicit &= name "fmt"
                            &= typFile
                            &= help "Preload this format file (e.g., \"plain\")"
                , poolFile = def &= explicit &= name "pool"
                            &= typFile
                            &= help ("Specify a string pool file to use "
                                    ++ " instead of the installed \"tex.pool\"")
                , interaction = ErrorStop -- same as defaultOptions and tex.web
                            &= typ "MODE"
                            &= help ("Specify an interaction mode"
                                    ++ " (batch, nonstop, scroll, or errorstop);"
                                    ++ " default=errorstop")
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
    let options = (defaultOptions $ unwords unusedArgs)
                    { explicitFormatFile
                        = formatFile
                            `mplus` (guard (not initex) >> Just "plain.fmt")
                    , interactionMode = interaction
                    }
    history <- texWithOptions fc options
    exitWithHistory history
