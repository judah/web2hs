module Language.Pascal.GenerateC where

import Language.Pascal.Syntax
import Language.Pascal.Pretty
import Language.Pascal.Typecheck
import Text.PrettyPrint.HughesPJ
import Data.Monoid hiding ( (<>) )
import Numeric
import Data.Maybe (catMaybes, isNothing)
import Data.List ((\\))


------------
{-
This module is concerned with turning parsed/flattend/resolved Pascal code
into C code that interoperates with web2hs-lib.

An overview of how this works:
- The main "program" is a C function.  Its local variables in Pascal become
  global variables in C.
- Other Pascal functions become C functions with the same local variables.
- jumps within a single function are implemented with C labels and goto.
- jumps from subfunctions to the main program are implemented with 
  setjmp/longjmp.
- Program arguments can be any type (int, record, etc).
- Special case for record program arguments: we pass them in as pointers
  to satisfy the Haskell FFI.  For example:
      program foo(x); var x:record_type...;...;end.
  becomes something like
      void foo(record_type *x_progArg) {
          x = *x_progArg;
      }
- Special case for file program arguments: 
      program foo(x); var x:file of text_char; begin reset(x);end.
  becomes something like
      char *x_progGlobal;
      FILE *x;
      void foo(char *x_progArg) {
          x_progGlobal = x_progArg;
          x = fopen(x_progGlobal,"r");
      }
  (We save the argument in a separate global variable so that it's accessible
  from subfunctions.)
-}

-------------
-- Generic utilities

braceBlock :: Doc -> Doc -> Doc
braceBlock head body = (head <+> text "{") $+$ nest 2 body
                            $+$ text "}"

mapSemis :: (a -> Doc) -> [a] -> Doc
mapSemis f xs = vcat $ map (\x -> f x <> semi) xs

----------------
-- Types

-- Generate a variable declaration, e.g. "int v" or "FILE *x"
cType :: OrdType -> Doc -> Doc
cType (BaseType (Ordinal _ _)) v = text "int" <+> v
cType (BaseType OrdinalChar) v = text "char" <+> v
cType RealType v = text "float" <+> v
cType ArrayType {..} v
    = cType arrayEltType 
        (v <> hcat (map (brackets . pretty . ordSize)
                                    arrayIndexType))
cType (FileType b) v = case b of
    BaseType (Ordinal 0 255) -> text "FILE *" <+> v
    BaseType OrdinalChar -> text "FILE *" <+> v
cType RecordType { recordName = Just n } v = pretty n <+> v
cType RecordType { recordFields = FieldList {variantPart=Nothing,..}} v
    = cRecordType fixedPart <+> v
cType t _ = error ("unknown type: " ++ show t)

cRecordType :: Fields Ordinal -> Doc
cRecordType fs = text "struct" <+> braces (semilistOneLine $ map cField fs)
  where
    cField (n,t) = cType t (pretty n) 

star :: Doc
star = text "*"

declareConstant :: (Var,ConstValue) -> Doc
declareConstant (v,c)
    = text "const" <+> constType c <+> pretty v <+> equals 
        <+> generateConstValue c
  where
    constType (ConstInt _) = text "int" -- TODO
    constType (ConstReal _) = text "float"
    constType (ConstString _) = text "char*"

declareVar :: (Var,Type Ordinal) -> Doc
declareVar (v,t) = cType t (pretty v)

declareRecordType :: (Name, FieldList Ordinal) -> Doc
declareRecordType (n,fs)
    = text "typedef" 
        <+> cType (RecordType Nothing fs) (pretty n)

----------------------
-- Generating the .h file.  This is not directly used by the .c file,
-- but it may be useful for c2hs or hsc2hs.
-- 
-- It provides a declaration of the main program function, along with
-- any necessary record/struct types.

generateHeader :: Program Scoped Ordinal -> Doc
generateHeader Program {progBlock = Block {..},..}
    =  text "#include <stdio.h>" -- for FILE*
        $$ mapSemis declareRecordType [(n,fs) | (n,RecordType {recordFields=fs})
                                                <- blockTypes]
        $$ head <> semi
  where
    head = pretty "void" <+> pretty progName 
            <> parens (commaList [progArgType p (progArgVar p) | p <- progArgs])

---------------------------
-- Generating the .c file

