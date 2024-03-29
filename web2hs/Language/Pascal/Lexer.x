{
module Language.Pascal.Lexer(
    Token(..),
    Alex,
    runAlex,
    alexMonadScan,
    getPosition,
    Pos(..),
    lexerError,
    ) where
import Control.Monad
}

%wrapper "monad"

$whitechar = [ \t\n\r\f\v]
$digit = [0-9]
$alpha = [a-zA-Z]
$underline = [_]

pascal :-

$white+         { skip }
\{([\n]|[^\}])*\}      { skip }
and             { tok TokAnd }
array           { tok TokArray }
begin           { tok TokBegin }
case            { tok TokCase }
const           { tok TokConst }
div		{ tok TokDiv }
do		{ tok TokDo }
downto		{ tok TokDownto }
else		{ tok TokElse }
end		{ tok TokEnd }
file            { tok TokFile }
for		{ tok TokFor }
forward		{ tok TokForward }
function	{ tok TokFunction }
goto		{ tok TokGoto }
if		{ tok TokIf }
label		{ tok TokLabel }
mod		{ tok TokMod }
not		{ tok TokNot }
of		{ tok TokOf }
or		{ tok TokOr }
others		{ tok TokOthers }
packed		{ tok TokPacked }
procedure	{ tok TokProcedure }
program		{ tok TokProgram }
record		{ tok TokRecord }
repeat		{ tok TokRepeat }
then            { tok TokThen }
to              { tok TokTo }
type            { tok TokType }
until           { tok TokUntil }
var		{ tok TokVar }
while		{ tok TokWhile }
write		{ tok TokWrite }
writeln		{ tok TokWriteln }
-- Work with -underline
write_ln	{ tok TokWriteln }
"+"             { tok TokPlus }
"*"             { tok TokTimes }
"/"             { tok TokDivide }
"="		{ tok TokEQ }
"<>"		{ tok TokNEQ }
"<"		{ tok TokLT }
">"		{ tok TokGT }
"["		{ tok TokLeftBracket }
"]"		{ tok TokRightBracket }
"."		{ tok TokPeriod }
","		{ tok TokComma }
"("		{ tok TokLeftParen }
")"		{ tok TokRightParen }
":"		{ tok TokColon }
";"		{ tok TokSemicolon }
"^"		{ tok TokCaret }
"<="		{ tok TokLTEQ }
">="		{ tok TokGTEQ }
":="		{ tok TokEQDef }
\' ([^'] | "''") * \'   { tok1 $ TokStringConst . unescape . init . tail}


$alpha [$alpha $digit $underline]*     { tok1 TokIdent }
$digit+                     { tok1 $ TokInt . read }
$digit+ "." $digit+         { tok1 $ TokReal . readReal}
-- Messes with the following
-- (I.e., how to parse "2-3"?
-- "-" $digit+                     { TokInt . negate . read . drop 1 }

"-"             { tok TokMinus }

-- Final case: catch errors, since the alex "monad" wrapper doesn't print
-- a position for lexer errors.
.               { unexpectedInput }

{
data Token 
    = TokInt Integer
    | TokReal Rational
    | TokStringConst String
    | TokIdent String
    | TokAnd
    | TokArray
    | TokBegin
    | TokCase
    | TokConst
    | TokDiv
    | TokDo
    | TokDownto
    | TokElse
    | TokEnd
    | TokFile
    | TokFor
    | TokForward
    | TokFunction
    | TokGoto
    | TokIf
    | TokLabel
    | TokMod
    | TokNot
    | TokOf
    | TokOr
    | TokOthers
    | TokPacked
    | TokProcedure
    | TokProgram
    | TokRecord
    | TokRepeat
    | TokString
    | TokThen
    | TokTo
    | TokType
    | TokUntil
    | TokVar
    | TokWhile
    | TokWrite
    | TokWriteln
    | TokPlus
    | TokMinus
    | TokTimes
    | TokDivide
    | TokEQ
    | TokNEQ
    | TokLT
    | TokGT
    | TokLeftBracket
    | TokRightBracket
    | TokPeriod
    | TokComma
    | TokLeftParen
    | TokRightParen
    | TokColon
    | TokSemicolon
    | TokCaret
    | TokLTEQ
    | TokGTEQ
    | TokEQDef
    | TokEOF
            deriving Show

unescape :: String -> String
unescape ('\'':'\'':cs) = '\'' : unescape cs
unescape (c:cs) = c : unescape cs
unescape "" = ""

-- \d+ "." \d+
readReal :: String -> Rational
readReal xs = let
    (w,_:r) = break (=='.') xs
    in fromInteger (read w) + fromInteger (read r) / (10^length r)

tok :: Token -> AlexAction Token
tok t _ _ = return t

tok1 :: (String -> Token) -> AlexAction Token
tok1 f i@(_,_,_,s) len = return $ f (take len s)

unexpectedInput :: AlexAction Token
unexpectedInput i@(_,_,_,s) len = lexerError (inputPos i)
                                    $ "unexpected input "
                                    ++ show (take len s)

alexEOF = return TokEOF

type Pos = (Int,Int)

getPosition :: Alex Pos
getPosition = liftM inputPos alexGetInput

inputPos :: AlexInput -> Pos
inputPos (AlexPn _ l c,_,_,_) = (l,c)

lexerError :: Pos -> String -> Alex a
lexerError p s = do
    alexError $ show p ++ ": " ++ s

}
