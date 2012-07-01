import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.PackageDescription
import System.FilePath ( (</>) )
import System.Directory (renameFile)

import Distribution.Web2hs

main = defaultMainWithHooks
        $ generateFormats
        $ web2hsUserHooks simpleUserHooks

generateFormats hooks = hooks
    { buildHook = \pd lbi hooks' flags -> do
                    buildHook hooks pd lbi hooks' flags
                    let execName = "web2hs-tex"
                    let execPath = buildDir lbi </> execName </> execName
                    putStrLn "Generating format files..."
                    rawSystem' execPath ["--initex", "plain.tex", "\\dump"]
                    renameFile "plain.fmt" (web2hsBuildDir lbi </> "plain.fmt")
                    renameFile "plain.log" (web2hsBuildDir lbi </> "plain.log")
    , copyHook = copyWithFormat (copyHook hooks)
    , instHook = copyWithFormat (instHook hooks)
    }
    
copyWithFormat act pd lbi hooks' flags = do
    let formatPath = web2hsBuildDir lbi </> "plain.fmt"
    act pd { dataFiles = "plain.fmt" : dataFiles pd } lbi hooks' flags
