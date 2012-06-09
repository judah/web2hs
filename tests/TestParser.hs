module Main where

import Language.Pascal.Parser
import Language.Pascal.Lexer
import Language.Pascal.Syntax
import Language.Pascal.Transform
import Language.Pascal.Pretty
import Language.Pascal.GenerateC
import Text.PrettyPrint.HughesPJ

import Control.Monad
import System.FilePath
import System.Environment

testParser :: Pretty a => (Alex a) -> String -> IO ()
testParser f prog = case runAlex prog f of
                        Left err -> print err
                        Right x -> print $ pretty x

main = do
    [progIn, progOut] <- getArgs
    old <- readFile progIn
    case runAlex old program of
        Left err -> print err
        Right s -> do
                    let flat = flattenProgram s
                    let resolved = resolveProgram flat
                    writeFile (replaceExtension progOut ".p")
                        $ render $ pretty resolved
                    writeFile progOut
                        $ render $ generateProgram resolved
                    putStrLn "Success."
