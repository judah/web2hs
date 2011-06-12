module Language.Pascal.Pretty where

import Language.Pascal.Syntax
import Text.PrettyPrint.HughesPJ

class Pretty a where
    pretty :: a -> Doc
    prettyPrec :: Int -> a -> Doc
    pretty = prettyPrec 0
    prettyPrec  = const pretty

instance Pretty Doc where
    pretty = id

instance Pretty String where
    pretty = text

instance Pretty Integer where
    pretty = integer -- TODO: negative numbers

-----------------------

myhang x = hang x 2

instance Pretty Program where
    pretty Program{..} = 
        myhang (text "program" <+> pretty progName <> paramList progArgs <> semi)
        (pretty progBlock)
        $$ char '.'
            
paramList, commaList :: Pretty a => [a] -> Doc
paramList [] = empty
paramList xs = parens $ commaList xs

commaList [] = empty
commaList [x] = pretty x
commaList (x:xs) = pretty x <> comma <+> commaList xs


semicolonList :: Pretty a => [a] -> Doc
semicolonList [] = empty
semicolonList [x] = pretty x
semicolonList (x:xs) = pretty x <> semi $$ semicolonList xs

semilistOneLine :: Pretty a => [a] -> Doc
semilistOneLine = sep . map (\d -> pretty d <> semi)

unlessNull :: [a] -> Doc -> Doc
unlessNull [] _ = empty
unlessNull _ d = d


instance Pretty Block where
    pretty Block {..} = vcat
        [ unlessNull blockLabels $ text "label" <+> commaList blockLabels <> semi
        , unlessNull blockConstants $ text "const" <+> semilistOneLine (map assign blockConstants)
        , unlessNull blockTypes $ text "type" <+> semilistOneLine (map assign blockTypes)
        , unlessNull blockVars $ text "var" <+> semilistOneLine (map assignT blockVars)
        , vcat (map pretty blockFunctions)
        , compound blockStatements
        ]

assign, assignT :: (Pretty a, Pretty b) => (a,b) -> Doc
assign (x,y) = pretty x <> equals <> pretty y
assignT (x,y) = pretty x <> colon <> pretty y


compound :: StatementList -> Doc
compound l = myhang (text "begin") (semicolonList l) $$ text "end"

instance Pretty FunctionDecl where
    pretty FuncForward {..} = funcKind funcHeading 
                                <+> pretty funcName <+> pretty funcHeading
                                <> semi <+> text "forward"
    pretty Func {..} = (funcKind funcHeading <+> pretty funcName <+> pretty funcHeading
                                <> semi) $$ pretty funcBlock

funcKind :: FuncHeading -> Doc
funcKind FuncHeading {..} = case funcReturnType of
                                Nothing -> text "procedure"
                                Just _ -> text "function"

instance Pretty FuncHeading where
    pretty FuncHeading{..} = args <+> returntype
      where
        returntype = maybe empty (\t -> char ':' <+> pretty t) funcReturnType
        args = if null funcArgs
                        then empty
                        else parens $ commaList funcArgs

instance Pretty FuncParam where
    pretty FuncParam{..} = (if paramByRef then text "var" else empty)
                            <+> pretty paramName <> colon <> pretty paramType

instance Pretty Statement where
    pretty (Nothing,s) = pretty s
    pretty (Just l, s) = pretty l <> colon <+> pretty s

instance Pretty StatementBase where
    pretty AssignStmt {..} = pretty assignTarget <+> text ":=" <+> pretty assignExpr
    pretty ProcedureCall {..} = pretty funName <> parens (commaList procArgs)
    pretty ForStmt {..} = myhang
                            (text "for" <+> pretty loopVar 
                                <+> text ":=" 
                                <+> pretty forStart
                                <+> pretty forDirection
                                <+> pretty forEnd
                                <+> text "do")
                            (pretty forBody)
    pretty IfStmt {elseStmt = Nothing,..}
        = myhang (text "if" <+> pretty ifCond)
                (text "then" <+> pretty thenStmt)
    pretty IfStmt {elseStmt = Just s, ..}
        = myhang (text "if" <+> pretty ifCond)
                $ (text "then" <+> pretty thenStmt)
                 $$ (text "else" <+> pretty s)
    pretty RepeatStmt {..}
        = myhang (text "repeat") (semicolonList loopBody)
            $$ text "until" <+> (pretty loopExpr)
    pretty WhileStmt {..}
        = myhang (text "while" <+> pretty loopExpr) (pretty loopStmt)
    pretty CaseStmt {..} = (myhang (text "case" <+> pretty caseExpr <+> text "of")
                            $ semicolonList caseList)
                            $$ text "end"
    -- TODO: This doesn't have a semicolon after it in a compound statement.
    pretty (MarkLabel l) = pretty l <> colon
    pretty (Goto l) = text "goto" <+> pretty l
    pretty (CompoundStmt ss) = compound ss
    pretty Write {..} = text (if addNewline then "writeln" else "write")
                         <> parens (commaList writeArgs)
    pretty EmptyStatement = empty

