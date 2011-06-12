{
module Language.Pascal.Parser where

import Language.Pascal.Lexer
import Language.Pascal.Syntax
}

%tokentype { Token }
%monad { Alex }
%lexer { alexLexer } { TokEOF }
%error { parseError }

-- Shift-reduce for nested if-then-else
%expect 1

%name program pascalProgram
%name typeDescr typeDescr
%name compoundStatement compoundStatement
%name statement statement
%name expression expr

-- As specified in ISO7185
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
    nonnegreal      { TokReal $$ }
    stringConst     { TokStringConst $$ }
    
%%

pascalProgram :: { Program }
    : program ident progParams ';' block '.'
        { Program $2 $3 $5 }

progParams
    : '(' commalist(ident) ')' { $2 }
    | {- empty -}           { [] }


block :: { Block }
    : blockLabels blockConstants blockTypes blockVars blockFuncs
      compoundStatement
    { Block $1 $2 $3 $4 $5 $6 }

blockLabels :: { [Label] }
    : label commalistNonempty(labelName) ';'  { $2 }
    | {- empty -}           { [] }

blockConstants :: { [(Name,ConstValue)] }
    : const semilist(constAssign) { $2 }
    | {- empty -}           { [] }
constAssign :: { (Name,ConstValue) }
    : ident '=' constValue { ($1,$3) }

blockTypes :: { [(Name,Type)] }
    : type semilist(typeDeclar) { $2 }
    | {- empty -}           { [] }
typeDeclar :: { (Name,Type) }
    : ident '=' typeDescr   { ($1,$3) }

blockVars :: { [(Name,Type)] }
    : var semilist(varDecls)   { [(n,t) | (ns,t) <- $2, n <- ns] }
    | {- empty -}           { [] }
varDecls :: { ([Name],Type) }
    : commalistNonempty(ident) ':' typeDescr { ($1,$3) }

blockFuncs :: {[FunctionDecl]}
    : semilist(functionDecl)    { $1 }
    | {- empty -}           { [] }

functionDecl :: { FunctionDecl }
    : procedure ident paramList ';' forward
        { FuncForward $2 (FuncHeading $3 Nothing) }
    | procedure ident paramList ';' block
        { Func $2 (FuncHeading $3 Nothing) $5 }
    | function ident paramList ':' typeDescr ';' forward
        { FuncForward $2 (FuncHeading $3 (Just $5)) }
    | function ident paramList ':' typeDescr ';' block
        { Func $2 (FuncHeading $3 (Just $5)) $7 }


paramList :: { [FuncParam] }
    : {- empty -}   { [] }
    | '(' funcParams ')'     { concat (reverse $2) }

funcParams :: { [[FuncParam]] }
    : funcParam { [$1] }
    | funcParams ';' funcParam  { $3 : $1 }

funcParam :: { [FuncParam] }
    : maybevar commalistNonempty(ident) ':' typeDescr
        { [FuncParam n t r | let r = $1, let t = $4, 
                                n <- $2] }

maybevar :: { Bool }
    : var   { True } 
    | {- empty -} { False }



compoundStatement :: { StatementList }
    -- note: I think the trailing semicolon on the last substatement
    -- is optional in Pascal, but tangle seems to always generate it.
    : begin statementList end { $2 }

statementList :: { StatementList }
    : statementListHelper { reverse $1 }
statementListHelper :: { StatementList }
    : statement { [$1] }
    | statementListHelper ';' statement { $3 : $1 }

statement :: { Statement }
    : statementBase { (Nothing,$1) }
    | labelName ':' statementBase { (Just $1,$3) }

statementBase :: { StatementBase }
    : varRef ":=" expr { AssignStmt $1 $3 }
    | goto labelName { Goto $2 }
    | ident { ProcedureCall $1 [] }
    | ident '(' commalist(expr) ')' { ProcedureCall $1 $3 }
    | if expr then statement { IfStmt $2 $4 Nothing }
    | if expr then statement  else statement { IfStmt $2 $4 (Just $6) }
    | for ident ":=" expr forDir expr do statement
                    { ForStmt $2 $4 $6 $5 $8 }
    | repeat statementList until expr
        { RepeatStmt $4 $2 }
    | while expr do statement { WhileStmt $2 $4 }
    | case expr of caseEltList { CaseStmt $2 $4 }
    | write '(' commalist(writeArg) ')' { Write False $3 }
    | writeln '(' commalist(writeArg) ')' { Write True $3 }
    | compoundStatement     { CompoundStmt $1 }
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
    : expr          { WriteArg $1 Nothing }
    | expr ':' nonnegint  { WriteArg $1 (Just ($3,Nothing)) }
    | expr ':' nonnegint  ':' nonnegint
                    { WriteArg $1 (Just ($3,Just $5)) }

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


constValue :: { ConstValue }
    : '-' nonnegint { ConstInt (negate $2) }
    | '-' nonnegreal { ConstReal (negate $2) }
    | nonnegConstValue { $1 }

-- To remove reduce/reduce conflicts with '-'
nonnegConstValue
    : nonnegint   { ConstInt $1 }
    | nonnegreal  { ConstReal $1 }
    | stringConst { ConstString $1 }
    | '+' nonnegint { ConstInt $2 }


-- types

typeDescr :: { Type }
    : baseType { BaseType $1 }
    | maybepacked array '[' commalistNonempty(baseType) ']' of typeDescr
                        { ArrayType $4 $7 }
    | maybepacked file of typeDescr
                        { FileType $4 }
    | maybepacked record fieldList end { RecordType $3 }


baseType :: { BaseType }
    : ident { NamedType $1 }
    | bound '.' '.' bound   { Range $1 $4 } 

maybepacked
    : {- empty -} { () }
    | packed    { () }

bound :: { Bound }
    : ident     { VarBound $1 }
    | nonnegint       { IntBound $1 }
    | '+' bound { $2 }
    | '-' bound { NegBound $2 }

fieldList :: { FieldList }
    : fixedFields { FieldList $1 Nothing }
    | fixedFields  variantFields
                        { FieldList $1 (Just $2) }
    | variantFields
                        { FieldList [] (Just $1) }

fixedFields :: { Fields }
    : fixedFieldsHelper { concat $ reverse $1 }
    | fixedFieldsHelper ';' { concat $ reverse $1 }

fixedFieldsHelper :: { [Fields] }
    : recordSelection { [$1] }
    | fixedFieldsHelper ';' recordSelection { $3 : $1 }

recordSelection :: { Fields }
    : commalistNonempty(ident) ':' typeDescr
        { [(n::Name,t::Type) | let ns = $1, let t = $3, n <- ns] }

variantFields :: { Variant }
    : case typeDescr of semilist(variant)
        { Variant $2 $4 }

variant :: { (Integer,Fields) }
    : nonnegint ':' '(' fixedFields')' { ($1,$4) }


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


-----------
-- Lists

-- this is nonempty.
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
