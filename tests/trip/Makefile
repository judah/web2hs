ROOTDIR=../..
TEXSOURCEDIR=../../web2hs-tex
TIESOURCEDIR=../../tie
WEBLIBDIR=../../web2hs-lib/cbits
EXPECTED=expected-output

GHC=ghc
GCC=gcc

all: tex-trip trip-output.diff

tie: $(TIESOURCEDIR)/tie.c
	$(GCC) -o tie $(TIESOURCEDIR)/tie.c

trip2.ch: tie trip.ch $(TEXSOURCEDIR)/tex.web $(TEXSOURCEDIR)/tex.ch
	./tie -c trip2.ch $(TEXSOURCEDIR)/tex.web $(TEXSOURCEDIR)/tex.ch trip.ch

tex.p: $(TEXSOURCEDIR)/tex.web trip2.ch
	web2hs-tangle $(TEXSOURCEDIR)/tex.web trip2.ch tex.p tex.pool

tex.c: tex.p
	web2hs tex.p tex.c

tex-trip: tex.c $(TEXSOURCEDIR)/TeX.hs $(WEBLIBDIR)/web2hs_pascal_builtins.h
	$(GHC) tex.c $(TEXSOURCEDIR)/TeX.hs -I$(WEBLIBDIR) \
	    -o tex-trip \
	    -XRecordWildCards -XDeriveDataTypeable \
	    -hidir . -odir .

clean:
	rm -f tie trip2.ch tex.p tex.pool
	rm -f tex.p tex.c tex.h tex.o Main.hi Main.o tex-trip
	rm -f trip.dvi trip.log trip.fot trip.typ 8terminal.tex trip.fmt
	rm -f tripin.log tripin.fot
	rm -f trip-output.diff

trip-output.diff: tex-trip
# use (|| true) since trip.tex causes (recoverable) errors,
# which makes bash think that this command failed.
# (similarly, diff returns failure if the files aren't exactly the same.)
	printf "\n\\input trip\n" | ./tex-trip --initex > tripin.fot || true
	mv trip.log tripin.log
	printf " &trip  trip \n" | ./tex-trip --initex > trip.fot || true
	web2hs-dvitype --output-level=2 --start-page="*.*.*.*.*.*.*.*.*.*" --max-pages=1000000 --resolution=72.27 --magnification=0 trip.dvi > trip.typ
	
	diff tripin.log $(EXPECTED)/tripin.log > trip-output.diff || true
	diff trip.log $(EXPECTED)/trip.log >> trip-output.diff || true
	diff trip.fot $(EXPECTED)/trip.fot >> trip-output.diff || true
	diff trip.typ $(EXPECTED)/trip.typ >> trip-output.diff || true
