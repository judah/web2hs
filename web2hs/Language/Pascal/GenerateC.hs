module Language.Pascal.GenerateC where

import Language.Pascal.Syntax
import Language.Pascal.Pretty
import Language.Pascal.Typecheck
import Text.PrettyPrint.HughesPJ
import Data.Monoid hiding ( (<>) )
import Numeric
import Data.Maybe (catMaybes, isNothing)

-- TODO: elim extraneous parens

-- TODO: use better types for short ints

{-
Type mapping:
local arrays -> C stack arrays
global arrays -> dynamically allocated ptr
strings -> C strings (they're constants)

ranged values:
    - uint_8,
    - int_8
    - uint_16
    - int_16
    - uint_32
    - int_32

character/byte files:

typedef struct {
    char nextChar;
    FILE *file;
} pascal_text_file;

typedef struct {
    void *nextElt;



-}


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

cRecordType fs = text "struct" <+> braces (semilistOneLine $ map cField fs)
  where
    cField (n,t) = cType t (pretty n) 

cRetType :: OrdType -> Doc
cRetType (BaseType o) = text "int"
cRetType RealType = text "float"
cRetType t = error $ "return type not implemented: " ++ show (pretty t)

braceBlock :: Doc -> Doc -> Doc
braceBlock head body = (head <+> text "{") $+$ nest 2 body
                            $+$ text "}"


generateProgram :: Program Scoped Ordinal -> Doc
generateProgram Program {progBlock = Block{..},..} = let
    head = pretty "void" <+> pretty progName 
            <> parens (commaList [text "char *" <> progArgVar p | p <- progArgs])
    jmpLabels = blockLabels
    body = programStatements jmpLabels blockStatements
    in headerIncludes
        $$ mapSemis declareConstant blockConstants
        $$ mapSemis declareRecordType [(n,fs) | (n,RecordType {recordFields=fs})
                                                <- blockTypes]
        $$ mapSemis declareVar blockVars
        $$ mapSemis (\p -> text "char *" <> progGlobalVar p) progArgs
        $$ mapSemis (\l -> text "jmp_buf" <+> labelBuf l) jmpLabels
        $$ vcat (map (generateFunction jmpLabels) blockFunctions)
        $$ braceBlock head 
            (mapSemis (\p -> progGlobalVar p <+> equals <+> progArgVar p) progArgs
                $$ body)

mapSemis :: (a -> Doc) -> [a] -> Doc
mapSemis f xs = vcat $ map (\x -> f x <> semi) xs

headerIncludes = text "#include \"builtins.h\""
                $$ text "#include <setjmp.h>"

-- Labels come in two varieties:
-- 1) most goto/labels are local to a single function, and map directly
--    to C labels.
-- 2) Some error-recovery labels are defined in the main program and then
--    other functions goto them.  We need to use setjmp/longjmp for them.
--    This is relatively safe since the main program function
--    doesn't define any local variables.
-- As a result, the statement-generating code passes around a list of labels
-- which should be jumped to via longjmp instead of via goto.
labelID :: Label -> Doc
labelID l = text "label_" <> pretty l

labelBuf :: Label -> Doc
labelBuf l = text "label_" <> pretty l <> text "_buf"

progArgVar v = pretty v <> text "_progArg"
progGlobalVar v = pretty v <> text "_progGlobal"

declareConstant (v,c)
    = text "const" <+> constType c <+> pretty v <+> equals 
        <+> generateConstValue c
  where
    constType (ConstInt _) = text "int" -- TODO
    constType (ConstReal _) = text "float"
    constType (ConstString _) = text "char*"

declareVar (v,t) = cType t (pretty v)

declareRecordType (n,fs) = text "typedef" <+> cType (RecordType Nothing fs)
                                                (pretty n)

programStatements :: [Label] -> [Statement Scoped] -> Doc
programStatements jmpLabels ss = loop (reverse ss)
  where
    loop [] = empty
    loop ((Nothing,s):ss)
        = loop ss $$ generateStatementBase jmpLabels s <> semi
    loop ((Just l,s):ss)
        = braceBlock (jmpTest l) (loop ((Nothing,s):ss))
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
            $ vcat (map (generateStatement jmpLabels) blockStatements))


