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
            
paramList :: Pretty a => [a] -> Doc
paramList [] = empty
paramList xs = parens $ commaList xs
  where
    commaList [x] = pretty x
    commaList (x:xs) = pretty x <> comma <> commaList xs

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
    pretty s = parens $ text $ show s

----------------

instance Pretty BaseType where
    pretty (NamedType n) = pretty n
    pretty Range {..} = pretty lowerBound <> text ".." <> pretty upperBound


instance Pretty Type where
    pretty (BaseType t) = pretty t
    pretty ArrayType {..} = text "array" <> brackets (pretty arrayIndexType)
                                <+> text "of" <+> pretty arrayEltType
    pretty FileType {..} = text "file" <+> text "of" <+> pretty fileEltType

