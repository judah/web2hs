import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Utils (createDirectoryIfMissingVerbose)
import Distribution.Simple.Setup (fromFlag, buildVerbosity)
import Distribution.PackageDescription
import System.Process (rawSystem)
import System.FilePath ( (</>) )
import Control.Monad (when)

main = defaultMainWithHooks myHooks

myHooks = simpleUserHooks
            { 
            buildHook = \pd lbi hooks' flags -> do
                            createDirectoryIfMissingVerbose (fromFlag (buildVerbosity flags))
                                    True (parentDir lbi)
                            generateTangle lbi
                            buildHook simpleUserHooks (addCFile lbi pd) lbi hooks' flags
            }

tanglePascalSrc = "tangle.p"
parentDir = buildDir
tangleCLoc lbi = buildDir lbi </> "tangle.c"

generateTangle lbi = do
    rawSystem "web2hs" [tanglePascalSrc, tangleCLoc lbi]

addCFile lbi pd@PackageDescription {executables = [exec@Executable{buildInfo=bi}]}
    = pd {executables = [exec {buildInfo = bi { cSources = [tangleCLoc lbi] ++ cSources bi}}]}
