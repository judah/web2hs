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
               | WhileStmt { loopExpr :: Expr, loopStmt :: Statement}
               | RepeatStmt { loopExpr :: Expr, loopBody :: Body}
               | CaseStmt { caseExpr :: Expr, caseList :: [CaseElt] }
               | Goto Label
               | MarkLabel Label
               | Write {addNewline :: Bool,
                        writeArgs :: [WriteArg]
                        }
               | SubBlock [Statement]
               | EmptyStatement
        deriving Show

-- Unsure about these...
data VarReference = NameRef Name
                  | ArrayRef VarReference [Expr]
                  | DeRef VarReference -- pointer dereference; also for files
                  | RecordRef VarReference Name
                deriving Show

data ForDir = UpTo | DownTo
        deriving Show

data CaseElt = CaseElt {
               -- TODO: In Pascal, cases can be any constant identifier
                caseConstants :: [Maybe ConstValue], -- nothing if "others:"
                caseStmt :: Statement
                }
    deriving Show

data WriteArg = WritePadded Integer Expr | WritePlain Expr
    deriving Show

-- <statement> | BEGIN <statement-list> END
type Body = [Statement]

data Expr 
          = ConstExpr ConstValue
          | VarExpr VarReference
          | FuncCall Name [Expr]
          | BinOp Expr BinOp Expr
          | NotOp Expr
          | Negate Expr
          | ArrayAccess Name [Expr]
    deriving Show
            -- records?


data Declaration
            = NewVar Name Type
            | NewConst Name ConstValue
            | NewType Name Type
            | NewLabel Label
            | NewFunction Function
        deriving Show

type Label = Integer -- Name?

data Function = Function {
                funcName :: Name,
                funcParams :: [FuncParam],
                funcReturnType :: Maybe Type, -- Nothing if procedure
                funcLabels :: [Label],
                funcLocalVars :: ParamList, -- variables
                funcBody :: Maybe [Statement] -- or "forward"
            }
    deriving Show

type ParamList = [(Name,Type)]

data FuncParam = FuncParam {paramName :: Name, paramType :: Type, paramByRef :: Bool}
            deriving Show

data ConstValue = ConstInt Integer
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
    | ArrayType { arrayIndexType :: [BaseType] , -- can be any ordinal type
                    arrayEltType :: Type
                }
    | FileType { fileEltType :: Type }
    | RecordType { recordFields :: [(Name,BaseType)] }
        deriving Show

data BaseType
    = NamedType Name
    -- prim: integer, char, real,
    | Range {lowerBound, upperBound :: Either Integer Name} -- may refer to a constant
        
    deriving Show
