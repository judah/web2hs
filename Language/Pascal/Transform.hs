module Language.Pascal.Transform
        (flattenProgram,
         resolveProgram,
        )
        where

import Language.Pascal.Syntax

import Control.Arrow

import qualified Data.Map as Map
import Data.Map (Map )
import Control.Monad.Trans.State.Lazy
import Control.Monad.Trans.Reader
import Control.Monad.Trans.Class
import Control.Applicative hiding (Const)

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

flattenProgram :: Program Name NamedOrdinal -> Program Name Ordinal
flattenProgram p = p {progBlock = flip runReader Map.empty
                                    $ flip runReaderT builtinTypes
                                    $ flattenBlock (progBlock p)}

flattenBlock :: Block Name NamedOrdinal -> TypeM (Block Name Ordinal)
flattenBlock b@Block {..}
    = mapReaderT (withs (uncurry withConstValue) blockConstants)
      $ withs (uncurry withBlockType) blockTypes $ do
            blockTypes <- mapM (secondM flattenType) blockTypes -- TODO: redundant
            blockVars <- mapM (secondM flattenType) blockVars
            blockFunctions <- mapM flattenFuncDecl blockFunctions
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

flattenFuncDecl :: FunctionDecl Name NamedOrdinal -> TypeM (FunctionDecl Name Ordinal)
flattenFuncDecl FuncForward {..} = FuncForward funcName <$> flattenHeading funcHeading
flattenFuncDecl Func {..} = Func funcName <$> flattenHeading funcHeading
                                          <*> flattenBlock funcBlock

flattenHeading :: FuncHeading v NamedOrdinal -> TypeM (FuncHeading v Ordinal)
flattenHeading FuncHeading {..}
    = FuncHeading <$> mapM flattenParam funcArgs
                  <*> Traversable.mapM flattenType funcReturnType
  where
    flattenParam FuncParam {..} = FuncParam paramName
                                            <$> flattenType paramType
                                            <*> pure paramByRef

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

firstM :: Monad m => (a -> m b) -> (a,c) -> m (b,c)
firstM f (x,y) = do
    z <- f x
    return (z,y)

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

withConstant :: Monad m => Name -> Integer
        -> ReaderT ConstMap m a -> ReaderT ConstMap m a
withConstant n k = local $ Map.insert n k

withType :: Name -> NamedType -> TypeM () -> TypeM ()
withType n t act = do
    o <- flattenType t
    local (Map.insert n o) act

---------------------------------------------

resolveProgram :: Program Name Ordinal -> Program Var Ordinal
resolveProgram p@Program {..} = Program {
                                    progBlock = flip evalState 0
                                                $ flip runReaderT Map.empty
                                                $ withPrimConsts $ resolveBlock progBlock
                                    ,..
                                }

withPrimConsts = withConstVar "true" (ConstInt 1)
                . withConstVar "false" (ConstInt 0)
                . withBlockVar "tty" (FileType (BaseType (Ordinal 0 255)))

type VarM = ReaderT (Map Name Var) (State Integer)

resolveBlock :: Block Name Ordinal -> VarM (Block Var Ordinal)
resolveBlock b@Block {..} = withs (uncurry withBlockVar) blockVars 
                        $ withs (uncurry withConstVar) blockConstants $ do
        blockFunctions <- mapM resolveFunction blockFunctions
        blockStatements <- mapM resolveStatement blockStatements
        blockConstants <- mapM (firstM resolveVar) blockConstants
        blockVars <- mapM (firstM resolveVar) blockVars
        return Block {..}

withBlockVar :: Name -> Type Ordinal -> VarM a -> VarM a
withBlockVar n t act = do
    u <- nextUnique
    local (Map.insert n (Var n u t)) act

withConstVar :: Name -> ConstValue -> VarM a -> VarM a
withConstVar n c act = do
    u <- nextUnique
    local (Map.insert n (Const n u c)) act

nextUnique = lift $ do
    u <- get
    put (u+1)
    return u 

resolveVar :: Name -> VarM Var
resolveVar n = asks $ myLookup "resolveVar" n

