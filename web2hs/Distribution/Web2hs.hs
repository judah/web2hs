module Distribution.Web2hs(web2hsUserHooks) where

import Distribution.Simple
import Distribution.PackageDescription
import System.Process (readProcessWithExitCode, showCommandForUser)
import System.Exit (ExitCode(..), exitWith)
import System.FilePath (replaceExtension)
import System.Directory (doesFileExist, removeFile)
import System.IO (hPutStr, hPutStrLn, stderr, stdout)
import Control.Monad (when)

web2hsWebFiles :: PackageDescription -> [String]
web2hsWebFiles p = [f | ("x-web2hs-source",f) <- customFieldsPD p]

-- For bootstrapping tangle, must call the helper "web2hs-tangle-boot"
tangleProgram :: PackageDescription -> String
tangleProgram p = let 
    tangles = [p | ("x-web2hs-tangle",p) <- customFieldsPD p]
    in if null tangles then "web2hs-tangle" else last tangles
                    
-- | Looks for fields of the form
-- 
-- > x-web2hs-source: dvitype.web
--
-- For each such field, it uses tangle and web2hs to generate
-- the corresponding .c/.h file during the "configure" step.
-- Futhermore, it removes all generated files during the "clean" step.
web2hsUserHooks :: UserHooks -> UserHooks
web2hsUserHooks hooks = hooks
    { confHook = \genericDescript flags -> do
        let pd = packageDescription $ fst genericDescript
        let progs = web2hsWebFiles pd
        mapM_ (generateC (tangleProgram pd)) progs
        confHook hooks genericDescript flags
    , cleanHook = \packageDescript () hooks' flags -> do
                    mapM_ removeProgFiles
                        $ web2hsWebFiles packageDescript
                    cleanHook hooks packageDescript () hooks' flags
    }

generateC tangle prog = do
    rawSystem' tangle
        $ [prog] ++ map (replaceExtension prog) ["ch","p","pool"]
    rawSystem' "web2hs"
        $ map (replaceExtension prog) ["p","c"]

removeProgFiles prog = mapM_ (removeFileIfExists . replaceExtension prog)
                        ["p","pool","h","c"]

removeFileIfExists f = do
    exists <- doesFileExist f
    when exists $ removeFile f

rawSystem' p args = do
    hPutStrLn stdout $ showCommandForUser p args
    (exit, out,err) <- readProcessWithExitCode p args ""
    hPutStr stdout out
    hPutStr stderr err
    when (exit /= ExitSuccess)
        $ exitWith exit