instance Pretty WriteArg where
    pretty WriteArg {..} = pretty writeExpr
                            <> case widthAndDigits of
                                Nothing -> empty
                                Just (w,md) 
                                  -> colon <> pretty w
                                    <> case md of
                                        Nothing -> empty
                                        Just d -> colon <> pretty d

instance Pretty ForDir where
    pretty UpTo = text "to"
    pretty DownTo = text "downto"

instance Pretty VarReference where
    pretty (NameRef n) = pretty n
    pretty (ArrayRef n e) = pretty n <> lbrack <> commaList e <> rbrack
    pretty (DeRef n) = pretty n <> char '^'
    pretty (RecordRef n f) = pretty n <> char '.' <> pretty f

instance Pretty CaseElt where
    pretty CaseElt {..} = commaList (map caseConst caseConstants) <+> colon
                            <+> pretty caseStmt
        where
            caseConst Nothing = text "others"
            caseConst (Just e) = pretty e


instance Pretty Expr where
    pretty (ConstExpr c) = pretty c
    pretty (VarExpr v) = pretty v
    pretty (FuncCall n as) = pretty n <> 
                                if null as
                                    then parens empty
                                    else paramList as
    -- TODO: precendence
    pretty (BinOp e1 o e2) = parens $ pretty e1 <+> pretty o <+> pretty e2
    pretty (NotOp e) = parens $ text "not" <+> pretty e
    pretty (Negate e) = char '-' <> pretty e
    pretty (ArrayAccess n e) = pretty n <> brackets (commaList e)

instance Pretty BinOp where
    pretty Plus = char '+'
    pretty Minus = char '-'
    pretty Times = char '*'
    pretty Divide = char '/'
    pretty Div = text "div"
    pretty Mod = text "mod"
    pretty Or = text "or"
    pretty And = text "and"
    pretty OpEQ = text "="
    pretty NEQ = text "<>"
    pretty OpLT = text "<"
    pretty LTEQ = text "<="
    pretty OpGT = text ">"
    pretty GTEQ = text ">="

instance Pretty ConstValue where
    pretty (ConstInt n) = pretty n
    pretty (ConstReal n) = pretty n
    -- Pascal escapes a single-quote with a double-quote.
    pretty (ConstString s) = quotes $ text $ concatMap escape s
      where
        escape '\'' = "''"
        escape c = [c]

instance Pretty Rational where
    pretty = text . show . fromRational

----------------

instance Pretty BaseType where
    pretty (NamedType n) = pretty n
    pretty Range {..} = pretty lowerBound <> text ".." <> pretty upperBound

instance Pretty Bound where
    pretty (IntBound n) = pretty n
    pretty (NegBound b) = pretty b
    pretty (VarBound n) = pretty n

instance Pretty Type where
    pretty (BaseType t) = pretty t
    pretty ArrayType {..} = text "array" <> brackets (commaList arrayIndexType)
                                <+> text "of" <+> pretty arrayEltType
    pretty FileType {..} = text "file" <+> text "of" <+> pretty fileEltType
    pretty (RecordType FieldList {..}) = myhang (text "record") internals $$ text "end"
      where
        internals = case variantPart of
                        Nothing -> prettyFields fixedPart
                        Just v
                            | null fixedPart -> prettyVariant v
                            | otherwise      -> prettyFields fixedPart
                                                    <> semi
                                                    $$ prettyVariant v

prettyFields :: Fields -> Doc
prettyFields = semicolonList . map assignT

prettyVariant :: Variant -> Doc
prettyVariant Variant {..} = myhang (text "case" <+> pretty variantSelector
                                        <+> text "of")
                                (semicolonList $ map fieldChoice variantFields)
    where
        fieldChoice (n,fs) = pretty n <> colon <+> prettyFields fs
                                

---------------