generateProgram :: Program Scoped Ordinal -> Doc
generateProgram Program {progBlock = Block{..},..} = let
    head = pretty "void" <+> pretty progName 
            <> parens (commaList [progArgType p (progArgVar p) | p <- progArgs])
    jmpLabels = blockLabels
    body = programStatements [] blockStatements -- any jumps would be local
    in cIncludes
        $$ mapSemis declareConstant blockConstants
        $$ mapSemis declareRecordType [(n,fs) | (n,RecordType {recordFields=fs})
                                                <- blockTypes]
        $$ mapSemis declareVar blockVars
        $$ mapSemis programArgDeclarations progArgs
        $$ mapSemis (\l -> text "jmp_buf" <+> labelBuf l) jmpLabels
        $$ vcat (map (generateFunction jmpLabels) blockFunctions)
        $$ braceBlock head 
            (mapSemis programArgInitialization progArgs
                $$ body)

cIncludes :: Doc
cIncludes = text "#include \"web2hs_pascal_builtins.h\""
                $$ text "#include <setjmp.h>"

---------
-- Program argument initialization

progArgVar, progGlobalVar :: Var -> Doc
progArgVar v = pretty v <> text "_progArg"
progGlobalVar v
    | isFileVar v = pretty v <> text "_progGlobal"
    | otherwise = error $ "argument doesn't need global copy: "
                    ++ show (pretty v)


programArgDeclarations :: Var -> Doc
programArgDeclarations v
    | isFileVar v = progArgType v (progGlobalVar v)
    | otherwise = empty

programArgInitialization :: Var -> Doc
programArgInitialization v
    | isRecordVar v = pretty v <+> equals <+> star <> progArgVar v
    | isFileVar v = progGlobalVar v <+> equals <+> progArgVar v
    | otherwise = star <> pretty v <+> equals <+> progArgVar v

isFileVar :: Var -> Bool
isFileVar Var {varType = FileType _} = True
isFileVar _ = False

isRecordVar :: Var -> Bool
isRecordVar Var {varType = RecordType {}} = True
isRecordVar _ = False


progArgType :: Var -> Doc -> Doc
progArgType v@Var{..} w
    | isFileVar v  = text "char *" <> w
    | isRecordVar v = cType varType (pretty "*" <> w)
    | otherwise = cType varType w

-----------------------------------------------
-- Labels come in two varieties:
-- 1) most goto/labels are local to a single function, and map directly
--    to C labels.
-- 2) Some error-recovery labels are defined in the main program and then
--    other functions goto them.  We need to use setjmp/longjmp for them.
--    This is relatively safe since the main program function
--    doesn't define any local variables.
-- To distinguish the two, the statement-generating functions pass around
-- a list of labels which should be jumped to via longjmp instead of via goto.
labelID :: Label -> Doc
labelID l = text "label_" <> pretty l

labelBuf :: Label -> Doc
labelBuf l = text "label_" <> pretty l <> text "_buf"


{- The goal is for both the main program and other subfunctions
to be able to jump into arbitrary parts of the main program.
To do this, we translate

    ...; lab: s; ...

into:

    if (0==setjmp(..)) {
        ...
    }
    lab: s;
    ...

Then, we turn Pascal gotos in the main program into "goto lab"
and we turn Pascal gotos in subfunctions into "longjmp(..)".
-}
programStatements :: [Label] -> [Statement Scoped] -> Doc
programStatements jmpLabels ss = loop (reverse ss)
  where
    loop [] = empty
    loop ((Nothing,s):ss)
        = loop ss $$ generateStatementBase jmpLabels s <> semi
    loop ((Just l,s):ss)
        = braceBlock (jmpTest l) (loop ss)
            $$ hang (labelID l <> colon) 2
                (generateStatementBase jmpLabels s <> semi)
    jmpTest l = text "if (0==setjmp(" <> labelBuf l <> text "))"

generateFunction :: [Label] -> FunctionDecl Scoped Ordinal -> Doc
generateFunction _ FuncForward {..}
    = generateFuncHeading funcName funcHeading <> semi
generateFunction jmpLabels FuncDecl {funcBlock=Block{..},..}
    -- We currently don't allow nested types or consts, even though
    -- I believe Pascal does.  (None of the test .web files need them.)
    | not (null blockConstants)
        = error $ "function " ++ show (pretty funcName) ++ "has nested consts"
    | not (null blockConstants)
        = error $ "function " ++ show (pretty funcName) ++ "has nested types"
    | otherwise = braceBlock (generateFuncHeading funcName funcHeading)
        $ mapSemis declareVar blockVars
        $$ (wrapFuncRet funcName 
            $ compose (map wrapParam $ funcArgs funcHeading)
            $ vcat (map (generateStatement 
                            -- local labels shouldn't jump out of
                            -- this function
                            (jmpLabels \\ blockLabels))
                        blockStatements))

