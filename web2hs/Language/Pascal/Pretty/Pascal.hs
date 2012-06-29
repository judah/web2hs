module Language.Pascal.Pretty.Pascal(
        Pascal,
        prettyPascal,
        showPascal,
        ) where

import Language.Pascal.Syntax
import Language.Pascal.Pretty.Base

data Pascal

prettyPascal :: Pretty Pascal a => a -> Doc Pascal
prettyPascal = pretty

showPascal :: Pretty Pascal a => a -> String
showPascal = show . prettyPascal

class (Pretty Pascal (VarID s), Pretty Pascal (FuncID s),
        Pretty Pascal (FuncCallID s), Pretty Pascal (LValueRef s) )
    => PrettyID s

instance (Pretty Pascal (VarID s), Pretty Pascal (FuncID s),
        Pretty Pascal (FuncCallID s), Pretty Pascal (LValueRef s) )
    => PrettyID s

paramList :: Pretty Pascal a => [a] -> Doc Pascal
paramList [] = empty
paramList xs = parens $ commaList xs

semicolonList :: Pretty Pascal a => [a] -> Doc Pascal
semicolonList [] = empty
semicolonList [x] = pretty x
semicolonList (x:xs) = pretty x <> semi $$ semicolonList xs

semilistOneLine :: Pretty Pascal a => [a] -> Doc Pascal
semilistOneLine = sep . map (\d -> pretty d <> semi)

unlessNull :: [a] -> Doc t -> Doc t
unlessNull [] _ = empty
unlessNull _ d = d


instance (PrettyID v, Pretty Pascal t) => Pretty Pascal (Program v t) where
    pretty Program{..} = 
        myhang (pretty "program" <+> pretty progName <> paramList progArgs <> semi)
        (pretty progBlock)
        $$ pretty '.'
            


instance (PrettyID v, Pretty Pascal t) => Pretty Pascal (Block v t) where
    pretty Block {..} = vcat
        [ unlessNull blockLabels $ pretty "label" <+> commaList blockLabels <> semi
        , unlessNull blockConstants $ pretty "const" <+> semilistOneLine (map assign blockConstants)
        , unlessNull blockTypes $ pretty "type" <+> semilistOneLine (map assign blockTypes)
        , unlessNull blockVars $ pretty "var" <+> semilistOneLine (map assignT blockVars)
        , vcat (map pretty blockFunctions)
        , compound blockStatements
        ]

assign, assignT :: (Pretty Pascal a, Pretty Pascal b) => (a,b) -> Doc Pascal
assign (x,y) = pretty x <> equals <> pretty y
assignT (x,y) = pretty x <> colon <> pretty y


compound :: PrettyID v => StatementList v -> Doc Pascal
compound l = myhang (pretty "begin") (semicolonList l) $$ pretty "end"

instance (PrettyID v, Pretty Pascal t)
        => Pretty Pascal (FunctionDecl v t) where
    pretty FuncForward {..} = funcKind funcHeading 
                                <+> pretty funcName <+> pretty funcHeading
                                <> semi <+> pretty "forward"
    pretty FuncDecl {..} = myhang (funcKind funcHeading <+> pretty funcName <+> pretty funcHeading
                                <> semi) $ pretty funcBlock

funcKind :: Pretty Pascal t => FuncHeading v t -> Doc Pascal
funcKind FuncHeading {..} = case funcReturnType of
                                Nothing -> pretty "procedure"
                                Just _ -> pretty "function"

instance (PrettyID v, Pretty Pascal t)
        => Pretty Pascal (FuncHeading v t) where
    pretty FuncHeading{..} = args <+> returntype
      where
        returntype = maybe empty (\t -> pretty ':' <+> pretty t) funcReturnType
        args = if null funcArgs
                        then empty
                        else parens $ commaList funcArgs

instance (PrettyID v, Pretty Pascal t) => Pretty Pascal (FuncParam v t) where
    pretty FuncParam{..} = (if paramByRef then pretty "var" else empty)
                            <+> pretty paramName <> colon <> pretty paramType

instance PrettyID v => Pretty Pascal (Statement v) where
    pretty (Nothing,s) = pretty s
    pretty (Just l, s) = pretty l <> colon <+> pretty s

instance PrettyID v => Pretty Pascal (StatementBase v) where
    pretty AssignStmt {..} = pretty assignTarget <+> pretty ":=" <+> pretty assignExpr
    pretty ProcedureCall {..} = pretty funName <> parens (commaList procArgs)
    pretty ForStmt {..} = myhang
                            (pretty "for" <+> pretty loopVar 
                                <+> pretty ":=" 
                                <+> pretty forStart
                                <+> pretty forDirection
                                <+> pretty forEnd
                                <+> pretty "do")
                            (pretty forBody)
    pretty IfStmt {elseStmt = Nothing,..}
        = myhang (pretty "if" <+> pretty ifCond)
                (pretty "then" <+> pretty thenStmt)
    pretty IfStmt {elseStmt = Just s, ..}
        = myhang (pretty "if" <+> pretty ifCond)
                $ (pretty "then" <+> pretty thenStmt)
                 $$ (pretty "else" <+> pretty s)
    pretty RepeatStmt {..}
        = myhang (pretty "repeat") (semicolonList loopBody)
            $$ pretty "until" <+> (pretty loopExpr)
    pretty WhileStmt {..}
        = myhang (pretty "while" <+> pretty loopExpr) (pretty loopStmt)
    pretty CaseStmt {..} = (myhang (pretty "case" <+> pretty caseExpr <+> pretty "of")
                            $ semicolonList caseList)
                            $$ pretty "end"
    -- TODO: This doesn't have a semicolon after it in a compound statement.
    pretty (Goto l) = pretty "goto" <+> pretty l
    pretty (CompoundStmt ss) = compound ss
    pretty Write {..} = pretty (if addNewline then "writeln" else "write")
                         <> parens (commaList writeArgs)
    pretty EmptyStatement = empty

