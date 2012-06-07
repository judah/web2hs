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
                    writeFile (replaceExtension prog "out")
                        $ render $ pretty s
                    putStrLn "Succeeded parsing."
                    let flat = flattenProgram s
                    writeFile (replaceExtension prog "out.flat")
                        $ render $ pretty flat
                    putStrLn "Succeeded flattening."
                    let resolved = resolveProgram flat
                    writeFile (replaceExtension prog "out.resolved")
                        $ render $ pretty resolved
                    putStrLn "Succeeded rendering."
                    {-
                    writeFile (replaceExtension prog "diff.old")
                        $ concat $ lines old
                    writeFile (replaceExtension prog "diff.new")
                        $ renderStyle style {mode=OneLineMode} $ pretty s
                    -}
