{
module Language.Pascal.Parser(pascal) where

import Language.Pascal.Lexer
import Language.Pascal.Syntax
}

%name pascal
%tokentype { Token }
%error { parseError }

%token
    ident           { TokIdent $$ }
    int             { TokInt $$ }
    stringConst     { TokStringConst $$ }
    and             { TokAnd }
    array           { TokArray }
    begin           { TokBegin }
    case            { TokCase }
    const           { TokConst }
    div		    { TokDiv }
    do		    { TokDo }
    else	    { TokElse }
    end		    { TokEnd }
    for		    { TokFor }
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
    string	    { TokString }
    type            { TokType }
    var		    { TokVar }
    while	    { TokWhile }
    '+'             { TokPlus }
    '*'             { TokTimes }
    '/'             { TokDivide }
    '='		    { TokEQ }
    '<'		    { TokLT }
    '>'		    { TokGT }
    '{'		    { TokLeftBracket }
    '}'		    { TokRightBracket }
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
    
%%


pascal : semilist(declaration) {("This is it",concat $1)}

declaration :: { [ Declaration] }
    : constDeclar { $1 }
    | typeDeclar { $1 }
    

foo : begin end { () } 

semilist(p) : semilisthelper(p) { reverse $1 }
semilisthelper(p)
    : p ';'                     { [$1] }
    | semilisthelper(p) p ';'   { $2 : $1 }

constDeclar :: { [Declaration] }
    : const semilist(constAssign) { $2 }

constAssign :: { Declaration }
    : ident '=' constValue  { NewConst $1 $3 }

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
    | maybepacked array baseType of typeDescr
                        { ArrayType $3 $5 }

baseType :: { BaseType }
    : ident { NamedType $1 }
    | bound '.' '.' bound   { Range $1 $4 } 

maybepacked
    : packed    { () }
    |           { () }

bound :: { Either Int Name }
    : ident     { Right $1 }
    | int       { Left $1 }

{
parseError :: [Token] -> a
parseError _ = error "Parse error"
}
