import Distribution.Simple
import System.Process (rawSystem)
import Control.Monad (when)
import System.Directory (doesFileExist, removeFile)

main = defaultMainWithHooks myHooks

myHooks = simpleUserHooks
            { confHook = \genericDescript flags -> do
                        lbi <- confHook simpleUserHooks genericDescript flags
                        generateTangle lbi
                        return lbi
            , cleanHook = \packageDescript () hooks flags -> do
                            removeFileIfExists "tangle.c"
                            cleanHook simpleUserHooks packageDescript () hooks flags
            }

generateTangle lbi = do
    rawSystem "web2hs" ["tangle.p","tangle.c"]

removeFileIfExists f = do
    exists <- doesFileExist f
    when exists $ removeFile f
