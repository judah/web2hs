module Main where

import qualified Language.Pascal.Parser as Parser
import Language.Pascal.Lexer
import Language.Pascal.Transform
import Language.Pascal.Pretty.Base
import Language.Pascal.Pretty.Pascal
import Language.Pascal.Pretty.C

import System.Console.CmdArgs

import System.FilePath
import System.Exit (exitFailure)

data Options = Options {
        inputFile :: String,
        outputFile :: String,
        pascalDumpFile :: Maybe String
    } deriving (Show,Typeable,Data)

getOptions :: IO Options
getOptions = cmdArgs $
                Options
                    { inputFile = def &= argPos 0
                                    &= typ "INPUT.p"
                    , outputFile = def &= argPos 1
                                    &= typ "OUTPUT.c"
                    , pascalDumpFile = def
                        &= explicit
                        &= name "dump-pascal"
                        &= typFile
                        &= opt (Nothing::Maybe String)
                    } &= program "web2hs"

main :: IO ()
main = do
    Options {..} <- getOptions
    old <- readFile inputFile
    case runAlex old Parser.program of
        Left err -> putStrLn err >> exitFailure
        Right s -> do
            let transformed = resolveProgram
                                $ flattenProgram s
            case pascalDumpFile of
                Nothing -> return ()
                Just f -> writeFile f $ render $ prettyPascal transformed
            writeFile outputFile
                $ render $ generateProgram transformed
            writeFile (replaceExtension outputFile "h")
                $ render $ generateHeader transformed
