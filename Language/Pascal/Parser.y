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
%name expression expr

-- http://www.hkbu.edu.hk/~bba_ism/ISM2110/pas039.htm
%left '+' '-' or
%left '*' '/' div mod and
%left '=' "<>" '<' "<=" '>' ">="
%left not
%left NEG

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
    others	    { TokOthers }
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
    nonnegint       { TokInt $$ }
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
    | if expr then statement { IfStmt $2 $4 Nothing }
    | if expr then statement  else statement { IfStmt $2 $4 (Just $6) }
    | for ident ":=" expr forDir expr do statement
                    { ForStmt $2 $4 $6 $5 $8 }
    | repeat semilist(statement) until expr
        { RepeatStmt $4 $2 }
    | while expr do statement { WhileStmt $2 $4 }
    | case expr of caseEltList { CaseStmt $2 $4 }
    | write '(' commalist(writeArg) ')' { Write False $3 }
    | writeln '(' commalist(writeArg) ')' { Write True $3 }
    | compoundStatement     { SubBlock $1 }
    | {- empty -}           { EmptyStatement }

varRef :: { VarReference }
    : ident { NameRef $1 }
    | varRef'[' commalistNonempty(expr) ']' { ArrayRef $1 $3 }
    | varRef '^' { DeRef $1 }
    | varRef '.' ident { RecordRef $1 $3 }

labelName :: { Label }
    : nonnegint { $1 }

forDir :: { ForDir }
    : to    { UpTo }
    | downto { DownTo }

writeArg :: { WriteArg }
    : expr          { WritePlain $1 }
    | expr ':' nonnegint  { WritePadded $3 $1 }

caseEltList :: { [CaseElt] }
    : caseEltListHelper end    { reverse $1 }
    | caseEltListHelper caseElt end { reverse ($2 : $1) }

caseEltListHelper :: { [CaseElt] }
    : caseElt ';'      { [$1] }
    | caseEltListHelper caseElt ';' { $2 : $1 }

caseElt :: { CaseElt }
    : commalistNonempty(constValueOrOthers) ':' statement
            { CaseElt $1 $3 }

constValueOrOthers :: { Maybe ConstValue }
    : others        { Nothing }
    | constValue    { Just $1 }

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
    : '-' nonnegint { ConstInt (negate $2) }
    | nonnegConstValue { $1 }

-- To remove reduce/reduce conflicts with '-'
nonnegConstValue
    : nonnegint   { ConstInt $1 }
    | stringConst { ConstString $1 }


-- types

typeDeclar :: { [Declaration] }
    : type semilist(typeSpec)  { $2 }

typeSpec :: { Declaration }
    : ident '=' typeDescr   { NewType $1 $3 }


typeDescr :: { Type }
    : baseType { BaseType $1 }
    | maybepacked array '[' commalistNonempty(baseType) ']' of typeDescr
                        { ArrayType $4 $7 }
    | maybepacked file of typeDescr
                        { FileType $4 }
    | maybepacked record recordFields end { RecordType (reverse $3) }

baseType :: { BaseType }
    : ident { NamedType $1 }
    | bound '.' '.' bound   { Range $1 $4 } 

maybepacked
    : {- empty -} { () }
    | packed    { () }

bound :: { Either Integer Name }
    : ident     { Right $1 }
    | nonnegint       { Left $1 }
    | '+' nonnegint   { Left $2 }
    | '-' nonnegint   { Left (negate $2) }


recordFields :: { [(Name,BaseType)] }
    : {- empty -} { [] }
    | recordFields ident ':' baseType ';' { ($2,$4) : $1 }

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
    | not expr { NotOp $2 }
    | '-' expr %prec NEG { Negate $2 }
    | nonnegConstValue { ConstExpr $1 }
    | varRef { VarExpr $1 }
    | ident '(' commalist(expr) ')' { FuncCall $1 $3 }
    | '(' expr ')' { $2 }

------
-- Functions

procedureDeclar :: { Function }
    : procedure ident funcParams ';' localLabels localVars functionBody
        { Function $2 $3 Nothing $5 $6 $7 }

functionDeclar :: { Function }
    : function ident funcParams ':' typeDescr ';' localLabels
            localVars functionBody
        { Function $2 $3 (Just $5) $7 $8 $9 }

functionBody :: { Maybe [Statement] }
    : compoundStatement     { Just $1 }
    | forward   { Nothing }

funcParams :: { [FuncParam] }
    : '(' funcParamList ')' { concat (reverse $2) }
    | {- empty -}          { [] }

funcParamList :: { [[FuncParam]] }
    : funcParam { [$1] }
    | funcParamList ';' funcParam  { $3 : $1 }

funcParam :: { [FuncParam] }
    : maybevar commalistNonempty(ident) ':' typeDescr
        { [FuncParam n t r | let r = $1, let t = $4, 
                                n <- $2] }

localVars :: { ParamList }
    :  { [] }
    | semilist(localVarDecl) { concat $1 }

localVarDecl :: { ParamList }
    : maybevar commalistNonempty(ident) ':' typeDescr
        { fmap (\n -> (n,$4)) $2 }

maybevar :: { Bool }
    : var   { True } 
    | {- empty -} { False }

localLabels :: { [Label] }
    : { [] }
    | semilist(localLabel) { concat $1 }

localLabel :: { [Label] }
    : label commalistNonempty(labelName) { $2 }

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