wrapFuncRet :: Func -> Doc -> Doc
wrapFuncRet f@Func {funcVarHeading=FuncHeading {funcReturnType=r}} d
    = case r of
        Nothing -> d
        Just t -> let v = FuncReturn f t
                  in cType t (pretty v) <> semi
                        $$ d
                        $$ text "return" <+> pretty v <> semi

-- TODO: params by ref

generateFuncHeading funcName FuncHeading {..} = let
    ret = maybe (text "void") cRetType funcReturnType
    args = parens $ commaList $ map generateParam funcArgs
    in ret <+> pretty funcName <> args

generateParam FuncParam {..} = declareVar (paramName, paramType)

generateStatement :: [Label] -> Statement Scoped -> Doc
generateStatement ls (Nothing, s) = generateStatementBase ls s <> semi
generateStatement ls (Just l, s) = hang (labelID l <> colon) 2
                                    $ generateStatementBase ls s
                                        <> semi

generateStatementBase jmpLabels s = case s of
    AssignStmt v e
        -> generateRef v <+> equals <+> generateExpr e
    ProcedureCall (DefinedFunc f) args
        -> pretty f <> parens (commaList $ map generateExpr args)
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
    FuncCall (DefinedFunc f) es
                -> pretty f <> parens (commaList $ map generateExpr es)
    FuncCall (BuiltinFunc f) es -> generateBuiltin f es
    -- TODO: is this right?
    -- Treating Divide as always producing a real output.
    BinOp x Divide y -> castFloat (generateExpr x)
                            <> cOp Divide <> castFloat (generateExpr y)
    BinOp x o y -> parens (generateExpr x) 
                        <> cOp o <> parens (generateExpr y)
    NotOp e -> text "!" <> parens (generateExpr e)
    Negate e -> text "-" <> parens (generateExpr e)

castFloat e = text "(float)" <> parens e

generateConstValue (ConstInt n) = pretty n
generateConstValue (ConstString [c]) = text $ show c
-- quote/escape using the Show Char and Show String instances
generateConstValue (ConstString s) = text $ show s
generateConstValue (ConstReal r)
    = pretty $ showFFloat Nothing (realToFrac r :: Double) ""

generateRef :: VarReference Scoped -> Doc
generateRef (NameRef v) = pretty v
-- TODO: correct access for ordinal types not starting at zero
-- TODO: more general arrays
generateRef (ArrayRef (NameRef v) es)
    = parens (pretty v) <> arrayAccess v es
generateRef (RecordRef v n) = parens (pretty v) <> text "." <> pretty n
generateRef (DeRef v) = text "[FILEREF]" -- error "file refs not implemented"
generateRef _ = error "refs not implemented yet"

-- TODO: check it's the right number of indices
arrayAccess :: Var -> [Expr Scoped] -> Doc
arrayAccess v es
    | ArrayType {..} <- varType v
        = hcat $ map brackets $ zipWith ordAccess arrayIndexType
                                $ map generateExpr es
    | otherwise = error ("accessing " ++ varName v ++ " as array")

ordAccess o e
    | ordLower o == 0 = e
    | otherwise = parens e <> text "-" <> pretty (ordLower o)

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

-- TODO: more general
-- For now (TODO I do more now)
-- - either a const string or an integer
-- - no widths
-- - no escaping for strings

generateWrite :: Bool -> [WriteArg Scoped] -> Doc
generateWrite addNewline writeArgs = case writeArgs of
    -- TODO: what if record type, or non-byte
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
generateBuiltin f _ = error $ "unknown builtin " ++ show f   

openForRead :: Expr Scoped -> [Expr Scoped] -> Doc
openForRead f es = pretty f <+> equals <+> case es of
    [] | VarExpr (NameRef v) <- f -> openForRead (progGlobalVar v)
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

isByteVar (VarExpr (NameRef v)) = varType v `elem` byteTypes
isByteVar _ = False

byteTypes = map BaseType [Ordinal 0 255, OrdinalChar]
