module TestParser where

import Language.Pascal.Parser
import Language.Pascal.Lexer
import Language.Pascal.Syntax
import Language.Pascal.Pretty

testParser :: Pretty a => (Alex a) -> String -> IO ()
testParser f prog = case runAlex prog f of
                        Left err -> print err
                        Right x -> print $ pretty x
