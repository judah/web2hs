import Distribution.Simple
import System.Process (rawSystem)
import Control.Monad (when, mapM_)
import System.Directory (doesFileExist, removeFile)
import System.FilePath ((<.>))

main = defaultMainWithHooks myHooks

myHooks = simpleUserHooks
            { confHook = \genericDescript flags -> do
                        lbi <- confHook simpleUserHooks genericDescript flags
                        mapM_ (generateC lbi) programs
                        return lbi
            , cleanHook = \packageDescript () hooks flags -> do
                            mapM_ removeFileIfExists
                                [prog <.> ext | prog <- programs,
                                                ext <- ["p","pool","h","c"]]
                            cleanHook simpleUserHooks packageDescript () hooks flags
            }

programs = ["dvitype","pooltype"]

generateC lbi prog = do
    -- TODO: don't do this each time?
    rawSystem "web2hs-tangle" [prog<.>"web", prog<.>"ch", prog<.>"p", prog<.>"pool"]
    rawSystem "web2hs" [prog<.>"p",prog<.>"c"]

removeFileIfExists f = do
    exists <- doesFileExist f
    when exists $ removeFile f