compose :: [a -> a] -> a -> a
compose fs x = foldr (.) id fs $ x

wrapFuncRet :: Func -> Doc -> Doc
wrapFuncRet f@Func {funcVarHeading=FuncHeading {funcReturnType=r}} d
    = case r of
        Nothing -> d
        Just t -> let v = FuncReturn f t
                  in cType t (pretty v) <> semi
                        $$ d
                        $$ text "return" <+> pretty v <> semi

generateFuncHeading :: Func -> FuncHeading Scoped Ordinal -> Doc
generateFuncHeading funcName FuncHeading {..} = let
    ret = maybe (text "void" <+>) cType funcReturnType
    args = parens $ commaList $ map generateParam funcArgs
    in ret $ pretty funcName <> args

generateParam :: FuncParam Scoped Ordinal -> Doc
generateParam FuncParam {..}
    | not paramByRef = declareVar (paramName, paramType)
    | otherwise = cType paramType (star <> paramArg paramName)

wrapParam :: FuncParam Scoped Ordinal -> Doc -> Doc
wrapParam FuncParam {..} d
    | not paramByRef = d
    | otherwise
        =   declareVar (paramName, paramType) <> semi
            $$ pretty paramName <+> equals <+> star <> paramArg paramName <> semi
            $$ d
            $$ star <> paramArg paramName <+> equals <+> pretty paramName <> semi

paramArg :: Var -> Doc
paramArg v = pretty v <> pretty "_arg"

generateStatement :: [Label] -> Statement Scoped -> Doc
generateStatement ls (Nothing, s) = generateStatementBase ls s <> semi
generateStatement ls (Just l, s) = hang (labelID l <> colon) 2
                                    $ generateStatementBase ls s
                                        <> semi

generateStatementBase :: [Label] -> StatementBase Scoped -> Doc
generateStatementBase jmpLabels s = case s of
    AssignStmt v e
        -> generateRef v <+> equals <+> generateExpr e
    ProcedureCall (DefinedFunc f) args -> callFunction f args
    ProcedureCall (BuiltinFunc f) args -> generateBuiltin f args
    IfStmt {..} -> braceBlock (text "if"
                                <+> parens (generateExpr ifCond))
                    (generateStatement jmpLabels thenStmt)
                    $+$ case elseStmt of
                          Nothing -> mempty
                          Just s -> braceBlock (text "else")
                                        (generateStatement jmpLabels s)
    ForStmt {..}
        -> braceBlock (text "for" <+> parens
                        (forHead loopVar forStart
                            forEnd forDirection))
                $ generateStatement jmpLabels forBody
    WhileStmt {..}
        -> braceBlock (text "while" <+> parens
                            (generateExpr loopExpr))
                $ generateStatement jmpLabels loopStmt
    RepeatStmt {..}
        -> braceBlock (text "do")
            (vcat (map (generateStatement jmpLabels) loopBody))
            <> text "while"
            <+> parens (generateExpr (NotOp loopExpr))
    CaseStmt {..} -> braceBlock
                        (text "switch" <+> parens (generateExpr caseExpr))
                        $ vcat (map (generateCase jmpLabels) caseList)
    Goto l
        | l `elem` jmpLabels -> text "longjmp"
                                    <+> paramList [labelBuf l, pretty "1"]
        | otherwise -> text "goto" <+> labelID l
    Write {..} -> generateWrite addNewline writeArgs
    CompoundStmt s -> vcat (map (generateStatement jmpLabels) s)
    EmptyStatement -> empty

forHead :: VarID Scoped -> Expr Scoped -> Expr Scoped -> ForDir
        -> Doc
forHead i start end UpTo
    = pretty i <> equals <> pretty start <> semi
        <+> pretty i <> text "<=" <> pretty end <> semi
        <+> pretty i <> text "++"
forHead i start end DownTo
    = pretty i <> equals <> pretty start <> semi
        <+> pretty i <> text ">=" <> pretty end <> semi
        <+> pretty i <> text "--"

