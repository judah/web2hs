module TestParser where

import Language.Pascal.Parser
import Language.Pascal.Lexer
import Language.Pascal.Syntax
import Language.Pascal.Transform
import Language.Pascal.Pretty
import Text.PrettyPrint.HughesPJ

import Control.Monad
import System.FilePath

testParser :: Pretty a => (Alex a) -> String -> IO ()
testParser f prog = case runAlex prog f of
                        Left err -> print err
                        Right x -> print $ pretty x

-- Unless specified otherwise, these are all tangled directly from the .web
-- source.
testPrograms = [ "pooltype.p"
               , "tangle.p"
               , "weave.p"
               , "dvitype.p"
               -- bibtex has an "extern" function declaration for erstat.
               -- I don't think that's valid Pascal, so I just changed it.
               , "bibtex.p"
               , "tex.p"
               -- etex from tex.web and etex.ch.
               , "etex.p"
               ]

runTests :: IO ()
runTests = forM_ testPrograms $ \prog -> do
    old <- readFile prog
    putStrLn $ "==== " ++ prog ++ " ===="
    case runAlex old program of
        Left err -> print err
        Right s -> do
                    putStrLn "Succeeded."
                    writeFile (replaceExtension prog "out1")
                        $ render $ pretty s
                    writeFile (replaceExtension prog "out2")
                        $ render $ pretty $ flattenProgram s
                    {-
                    writeFile (replaceExtension prog "diff.old")
                        $ concat $ lines old
                    writeFile (replaceExtension prog "diff.new")
                        $ renderStyle style {mode=OneLineMode} $ pretty s
                    -}
