import Distribution.Simple
import System.Process (rawSystem)
import Control.Monad (when)
import System.Directory (doesFileExist, removeFile)

main = defaultMainWithHooks myHooks

myHooks = simpleUserHooks
            { buildHook = \pd lbi hooks' flags -> do
                        generateTangle
                        buildHook simpleUserHooks pd lbi hooks' flags
            , cleanHook = \packageDescript () hooks flags -> do
                            mapM_ removeFileIfExists ["tangle.c","tangle.h"]
                            cleanHook simpleUserHooks packageDescript () hooks flags
            }

generateTangle = do
    rawSystem "web2hs" ["tangle.p","tangle.c"]

removeFileIfExists f = do
    exists <- doesFileExist f
    when exists $ removeFile f
