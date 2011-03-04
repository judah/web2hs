module TestParser where

import Language.Pascal.Parser
import Language.Pascal.Lexer
import Language.Pascal.Syntax

testParser :: Show a => ([Token] -> a) -> String -> IO ()
testParser f = print . f . alexScanTokens

testLexer :: String -> [Token]
testLexer = alexScanTokens
