import Distribution.Simple
import Distribution.Web2hs

main = defaultMainWithHooks $ web2hsUserHooks simpleUserHooks

