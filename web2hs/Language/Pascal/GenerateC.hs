module Language.Pascal.GenerateC where

import Language.Pascal.Syntax
import Language.Pascal.Pretty
import Language.Pascal.Typecheck
import Text.PrettyPrint.HughesPJ
import Data.Monoid hiding ( (<>) )
import Numeric
import Data.List ((\\))
import Foreign.C.Types (CChar)

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
cType (BaseType o) v = text (ordinalCName o) <+> v
cType RealType v = text "float" <+> v
cType ArrayType {..} v
    = cType arrayEltType 
        (v <> hcat (map (brackets . pretty . ordSize)
                                    arrayIndexType))
cType (FileType _) v = text "FILE *" <+> v
cType (PointerType t) v = cType t (text "*" <> v)
cType RecordType { recordName = Just n } v = pretty n <+> v
cType RecordType { ..} v = cRecordType recordFields <+> v

ordinalCName :: Ordinal -> String
ordinalCName OrdinalChar = "char"
ordinalCName (Ordinal l h)
    | l > h = error $ "ordinalCName: low is less than high: " ++ show (l,h)
    | inRange 0 (2^8) = "uint8_t"
    | inRange 0 (2^16) = "uint16_t"
    | inRange 0 (2^32) = "uint32_t"
    | inRange (-2^7) (2^7) = "int8_t"
    | inRange (-2^15) (2^15) = "int16_t"
    | inRange (-2^31) (2^31) = "int32_t"
    | otherwise = error $ "ordinalCName: range too big: " ++ show (l,h)
  where
    inRange low hi = l >= low && h < hi

ordSize :: Ordinal -> Integer
ordSize o = ordUpper o - ordLower o + 1

-- Since we're translating Pascal chars as C "char",
-- which may be either signed or unsigned, we use the Haskell CChar type
-- to determine its bounds.
ordLower, ordUpper :: Ordinal -> Integer
ordLower (Ordinal l _) = l
ordLower OrdinalChar = fromIntegral (minBound :: CChar)
ordUpper (Ordinal _ u) = u
ordUpper OrdinalChar = fromIntegral (maxBound :: CChar)



{- Record type translation:

two_halves=packed record rh:halfword;
case two_choices of 1:(lh:halfword);2:(b0:quarterword;b1:quarterword);
end

becomes:

struct {
    halfword rh;
    union {
        struct {halfword lh;} var1;
        struct {
            quarterword b0;
            quarterword b1;
        } var2;
    } variant;
};

-}

cRecordType :: FieldList Ordinal -> Doc
cRecordType FieldList {..}
    = braceBlock (text "struct") (
                mapSemis cField fixedPart
                $$ maybe empty unionType variantPart)
  where
    cField (n,t) = cType t (prettyField n) 
    unionType Variant {..}
        = braceBlock (text "union") (mapSemis vField variantFields)
                <+> text "variant" <> semi
    vField (i,fs) = braceBlock (text "struct") (mapSemis cField fs)
                        <+> text "var" <> pretty i

prettyField :: Name -> Doc
prettyField "int" = text "int_"
prettyField n = text n

star :: Doc
star = text "*"

declareConstant :: (Var,ConstValue) -> Doc
declareConstant (v,c)
    = text "const" <+> constType c <+> pretty v <+> equals 
        <+> generateConstValue c
  where
    constType (ConstInt _) = text "int" -- TODO
    constType (ConstReal _) = text "float"
    constType (ConstChar _) = text "char"
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
        $$ text "#include <stdint.h>" -- for u_int8,etc.
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
    | otherwise = pretty v <+> equals <+> progArgVar v

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
progArgType c@Const{..} _ = error $ "progArgType: shouldn't happen: constant arg "
                            ++ show (pretty c)

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
programStatements jmpLabels = loop . reverse
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
    AssignStmt (VLValue v) e
        -> generateRef v <+> equals <+> generateExpr e
    AssignStmt (FLValue f) e
        -> pretty f <+> equals <+> generateExpr e
    ProcedureCall (DefinedFunc f) args -> callFunction f args
    ProcedureCall (BuiltinFunc f) args -> generateBuiltin f args
    IfStmt {..} -> braceBlock (text "if"
                                <+> parens (generateExpr ifCond))
                    (generateStatement jmpLabels thenStmt)
                    $+$ case elseStmt of
                          Nothing -> mempty
                          Just s' -> braceBlock (text "else")
                                        (generateStatement jmpLabels s')
    ForStmt {..} -> forStmt loopVar forStart forEnd forDirection
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
    CompoundStmt s' -> vcat (map (generateStatement jmpLabels) s')
    EmptyStatement -> empty

