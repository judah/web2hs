# Instructions
The TRIP test was designed by D. E. Knuth to test the correctness of
implementations of TeX.  

To run the test for `web2hs`, run `make all` from inside this folder.  That
command will build a customized version of TeX with the internal constants
required by the test.

If all goes well, it will produce the file `trip-output.diff`.  That file may
be examined to check whether the differences from the expected outputs are all
trivial.
