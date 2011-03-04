{
module Language.Pascal.Lexer(alexScanTokens,Token(..)) where
}

%wrapper "basic"

$whitechar = [ \t\n\r\f\v]
$digit = [0-9]
$alpha = [a-zA-Z]

pascal :-

$white+         ;
\{[^\}]*\}         ;
and             { const TokAnd }
array           { const TokArray }
begin           { const TokBegin }
case            { const TokCase }
const           { const TokConst }
div		{ const TokDiv }
do		{ const TokDo }
downto		{ const TokDownto }
else		{ const TokElse }
end		{ const TokEnd }
file            { const TokFile }
for		{ const TokFor }
forward		{ const TokForward }
function	{ const TokFunction }
goto		{ const TokGoto }
if		{ const TokIf }
label		{ const TokLabel }
mod		{ const TokMod }
not		{ const TokNot }
of		{ const TokOf }
or		{ const TokOr }
packed		{ const TokPacked }
procedure	{ const TokProcedure }
program		{ const TokProgram }
record		{ const TokRecord }
repeat		{ const TokRepeat }
then            { const TokThen }
to              { const TokTo }
type            { const TokType }
var		{ const TokVar }
while		{ const TokWhile }
"+"             { const TokPlus }
"*"             { const TokTimes }
"/"             { const TokDivide }
"="		{ const TokEQ }
"<"		{ const TokLT }
">"		{ const TokGT }
"["		{ const TokLeftBracket }
"]"		{ const TokRightBracket }
"."		{ const TokPeriod }
","		{ const TokComma }
"("		{ const TokLeftParen }
")"		{ const TokRightParen }
":"		{ const TokColon }
";"		{ const TokSemicolon }
"^"		{ const TokCaret }
"<="		{ const TokLTEQ }
">="		{ const TokGTEQ }
":="		{ const TokEQDef }
\' ([^'] | "''") * \'   { TokStringConst . unescape . init . tail}


$alpha [$alpha $digit]*     { TokIdent }
$digit+                     { TokInt . read }
"-" $digit+                     { TokInt . negate . read . drop 1 }

"-"             { const TokMinus }

{
data Token 
    = TokInt Int
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
    | TokPacked
    | TokProcedure
    | TokProgram
    | TokRecord
    | TokRepeat
    | TokString
    | TokThen
    | TokTo
    | TokType
    | TokVar
    | TokWhile
    | TokPlus
    | TokMinus
    | TokTimes
    | TokDivide
    | TokEQ
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
            deriving Show

unescape :: String -> String
unescape ('\'':'\'':cs) = '\'' : unescape cs
unescape (c:cs) = c : unescape cs
unescape "" = ""
}
