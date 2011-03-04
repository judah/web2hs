{4:}{9:}{$C-,A+,D-}{[$C+,D+]}{:9}program TEX;label{6:}1,9998,9999;
{:6}const{11:}memmax=30000;memmin=0;bufsize=500;errorline=72;
halferrorline=42;maxprintline=79;stacksize=200;maxinopen=6;fontmax=75;
fontmemsize=20000;paramsize=60;nestsize=40;maxstrings=3000;
stringvacancies=8000;poolsize=32000;savesize=600;triesize=8000;
trieopsize=500;dvibufsize=800;filenamesize=40;
poolname='TeXformats:TEX.POOL                     ';
{:11}type{18:}ASCIIcode=0..255;{:18}{25:}eightbits=0..255;
alphafile=packed file of char;bytefile=packed file of eightbits;
{:25}{38:}poolpointer=0..poolsize;strnumber=0..maxstrings;
packedASCIIcode=0..255;{:38}{101:}scaled=integer;
nonnegativeinteger=0..2147483647;smallnumber=0..63;
{:101}{109:}glueratio=real;{:109}{113:}quarterword=0..255;
halfword=0..65535;twochoices=1..2;fourchoices=1..4;


begin
A := 42;
end.
