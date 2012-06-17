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

main = do
    [progIn, progOut] <- getArgs
    old <- readFile progIn
    case runAlex old program of
        Left err -> print err
        Right s -> writeFile progOut $ render
                    $ generateProgram
                    $ resolveProgram
                    $ flattenProgram s
