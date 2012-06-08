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

flattenProgram :: Program Unscoped NamedOrdinal -> Program Unscoped Ordinal
flattenProgram p = p {progBlock = flip runReader Map.empty
                                    $ flip runReaderT builtinTypes
                                    $ flattenBlock (progBlock p)}

flattenBlock :: Block Unscoped NamedOrdinal -> TypeM (Block Unscoped Ordinal)
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

withs' :: Monad m => (a -> (b -> m c) -> m c) -> [a] -> ([b] -> m c) -> m c
withs' _ [] act = act []
withs' f (x:xs) act = f x $ \y -> withs' f xs $ act . (y:)

withConstValue n (ConstInt k) = withConstant n k
withConstValue _ _ = id


withBlockType :: Name -> NamedType -> TypeM a -> TypeM a
withBlockType n t act = do
    o <- flattenType t
    local (Map.insert n o) act

flattenFuncDecl :: FunctionDecl Unscoped NamedOrdinal
                    -> TypeM (FunctionDecl Unscoped Ordinal)
flattenFuncDecl FuncForward {..} = FuncForward funcName <$> flattenHeading funcHeading
flattenFuncDecl FuncDecl {..} = FuncDecl funcName <$> flattenHeading funcHeading
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

resolveProgram :: Program Unscoped Ordinal -> Program Scoped Ordinal
resolveProgram p@Program {..} = Program {
                                    progBlock = flip evalState 0
                                                $ flip runReaderT Map.empty
                                                $ withPrimConsts $ resolveBlock Global progBlock
                                    ,..
                                }

withPrimConsts = withConstVar "true" (ConstInt 1)
                . withConstVar "false" (ConstInt 0)
                . withBlockVar Global "tty" (FileType (BaseType (Ordinal 0 255)))

type VarM = ReaderT (Map Name (Either Var Func)) (State Integer)

resolveBlock :: Scope -> Block Unscoped Ordinal -> VarM (Block Scoped Ordinal)
resolveBlock s b@Block {..} = withs (uncurry $ withBlockVar s) blockVars 
                        $ withs (uncurry withConstVar) blockConstants 
                        $ withs' withFunction blockFunctions $ \blockFunctions -> do
        blockStatements <- mapM resolveStatement blockStatements
        blockConstants <- mapM (firstM resolveVar) blockConstants
        blockVars <- mapM (firstM resolveVar) blockVars
        return Block {..}

withBlockVar :: Scope -> Name -> Type Ordinal -> VarM a -> VarM a
withBlockVar s n t act = do
    u <- nextUnique
    local (Map.insert n (Left $ Var n u t s)) act

withConstVar :: Name -> ConstValue -> VarM a -> VarM a
withConstVar n c act = do
    u <- nextUnique
    local (Map.insert n (Left $ Const n u c)) act

nextUnique = lift $ do
    u <- get
    put (u+1)
    return u 

resolveVar :: Name -> VarM Var
resolveVar n = do
    m <- ask
    case myLookup "resolveVar" n m of
        Left v -> return v
        Right f -> error $ "expected var, got func: " ++ show n
                        ++ "\n" ++ show (cvtMap m)
  where
    cvtMap = fmap $ either (\v -> varName v ++ "_v")
                        (\f -> funcVarName f ++ "_f")

resolveFunc :: Name -> VarM FuncCall
resolveFunc n = do
    f <- resolveFuncCallOrVar n
    case f of
        Left v -> error $ "resolveFunc: " ++ show n 
                                    ++ "expected func, got var"
        Right f -> return f
 
resolveFuncCallOrVar :: Name -> VarM (Either Var FuncCall)
resolveFuncCallOrVar n = do
    r <- asks $ Map.lookup n
    return $ case r of
                Nothing -> Right $ BuiltinFunc n
                Just (Right f) -> Right $ DefinedFunc f
                Just (Left v) -> Left v

