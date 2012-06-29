-- | This module provides a wrapper around Text.PrettyPrint.HughesPJ.
-- It adds two new things:
-- 1) An extra type parameter to the "Doc" type,
-- 2) a "Pretty" typeclass, with member "pretty :: a -> Doc t".
-- 
-- The extra type parameter lets us separate the pretty-printing of
-- Pascal and C code.
module Language.Pascal.Pretty.Base where

import Language.Pascal.Syntax
import qualified Text.PrettyPrint.HughesPJ as HPJ

newtype Doc t = Doc {rawDoc :: HPJ.Doc}
                deriving Show

liftDoc :: (HPJ.Doc -> HPJ.Doc) -> Doc t -> Doc t
liftDoc f = Doc . f . rawDoc

liftDoc2 :: (HPJ.Doc -> HPJ.Doc -> HPJ.Doc) -> Doc t -> Doc t -> Doc t
liftDoc2 f x y = Doc $ f (rawDoc x) (rawDoc y)

(<>) :: Doc t -> Doc t -> Doc t
(<>) = liftDoc2 (HPJ.<>)

(<+>) :: Doc t -> Doc t -> Doc t
(<+>) = liftDoc2 (HPJ.<+>)

($$) :: Doc t -> Doc t -> Doc t
($$) = liftDoc2 (HPJ.$$)

($+$) :: Doc t -> Doc t -> Doc t
($+$) = liftDoc2 (HPJ.$+$)

empty :: Doc t
empty = Doc HPJ.empty

class Pretty t a where
    pretty :: a -> Doc t
    -- TODO: remove extra parens using:
    -- prettyPrec :: Int -> a -> Doc t
    -- pretty = prettyPrec 0
    -- prettyPrec  = const pretty

instance Pretty t HPJ.Doc where
    pretty = Doc

instance (t1 ~ t2) => Pretty t1 (Doc t2) where
-- This is better than instance Pretty t (Doc t),
-- since it ensures that pretty (pretty x) is unambiguous.
    pretty = Doc . rawDoc

instance Pretty t String where
    pretty = pretty . HPJ.text

instance Pretty t Char where
    pretty = pretty . HPJ.char

instance Pretty t Integer where
    pretty = pretty . HPJ.integer

instance Pretty t Rational where
    pretty = pretty . show . (fromRational :: Rational -> Double)

render :: Doc t -> String
render = HPJ.render . rawDoc

myhang :: Doc t -> Doc t -> Doc t
myhang = liftDoc2 (flip HPJ.hang 2)

nest :: Int -> Doc t -> Doc t
nest k = liftDoc (HPJ.nest k)

comma, semi, colon, equals, star :: Doc t
comma = Doc HPJ.comma
semi = Doc HPJ.semi
colon = Doc HPJ.colon
equals = Doc HPJ.equals
star = pretty '*'

parens, brackets, braces, quotes, doubleQuotes :: Doc t -> Doc t
parens = liftDoc HPJ.parens
brackets = liftDoc HPJ.brackets
braces = liftDoc HPJ.braces
quotes = liftDoc HPJ.quotes
doubleQuotes = liftDoc HPJ.doubleQuotes

hcat, vcat, sep :: [Doc t] -> Doc t
hcat = Doc . HPJ.hcat . fmap rawDoc
vcat = Doc . HPJ.vcat . fmap rawDoc
sep = Doc . HPJ.sep . fmap rawDoc

commaList :: Pretty t a => [a] -> Doc t
commaList [] = empty
commaList [x] = pretty x
commaList (x:xs) = pretty x <> comma <+> commaList xs



-----------------

instance Pretty t Var where
    pretty Var {..} = pretty varName <> pretty "_" <> pretty varUnique
                <> case varScope of
                    Global -> pretty "g"
                    Local -> pretty "l"
    pretty Const {..} = pretty constName <> pretty "_" <> pretty constUnique
                        <> pretty "c"
                        
instance Pretty t Func where
    pretty Func {..} = pretty funcVarName <> pretty "_" <> pretty funcUnique

instance Pretty t FuncCall where
    pretty (DefinedFunc f) = pretty  f
    pretty (BuiltinFunc f) = pretty f <> pretty "_builtin"

instance Pretty t FuncReturn where
    pretty FuncReturn {..} = pretty varFuncReturnId <> pretty "_ret"

instance (Pretty t (VarReference Scoped)) => Pretty t LValue where
    pretty (VLValue v) = pretty v
    pretty (FLValue f) = pretty f
