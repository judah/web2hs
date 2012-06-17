-- | This module defines an AST for the subset of Pascal used by TeX and friends.
module Language.Pascal.Syntax where

type Name = String

type Label = Integer

-- Using:
-- http://www.chasanc.com/index.php/Compiler/Backus-Naur-Form-BNF-of-Pascal-Language.html
-- Much better:
-- http://www.freepascal.org/docs-html/ref/ref.html

data Program v t = Program {
                progName :: Name,
                progArgs :: [VarID v],
                progBlock :: Block v t
            }

data Block v t = Block {
                blockLabels :: [Label],
                -- TODO: remember var/const uniques here
                blockConstants :: [(VarID v,ConstValue)],
                blockTypes :: [(Name,Type t)],
                blockVars :: [(VarID v,Type t)],
                blockFunctions :: [FunctionDecl v t],
                blockStatements :: StatementList v
            }

data FunctionDecl v t = FuncForward {funcName :: FuncID v, funcHeading :: FuncHeading v t}
                 -- TODO: grammar can't tell when we're defining previously-declared
                 -- forward procedures.
                 -- | FuncIdent {funcName :: Name, funcBlock :: Block}
                 | FuncDecl {funcName :: FuncID v, funcHeading :: FuncHeading v t, 
                         funcBlock :: Block v t}

data FuncHeading v t = FuncHeading {
                    funcArgs :: [FuncParam v t],
                    funcReturnType :: Maybe (Type t) -- Nothing if it's a procedure.
                }

                
data FuncParam v t = FuncParam {paramName :: VarID v, paramType :: Type t,
                            paramByRef :: Bool}


--------------------------------------------

type StatementList v = [Statement v]

type Statement v = (Maybe Label,StatementBase v)

data StatementBase v =
               AssignStmt {assignTarget :: VarReference v, assignExpr :: Expr v}
               | ProcedureCall {funName :: FuncCallID v, procArgs :: [Expr v]}
               | IfStmt { ifCond :: Expr v, thenStmt :: Statement v,
                            elseStmt :: Maybe (Statement v)}
               | ForStmt { loopVar :: VarID v, forStart, forEnd :: Expr v,
                        forDirection :: ForDir,
                        forBody :: (Statement v)}
               | WhileStmt { loopExpr :: Expr v, loopStmt :: (Statement v)}
               | RepeatStmt { loopExpr :: Expr v, loopBody :: StatementList v }
               | CaseStmt { caseExpr :: Expr v, caseList :: [CaseElt v] }
               | Goto Label
               | Write {addNewline :: Bool,
                        writeArgs :: [WriteArg v]
                        }
               | CompoundStmt (StatementList v)
               | EmptyStatement

-- Unsure about these...
data VarReference v = NameRef (VarID v)
                  | ArrayRef (VarReference v) [Expr v]
                  | DeRef (VarReference v) -- pointer dereference; also for files
                  | RecordRef (VarReference v) Name

data ForDir = UpTo | DownTo

data CaseElt v = CaseElt {
               -- TODO: In Pascal, cases can be any constant identifier
                caseConstants :: [Maybe ConstValue], -- nothing if "others:"
                caseStmt :: Statement v
                }

data WriteArg v = WriteArg {
                    writeExpr :: Expr v,
                    -- I'm not sure whether pascal allows
                    -- arbitrary expressions here, but it seems
                    -- like it should be OK.
                    widthAndDigits :: Maybe (Expr v, Maybe (Expr v))
                }

-- <statement> | BEGIN <statement-list> END
type Body v = [Statement v]

data Expr v
          = ConstExpr ConstValue
          | VarExpr (VarReference v)
          | FuncCall (FuncCallID v) [Expr v]
          | BinOp (Expr v) BinOp (Expr v)
          | NotOp (Expr v)
          | Negate (Expr v)
          -- not necessary? | ArrayAccess Name [Expr]
            -- records?


data ConstValue = ConstInt Integer
                | ConstReal Rational
                | ConstString String

data BinOp = Plus | Minus | Times | Divide | Div | Mod
            | Or | And
            | OpEQ | NEQ | OpLT | LTEQ | OpGT | GTEQ
                             

data Type t
    = BaseType t
    | RealType
    -- For now, we just ignore "packed".
    | ArrayType { arrayIndexType :: [t] , -- can be any ordinal type
                    arrayEltType :: Type t
                }
    | FileType { fileEltType :: Type t }
    | RecordType { recordName :: Maybe Name,
                   recordFields :: FieldList t }
    | Pointer (Type t)
        deriving (Eq, Show)

--  NOTE: TeX only requires a subset of Pascal's record functionality.
data FieldList t = FieldList {
                        fixedPart :: Fields t,
                        variantPart :: Maybe (Variant t)
                    } deriving (Eq,Show)

type Fields t = [(Name,Type t)]

data Variant t = Variant {
                variantSelector :: Type t,
                variantFields :: [(Integer,Fields t)]
                } deriving (Eq,Show)



-- Things which can index arrays
data Ordinal = Ordinal Integer Integer
            -- We need to differentiate Char for output purposes.
             | OrdinalChar
                    deriving (Show,Eq)

ordSize :: Ordinal -> Integer
ordSize o = ordUpper o - ordLower o + 1

ordLower, ordUpper :: Ordinal -> Integer
ordLower (Ordinal l _) = l
ordLower OrdinalChar = 0
ordUpper (Ordinal _ u) = u
ordUpper OrdinalChar = 255

type NamedType = Type NamedOrdinal

type OrdType = Type Ordinal

data NamedOrdinal
    = NamedType Name
    -- prim: integer, char, real,
    | Range {lowerBound, upperBound :: Bound} -- may refer to a constant
    deriving Show

-- This is not exactly the ISO BNF, but it's enough for TeX.
data Bound = IntBound Integer
           | NegBound Bound
           | VarBound Name
    deriving Show

------------------------------------

-- Functions: 
-- FuncCall calls either a builtin of a particular name
-- or a predefined function.

data Scoped
data Unscoped

type family VarID v :: *
type family FuncID v :: *
type family FuncCallID v :: *

type instance VarID Unscoped = Name
type instance FuncID Unscoped = Name
type instance FuncCallID Unscoped = Name

type instance VarID Scoped = Var
type instance FuncID Scoped = Func
type instance FuncCallID Scoped = FuncCall

data FuncCall = DefinedFunc Func | BuiltinFunc Name

data Func = Func
            { funcVarName :: Name
            , funcUnique :: Integer
            , funcVarHeading :: FuncHeading Scoped Ordinal
            }

data Var = Var
            { varName :: Name
            , varUnique :: Integer
            , varType :: Type Ordinal
            , varScope :: Scope
            }
            | Const
                { varName :: Name
                , varUnique :: Integer
                , varValue :: ConstValue
                }
            | FuncReturn
                { varFuncReturnId :: Func
                , varFuncReturnType :: Type Ordinal
                }

data Scope = Local | Global
            deriving Show