generateCase :: [Label] -> CaseElt Scoped -> Doc
generateCase jmpLabels CaseElt {..} = hang cases 2 statements
  where
    cases = vcat $ map (<> colon)
            $ map (maybe (text "default") mkCase) caseConstants
    mkCase (ConstInt k) = text "case " <> pretty k
    mkCase c = error $ "can't handle case " ++ show (pretty c)
    statements = generateStatement jmpLabels caseStmt $$ text "break;"

generateExpr :: Expr Scoped -> Doc
generateExpr e = case e of
    ConstExpr c -> generateConstValue c
    VarExpr (DeRef v) -> pretty "pascal_peekc" <> parens (generateRef v)
    VarExpr v -> generateRef v
    FuncCall (DefinedFunc f) es -> callFunction f es
    FuncCall (BuiltinFunc f) es -> generateBuiltin f es
    -- TODO: is this right?
    -- Treating Divide as always producing a real output.
    BinOp x Divide y -> castFloat (generateExpr x)
                            <> cOp Divide <> castFloat (generateExpr y)
    BinOp x o y -> parens (generateExpr x) 
                        <> cOp o <> parens (generateExpr y)
    NotOp e -> text "!" <> parens (generateExpr e)
    Negate e -> text "-" <> parens (generateExpr e)

callFunction :: Func -> [Expr Scoped] -> Doc
callFunction f es = pretty f
                <> parens (commaList $ zipWith generateParamExpr
                                                (funcArgs (funcVarHeading f))
                                                es)
  where
    generateParamExpr FuncParam {..} e
        | paramByRef = text "&" <> parens (generateExpr e)
        | otherwise = generateExpr e

castFloat :: Doc -> Doc
castFloat e = text "(float)" <> parens e

generateConstValue :: ConstValue -> Doc
generateConstValue (ConstInt n) = pretty n
generateConstValue (ConstString [c]) = text $ show c
-- quote/escape using the Show Char and Show String instances
generateConstValue (ConstString s) = text $ show s
generateConstValue (ConstReal r)
    = pretty $ showFFloat Nothing (realToFrac r :: Double) ""

generateRef :: VarReference Scoped -> Doc
generateRef (NameRef v) = pretty v
generateRef (ArrayRef v es)
    = parens (generateRef v) <> arrayAccess v es
generateRef (RecordRef v n) = parens (generateRef v) <> text "." <> pretty n
generateRef (DeRef v) = text "[FILEREF]" -- error "file refs not implemented"

-- TODO: check it's the right number of indices
arrayAccess :: VarReference Scoped -> [Expr Scoped] -> Doc
arrayAccess v es
    | ArrayType {..} <- inferRefTypeNonConst v
        = hcat $ map brackets $ zipWith ordAccess arrayIndexType
                                $ map generateExpr es
    | otherwise = error ("accessing " ++ show (pretty v) ++ " as array")

ordAccess :: Ordinal -> Doc -> Doc
ordAccess o e
    | ordLower o == 0 = e
    | otherwise = parens e <> text "-" <> pretty (ordLower o)

cOp:: BinOp -> Doc
cOp Plus = text "+"
cOp Minus = text "-"
cOp Times = text "*"
cOp Divide = text "/"
cOp Div = text "/" -- todo: negative?
cOp Mod = text "%"
cOp Or = text "||"
cOp And = text "&&"
cOp OpEQ = text "=="
cOp NEQ = text "!="
cOp OpLT = text "<"
cOp LTEQ = text "<="
cOp OpGT = text ">"
cOp GTEQ = text ">="


--------------------

generateWrite :: Bool -> [WriteArg Scoped] -> Doc
generateWrite addNewline writeArgs = case writeArgs of
    w:ws | FileType t <- inferExprType (writeExpr w)
            , t `elem` map BaseType [IntegralType, CharType]
        -> text "fprintf"
            <> parens (commaList $ generateExpr (writeExpr w) : printfArgs ws)
    _ -> text "printf" <> parens (commaList $ printfArgs writeArgs)
  where
    printfArgs ws = let (fs,xs) = unzip (map mkArg ws)
                    in doubleQuotes (pretty $ concat fs ++ endLine)
                        : xs
    endLine = if addNewline then "\\n" else ""
    mkArg :: WriteArg Scoped -> (String,Doc)
    mkArg WriteArg {..} = case inferExprType writeExpr of
        BaseType StringType -> ("%s", generateExpr writeExpr)
        BaseType CharType -> ("%c", generateExpr writeExpr)
        BaseType IntegralType -> case widthAndDigits of
            Nothing -> ("%d",generateExpr writeExpr)
            Just (k,Nothing) 
                -> ("%" ++ show (extractConstInt k) ++ "d"
                   , generateExpr writeExpr)
            Just (k,Just d)
                -> ("%" ++ show (extractConstInt k) ++ "."
                    ++ show (extractConstInt d) ++ "f"
                , castFloat $ parens (generateExpr writeExpr))
        RealType -> let
            f = case widthAndDigits of
                    Nothing -> "%f"
                    Just (k,Nothing) ->  "%" ++ show (extractConstInt k)
                                            ++ "f"
                    Just (k,Just d) -> "%" ++ show (extractConstInt k)
                                    ++ "."
                                    ++ show (extractConstInt d)
                                    ++ "f"
            in (f, generateExpr writeExpr)
        _ -> error ("Unknown type for write arg: "
                            ++ show (pretty writeExpr))

