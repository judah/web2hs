module Distribution.Web2hs(web2hsUserHooks) where

import Distribution.Simple
import Distribution.Simple.LocalBuildInfo
import Distribution.Simple.Utils (createDirectoryIfMissingVerbose)
import Distribution.Simple.Setup (fromFlag, buildVerbosity, BuildFlags)
import Distribution.PackageDescription
import System.Process (readProcessWithExitCode, showCommandForUser)
import System.Exit (ExitCode(..), exitWith)
import System.FilePath (replaceExtension, takeBaseName, (<.>), (</>) )
import System.IO (hPutStr, hPutStrLn, stderr, stdout)
import Control.Monad (when)
import Data.Traversable (forM)
import Data.List (nub)

web2hsWebFiles :: BuildInfo -> [String]
web2hsWebFiles e = [f | ("x-web2hs-source",f) <- customFieldsBI e]

-- Keep all generated files for all executables in one folder.
-- This way we can get at all of the .pool files at once.
web2hsBuildDir :: LocalBuildInfo -> FilePath
web2hsBuildDir lbi = buildDir lbi </> "web2hs-gen"

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
    { buildHook = \pd lbi hooks' flags -> do
        putStrLn "Preprocessing WEB files..."
        exes <- forM (executables pd) $ \exe -> do
                    bi <- preprocessBuildInfo lbi flags $ buildInfo exe
                    return exe {buildInfo = bi}
        maybe_lib <- forM (library pd) $ \lib -> do
                    bi <- preprocessBuildInfo lbi flags $ libBuildInfo lib
                    return lib {libBuildInfo = bi}
        -- TODO: nub
        buildHook hooks
            pd { executables = exes, library = maybe_lib }
            lbi hooks' flags
    , copyHook = copyWithPool (copyHook hooks)
    , instHook = copyWithPool (instHook hooks)
    }

preprocessBuildInfo :: LocalBuildInfo -> BuildFlags -> BuildInfo -> IO BuildInfo
preprocessBuildInfo lbi flags bi = do
    let verbosity = fromFlag (buildVerbosity flags)
    let parent = web2hsBuildDir lbi
    createDirectoryIfMissingVerbose verbosity True parent
    cFiles <- forM (web2hsWebFiles bi) $ \f -> do
                let cOutput = parent </> takeBaseName f <.> "c"
                generateC (tangleProgram $ localPkgDescr lbi) f cOutput
                return cOutput
    return bi
            { cSources = cFiles ++ cSources bi
            , includeDirs = parent : includeDirs bi
            }
 

-- Copy the .pool files so they can be accessed from the executable as data files.
copyWithPool act pd lbi hooks' flags = do
            let poolDir = web2hsBuildDir lbi
            let webFiles = [f | exe <- executables pd, f <- web2hsWebFiles $ buildInfo exe]
                        ++ maybe [] (web2hsWebFiles . libBuildInfo) (library pd)
            let poolFiles = nub $ map (flip replaceExtension "pool") webFiles
            act pd { dataFiles = poolFiles 
                   , dataDir = poolDir
                   }
                lbi hooks' flags

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
