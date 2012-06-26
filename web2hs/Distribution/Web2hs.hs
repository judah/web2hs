module Distribution.Web2hs(web2hsUserHooks) where

import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Utils (createDirectoryIfMissingVerbose)
import Distribution.Simple.Setup (fromFlag, buildVerbosity)
import Distribution.PackageDescription
import System.Process (readProcessWithExitCode, showCommandForUser)
import System.Exit (ExitCode(..), exitWith)
import System.FilePath (replaceExtension, takeBaseName, (<.>), (</>) )
import System.IO (hPutStr, hPutStrLn, stderr, stdout)
import Control.Monad (when, forM)

web2hsWebFiles :: Executable -> [String]
web2hsWebFiles e = [f | ("x-web2hs-source",f) <- customFieldsBI $ buildInfo e]

web2hsBuildDir :: LocalBuildInfo -> Executable -> FilePath
web2hsBuildDir lbi e = buildDir lbi </> exeName e </> "web2hs"

-- For bootstrapping tangle, must call the helper "web2hs-tangle-boot"
tangleProgram :: PackageDescription -> String
tangleProgram p = let 
    tangles = [p | ("x-web2hs-tangle",p) <- customFieldsPD p]
    in if null tangles then "web2hs-tangle" else last tangles
                    
-- | This changes the given hooks to look for executables with fields of the form
-- 
-- > x-web2hs-source: dvitype.web
--
-- For each such field, it uses tangle and web2hs to generate
-- the corresponding .c/.h files.  (They are stored in "dist/build", and
-- "cabal clean" will delete them along with everything else in those directories.)
-- It also changes the executables to build against the generated files.
web2hsUserHooks :: UserHooks -> UserHooks
web2hsUserHooks hooks = hooks
    {
    buildHook = \pd lbi hooks' flags -> do
        exes <- forM (executables pd) $ \exe -> do
                    let bi = buildInfo exe
                    let verbosity = fromFlag (buildVerbosity flags)
                    let parent = web2hsBuildDir lbi exe
                    createDirectoryIfMissingVerbose verbosity True parent
                    cFiles <- forM (web2hsWebFiles exe) $ \f -> do
                                let cOutput = parent </> takeBaseName f <.> "c"
                                generateC (tangleProgram pd) f cOutput
                                return cOutput
                    return exe { buildInfo = bi
                                    { cSources = cFiles ++ cSources bi
                                    , includeDirs = parent : includeDirs bi
                                    } 
                               }
        buildHook hooks
            pd { executables = exes } lbi hooks' flags
    }

generateC tangle webFile cFile = do
    let changeFile = replaceExtension webFile "ch"
    let pascalFile = replaceExtension cFile "p"
    let poolFile = replaceExtension cFile "pool"
    rawSystem' tangle [webFile, changeFile, pascalFile, poolFile]
    rawSystem' "web2hs" [pascalFile, cFile]

rawSystem' p args = do
    hPutStrLn stdout $ showCommandForUser p args
    (exit, out,err) <- readProcessWithExitCode p args ""
    hPutStr stdout out
    hPutStr stderr err
    when (exit /= ExitSuccess)
        $ exitWith exit
