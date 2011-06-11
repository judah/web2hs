-- | This module defines an AST for the subset of Pascal used by TeX and friends.
module Language.Pascal.Syntax where

type Name = String

type Label = Integer

-- Using:
-- http://www.chasanc.com/index.php/Compiler/Backus-Naur-Form-BNF-of-Pascal-Language.html
-- Much better:
-- http://www.freepascal.org/docs-html/ref/ref.html

data Program = Program {
                progName :: Name,
                progArgs :: [Name],
                progBlock :: Block
            }

data Block = Block {
                blockLabels :: [Label],
                blockConstants :: [(Name,ConstValue)],
                blockTypes :: [(Name,Type)],
                blockVars :: [(Name,Type)],
                blockFunctions :: [FunctionDecl],
                blockStatements :: StatementList
            }

data FunctionDecl = FuncForward {funcName :: Name, funcHeading :: FuncHeading}
                 -- TODO: grammar can't tell when we're defining previously-declared
                 -- forward procedures.
                 -- | FuncIdent {funcName :: Name, funcBlock :: Block}
                 | Func {funcName :: Name, funcHeading :: FuncHeading, 
                         funcBlock :: Block}

data FuncHeading = FuncHeading {
                    funcArgs :: [FuncParam],
                    funcReturnType :: Maybe Type -- Nothing if it's a procedure.
                }
                
data FuncParam = FuncParam {paramName :: Name, paramType :: Type, paramByRef :: Bool}
            deriving Show


--------------------------------------------

-- I'm making a simplification here:
-- Don't allow labels at the top-level of a compound statement.

type StatementList = [(Maybe Label,Statement)]

data Statement =
               AssignStmt {assignTarget :: VarReference, assignExpr :: Expr}
               | ProcedureCall {funName :: Name, procArgs :: [Expr]}
               | IfStmt { ifCond :: Expr, thenStmt :: Statement,
                            elseStmt :: Maybe Statement}
               | ForStmt { loopVar :: Name, forStart, forEnd :: Expr,
                        forDirection :: ForDir,
                        forBody :: Statement}
               | WhileStmt { loopExpr :: Expr, loopStmt :: Statement}
               | RepeatStmt { loopExpr :: Expr, loopBody :: StatementList }
               | CaseStmt { caseExpr :: Expr, caseList :: [CaseElt] }
               | Goto Label
               | MarkLabel Label
               | Write {addNewline :: Bool,
                        writeArgs :: [WriteArg]
                        }
               | CompoundStmt StatementList
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
    | RecordType { recordFields :: [(Name,Type)] }
        deriving Show

data BaseType
    = NamedType Name
    -- prim: integer, char, real,
    | Range {lowerBound, upperBound :: Either Integer Name} -- may refer to a constant
        
    deriving Show
