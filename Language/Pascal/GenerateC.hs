module Language.Pascal.GenerateC where

import Language.Pascal.Syntax
import Language.Pascal.Pretty
import Text.PrettyPrint.HughesPJ
import Data.Monoid hiding ( (<>) )
import Numeric
import Data.Maybe (catMaybes)

-- TODO: elim extraneous parens

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
cType (BaseType o) v = text "int" <+> v -- TODO: be more careful
cType RealType v = text "float" <+> v
cType ArrayType {..} v
    = cType arrayEltType 
        (v <> hcat (map (brackets . pretty . ordSize)
                                    arrayIndexType))
cType (FileType b) v = case b of
    BaseType (Ordinal 0 255) -> text "pascal_file" <+> v
cType t _ = error ("unknown type: " ++ show t)

braceBlock :: Doc -> Doc -> Doc
braceBlock head body = (head <+> text "{") $+$ nest 2 body
                            $+$ text "}"


generateProgram :: Program Scoped Ordinal -> Doc
generateProgram Program {progBlock = Block{..},..} = let
    head = pretty "void" <+> pretty progName 
            <> parens (commaList
                [text "char *" <> pretty p | p <- progArgs])
    body = vcat $ map generateStatement blockStatements 
    in headerIncludes
        $$ mapSemis declareConstant blockConstants
        $$ mapSemis declareVar blockVars
        $$ braceBlock head body

mapSemis :: (a -> Doc) -> [a] -> Doc
mapSemis f xs = vcat $ map (\x -> f x <> semi) xs

headerIncludes = text "#include \"builtins.h\""

labelID :: Label -> Doc
labelID l = text "label_" <> pretty l

declareConstant (v,c)
    = text "const" <+> constType c <+> pretty v <+> equals 
        <+> generateConstValue c
  where
    constType (ConstInt _) = text "int" -- TODO
    constType (ConstReal _) = text "float"
    constType (ConstString _) = text "char*"

declareVar (v,t) = cType t (pretty v)

generateStatement (Nothing, s) = generateStatementBase s <> semi
generateStatement (Just l, s) = hang (labelID l <> colon) 2
                                    $ generateStatementBase s
                                        <> semi

generateStatementBase s = case s of
    AssignStmt v e
        -> generateRef v <+> equals <+> generateExpr e
    ProcedureCall f args
        -> pretty f <> parens (commaList $ map generateExpr args)
    IfStmt {..} -> braceBlock (text "if"
                                <+> parens (generateExpr ifCond))
                    (generateStatement thenStmt)
                    $+$ case elseStmt of
                          Nothing -> mempty
                          Just s -> braceBlock (text "else")
                                        (generateStatement s)
    ForStmt {..}
        -> braceBlock (text "for" <+> parens
                        (forHead loopVar forStart
                            forEnd forDirection))
                $ generateStatement forBody
    WhileStmt {..}
        -> braceBlock (text "while" <+> parens
                            (generateExpr loopExpr))
                $ generateStatement loopStmt
    RepeatStmt {..}
        -> braceBlock (text "do")
            (vcat (map generateStatement loopBody))
            <> text "while"
            <+> parens (generateExpr (NotOp loopExpr))
    CaseStmt {..} -> error "case statements not yet implemented"
    Goto l -> text "goto" <+> labelID l
    Write {..} -> generateWrite addNewline writeArgs
    CompoundStmt s -> vcat (map generateStatement s)
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


generateExpr :: Expr Scoped -> Doc
generateExpr e = case e of
    ConstExpr c -> generateConstValue c
    VarExpr v -> generateRef v
    FuncCall f es -> pretty f
                        <> parens (commaList $ map generateExpr es)
    BinOp x o y -> parens (generateExpr x) 
                        <> cOp o <> parens (generateExpr y)
    NotOp e -> text "!" <> parens (generateExpr e)
    Negate e -> text "-" <> parens (generateExpr e)

generateConstValue (ConstInt n) = pretty n
generateConstValue (ConstString s) = quotes (text s)
generateConstValue (ConstReal r)
    = pretty $ showFFloat Nothing (realToFrac r :: Double) ""

generateRef :: VarReference Scoped -> Doc
generateRef (NameRef v) = pretty v
-- TODO: correct access for ordinal types not starting at zero
-- TODO: more general arrays
generateRef (ArrayRef (NameRef v) es)
    = parens (pretty v) <> arrayAccess v es
generateRef (RecordRef _ _) = error "record refs not implemented"
generateRef (DeRef v) = error "file refs not implemented"
generateRef _ = error "refs not implemented yet"

-- TODO: check it's the right number of indices
arrayAccess :: Var -> [Expr Scoped] -> Doc
arrayAccess v es
    | ArrayType {..} <- varType v
        = hcat $ map brackets $ zipWith ordAccess arrayIndexType
                                $ map generateExpr es
    | otherwise = error ("accessing " ++ varName v ++ " as array")

ordAccess Ordinal {..} e
    | ordLower == 0 = e
    | otherwise = parens e <> text "-" <> pretty ordLower

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
-- For now:
-- - either a const string or an integer
-- - no widths
-- - no escaping for strings

generateWrite :: Bool -> [WriteArg Scoped] -> Doc
generateWrite addNewline writeArgs
    = text "printf" <> parens (commaList printfArgs)
  where
    printfArgs = doubleQuotes (pretty $ concat strArgs ++ endLine)
                    : catMaybes paramArgs
    endLine = if addNewline then "\\n" else ""
    (strArgs, paramArgs) = unzip $ map mkArg writeArgs
    mkArg WriteArg {writeExpr = ConstExpr (ConstString s)} = (s, Nothing)
    mkArg WriteArg {writeExpr = e, widthAndDigits = Just (k,Nothing)}
                            = ("%" ++ show (extractConstInt k) ++ "d"
                              , Just (generateExpr e))
    mkArg WriteArg {writeExpr = e, widthAndDigits = Nothing}
                            = ("%d", Just (generateExpr e))

extractConstInt :: Expr Scoped -> Integer
extractConstInt (ConstExpr (ConstInt n)) = n
extractConstInt (VarExpr (NameRef Const {varValue = ConstInt n})) = n
extractConstInt c = error ("unable to get constant int from expression "
                            ++ show (pretty c))