{-
For statements:

To translate
    var i:0..255;
    for i:=0 to 255; do ...;
we can't just use
    for (i=0; i<=255; i++)
since i<=255 will always succeed.

Instead, use:
    i=0;
    if (i<=255) do {
        ...
    } while (i++ < 255);
    i = 255;

We need the ending "i=255" since otherwise "i" ends up incremented
one *past* the final value.

We can omit the initial "if" test in most cases where the for loop bounds
are constants.
-}

forStmt :: VarID Scoped -> Expr Scoped -> Expr Scoped -> ForDir -> Doc -> Doc
forStmt i start end dir stmt
    = pretty i <> equals <> generateExpr start <> semi
    $$ braceBlock (
        whenD needInitialCheck
                (text "if" <+> parens (pretty i <> cmpEq <> generateExpr end) )
            <+> text "do")
        stmt
        <+> text "while" 
        <+> parens (pretty i <> adv <+> cmpNEq <> generateExpr end) <> semi
    $$ pretty i <+> equals <+> generateExpr end <> semi
  where
    (low,hi,cmpEq,cmpNEq,adv) = case dir of
        UpTo -> (start,end,text "<=", text "<", text "++")
        DownTo -> (end,start,text ">=", text ">", text "--")
    -- Check whether the loop is guaranteed to run at least once.
    -- (If not, we can omit the initial "if" tet.)
    -- We know it must if the low and hi are constants and low<=hi.
    -- (Omitting it prevents warnings from gcc that the test is
    --  guaranteed to succeed.)
    needInitialCheck
        | ConstExpr (ConstInt k1) <- low
        , ConstExpr (ConstInt k2) <- hi
        , k1<=k2    = False
        | otherwise = True

whenD :: Bool -> Doc -> Doc
whenD True x = x
whenD False _ = empty


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
    -- Pascal treats Divide as always producing a real output.
    -- C throws out the remainder when dividing two integers.
    -- So to keep the remainder, we first cast the inputs to floats.
    BinOp x Divide y -> castFloat (generateExpr x)
                            <> cOp Divide <> castFloat (generateExpr y)
    BinOp x o y -> parens (generateExpr x) 
                        <> cOp o <> parens (generateExpr y)
    NotOp x -> text "!" <> parens (generateExpr x)
    Negate x -> text "-" <> parens (generateExpr x)

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
-- quote/escape using the Show Char and Show String instances
generateConstValue (ConstChar c) = text $ show c
generateConstValue (ConstString s) = text $ show s
generateConstValue (ConstReal r)
    = pretty $ showFFloat Nothing (realToFrac r :: Double) ""

generateRef :: VarReference Scoped -> Doc
generateRef (NameRef v) = pretty v
generateRef (ArrayRef v es)
    = parens (generateRef v) <> arrayAccess v es
generateRef (RecordRef v n) = parens (generateRef v) <> text "."
                                <> recordAccess v n
generateRef (DeRef _) = error "generateRef: file refs not implemented."

-- TODO: check it's the right number of indices
arrayAccess :: VarReference Scoped -> [Expr Scoped] -> Doc
arrayAccess v es = case inferRefType v of
        RefType ArrayType {..}  -> indexed $ zipWith ordAccess arrayIndexType
                                $ map generateExpr es
        -- Pointers are zero-indexed.
        RefType (PointerType _)   -> indexed $ map generateExpr es
        _               -> error ("accessing " ++ show (pretty v) ++ " as array")
  where
    indexed = hcat . map brackets

ordAccess :: Ordinal -> Doc -> Doc
ordAccess o e
    | ordLower o == 0 = e
    | otherwise = parens e <> text "-" <> parens (pretty (ordLower o))

recordAccess :: VarReference Scoped -> Name -> Doc
recordAccess v n
    | RefType RecordType {..} <- inferRefType v
        = case lookupField n recordFields of
            Just (Left _) -> prettyField n
            Just (Right (k,_)) -> text "variant.var" <> pretty k
                                        <> text "." <> prettyField n
            Nothing -> error $ "can't find field " ++ show n
    | otherwise = error $ "not a record: " ++ show (pretty v)


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
    w:ws | FileType _ <- inferExprType (writeExpr w)
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
        BaseType CharType -> ("%c", generateExpr writeExpr)
        BaseType UnrangedInt -> case widthAndDigits of
            Nothing -> ("%c",generateExpr writeExpr)
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
        PointerType _ -> ("%s", generateExpr writeExpr)
        -- The ArrayType and FileType cases never appear in TeX-and-friends,
        -- but they're useful for debugging.
        -- Note that the ArrayType case assumes the array contains
        -- a null character.
        ArrayType _ (BaseType CharType) ->
                ("%s",generateExpr writeExpr)
        FileType _ -> ("%p", generateExpr writeExpr);
        _ -> error $ "Unknown write expression: " ++ show (pretty writeExpr)

