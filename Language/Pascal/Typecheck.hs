module Language.Pascal.Typecheck where

import Language.Pascal.Syntax
import Language.Pascal.Pretty

-- a little of a hack, since you can't have arrays
-- of strings.  whatever.
data ExprBaseType = StringType | IntegralType
type ExprType = Type ExprBaseType

exprType :: Type a -> ExprType
exprType (BaseType _) = BaseType IntegralType
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
inferExprType (FuncCall _ _) = error "inferExprType: FuncCall"
inferExprType (BinOp e _ _) = inferExprType e -- TODO: compare
inferExprType (NotOp e) = inferExprType e
inferExprType (Negate e) = inferExprType e


inferConstType :: ConstValue -> ExprType
inferConstType (ConstInt _) = BaseType IntegralType
inferConstType (ConstReal _) = RealType
inferConstType (ConstString _) = BaseType StringType

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


