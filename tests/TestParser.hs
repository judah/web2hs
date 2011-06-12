module TestParser where

import Language.Pascal.Parser
import Language.Pascal.Lexer
import Language.Pascal.Syntax
import Language.Pascal.Pretty
import Text.PrettyPrint.HughesPJ

import Control.Monad
import System.FilePath

testParser :: Pretty a => (Alex a) -> String -> IO ()
testParser f prog = case runAlex prog f of
                        Left err -> print err
                        Right x -> print $ pretty x

testPrograms = [ "pooltype.p"
               , "tangle.p"
               , "weave.p"
               , "dvitype.p"
               , "tex.p"
               ]

runTests :: IO ()
runTests = forM_ testPrograms $ \prog -> do
    old <- readFile prog
    putStrLn $ "==== " ++ prog ++ " ===="
    case runAlex old program of
        Left err -> print err
        Right s -> do
                    putStrLn "Succeeded."
                    writeFile (replaceExtension prog "out")
                        $ render $ pretty s
                    {-
                    writeFile (replaceExtension prog "diff.old")
                        $ concat $ lines old
                    writeFile (replaceExtension prog "diff.new")
                        $ renderStyle style {mode=OneLineMode} $ pretty s
                    -}
