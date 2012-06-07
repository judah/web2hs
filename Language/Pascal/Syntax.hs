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
                progArgs :: [Name],
                progBlock :: Block v t
            } deriving Show

data Block v t = Block {
                blockLabels :: [Label],
                -- TODO: remember var/const uniques here
                blockConstants :: [(v,ConstValue)],
                blockTypes :: [(Name,Type t)],
                blockVars :: [(v,Type t)],
                blockFunctions :: [FunctionDecl v t],
                blockStatements :: StatementList v
            } deriving Show

-- TODO: Resolve function names also
data FunctionDecl v t = FuncForward {funcName :: Name, funcHeading :: FuncHeading v t}
                 -- TODO: grammar can't tell when we're defining previously-declared
                 -- forward procedures.
                 -- | FuncIdent {funcName :: Name, funcBlock :: Block}
                 | Func {funcName :: Name, funcHeading :: FuncHeading v t, 
                         funcBlock :: Block v t}
            deriving Show

data FuncHeading v t = FuncHeading {
                    funcArgs :: [FuncParam v t],
                    funcReturnType :: Maybe (Type t) -- Nothing if it's a procedure.
                } deriving Show
                
data FuncParam v t = FuncParam {paramName :: v, paramType :: Type t, paramByRef :: Bool}
            deriving Show


--------------------------------------------

type StatementList v = [Statement v]

type Statement v = (Maybe Label,StatementBase v)

data StatementBase v =
               AssignStmt {assignTarget :: VarReference v, assignExpr :: Expr v}
               | ProcedureCall {funName :: Name, procArgs :: [Expr v]}
               | IfStmt { ifCond :: Expr v, thenStmt :: Statement v,
                            elseStmt :: Maybe (Statement v)}
               | ForStmt { loopVar :: v, forStart, forEnd :: Expr v,
                        forDirection :: ForDir,
                        forBody :: (Statement v)}
               | WhileStmt { loopExpr :: Expr v, loopStmt :: (Statement v)}
               | RepeatStmt { loopExpr :: Expr v, loopBody :: StatementList v }
               | CaseStmt { caseExpr :: Expr v, caseList :: [CaseElt v] }
               | Goto Label
               | MarkLabel Label
               | Write {addNewline :: Bool,
                        writeArgs :: [WriteArg v]
                        }
               | CompoundStmt (StatementList v)
               | EmptyStatement
        deriving Show

-- Unsure about these...
data VarReference v = NameRef v
                  | ArrayRef (VarReference v) [Expr v]
                  | DeRef (VarReference v) -- pointer dereference; also for files
                  | RecordRef (VarReference v) Name
                deriving Show

data ForDir = UpTo | DownTo
        deriving Show

data CaseElt v = CaseElt {
               -- TODO: In Pascal, cases can be any constant identifier
                caseConstants :: [Maybe ConstValue], -- nothing if "others:"
                caseStmt :: Statement v
                }
    deriving Show

data WriteArg v = WriteArg {
                    writeExpr :: Expr v,
                    widthAndDigits :: Maybe (Integer, Maybe Integer)
                }
    deriving Show

-- <statement> | BEGIN <statement-list> END
type Body v = [Statement v]

data Expr v
          = ConstExpr ConstValue
          | VarExpr (VarReference v)
          | FuncCall Name [Expr v]
          | BinOp (Expr v) BinOp (Expr v)
          | NotOp (Expr v)
          | Negate (Expr v)
          -- not necessary? | ArrayAccess Name [Expr]
    deriving Show
            -- records?


data ConstValue = ConstInt Integer
                | ConstReal Rational
                | ConstString String
        deriving Show

data BinOp = Plus | Minus | Times | Divide | Div | Mod
            | Or | And
            | OpEQ | NEQ | OpLT | LTEQ | OpGT | GTEQ
    deriving Show
                             
            {-
                DefineProcedure Procedure
               | DefineFunction Function
               | DeclareType NewType
               | DeclareVar Name PascalType
-}

data Type t
    = BaseType t
    | RealType
    -- For now, we just ignore "packed".
    | ArrayType { arrayIndexType :: [t] , -- can be any ordinal type
                    arrayEltType :: Type t
                }
    | FileType { fileEltType :: Type t }
    | RecordType { recordFields :: FieldList t }
        deriving Show

--  NOTE: TeX only requires a subset of Pascal's record functionality.
data FieldList t = FieldList {
                        fixedPart :: Fields t,
                        variantPart :: Maybe (Variant t)
                    }
            deriving Show

type Fields t = [(Name,Type t)]

data Variant t = Variant {
                variantSelector :: Type t,
                variantFields :: [(Integer,Fields t)]
                }
        deriving Show




data Ordinal = Ordinal { ordLower, ordUpper :: Integer}
                    deriving Show

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
                { varName :: Name
                , varUnique :: Integer
                , varType :: Type Ordinal
                }
    deriving Show

data Scope = Local | Global
            deriving Show