-- TODO: no way to remember the function return var
-- TODO: different uniques for forward func decl and actual definition
resolveFunction :: FunctionDecl Name Ordinal -> VarM (FunctionDecl Var Ordinal)
resolveFunction FuncForward {..} = withHeading funcName funcHeading $ do
    funcHeading <- resolveHeading funcHeading
    return FuncForward {..}
resolveFunction Func {..} = withHeading funcName funcHeading $ do
    funcHeading <- resolveHeading funcHeading
    funcBlock <- resolveBlock funcBlock
    return Func {..}

withHeading :: Name -> FuncHeading Name Ordinal -> VarM a -> VarM a
withHeading funcName FuncHeading {..} = let
    params = [(paramName,paramType) | FuncParam{..} <- funcArgs]
    in withs (uncurry withBlockVar) params
        . case funcReturnType of
            Nothing -> id
            Just t -> \act -> do
                        u <- nextUnique
                        local (Map.insert funcName $ FuncReturn funcName u t) act

resolveHeading :: FuncHeading Name Ordinal -> VarM (FuncHeading Var Ordinal)
resolveHeading FuncHeading {..} = FuncHeading
                                <$> mapM resolveParam funcArgs
                                <*> pure funcReturnType
  where
    resolveParam FuncParam {..} = FuncParam
                                <$> asks (myLookup "resolveParam" paramName)
                                    <*> pure paramType <*> pure paramByRef

resolveStatement :: Statement Name -> VarM (Statement Var)
resolveStatement = secondM resolveStatementBase

resolveStatementBase :: StatementBase Name -> VarM (StatementBase Var)
resolveStatementBase s = case s of
    AssignStmt {..} -> AssignStmt <$> resolveRef assignTarget
                                  <*> resolveExpr assignExpr
    ProcedureCall {..} -> ProcedureCall funName <$> mapM resolveExpr procArgs
    IfStmt {..} -> IfStmt <$> resolveExpr ifCond
                         <*> resolveStatement thenStmt
                         <*> Traversable.mapM resolveStatement elseStmt
    ForStmt {..} -> ForStmt <$> resolveVar loopVar
                        <*> resolveExpr forStart <*> resolveExpr forEnd
                        <*> pure forDirection <*> resolveStatement forBody
    WhileStmt {..} -> WhileStmt <$> resolveExpr loopExpr <*> resolveStatement loopStmt
    RepeatStmt {..} -> RepeatStmt <$> resolveExpr loopExpr
                            <*> resolveStatementList loopBody
    CaseStmt {..} -> CaseStmt <$> resolveExpr caseExpr 
                            <*> mapM resolveCaseElt caseList
    Goto l -> pure $ Goto l
    MarkLabel l -> pure $ MarkLabel l
    Write {..} -> Write addNewline <$> mapM resolveWriteArg writeArgs
    CompoundStmt s -> CompoundStmt <$> resolveStatementList s
    EmptyStatement -> pure EmptyStatement

resolveCaseElt CaseElt {..} = CaseElt caseConstants <$> resolveStatement caseStmt
resolveWriteArg WriteArg {..} = flip WriteArg widthAndDigits <$> resolveExpr writeExpr

resolveStatementList :: StatementList Name -> VarM (StatementList Var)
resolveStatementList = mapM (secondM resolveStatementBase)

resolveRef :: VarReference Name -> VarM (VarReference Var)
resolveRef r = case r of
    NameRef v -> NameRef <$> asks (myLookup "resolveRef" v)
    ArrayRef v es -> ArrayRef <$> resolveRef v <*> mapM resolveExpr es
    DeRef v -> DeRef <$> resolveRef v
    RecordRef v n -> RecordRef <$> resolveRef v <*> pure n

resolveExpr :: Expr Name -> VarM (Expr Var)
resolveExpr e = case e of
    ConstExpr c -> pure $ ConstExpr c
    VarExpr (NameRef v) -> do
        haveVar <- asks (Map.member v)
        if haveVar
            then VarExpr <$> (resolveRef $ NameRef v)
            else pure $ FuncCall v []
    VarExpr v -> VarExpr <$> resolveRef v
    FuncCall n es -> FuncCall n <$> mapM resolveExpr es
    BinOp e o f -> BinOp <$> resolveExpr e <*> pure o <*> resolveExpr f
    NotOp e -> NotOp <$> resolveExpr e
    Negate e -> Negate <$> resolveExpr e
