-- | This module defines an AST for the subset of Pascal used by TeX and friends.
module Language.Pascal.Syntax where

type Name = String

-- Using:
-- http://www.chasanc.com/index.php/Compiler/Backus-Naur-Form-BNF-of-Pascal-Language.html
-- Much better:
-- http://www.freepascal.org/docs-html/ref/ref.html

data Program = Program {
                progName :: Name,
                progArgs :: [Name],
                progDecls :: [Declaration],
                progStmts :: [Statement]
            }
    deriving Show

data Statement =
               AssignStmt {assignTarget :: Name, assignExpr :: Expr}
               | FuncCallStmt {funName :: Name, funcArgs :: [Name]}
               | ForStmt { loopVar :: Name, forStart, forEnd :: Expr,
                        forBody :: Body}
               | WhileStmt { loopExpr :: Expr, loopBody :: Body}
               | RepeatStmt { loopExpr :: Expr, loopBody :: Body}
        deriving Show

-- <statement> | BEGIN <statement-list> END
type Body = [Statement]

data Expr = IntExpr Int
          | ConstExpr ConstValue
          | StringExpr String -- ?
          | FuncCall
          | BinOp Expr Op Expr
          | ArrayAccess Name Expr
    deriving Show
            -- records?

data Op = Op deriving Show
data DefineProcedure = DefineProcedure
data DefineFunction = DefineFunction1
data Function = Function
data Procedure = Procedure

data Declaration
            = NewVar Name Type
            | NewConst Name ConstValue
            | NewType Name Type
            | NewLabel Int -- ? Name?
    deriving Show

data ConstValue = ConstInt Int
                | ConstChar Char
                | ConstString String
        deriving Show

data BinOp = Plus | Minus | Times | Divide | Div | Mod
    deriving Show
                             
            {-
                DefineProcedure Procedure
               | DefineFunction Function
               | DeclareType NewType
               | DeclareVar Name PascalType
-}

data Type
    = BaseType BaseType
    -- For now, we just ignore "packed".
    | ArrayType { arrayIndexType :: BaseType , -- can be any ordinal type
                    arrayEltType :: Type
                }
        deriving Show

data BaseType
    = NamedType Name
    -- prim: integer, char, real,
    | Range {lowerBound, upperBound :: Either Int Name} -- may refer to a constant
        
    deriving Show
