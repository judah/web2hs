module Language.Pascal.Interpreter.Base where

-- TODO: more efficient.
import Data.Array
import System.IO

import Control.Monad.IO.Class
import Control.Monad.Trans.Class
import Control.Monad.Trans.State.Strict
import Control.Monad.Trans.Error

import qualified Data.IntMap as IntMap

type File = Handle
type PArray = Array Int

-- Basic trick was taken from here, but I've definitely seen it elsewhere.
-- http://ryani.freeshell.org/haskell/RefMonad.hs

data TypeRep a where
    IntRep :: TypeRep Int
    RealRep :: TypeRep Double
    FileRep :: TypeRep File
    ArrayRep :: TypeRep a -> TypeRep (PArray a)
    RecordRep :: RecordRep a -> TypeRep (Record a)

data RecordRep a where
    NilRep :: RecordRep Nil
    ConsRep :: TypeRep a -> RecordRep b -> RecordRep (Cons a b)

data Nil = Nil
data Cons a b = Cons a b
newtype Record a = Record a

class Typeable a where
    typeRep :: TypeRep a

instance Typeable Int where
    typeRep = IntRep

instance Typeable Double where
    typeRep = RealRep

instance Typeable a => Typeable (PArray a) where
    typeRep = ArrayRep typeRep

instance RecordTypeable a => Typeable (Record a) where
    typeRep = RecordRep recordTypeRep

class RecordTypeable a where
    recordTypeRep :: RecordRep a

instance RecordTypeable Nil where
    recordTypeRep = NilRep

instance (Typeable a, RecordTypeable b) => RecordTypeable (Cons a b) where
    recordTypeRep = ConsRep typeRep recordTypeRep


-----------------------
-- Testing for equality

data TEq a b where Refl :: TEq a a

typeEq :: TypeRep a -> TypeRep b -> Maybe (TEq a b)
typeEq IntRep IntRep = Just Refl
typeEq RealRep RealRep = Just Refl
typeEq FileRep FileRep = Just Refl
typeEq (ArrayRep x) (ArrayRep y) = do
    Refl <- typeEq x y
    return Refl
typeEq (RecordRep x) (RecordRep y) = do
    Refl <- recordTypeEq x y
    return Refl

recordTypeEq :: RecordRep a -> RecordRep b -> Maybe (TEq a b)
recordTypeEq NilRep NilRep = Just Refl
recordTypeEq (ConsRep x xs) (ConsRep y ys) = do
    Refl <- typeEq x y
    Refl <- recordTypeEq xs ys
    return Refl

------
-- casting

cast :: TypeRep a -> TypeRep b -> a -> Maybe b
cast r1 r2 x = do
    Refl <- typeEq r1 r2
    return x
    
---------
-- Environments

data TypedValue where
    TypedValue :: TypeRep a -> a -> TypedValue

data Variable a = Variable {
                    varIsGlobal :: Bool,
                    varID :: Int
                    }

type Scope = IntMap.IntMap TypedValue

data Environment = Environment {
                        localScope, globalScope :: Scope
                    }

lookupVar :: Typeable a => Variable a -> Environment -> Maybe a
lookupVar Variable{..} Environment {..} = do
    let scope = if varIsGlobal then globalScope else localScope
    TypedValue rep x <- IntMap.lookup varID scope
    cast rep typeRep x

-- Doesn't check whether the variable was previously set to a different value.
insertVar :: Typeable a => Variable a -> a -> Environment -> Environment
insertVar Variable{..} x e@Environment{..}
    | varIsGlobal   = e {globalScope = IntMap.insert varID
                                            (TypedValue typeRep x) globalScope}
    | otherwise = e { localScope = IntMap.insert varID
                                            (TypedValue typeRep x) localScope}

--------
-- Environment monad
                                    
-- For now, no good error handling
newtype PascalM m a = PascalM (StateT Environment m a)
                        deriving (Monad, MonadIO)

instance MonadTrans PascalM where
    lift = PascalM . lift

getVar :: (Monad m, Typeable a) => Variable a -> PascalM m a
getVar v = do
            ma <- PascalM $ gets $ lookupVar v
            case ma of
                Nothing -> error "Mismatched tyes"
                Just x -> return x

setVar :: (Monad m, Typeable a) => Variable a -> a -> PascalM m ()
setVar v x = PascalM $ modify $ insertVar v x
