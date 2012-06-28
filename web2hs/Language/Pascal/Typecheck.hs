module Language.Pascal.Typecheck(
                            ExprType,
                            Unranged(..),
                            inferExprType,
                            RefType(..),
                            inferRefType,
                            ) where

import Language.Pascal.Syntax
import Language.Pascal.Pretty

-- This module lets us find the type of a given expression.
-- Its main uses in Language.Pascal.GenerateC are to:
-- - Let the "write" and "write_ln" builtins handle different types.
-- - Figure out whether a record field is variant.
-- - Allow correct access of arrays not indexed starting at zero.

data Unranged = UnrangedInt | CharType
                deriving Eq

type ExprType = Type Unranged

exprType :: OrdType -> ExprType
exprType = fmap $ \o -> case o of
    Ordinal _ _ -> UnrangedInt
    OrdinalChar -> CharType

inferExprType :: Expr Scoped -> ExprType
inferExprType (ConstExpr c) = case c of
                                ConstInt _ -> BaseType UnrangedInt
                                ConstReal _ -> RealType
                                ConstString _ -> PointerType (BaseType CharType)
inferExprType (VarExpr v) = case inferRefType v of
                                UnboundedIntRef -> BaseType UnrangedInt
                                RefType t -> exprType t
inferExprType (FuncCall f _) = exprType $ inferFuncType f
-- Special case: in Pascal, dividing two integers produces a real.
inferExprType (BinOp _ Divide _) = RealType
inferExprType e@(BinOp e1 _ e2)
    | Just t <- joinTypes (inferExprType e1) (inferExprType e2) = t
    | otherwise = error $ "can't join types in " ++ show (pretty e)
inferExprType (NotOp e) = inferExprType e
inferExprType (Negate e) = inferExprType e

inferFuncType :: FuncCall -> OrdType
inferFuncType b@(BuiltinFunc _)
    = error $ "can't infer type of builtin " ++ show (pretty b)
inferFuncType (DefinedFunc f)
    | Just t <- funcReturnType (funcVarHeading f) = t
    | otherwise = error $ "can't infer return type for procedure "
                            ++ show (pretty f)


-- TODO: we're currently ignoring some cases which should be errors,
-- such as adding together two records.
joinTypes :: ExprType -> ExprType -> Maybe ExprType
joinTypes RealType (BaseType _) = Just RealType
joinTypes (BaseType _) RealType = Just RealType
-- TODO: for now, two unequal ranged types combine to an unbounded type.
joinTypes (BaseType _) (BaseType _) = Just $ BaseType UnrangedInt 
joinTypes t1 t2
    | t1==t2 = Just t1
    | otherwise = Nothing

data RefType = UnboundedIntRef | RefType OrdType

inferRefType :: VarReference Scoped -> RefType
inferRefType (NameRef Var{..}) = RefType varType
inferRefType (NameRef Const{..}) = case constValue of
                                    ConstReal _ -> RefType RealType
                                    ConstInt _ -> UnboundedIntRef
                                    ConstString _ -> RefType $ PointerType
                                                        $ BaseType OrdinalChar
inferRefType (DeRef v)
    = case inferRefType v of
        RefType (FileType t) -> RefType t
        _ -> error $ "deref of non-file: " ++ show (pretty v)
inferRefType r@(ArrayRef v es)
    = case inferRefType v of
        RefType ArrayType {..}
            | length arrayIndexType == length es -> RefType arrayEltType
            | otherwise -> error $ "array ref: index mismatch: "
                                    ++ show (pretty r)
        RefType (PointerType t)
            | length es==1 -> RefType t
        _ -> error $ "array ref: not an array: " ++ show (pretty r)
inferRefType r@(RecordRef v n)
    = case inferRefType v of
        RefType RecordType {..} -> RefType $ case lookupField n recordFields of
                Just (Left t) -> t
                Just (Right (_,t)) -> t
                Nothing -> error $ "record ref: unknown field: "
                                    ++ show (pretty r)
        _ -> error $ "record ref: not a record: " ++ show (pretty r)