resolveFuncReturnOrVar :: Name -> VarM Var
resolveFuncReturnOrVar n = do
    r <- asks $ myLookup "resolveFuncReturnOrVar" n
    case r of
        Left v -> return v
        Right f
            | Just  t <- funcReturnType (funcVarHeading f)
                                     -> return $ FuncReturn f t
            | otherwise -> error 
                            $ "setting return for procedure "
                                 ++ show n

    




withFunction :: FunctionDecl Unscoped Ordinal
            -> (FunctionDecl Scoped Ordinal -> VarM a) -> VarM a
withFunction FuncForward {..} act
    = withHeading funcName funcHeading $ \funcName -> do
        let funcHeading = funcVarHeading funcName
        act FuncForward {..}
withFunction FuncDecl {..} act
    = withHeading funcName funcHeading $ \funcName -> do
        let funcHeading = funcVarHeading funcName
        funcBlock <- resolveBlock Local funcBlock
        act FuncDecl {..}

withHeading :: Name -> FuncHeading Unscoped Ordinal
            -> (Func -> VarM a) -> VarM a
withHeading n FuncHeading {..} act = do
    existing <- asks (Map.lookup n)
    case existing of
        Just (Right f) -> act f
        _ -> do
                funcUnique <- nextUnique
                withs' withParam funcArgs $ \funcArgs -> do
                let funcVarName = n
                let funcVarHeading = FuncHeading {..}
                let f = Func {..}
                withFuncReturn f funcReturnType
                    $ local (Map.insert n (Right f)) $ act f
                -- local (Map.insert n (Right f)) $ act f
-- TODO: test for valid FuncReturns...
withFuncReturn :: Func -> Maybe (Type Ordinal) -> VarM a -> VarM a
withFuncReturn _ Nothing = id
withFuncReturn f (Just t) = local (Map.insert (funcVarName f) (Left (FuncReturn f t)))

withParam :: FuncParam Unscoped Ordinal -> (FuncParam Scoped Ordinal -> VarM a)
                -> VarM a
withParam FuncParam {..} act = withBlockVar Local paramName paramType $ do
    paramName <- resolveVar paramName
    act $ FuncParam {..}
                            

resolveStatement :: Statement Unscoped -> VarM (Statement Scoped)
resolveStatement = secondM resolveStatementBase

resolveStatementBase :: StatementBase Unscoped -> VarM (StatementBase Scoped)
resolveStatementBase s = case s of
    AssignStmt {assignTarget = NameRef n,..} -> do
                v <- resolveFuncReturnOrVar n
                AssignStmt (NameRef v) <$> resolveExpr assignExpr
    AssignStmt {..} -> AssignStmt <$> resolveRef assignTarget
                                  <*> resolveExpr assignExpr
    ProcedureCall {..} -> ProcedureCall
                            <$> resolveFunc funName
                            <*> mapM resolveExpr procArgs
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

resolveStatementList :: StatementList Unscoped -> VarM (StatementList Scoped)
resolveStatementList = mapM (secondM resolveStatementBase)

resolveRef :: VarReference Unscoped -> VarM (VarReference Scoped)
resolveRef r = case r of
    NameRef v -> NameRef <$> resolveVar v
    ArrayRef v es -> ArrayRef <$> resolveRef v <*> mapM resolveExpr es
    DeRef v -> DeRef <$> resolveRef v
    RecordRef v n -> RecordRef <$> resolveRef v <*> pure n

resolveExpr :: Expr Unscoped -> VarM (Expr Scoped)
resolveExpr e = case e of
    ConstExpr c -> pure $ ConstExpr c
    VarExpr (NameRef n) -> do
        funcOrVar <- resolveFuncCallOrVar n
        case funcOrVar of
            Left v -> return $ VarExpr (NameRef v)
            Right f -> return $ FuncCall f []
    VarExpr v -> VarExpr <$> resolveRef v
    FuncCall n es -> FuncCall <$> resolveFunc n <*> mapM resolveExpr es
    BinOp e o f -> BinOp <$> resolveExpr e <*> pure o <*> resolveExpr f
    NotOp e -> NotOp <$> resolveExpr e
    Negate e -> Negate <$> resolveExpr e
