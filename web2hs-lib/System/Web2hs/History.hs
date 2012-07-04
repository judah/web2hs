-- | This modules defines a datatype for describing the \"history\" of a computation;
-- namely, whether any warnings or errors occurred.
module System.Web2hs.History (
                    History(..),
                    fromCInt,
                    exitWithHistory,
                    ) where

import Foreign.C
import System.Exit

data History = Spotless -- ^ No errors or warnings occurred.
            | Warnings -- ^ Warnings occurred, but no errors.
            | Errors -- ^ Errors occurred, but they were not fatal.
            | FatalErrors -- ^ Fatal errors caused premature termination.
    deriving (Show,Eq,Ord,Enum)
        -- deriving Enum sets Spotless==0, Warnings==1, etc., which
        -- matches the Pascal definitions.

fromCInt :: CInt -> History
fromCInt = toEnum . fromEnum

-- | If any errors occurred, call 'exitFailure'.  Otherwise, call 'exitSuccess'.
exitWithHistory :: History -> IO a
exitWithHistory h
    | h >= Errors = exitFailure
    | otherwise = exitSuccess
