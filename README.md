# Overview
The `web2hs` project integrates TeX and friends with the Haskell programming language.
It reimplements the scaffolding
for building and running the original TeX sources on modern-day systems.  Furthermore, it
provides a way to run TeX from Haskell code *without invoking any external executables*.

A short history lesson: the original TeX sources were (and still are) written in
Pascal.  Nearly all modern TeX distributions use `web2c`, which modifies and
translates the original Pascal sources into corresponding C code.

We reimplement the Pascal-to-C conversion with an executable called `web2hs`, which was written
in Haskell.  We also provide several executables based on the standard TeX support
programs:

- `web2hs-tex` provides a running version of (plain) TeX.  (Due to known bugs, we make no
  claims that it will behave exactly the same as ``true" TeX implementations.)
- `web2hs-dvitype` parses prints the contents of a DVI file in human-readable form.
- `web2hs-tangle` and `web2hs-weave` process the literate WEB file format of the TeX source
  files.
- `web2hs-pooltype` parses and prints WEB .pool files.

Addtionally, the `web2hs-tex` package provides an interface for using TeX as a library in a
Haskell program, without invoking separate executables.
(See `tests/Test.hs` for an example usage.)  

## Status
This package is being provided as a technology preview, and should NOT be considered
release quality.  It has not been heavily tested and has known bugs; use it at your own risk with documents that you care about.

The program `web2hs-tex` currently passes Knuths' TRIP test (see
`tests/trip/README.md`).  Hypothetically, this suggests that it should produce
the same output as other TeX implementations.  However, we have not yet done
further significant testing to verify that fact; so again, use at your own risk.


# Installing

## 1. Create a ~/.web2hs file
We assume that you have a TeX distribution such as
[texlive](http://http://www.tug.org/texlive/) already installed on your computer.  Web2hs
currently does not provide necessary support files such as fonts and macro style files.

As a first step, create a `~/.web2hs` file which will point web2hs to your installed files.
For example, my
`~/.web2hs` file contains:

    /usr/local/texlive/2011basic/texmf-dist/ls-R

Each line
of that file should be a full path to a `ls-R` file as created by, e.g., `texlive`.  
## 2. Compile packages
If you do not already have a Haskell installation, you should first install
the [Haskell Platform](http://hackage.haskell.org/platform/).

Then, run the following commands from the root folder of this repo:

    cabal install web2hs/
    cabal install web2hs-lib/
    cabal install web2hs-tangle-boot/
    cabal install web2hs-web
    cabal install web2hs-texware
    cabal install web2hs-tex

# License
The Haskell code in this project is under the BSD3 license.  

The original WEB/Pascal sources were written by Donald E. Knuth and contain individual licenses:

- `web2hs-tex/tex.web`
- `web2hs-web/tangle.web`
- `web2hs-texware/dvitype.web`  
- `web2hs-web/weave.web`
- `web2hs-texware/pooltype.web`

The TRIP test (`tests/trip/`) was written by D. E. Knuth.

The `tie` program (`tie/*`) is included in this repository for
completeness.  It is currently only used for the TRIP test.  Its license
may be found in `tie/tie.w`.
