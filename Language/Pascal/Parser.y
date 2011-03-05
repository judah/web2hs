{
module Language.Pascal.Parser where

import Language.Pascal.Lexer
import Language.Pascal.Syntax
}

%tokentype { Token }
%monad { Alex }
%lexer { alexLexer } { TokEOF }
%error { parseError }

%name program pascalProgram
%name declaration declaration
%name declarations declarations
%name typeDescr typeDescr
%name compoundStatement compoundStatement
%name statement statement
%name procedure procedureDeclar
%name localVars localVars

-- http://www.hkbu.edu.hk/~bba_ism/ISM2110/pas039.htm
%left '+' '-' or
%left '*' '/' div mod and
%left '=' "<>" '<' "<=" '>' ">="

%token
    and             { TokAnd }
    array           { TokArray }
    begin           { TokBegin }
    case            { TokCase }
    const           { TokConst }
    div		    { TokDiv }
    do		    { TokDo }
    downto	    { TokDownto }
    else	    { TokElse }
    end		    { TokEnd }
    file            { TokFile }
    for		    { TokFor }
    forward	    { TokForward }
    function	    { TokFunction }
    goto	    { TokGoto }
    if		    { TokIf }
    label	    { TokLabel }
    mod		    { TokMod }
    not		    { TokNot }
    of		    { TokOf }
    or		    { TokOr }
    packed	    { TokPacked }
    procedure	    { TokProcedure }
    program	    { TokProgram }
    record	    { TokRecord }
    repeat	    { TokRepeat }
    then            { TokThen }
    to              { TokTo }
    type            { TokType }
    until           { TokUntil }
    var		    { TokVar }
    while	    { TokWhile }
    write           { TokWrite }
    writeln         { TokWriteln }
    '+'             { TokPlus }
    '-'             { TokMinus }
    '*'             { TokTimes }
    '/'             { TokDivide }
    '='		    { TokEQ }
    "<>"	    { TokNEQ }
    '<'		    { TokLT }
    '>'		    { TokGT }
    '['		    { TokLeftBracket }
    ']'		    { TokRightBracket }
    '.'		    { TokPeriod }
    ','		    { TokComma }
    '('		    { TokLeftParen }
    ')'		    { TokRightParen }
    ':'		    { TokColon }
    ';'		    { TokSemicolon }
    '^'		    { TokCaret }
    "<="	    { TokLTEQ }
    ">="	    { TokGTEQ }
    ":="	    { TokEQDef }
    ident           { TokIdent $$ }
    int             { TokInt $$ }
    stringConst     { TokStringConst $$ }
    
%%

pascalProgram :: { Program }
    : program ident progParams ';' declarations compoundStatement '.'
        { Program $2 $3 $5 $6 }

progParams
    : '(' commalist(ident) ')' { $2 }
    | {- empty -}           { [] }

compoundStatement :: { [Statement] }
    -- note: I think the trailing semicolon on the last substatement
    -- is optional in Pascal, but tangle seems to always generate it.
    : begin compoundStmtList end { reverse $2 }
compoundStmtList :: { [Statement] }
    : {- empty -} { [] }
    | compoundStmtList statementOrLabel { $2 : $1 }

statementOrLabel :: { Statement }
    : statement ';' { $1 }
    | labelName ':' { MarkLabel $1 }

block :: { [Statement] }
    : statement { [$1] }
    | compoundStatement { $1 }

statement :: { Statement }
    : varRef ":=" expr { AssignStmt $1 $3 }
    | goto labelName { Goto $2 }
    | ident { ProcedureCall $1 [] }
    | ident '(' commalist(expr) ')' { ProcedureCall $1 $3 }
    | if expr then block { IfStmt $2 $4 Nothing }
    | if expr then block  else block { IfStmt $2 $4 (Just $6) }
    | for ident ":=" expr forDir expr do block
                    { ForStmt $2 $4 $6 $5 $8 }
    | repeat semilist(statement) until expr
        { RepeatStmt $4 $2 }
    | write '(' commalist(writeArg) ')' { Write False $3 }
    | writeln '(' commalist(writeArg) ')' { Write True $3 }

varRef :: { VarReference }
    : ident { NameRef $1 }
    | ident '[' expr ']' { ArrayRef $1 $3 }

labelName :: { Label }
    : int { $1 }

forDir :: { ForDir }
    : to    { UpTo }
    | downto { DownTo }

writeArg :: { WriteArg }
    : expr          { WritePlain $1 }
    | expr ':' int  { WritePadded $3 $1 }

declarations : list(declaration) { concat $1 }

declaration :: { [ Declaration] }
    : constDeclar { $1 }
    | typeDeclar { $1 }
    | varDeclar { $1 }
    | labelDeclar { $1 }
    | functionDeclar ';' { [NewFunction $1] }
    | procedureDeclar ';' { [NewFunction $1] }

