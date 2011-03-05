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
               AssignStmt {assignTarget :: VarReference, assignExpr :: Expr}
               | ProcedureCall {funName :: Name, funcArgs :: [Expr]}
               | IfStmt { ifCond :: Expr, thenStmt :: Statement,
                            elseStmt :: Maybe Statement}
               | ForStmt { loopVar :: Name, forStart, forEnd :: Expr,
                        forDirection :: ForDir,
                        forBody :: Statement}
               | WhileStmt { loopExpr :: Expr, loopBody :: Body}
               | RepeatStmt { loopExpr :: Expr, loopBody :: Body}
               | Goto Label
               | MarkLabel Label
               | Write {addNewline :: Bool,
                        writeArgs :: [WriteArg]
                        }
               | SubBlock [Statement]
        deriving Show

-- Unsure about these...
data VarReference = NameRef Name
                  | ArrayRef Name Expr
                deriving Show

data ForDir = UpTo | DownTo
        deriving Show

data WriteArg = WritePadded Int Expr | WritePlain Expr
    deriving Show

-- <statement> | BEGIN <statement-list> END
type Body = [Statement]

data Expr 
          = ConstExpr ConstValue
          | StringExpr String -- ?
          | VarExpr VarReference
          | FuncCall Name [Expr]
          | BinOp Expr BinOp Expr
          | NotOp Expr
          | ArrayAccess Name Expr
    deriving Show
            -- records?


data Declaration
            = NewVar Name Type
            | NewConst Name ConstValue
            | NewType Name Type
            | NewLabel Label
            | NewFunction Function
        deriving Show

type Label = Int -- Name?

data Function = Function {
                funcName :: Name,
                funcParams :: ParamList,
                funcReturnType :: Maybe Type, -- Nothing if procedure
                funcLocalVars :: ParamList, -- variables
                funcBody :: Maybe [Statement] -- or "forward"
            }
    deriving Show

type ParamList = [(Name,Type)]   

data ConstValue = ConstInt Int
                | ConstChar Char
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

data Type
    = BaseType BaseType
    -- For now, we just ignore "packed".
    | ArrayType { arrayIndexType :: BaseType , -- can be any ordinal type
                    arrayEltType :: Type
                }
    | FileType { fileEltType :: Type }
        deriving Show

data BaseType
    = NamedType Name
    -- prim: integer, char, real,
    | Range {lowerBound, upperBound :: Either Int Name} -- may refer to a constant
        
    deriving Show