extractConstInt :: Expr Scoped -> Integer
extractConstInt (ConstExpr (ConstInt n)) = n
extractConstInt (VarExpr (NameRef Const {varValue = ConstInt n})) = n
extractConstInt c = error ("unable to get constant int from expression "
                            ++ show (pretty c))

generateBuiltin :: Name -> [Expr Scoped] -> Doc
generateBuiltin "chr" [e] = generateExpr e
generateBuiltin "reset" (e:es) = openForRead e es
generateBuiltin "rewrite" (e:es) = openForWrite e es
generateBuiltin "eof" [e] = pretty "pascal_eof" <> paramList [generateExpr e]
generateBuiltin "eoln" [e] = pretty "pascal_eoln" <> paramList [generateExpr e]
generateBuiltin "read" (f:es) = readVars f es
generateBuiltin "read_ln" [VarExpr (NameRef f)]
                = pretty "pascal_readln" <> paramList [pretty f]
generateBuiltin "get" [f] = pretty "(void)getc" <> paramList [f]
-- set_pos/cur_pos are Knuth-isms, rather than standard pascal.
generateBuiltin "set_pos" [f,p] = pretty "pascal_setpos" <> paramList [pretty f, generateExpr p]
generateBuiltin "abs" [x] = pretty "ABS" <> paramList [x]
generateBuiltin "trunc" [x] = pretty "TRUNC" <> paramList [x]
generateBuiltin "round" [x] = pretty "round" <> paramList [x]
generateBuiltin "cur_pos" [f] = pretty "pascal_curpos" <> paramList [f]
-- The WEB break function 
generateBuiltin "break" [e] = empty
generateBuiltin "page" [] = empty -- used only in primes.web
generateBuiltin "web2hs_find_cached" es
    = pretty "web2hs_find_cached" <> paramList (map generateExpr es)
generateBuiltin f _ = error $ "unknown builtin " ++ show f   

openForRead :: Expr Scoped -> [Expr Scoped] -> Doc
openForRead f es = pretty f <+> equals <+> case es of
    [] | VarExpr (NameRef v) <- f -> openForRead (progGlobalVar v)
    [ConstExpr (ConstString "TTY:")] -> text "stdin"
    [e] -> openForRead (generateExpr e)
  where
    openForRead path = text "fopen"
                        <> paramList [path, doubleQuotes (text "r")]

openForWrite :: Expr Scoped -> [Expr Scoped] -> Doc
openForWrite f es = pretty f <+> equals <+> case es of
    [] | VarExpr (NameRef v) <- f -> openForWrite (progGlobalVar v)
    [ConstExpr (ConstString "TTY:")] -> text "stdout"
    [e] -> openForWrite (generateExpr e)
  where
    openForWrite path = text "fopen"
                                <> paramList [path,doubleQuotes (text "w")]

readVars :: Expr Scoped -> [Expr Scoped] -> Doc
readVars (VarExpr (NameRef f)) es
    | FileType t <- varType f, t `notElem` byteTypes
        = error $ "readVars: file type of " ++ show (pretty f)
    | any (not . isByteVar) es
        = error $ "readVars: not byte types: " ++ show (map pretty es)
    | otherwise = semicolonList
                    [ pretty e <> text " = getc" <> paramList [pretty f] | e <- es]

isByteVar :: Expr Scoped -> Bool
isByteVar (VarExpr (NameRef v)) = varType v `elem` byteTypes
isByteVar _ = False

byteTypes :: [Type Ordinal]
byteTypes = map BaseType [Ordinal 0 255, OrdinalChar]