extractConstInt :: Expr Scoped -> Integer
extractConstInt (ConstExpr (ConstInt n)) = n
extractConstInt (VarExpr (NameRef Const {constValue=ConstInt n})) = n
extractConstInt c = error ("unable to get constant int from expression "
                            ++ show (pretty c))

generateBuiltin :: Name -> [Expr Scoped] -> Doc
-- Since C chars may be signed, we must cast int->char with (char), which
-- intentionally overflows 255:int to -1:char.
-- This way, for example:
--   var xord: array[char] of integer;
--   xord[chr(255)]
-- will be translated as
--   xord[(char)(255) - (-128)] 
--   === xord[-1 + 128]
--   === xord[127]
-- which is correct, since the char type is -128..127
-- and 255==-1 is the 128th entry in that list.
generateBuiltin "chr" [e] = cFunc "(char)" [e]
generateBuiltin "reset" (e:es) = openForRead e es
generateBuiltin "rewrite" (e:es) = openForWrite e es
generateBuiltin "eof" [e] = cFunc "pascal_eof" [e]
generateBuiltin "eoln" [e] = cFunc "pascal_eoln" [e]
generateBuiltin "erstat" [e] = cFunc "ERSTAT" [e]
generateBuiltin "close" [e] = cFunc "fclose" [e]
generateBuiltin "read" (f:es)
    = flip mapSemis es $ \e -> generateExpr e <+> equals <+> cFunc "getc" [f]
generateBuiltin "read_ln" [f] = cFunc "pascal_readln" [f]
generateBuiltin "get" [f] = cFunc "(void)getc" [f]
generateBuiltin "readBinary" [f,e,k]
    = cFuncDoc "read" [cFunc "fileno" [f], text "&" <> parens (generateExpr e)
                                 , generateExpr k]
generateBuiltin "writeBinary" [f,e,k]
    = cFuncDoc "write" [cFunc "fileno" [f], text "&" <> parens (generateExpr e)
                                  , generateExpr k]
generateBuiltin "writeInt32" [f,e] = cFunc "pascal_write32" [f,e]
-- set_pos/cur_pos are Knuth-isms, rather than standard pascal.
generateBuiltin "set_pos" [f,p] = cFunc "pascal_setpos" [f,p]
generateBuiltin "abs" [x] = cFunc "ABS" [x]
generateBuiltin "odd" [x] = cFunc "ODD" [x]
generateBuiltin "trunc" [x] = cFunc "TRUNC" [x]
generateBuiltin "round" [x] = cFunc "round" [x]
generateBuiltin "cur_pos" [f] = cFunc "pascal_curpos" [f]
-- The WEB break function 
generateBuiltin "break" [f] = cFunc "fflush" [f]
generateBuiltin "break_in" (f:_) = cFunc "fflush" [f]
generateBuiltin "page" [] = empty -- used only in primes.web
generateBuiltin "web2hs_find_cached" es = cFunc "web2hs_find_cached" es
generateBuiltin f es = error $ "unknown builtin " ++ show f   
                                ++ show (map pretty es)

cFunc :: Name -> [Expr Scoped] -> Doc
cFunc f = cFuncDoc f . map generateExpr

cFuncDoc :: Name -> [Doc] -> Doc
cFuncDoc f es = pretty f <> parens (commaList es)

openForRead :: Expr Scoped -> [Expr Scoped] -> Doc
openForRead f es = pretty f <+> equals <+> case es of
    [] | VarExpr (NameRef v) <- f -> fopen (progGlobalVar v)
    (ConstExpr (ConstString "TTY:"):_) -> text "stdin"
    [e] -> fopen (generateExpr e)
    [e,ConstExpr (ConstString "/O")] -> fopen (generateExpr e)
    _ -> error $ "openForRead: unrecognized arguments: " ++ show (map pretty es)
  where
    fopen path = cFuncDoc "fopen" [path, doubleQuotes (text "r")]

openForWrite :: Expr Scoped -> [Expr Scoped] -> Doc
openForWrite f es = pretty f <+> equals <+> case es of
    [] | VarExpr (NameRef v) <- f -> fopen (progGlobalVar v)
    (ConstExpr (ConstString "TTY:"):_) -> text "stdout"
    [e] -> fopen (generateExpr e)
    [e,ConstExpr (ConstString "/O")] -> fopen (generateExpr e)
    _ -> error $ "openForRead: unrecognized arguments: " ++ show (map pretty es)
  where
    fopen path = cFuncDoc "fopen" [path,doubleQuotes (text "w")]
