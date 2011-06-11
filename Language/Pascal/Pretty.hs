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

instance (Pretty a, Pretty b) => Pretty (Either a b) where
    prettyPrec n (Left x) = prettyPrec n x
    prettyPrec n (Right y) = prettyPrec n y

-----------------------

myhang x = hang x 2

instance Pretty Program where
    pretty Program{..} = 
        myhang (text "program" <+> pretty progName <> paramList progArgs <> semi)
        (semicolonList progDecls
            $$ vcat (map pretty progStmts))
        <> char '.'
            
paramList, commaList :: Pretty a => [a] -> Doc
paramList [] = empty
paramList xs = parens $ commaList xs

commaList [] = empty
commaList [x] = pretty x
commaList (x:xs) = pretty x <> comma <+> commaList xs

paramList' :: ParamList -> Doc
paramList' = paramList . map f
  where
    f (n,t) = pretty n <> colon <> pretty t

semicolonList :: Pretty a => [a] -> Doc
semicolonList = vcat . map (\d -> pretty d <> semi)

instance Pretty Declaration where
    pretty (NewLabel n) = text "label" <+> pretty n
    pretty (NewVar n t) = text "var" <+> pretty n <+> colon <+> pretty t
    pretty (NewType n t) = text "type" <+> pretty n <+> equals <+> pretty t
    pretty (NewFunction func) = pretty func
    pretty d = parens $ text $ show d

instance Pretty Function where
    pretty Function{funcReturnType=Nothing,..}
        = myhang (text "procedure" <+> text funcName 
                        <> paramList' funcParams <> semi)
            $ localVars funcLocalVars $$ pretty funcBody

localVars = semicolonList . map (\(n,t) -> text "var" <+> pretty n
                                            <+> colon <+> pretty t)

instance Pretty (Maybe [Statement]) where
    pretty Nothing = text "forward"
    pretty (Just xs) = pretty xs

instance Pretty [Statement] where
    pretty [] = empty
    pretty xs = myhang (text "begin") (semicolonList xs) $$ text "end"

instance Pretty Statement where
    pretty AssignStmt {..} = pretty assignTarget <+> text ":=" <+> pretty assignExpr
    pretty ProcedureCall {..} = pretty funName <> parens (commaList funcArgs)
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
        = myhang (text "repeat") (pretty loopBody)
            $$ text "until" <+> (pretty loopExpr)
    pretty WhileStmt {..}
        = myhang (text "while" <+> pretty loopExpr) (pretty loopStmt)
    -- TODO: This doesn't have a semicolon after it in a compound statement.
    pretty (MarkLabel l) = pretty l <> colon
    pretty (Goto l) = text "goto" <+> pretty l
    pretty (SubBlock ss) = semicolonList ss
    pretty Write {..} = text (if addNewline then "writeln" else "write")
                         <> parens (commaList writeArgs)

instance Pretty WriteArg where
    pretty (WritePlain e) = pretty e
    pretty (WritePadded n e) = pretty e <> colon <> pretty n

instance Pretty ForDir where
    pretty UpTo = text "to"
    pretty DownTo = text "downto"

instance Pretty VarReference where
    pretty (NameRef n) = pretty n
    pretty (ArrayRef n e) = pretty n <> lbrack <> commaList e <> rbrack

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
    -- Pascal escapes a single-quote with a double-quote.
    pretty (ConstString s) = quotes $ text $ concatMap escape s
      where
        escape '\'' = "''"
        escape c = [c]

----------------

instance Pretty BaseType where
    pretty (NamedType n) = pretty n
    pretty Range {..} = pretty lowerBound <> text ".." <> pretty upperBound


instance Pretty Type where
    pretty (BaseType t) = pretty t
    pretty ArrayType {..} = text "array" <> brackets (commaList arrayIndexType)
                                <+> text "of" <+> pretty arrayEltType
    pretty FileType {..} = text "file" <+> text "of" <+> pretty fileEltType
    pretty RecordType {..} = myhang (text "record")
                            (semicolonList $ map prettyField recordFields)
                        $$ text "end"
        where
            prettyField (n,b) = pretty n <> colon <> pretty b

---------------

