module Language.Pascal.Transform (flattenProgram) where

import Language.Pascal.Syntax

import Control.Arrow

import qualified Data.Map as Map
import Data.Map (Map )
import Control.Monad.Trans.Reader
import Control.Monad.Trans.Class
import Control.Applicative

import qualified Data.Traversable as Traversable

type TypeMap = Map Name (Type Ordinal)
type ConstMap = Map Name Integer

type TypeM = ReaderT TypeMap (Reader ConstMap)

builtinTypes :: TypeMap
builtinTypes = Map.fromList
                [ ("char", BaseType (Ordinal 0 255))
                -- TODO: unclear if boolean should be non-ordinal
                , ("boolean", BaseType (Ordinal 0 1))
                , ("integer", BaseType (Ordinal (- 2^31) (2^31 - 1)))
                , ("real", RealType)
                ]

myLookup :: (Show k, Ord k) => String -> k -> Map k a -> a
myLookup err k m = maybe (error $ err ++ ": missing key " ++ show k) id
                    $ Map.lookup k m

flattenProgram :: Program NamedOrdinal -> Program Ordinal
flattenProgram p = p {progBlock = flip runReader Map.empty
                                    $ flip runReaderT builtinTypes
                                    $ flattenBlock (progBlock p)}

flattenBlock :: Block NamedOrdinal -> TypeM (Block Ordinal)
flattenBlock b@Block {..}
    = mapReaderT (withs (uncurry withConstValue) blockConstants)
      $ withs (uncurry withBlockType) blockTypes $ do
            blockTypes <- mapM (secondM flattenType) blockTypes -- TODO: redundant
            blockVars <- mapM (secondM flattenType) blockVars
            blockFunctions <- return [] -- mapM flattenFuncDecl blockFunctions
            return Block {..}
                
withs :: Monad m => (a -> m b -> m b) -> [a] -> m b -> m b
withs _ [] act = act
withs f (x:xs) act = f x $ withs f xs act

withConstValue n (ConstInt k) = withConstant n k
withConstValue _ _ = id


withBlockType :: Name -> NamedType -> TypeM a -> TypeM a
withBlockType n t act = do
    o <- flattenType t
    local (Map.insert n o) act

flattenFuncDecl = undefined

flattenType :: NamedType -> TypeM (Type Ordinal)
flattenType (BaseType (NamedType n)) = asks (myLookup "flattenType" n)
flattenType (BaseType t) = BaseType <$> flattenOrd t
flattenType (ArrayType ts e) = ArrayType <$> mapM flattenOrd ts <*> flattenType e
flattenType (FileType t) = FileType <$> flattenType t
flattenType (RecordType FieldList {..})
    = (\x y -> RecordType $ FieldList x y) <$> flattenFields fixedPart
                               <*> Traversable.mapM flattenVariant variantPart
  where
    flattenFields = mapM (secondM flattenType)
    flattenVariant Variant {..} = Variant <$> flattenType variantSelector
                                          <*> mapM (secondM flattenFields)
                                                variantFields

secondM :: Monad m => (a -> m b) -> (c,a) -> m (c,b)
secondM f (x,y) = do
    z <- f y
    return (x,z)

flattenOrd :: NamedOrdinal -> TypeM Ordinal
flattenOrd (NamedType n) = do
    t <- asks (myLookup "flattenOrd" n)
    case t of
        BaseType o -> return o
        _ -> error "n is not a base type"

flattenOrd (Range low hi) = lift $ Ordinal <$> flattenBound low <*> flattenBound hi

flattenBound :: Bound -> Reader ConstMap Integer
flattenBound (IntBound n) = return n
flattenBound (NegBound b) = negate <$> flattenBound b
flattenBound (VarBound n) = asks $ (myLookup "flattenBound" n)

withConstant :: Name -> Integer -> Reader ConstMap a -> Reader ConstMap a
withConstant n k = local $ Map.insert n k

withType :: Name -> NamedType -> TypeM () -> TypeM ()
withType n t act = do
    o <- flattenType t
    local (Map.insert n o) act