instance PrettyID v => Pretty Pascal (WriteArg v) where
    pretty WriteArg {..} = pretty writeExpr
                            <> case widthAndDigits of
                                Nothing -> empty
                                Just (w,md) 
                                  -> colon <> pretty w
                                    <> case md of
                                        Nothing -> empty
                                        Just d -> colon <> pretty d

instance Pretty Pascal ForDir where
    pretty UpTo = pretty "to"
    pretty DownTo = pretty "downto"

instance PrettyID v => Pretty Pascal (VarReference v) where
    pretty (NameRef n) = pretty n
    pretty (ArrayRef n e) = pretty n <> brackets (commaList e)
    pretty (DeRef n) = pretty n <> pretty '^'
    pretty (RecordRef n f) = pretty n <> pretty '.' <> pretty f

instance PrettyID v => Pretty Pascal (CaseElt v) where
    pretty CaseElt {..} = myhang (commaList (map caseConst caseConstants)
                                    <> colon)
                            $ pretty caseStmt
        where
            caseConst Nothing = pretty "others"
            caseConst (Just e) = pretty e


instance PrettyID v => Pretty Pascal (Expr v) where
    pretty (ConstExpr c) = pretty c
    pretty (VarExpr v) = pretty v
    pretty (FuncCall n as) = pretty n <> 
                                if null as
                                    then parens empty
                                    else paramList as
    -- TODO: precendence
    pretty (BinOp e1 o e2) = parens $ pretty e1 <+> pretty o <+> pretty e2
    pretty (NotOp e) = parens $ pretty "not" <+> pretty e
    pretty (Negate e) = pretty '-' <> pretty e
    -- pretty (ArrayAccess n e) = pretty n <> brackets (commaList e)

instance Pretty Pascal BinOp where
    pretty Plus = pretty '+'
    pretty Minus = pretty '-'
    pretty Times = pretty '*'
    pretty Divide = pretty '/'
    pretty Div = pretty "div"
    pretty Mod = pretty "mod"
    pretty Or = pretty "or"
    pretty And = pretty "and"
    pretty OpEQ = pretty "="
    pretty NEQ = pretty "<>"
    pretty OpLT = pretty "<"
    pretty LTEQ = pretty "<="
    pretty OpGT = pretty ">"
    pretty GTEQ = pretty ">="

instance Pretty Pascal ConstValue where
    pretty (ConstInt n) = pretty n
    pretty (ConstReal n) = pretty n
    -- Pascal escapes a single-quote with a double-quote.
    pretty (ConstChar c) = pretty (ConstString [c])
    pretty (ConstString s) = quotes $ pretty $ concatMap escape s
      where
        escape '\'' = "''"
        escape c = [c]


----------------

instance Pretty Pascal NamedOrdinal where
    pretty (NamedType n) = pretty n
    pretty Range {..} = pretty lowerBound <> pretty ".." <> pretty upperBound

instance Pretty Pascal Bound where
    pretty (IntBound n) = pretty n
    pretty (NegBound b) = pretty b
    pretty (VarBound n) = pretty n

instance Pretty Pascal Ordinal where
    pretty (Ordinal l u) = pretty l <> pretty ".." <> pretty u
    pretty OrdinalChar = pretty "char"


instance Pretty Pascal t => Pretty Pascal (Type t) where
    pretty (BaseType t) = pretty t
    pretty RealType = pretty "real"
    pretty ArrayType {..} = pretty "array" <> brackets (commaList arrayIndexType)
                                <+> pretty "of" <+> pretty arrayEltType
    pretty FileType {..} = pretty "file" <+> pretty "of" <+> pretty fileEltType
    pretty (PointerType t) = pretty "^" <> pretty t
    pretty (RecordType _ FieldList {..})
            = myhang (pretty "record") internals $$ pretty "end"
      where
        internals = case variantPart of
                        Nothing -> prettyFields fixedPart
                        Just v
                            | null fixedPart -> prettyVariant v
                            | otherwise      -> prettyFields fixedPart
                                                    <> semi
                                                    $$ prettyVariant v

prettyFields :: Pretty Pascal t => Fields t -> Doc Pascal
prettyFields = semicolonList . map assignT

prettyVariant :: Pretty Pascal t => Variant t -> Doc Pascal
prettyVariant Variant {..} = myhang (pretty "case" <+> pretty variantSelector
                                        <+> pretty "of")
                                (semicolonList $ map fieldChoice variantFields)
    where
        fieldChoice (n,fs) = pretty n <> colon <+> prettyFields fs
                                


