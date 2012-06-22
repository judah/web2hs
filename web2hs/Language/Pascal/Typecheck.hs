module Language.Pascal.Typecheck where

import Language.Pascal.Syntax
import Language.Pascal.Pretty

-- a little of a hack, since you can't have arrays
-- of strings.  whatever.
-- TODO: maybe both ConstIntegral and BoundedIntegral
data ExprBaseType = StringType | CharType | IntegralType
                    deriving (Show,Eq)
type ExprType = Type ExprBaseType

exprType :: Type Ordinal -> ExprType
exprType (BaseType (Ordinal _ _)) = BaseType IntegralType
exprType (BaseType OrdinalChar) = BaseType CharType
exprType RealType = RealType
exprType ArrayType {..}
    = ArrayType (map (const IntegralType) arrayIndexType)
            (exprType arrayEltType)
exprType (FileType t) = FileType $ exprType t
exprType (Pointer t) = Pointer $ exprType t
-- TODO: fields
{-
exprType (RecordType FieldList {..})
     = RecordType FieldList {..}
  where
    fixedPart = fmap (second exprType) fixedPart

exprFieldType :: 
-}

inferExprType :: Expr Scoped -> ExprType
inferExprType (ConstExpr c) = inferConstType c
inferExprType (VarExpr v) = inferRefType v
inferExprType e@(FuncCall f _) = inferFuncType f
-- TODO: is this right?
-- Treating Divide as always producing a real output.
inferExprType (BinOp _ Divide _) = RealType
-- TODO: is this complicated logic really necessary?
inferExprType e@(BinOp e1 _ e2)
    | Just t <- joinTypes (inferExprType e1) (inferExprType e2) = t
    | otherwise = error $ "can't join types in " ++ show (pretty e)
inferExprType (NotOp e) = inferExprType e
inferExprType (Negate e) = inferExprType e

joinTypes (BaseType IntegralType) RealType = Just RealType
joinTypes RealType (BaseType IntegralType) = Just RealType
joinTypes t1 t2
    | t1==t2 = Just t1
    | otherwise = Nothing

inferFuncType :: FuncCall -> ExprType
inferFuncType b@(BuiltinFunc n)
    = error $ "can't infer type of " ++ show (pretty b)
inferFuncType (DefinedFunc f)
    | Just t <- funcReturnType (funcVarHeading f) = exprType t
    | otherwise = error $ "can't infer return type for procedure "
                            ++ show (pretty f)

inferConstType :: ConstValue -> ExprType
inferConstType (ConstInt _) = BaseType IntegralType
inferConstType (ConstReal _) = RealType
inferConstType (ConstString s)
    | length s == 1 = BaseType CharType
    | otherwise = BaseType StringType

inferRefType :: VarReference Scoped -> ExprType
inferRefType (NameRef v) = inferVarType v
inferRefType r@(ArrayRef v _)
    | ArrayType _ t <- inferRefType v = t
    | otherwise = error $
                    "inferRefType: non-array ref "
                    ++ show (pretty r)
inferRef r@(DeRef v) = case inferRefType v of
    FileType t -> t
    Pointer t -> t
    _ -> error $ "inferRefType: dereference of " ++ show (pretty r)
inferRef (RecordRef _ _) = error "inferRef: records not implemented"

inferVarType :: Var -> ExprType
inferVarType Var {..} = exprType varType
inferVarType Const {..} = inferConstType varValue
inferVarType FuncReturn {..} = exprType varFuncReturnType

-- Things like arrays will never have types involving Const.
inferRefTypeNonConst :: VarReference Scoped -> OrdType
inferRefTypeNonConst (NameRef Var{..}) = varType
inferRefTypeNonConst (NameRef FuncReturn{..}) = varFuncReturnType
inferRefTypeNonConst (NameRef v@Const{..})
    = error $ "var ref can't be const: " ++ show (pretty v)
inferRefTypeNonConst (DeRef v)
    = case inferRefTypeNonConst v of
        FileType t -> t
        _ -> error $ "deref of non-file: " ++ show (pretty v)
inferRefTypeNonConst r@(ArrayRef v es)
    = case inferRefTypeNonConst v of
        ArrayType {..}
            | length arrayIndexType == length es -> arrayEltType
            | otherwise -> error $ "array ref: index mismatch: "
                                    ++ show (pretty r)
        _ -> error $ "array ref: not an array: " ++ show (pretty r)
inferRefTypeNonConst r@(RecordRef v n)
    = case inferRefTypeNonConst v of
        RecordType {..} -> case lookupField n recordFields of
                Just (Left t) -> t
                Just (Right (_,t)) -> t
                Nothing -> error $ "record ref: unknown field: "
                                    ++ show (pretty r)
        _ -> error $ "record ref: not a record: " ++ show (pretty r)
