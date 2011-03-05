module TestParser where

import Language.Pascal.Parser
import Language.Pascal.Lexer
import Language.Pascal.Syntax

testParser :: Show a => (Alex a) -> String -> IO ()
testParser f = print . flip runAlex f