labelDeclar :: { [Declaration] }
    : label commalistNonempty(labelName) ';'  { fmap NewLabel $2 }

constDeclar :: { [Declaration] }
    : const semilist(constAssign) { $2 }
constAssign :: { Declaration }
    : ident '=' constValue  { NewConst $1 $3 }

varDeclar :: { [Declaration] }
    : var semilist(varDeclarSingle) { concat $2 }

varDeclarSingle :: { [Declaration] }
    : commalist(ident) ':' typeDescr
        { fmap (flip NewVar $3) $1 }



constValue :: { ConstValue }
    : int   { ConstInt $1 }
    | stringConst { ConstString $1 }


-- types

typeDeclar :: { [Declaration] }
    : type semilist(typeSpec)  { $2 }

typeSpec :: { Declaration }
    : ident '=' typeDescr   { NewType $1 $3 }


typeDescr :: { Type }
    : baseType { BaseType $1 }
    | maybepacked array '[' baseType ']' of typeDescr
                        { ArrayType $4 $7 }
    | maybepacked file of typeDescr
                        { FileType $4 }

baseType :: { BaseType }
    : ident { NamedType $1 }
    | bound '.' '.' bound   { Range $1 $4 } 

maybepacked
    : {- empty -} { () }
    | packed    { () }

bound :: { Either Int Name }
    : ident     { Right $1 }
    | int       { Left $1 }


intValue :: { Int }
    : int { $1 }

----------
-- Expressions

expr :: { Expr }
    : expr '+' expr { BinOp $1 Plus $3 }
    | expr '-' expr { BinOp $1 Minus $3 }
    | expr '*' expr { BinOp $1 Times $3 }
    | expr '/' expr { BinOp $1 Divide $3 }
    | expr div expr { BinOp $1 Div $3 }
    | expr mod expr { BinOp $1 Mod $3 }
    | expr or expr { BinOp $1 Or $3 }
    | expr and expr { BinOp $1 And $3 }
    | expr '=' expr { BinOp $1 OpEQ $3 }
    | expr "<>" expr { BinOp $1 NEQ $3 }
    | expr '<' expr { BinOp $1 OpLT $3 }
    | expr "<=" expr { BinOp $1 LTEQ $3 }
    | expr '>' expr { BinOp $1 OpGT $3 }
    | expr ">=" expr { BinOp $1 GTEQ $3 }
    | constValue    { ConstExpr $1 }
    | varRef { VarExpr $1 }
    | ident '(' commalist(expr) ')' { FuncCall $1 $3 }
    | '(' expr ')' { $2 }

------
-- Functions

procedureDeclar :: { Function }
    : procedure ident paramList ';' localVars functionBody
        { Function $2 $3 Nothing $5 $6 }

functionDeclar :: { Function }
    : function ident paramList ':' typeDescr ';' localVars functionBody
        { Function $2 $3 (Just $5) $7 $8 }

functionBody :: { Maybe [Statement] }
    : compoundStatement     { Just $1 }
    | forward   { Nothing }

paramList :: { ParamList }
    : '(' paramListHelper ')'   { reverse $2 }
    | {- empty -}       { [] }
paramListHelper :: { ParamList }
    : argVars { $1 }
    | paramListHelper ',' localVars { $3 ++ $1 }
argVars :: { ParamList }
    : var commalistNonempty(ident) ':' typeDescr
        { fmap (\n -> (n,$4)) $2 }

localVars :: { ParamList }
    :  { [] }
    | semilist(localVarDecl) { concat $1 }

localVarDecl :: { ParamList }
    : var commalistNonempty(ident) ':' typeDescr
        { fmap (\n -> (n,$4)) $2 }

-----------
-- Lists

semilist(p) : semilisthelper(p) { reverse $1 }
semilisthelper(p)
    : p ';'                     { [$1] }
    | semilisthelper(p) p ';'   { $2 : $1 }

list(p) : listhelper(p) { reverse $1 }
listhelper(p)
    :                       { [] }
    | listhelper(p) p    { $2 : $1 }

commalist(p) : 
    {- empty -}         { [] }
    | commalisthelper(p) { reverse $1 }
commalistNonempty(p)
    : commalisthelper(p) { reverse $1 }
commalisthelper(p)
    :  p                { [$1] }
    | commalisthelper(p) ',' p      { $3 : $1 }

{
alexLexer :: (Token -> Alex a) -> Alex a
alexLexer = (alexMonadScan >>=)

parseError :: Token -> Alex a
parseError tok = do
    p <- getPosition
    lexerError p $ "Parse error at token: " ++ show tok

}
