{4:}{9:}{$C-,A+,D-}{[$C+,D+]}{:9}program ETEX;label{6:}1,9998,9999;
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
twohalves=packed record rh:halfword;case twochoices of 1:(lh:halfword);
2:(b0:quarterword;b1:quarterword);end;
fourquarters=packed record b0:quarterword;b1:quarterword;b2:quarterword;
b3:quarterword;end;
memoryword=record case fourchoices of 1:(int:integer);2:(gr:glueratio);
3:(hh:twohalves);4:(qqqq:fourquarters);end;wordfile=file of memoryword;
{:113}{150:}glueord=0..3;
{:150}{212:}liststaterecord=record modefield:-203..203;
headfield,tailfield:halfword;eTeXauxfield:halfword;
pgfield,mlfield:integer;auxfield:memoryword;end;
{:212}{269:}groupcode=0..16;
{:269}{300:}instaterecord=record statefield,indexfield:quarterword;
startfield,locfield,limitfield,namefield:halfword;end;
{:300}{548:}internalfontnumber=0..fontmax;fontindex=0..fontmemsize;
{:548}{594:}dviindex=0..dvibufsize;{:594}{920:}triepointer=0..triesize;
{:920}{925:}hyphpointer=0..307;{:925}{1409:}savepointer=0..savesize;
{:1409}var{13:}bad:integer;{:13}{20:}xord:array[char]of ASCIIcode;
xchr:array[ASCIIcode]of char;
{:20}{26:}nameoffile:packed array[1..filenamesize]of char;
namelength:0..filenamesize;
{:26}{30:}buffer:array[0..bufsize]of ASCIIcode;first:0..bufsize;
last:0..bufsize;maxbufstack:0..bufsize;{:30}{32:}termin:alphafile;
termout:alphafile;
{:32}{39:}strpool:packed array[poolpointer]of packedASCIIcode;
strstart:array[strnumber]of poolpointer;poolptr:poolpointer;
strptr:strnumber;initpoolptr:poolpointer;initstrptr:strnumber;
{:39}{50:}poolfile:alphafile;{:50}{54:}logfile:alphafile;selector:0..21;
dig:array[0..22]of 0..15;tally:integer;termoffset:0..maxprintline;
fileoffset:0..maxprintline;trickbuf:array[0..errorline]of ASCIIcode;
trickcount:integer;firstcount:integer;{:54}{73:}interaction:0..3;
{:73}{76:}deletionsallowed:boolean;setboxallowed:boolean;history:0..3;
errorcount:-1..100;{:76}{79:}helpline:array[0..5]of strnumber;
helpptr:0..6;useerrhelp:boolean;{:79}{96:}interrupt:integer;
OKtointerrupt:boolean;{:96}{104:}aritherror:boolean;remainder:scaled;
{:104}{115:}tempptr:halfword;
{:115}{116:}mem:array[memmin..memmax]of memoryword;lomemmax:halfword;
himemmin:halfword;{:116}{117:}varused,dynused:integer;
{:117}{118:}avail:halfword;memend:halfword;{:118}{124:}rover:halfword;
{:124}{165:}{free:packed array[memmin..memmax]of boolean;
wasfree:packed array[memmin..memmax]of boolean;
wasmemend,waslomax,washimin:halfword;panicking:boolean;}
{:165}{173:}fontinshortdisplay:integer;
{:173}{181:}depththreshold:integer;breadthmax:integer;
{:181}{213:}nest:array[0..nestsize]of liststaterecord;
nestptr:0..nestsize;maxneststack:0..nestsize;curlist:liststaterecord;
shownmode:-203..203;{:213}{246:}oldsetting:0..21;
{:246}{253:}eqtb:array[1..6121]of memoryword;
xeqlevel:array[5268..6121]of quarterword;
{:253}{256:}hash:array[514..2880]of twohalves;hashused:halfword;
nonewcontrolsequence:boolean;cscount:integer;
{:256}{271:}savestack:array[0..savesize]of memoryword;
saveptr:0..savesize;maxsavestack:0..savesize;curlevel:quarterword;
curgroup:groupcode;curboundary:0..savesize;{:271}{286:}magset:integer;
{:286}{297:}curcmd:eightbits;curchr:halfword;curcs:halfword;
curtok:halfword;
{:297}{301:}inputstack:array[0..stacksize]of instaterecord;
inputptr:0..stacksize;maxinstack:0..stacksize;curinput:instaterecord;
{:301}{304:}inopen:0..maxinopen;openparens:0..maxinopen;
inputfile:array[1..maxinopen]of alphafile;line:integer;
linestack:array[1..maxinopen]of integer;{:304}{305:}scannerstatus:0..5;
warningindex:halfword;defref:halfword;
{:305}{308:}paramstack:array[0..paramsize]of halfword;
paramptr:0..paramsize;maxparamstack:integer;
{:308}{309:}alignstate:integer;{:309}{310:}baseptr:0..stacksize;
{:310}{333:}parloc:halfword;partoken:halfword;
{:333}{361:}forceeof:boolean;{:361}{382:}curmark:array[0..4]of halfword;
{:382}{387:}longstate:111..114;
{:387}{388:}pstack:array[0..8]of halfword;{:388}{410:}curval:integer;
curvallevel:0..5;{:410}{438:}radix:smallnumber;
{:438}{447:}curorder:glueord;
{:447}{480:}readfile:array[0..15]of alphafile;
readopen:array[0..16]of 0..2;{:480}{489:}condptr:halfword;iflimit:0..4;
curif:smallnumber;ifline:integer;{:489}{493:}skipline:integer;
{:493}{512:}curname:strnumber;curarea:strnumber;curext:strnumber;
{:512}{513:}areadelimiter:poolpointer;extdelimiter:poolpointer;
{:513}{520:}TEXformatdefault:packed array[1..20]of char;
{:520}{527:}nameinprogress:boolean;jobname:strnumber;logopened:boolean;
{:527}{532:}dvifile:bytefile;outputfilename:strnumber;logname:strnumber;
{:532}{539:}tfmfile:bytefile;
{:539}{549:}fontinfo:array[fontindex]of memoryword;fmemptr:fontindex;
fontptr:internalfontnumber;
fontcheck:array[internalfontnumber]of fourquarters;
fontsize:array[internalfontnumber]of scaled;
fontdsize:array[internalfontnumber]of scaled;
fontparams:array[internalfontnumber]of fontindex;
fontname:array[internalfontnumber]of strnumber;
fontarea:array[internalfontnumber]of strnumber;
fontbc:array[internalfontnumber]of eightbits;
fontec:array[internalfontnumber]of eightbits;
fontglue:array[internalfontnumber]of halfword;
fontused:array[internalfontnumber]of boolean;
hyphenchar:array[internalfontnumber]of integer;
skewchar:array[internalfontnumber]of integer;
bcharlabel:array[internalfontnumber]of fontindex;
fontbchar:array[internalfontnumber]of 0..256;
fontfalsebchar:array[internalfontnumber]of 0..256;
{:549}{550:}charbase:array[internalfontnumber]of integer;
widthbase:array[internalfontnumber]of integer;
heightbase:array[internalfontnumber]of integer;
depthbase:array[internalfontnumber]of integer;
italicbase:array[internalfontnumber]of integer;
ligkernbase:array[internalfontnumber]of integer;
kernbase:array[internalfontnumber]of integer;
extenbase:array[internalfontnumber]of integer;
parambase:array[internalfontnumber]of integer;
{:550}{555:}nullcharacter:fourquarters;{:555}{592:}totalpages:integer;
maxv:scaled;maxh:scaled;maxpush:integer;lastbop:integer;
deadcycles:integer;doingleaders:boolean;c,f:quarterword;
ruleht,ruledp,rulewd:scaled;g:halfword;lq,lr:integer;
{:592}{595:}dvibuf:array[dviindex]of eightbits;halfbuf:dviindex;
dvilimit:dviindex;dviptr:dviindex;dvioffset:integer;dvigone:integer;
{:595}{605:}downptr,rightptr:halfword;{:605}{616:}dvih,dviv:scaled;
curh,curv:scaled;dvif:internalfontnumber;curs:integer;
{:616}{646:}totalstretch,totalshrink:array[glueord]of scaled;
lastbadness:integer;{:646}{647:}adjusttail:halfword;
{:647}{661:}packbeginline:integer;{:661}{684:}emptyfield:twohalves;
nulldelimiter:fourquarters;{:684}{719:}curmlist:halfword;
curstyle:smallnumber;cursize:smallnumber;curmu:scaled;
mlistpenalties:boolean;{:719}{724:}curf:internalfontnumber;
curc:quarterword;curi:fourquarters;{:724}{764:}magicoffset:integer;
{:764}{770:}curalign:halfword;curspan:halfword;curloop:halfword;
alignptr:halfword;curhead,curtail:halfword;{:770}{814:}justbox:halfword;
{:814}{821:}passive:halfword;printednode:halfword;passnumber:halfword;
{:821}{823:}activewidth:array[1..6]of scaled;
curactivewidth:array[1..6]of scaled;background:array[1..6]of scaled;
breakwidth:array[1..6]of scaled;{:823}{825:}noshrinkerroryet:boolean;
{:825}{828:}curp:halfword;secondpass:boolean;finalpass:boolean;
threshold:integer;{:828}{833:}minimaldemerits:array[0..3]of integer;
minimumdemerits:integer;bestplace:array[0..3]of halfword;
bestplline:array[0..3]of halfword;{:833}{839:}discwidth:scaled;
{:839}{847:}easyline:halfword;lastspecialline:halfword;
firstwidth:scaled;secondwidth:scaled;firstindent:scaled;
secondindent:scaled;{:847}{872:}bestbet:halfword;fewestdemerits:integer;
bestline:halfword;actuallooseness:integer;linediff:integer;
{:872}{892:}hc:array[0..65]of 0..256;hn:smallnumber;ha,hb:halfword;
hf:internalfontnumber;hu:array[0..63]of 0..256;hyfchar:integer;
curlang,initcurlang:ASCIIcode;lhyf,rhyf,initlhyf,initrhyf:integer;
hyfbchar:halfword;{:892}{900:}hyf:array[0..64]of 0..9;initlist:halfword;
initlig:boolean;initlft:boolean;{:900}{905:}hyphenpassed:smallnumber;
{:905}{907:}curl,curr:halfword;curq:halfword;ligstack:halfword;
ligaturepresent:boolean;lfthit,rthit:boolean;
{:907}{921:}trie:array[triepointer]of twohalves;
hyfdistance:array[1..trieopsize]of smallnumber;
hyfnum:array[1..trieopsize]of smallnumber;
hyfnext:array[1..trieopsize]of quarterword;
opstart:array[ASCIIcode]of 0..trieopsize;
{:921}{926:}hyphword:array[hyphpointer]of strnumber;
hyphlist:array[hyphpointer]of halfword;hyphcount:hyphpointer;
{:926}{943:}trieophash:array[-trieopsize..trieopsize]of 0..trieopsize;
trieused:array[ASCIIcode]of quarterword;
trieoplang:array[1..trieopsize]of ASCIIcode;
trieopval:array[1..trieopsize]of quarterword;trieopptr:0..trieopsize;
{:943}{947:}triec:packed array[triepointer]of packedASCIIcode;
trieo:packed array[triepointer]of quarterword;
triel:packed array[triepointer]of triepointer;
trier:packed array[triepointer]of triepointer;trieptr:triepointer;
triehash:packed array[triepointer]of triepointer;
{:947}{950:}trietaken:packed array[1..triesize]of boolean;
triemin:array[ASCIIcode]of triepointer;triemax:triepointer;
trienotready:boolean;{:950}{971:}bestheightplusdepth:scaled;
{:971}{980:}pagetail:halfword;pagecontents:0..2;pagemaxdepth:scaled;
bestpagebreak:halfword;leastpagecost:integer;bestsize:scaled;
{:980}{982:}pagesofar:array[0..7]of scaled;lastglue:halfword;
lastpenalty:integer;lastkern:scaled;lastnodetype:integer;
insertpenalties:integer;{:982}{989:}outputactive:boolean;
{:989}{1032:}mainf:internalfontnumber;maini:fourquarters;
mainj:fourquarters;maink:fontindex;mainp:halfword;mains:integer;
bchar:halfword;falsebchar:halfword;cancelboundary:boolean;
insdisc:boolean;{:1032}{1074:}curbox:halfword;
{:1074}{1266:}aftertoken:halfword;{:1266}{1281:}longhelpseen:boolean;
{:1281}{1299:}formatident:strnumber;{:1299}{1305:}fmtfile:wordfile;
{:1305}{1331:}readyalready:integer;
{:1331}{1342:}writefile:array[0..15]of alphafile;
writeopen:array[0..17]of boolean;{:1342}{1345:}writeloc:halfword;
{:1345}{1383:}eTeXmode:0..1;
{:1383}{1391:}eofseen:array[1..maxinopen]of boolean;
{:1391}{1436:}LRtemp:halfword;LRptr:halfword;LRproblems:integer;
curdir:smallnumber;{:1436}{1483:}pseudofiles:halfword;
{:1483}{1506:}grpstack:array[0..maxinopen]of savepointer;
ifstack:array[0..maxinopen]of halfword;{:1506}{1547:}maxregnum:halfword;
maxreghelpline:strnumber;{:1547}{1549:}saroot:array[0..6]of halfword;
curptr:halfword;sanull:memoryword;{:1549}{1568:}sachain:halfword;
salevel:quarterword;{:1568}{1575:}lastlinefill:halfword;
dolastlinefit:boolean;activenodesize:smallnumber;
fillwidth:array[0..2]of scaled;bestplshort:array[0..3]of scaled;
bestplglue:array[0..3]of scaled;{:1575}{1591:}hyphstart:triepointer;
hyphindex:triepointer;{:1591}{1592:}discptr:array[1..3]of halfword;
{:1592}procedure initialize;var{19:}i:integer;{:19}{163:}k:integer;
{:163}{927:}z:hyphpointer;{:927}begin{8:}{21:}xchr[32]:=' ';
xchr[33]:='!';xchr[34]:='"';xchr[35]:='#';xchr[36]:='$';xchr[37]:='%';
xchr[38]:='&';xchr[39]:='''';xchr[40]:='(';xchr[41]:=')';xchr[42]:='*';
xchr[43]:='+';xchr[44]:=',';xchr[45]:='-';xchr[46]:='.';xchr[47]:='/';
xchr[48]:='0';xchr[49]:='1';xchr[50]:='2';xchr[51]:='3';xchr[52]:='4';
xchr[53]:='5';xchr[54]:='6';xchr[55]:='7';xchr[56]:='8';xchr[57]:='9';
xchr[58]:=':';xchr[59]:=';';xchr[60]:='<';xchr[61]:='=';xchr[62]:='>';
xchr[63]:='?';xchr[64]:='@';xchr[65]:='A';xchr[66]:='B';xchr[67]:='C';
xchr[68]:='D';xchr[69]:='E';xchr[70]:='F';xchr[71]:='G';xchr[72]:='H';
xchr[73]:='I';xchr[74]:='J';xchr[75]:='K';xchr[76]:='L';xchr[77]:='M';
xchr[78]:='N';xchr[79]:='O';xchr[80]:='P';xchr[81]:='Q';xchr[82]:='R';
xchr[83]:='S';xchr[84]:='T';xchr[85]:='U';xchr[86]:='V';xchr[87]:='W';
xchr[88]:='X';xchr[89]:='Y';xchr[90]:='Z';xchr[91]:='[';xchr[92]:='\';
xchr[93]:=']';xchr[94]:='^';xchr[95]:='_';xchr[96]:='`';xchr[97]:='a';
xchr[98]:='b';xchr[99]:='c';xchr[100]:='d';xchr[101]:='e';
xchr[102]:='f';xchr[103]:='g';xchr[104]:='h';xchr[105]:='i';
xchr[106]:='j';xchr[107]:='k';xchr[108]:='l';xchr[109]:='m';
xchr[110]:='n';xchr[111]:='o';xchr[112]:='p';xchr[113]:='q';
xchr[114]:='r';xchr[115]:='s';xchr[116]:='t';xchr[117]:='u';
xchr[118]:='v';xchr[119]:='w';xchr[120]:='x';xchr[121]:='y';
xchr[122]:='z';xchr[123]:='{';xchr[124]:='|';xchr[125]:='}';
xchr[126]:='~';{:21}{23:}for i:=0 to 31 do xchr[i]:=' ';
for i:=127 to 255 do xchr[i]:=' ';
{:23}{24:}for i:=0 to 255 do xord[chr(i)]:=127;
for i:=128 to 255 do xord[xchr[i]]:=i;
for i:=0 to 126 do xord[xchr[i]]:=i;{:24}{74:}interaction:=3;
{:74}{77:}deletionsallowed:=true;setboxallowed:=true;errorcount:=0;
{:77}{80:}helpptr:=0;useerrhelp:=false;{:80}{97:}interrupt:=0;
OKtointerrupt:=true;{:97}{166:}{wasmemend:=memmin;waslomax:=memmin;
washimin:=memmax;panicking:=false;}{:166}{215:}nestptr:=0;
maxneststack:=0;curlist.modefield:=1;curlist.headfield:=29999;
curlist.tailfield:=29999;curlist.eTeXauxfield:=0;
curlist.auxfield.int:=-65536000;curlist.mlfield:=0;curlist.pgfield:=0;
shownmode:=0;{991:}pagecontents:=0;pagetail:=29998;mem[29998].hh.rh:=0;
lastglue:=65535;lastpenalty:=0;lastkern:=0;lastnodetype:=-1;
pagesofar[7]:=0;pagemaxdepth:=0{:991};
{:215}{254:}for k:=5268 to 6121 do xeqlevel[k]:=1;
{:254}{257:}nonewcontrolsequence:=true;hash[514].lh:=0;hash[514].rh:=0;
for k:=515 to 2880 do hash[k]:=hash[514];{:257}{272:}saveptr:=0;
curlevel:=1;curgroup:=0;curboundary:=0;maxsavestack:=0;
{:272}{287:}magset:=0;{:287}{383:}curmark[0]:=0;curmark[1]:=0;
curmark[2]:=0;curmark[3]:=0;curmark[4]:=0;{:383}{439:}curval:=0;
curvallevel:=0;radix:=0;curorder:=0;
{:439}{481:}for k:=0 to 16 do readopen[k]:=2;{:481}{490:}condptr:=0;
iflimit:=0;curif:=0;ifline:=0;
{:490}{521:}TEXformatdefault:='TeXformats:plain.fmt';
{:521}{551:}for k:=0 to fontmax do fontused[k]:=false;
{:551}{556:}nullcharacter.b0:=0;nullcharacter.b1:=0;nullcharacter.b2:=0;
nullcharacter.b3:=0;{:556}{593:}totalpages:=0;maxv:=0;maxh:=0;
maxpush:=0;lastbop:=-1;doingleaders:=false;deadcycles:=0;curs:=-1;
{:593}{596:}halfbuf:=dvibufsize div 2;dvilimit:=dvibufsize;dviptr:=0;
dvioffset:=0;dvigone:=0;{:596}{606:}downptr:=0;rightptr:=0;
{:606}{648:}adjusttail:=0;lastbadness:=0;{:648}{662:}packbeginline:=0;
{:662}{685:}emptyfield.rh:=0;emptyfield.lh:=0;nulldelimiter.b0:=0;
nulldelimiter.b1:=0;nulldelimiter.b2:=0;nulldelimiter.b3:=0;
{:685}{771:}alignptr:=0;curalign:=0;curspan:=0;curloop:=0;curhead:=0;
curtail:=0;{:771}{928:}for z:=0 to 307 do begin hyphword[z]:=0;
hyphlist[z]:=0;end;hyphcount:=0;{:928}{990:}outputactive:=false;
insertpenalties:=0;{:990}{1033:}ligaturepresent:=false;
cancelboundary:=false;lfthit:=false;rthit:=false;insdisc:=false;
{:1033}{1267:}aftertoken:=0;{:1267}{1282:}longhelpseen:=false;
{:1282}{1300:}formatident:=0;
{:1300}{1343:}for k:=0 to 17 do writeopen[k]:=false;
{:1343}{1437:}LRtemp:=0;LRptr:=0;LRproblems:=0;curdir:=0;
{:1437}{1484:}pseudofiles:=0;{:1484}{1550:}saroot[6]:=0;sanull.hh.lh:=0;
sanull.hh.rh:=0;{:1550}{1569:}sachain:=0;salevel:=0;
{:1569}{1593:}discptr[2]:=0;discptr[3]:=0;
{:1593}{164:}for k:=1 to 19 do mem[k].int:=0;k:=0;
while k<=19 do begin mem[k].hh.rh:=1;mem[k].hh.b0:=0;mem[k].hh.b1:=0;
k:=k+4;end;mem[6].int:=65536;mem[4].hh.b0:=1;mem[10].int:=65536;
mem[8].hh.b0:=2;mem[14].int:=65536;mem[12].hh.b0:=1;mem[15].int:=65536;
mem[12].hh.b1:=1;mem[18].int:=-65536;mem[16].hh.b0:=1;rover:=20;
mem[rover].hh.rh:=65535;mem[rover].hh.lh:=1000;
mem[rover+1].hh.lh:=rover;mem[rover+1].hh.rh:=rover;
lomemmax:=rover+1000;mem[lomemmax].hh.rh:=0;mem[lomemmax].hh.lh:=0;
for k:=29987 to 30000 do mem[k]:=mem[lomemmax];
{790:}mem[29990].hh.lh:=6714;{:790}{797:}mem[29991].hh.rh:=256;
mem[29991].hh.lh:=0;{:797}{820:}mem[29993].hh.b0:=1;
mem[29994].hh.lh:=65535;mem[29993].hh.b1:=0;
{:820}{981:}mem[30000].hh.b1:=255;mem[30000].hh.b0:=1;
mem[30000].hh.rh:=30000;{:981}{988:}mem[29998].hh.b0:=10;
mem[29998].hh.b1:=0;{:988};avail:=0;memend:=30000;himemmin:=29987;
varused:=20;dynused:=14;{:164}{222:}eqtb[2881].hh.b0:=101;
eqtb[2881].hh.rh:=0;eqtb[2881].hh.b1:=0;
for k:=1 to 2880 do eqtb[k]:=eqtb[2881];{:222}{228:}eqtb[2882].hh.rh:=0;
eqtb[2882].hh.b1:=1;eqtb[2882].hh.b0:=117;
for k:=2883 to 3411 do eqtb[k]:=eqtb[2882];
mem[0].hh.rh:=mem[0].hh.rh+530;{:228}{232:}eqtb[3412].hh.rh:=0;
eqtb[3412].hh.b0:=118;eqtb[3412].hh.b1:=1;
for k:=3679 to 3682 do eqtb[k]:=eqtb[3412];
for k:=3413 to 3678 do eqtb[k]:=eqtb[2881];eqtb[3683].hh.rh:=0;
eqtb[3683].hh.b0:=119;eqtb[3683].hh.b1:=1;
for k:=3684 to 3938 do eqtb[k]:=eqtb[3683];eqtb[3939].hh.rh:=0;
eqtb[3939].hh.b0:=120;eqtb[3939].hh.b1:=1;
for k:=3940 to 3987 do eqtb[k]:=eqtb[3939];eqtb[3988].hh.rh:=0;
eqtb[3988].hh.b0:=120;eqtb[3988].hh.b1:=1;
for k:=3989 to 5267 do eqtb[k]:=eqtb[3988];
for k:=0 to 255 do begin eqtb[3988+k].hh.rh:=12;eqtb[5012+k].hh.rh:=k+0;
eqtb[4756+k].hh.rh:=1000;end;eqtb[4001].hh.rh:=5;eqtb[4020].hh.rh:=10;
eqtb[4080].hh.rh:=0;eqtb[4025].hh.rh:=14;eqtb[4115].hh.rh:=15;
eqtb[3988].hh.rh:=9;for k:=48 to 57 do eqtb[5012+k].hh.rh:=k+28672;
for k:=65 to 90 do begin eqtb[3988+k].hh.rh:=11;
eqtb[3988+k+32].hh.rh:=11;eqtb[5012+k].hh.rh:=k+28928;
eqtb[5012+k+32].hh.rh:=k+28960;eqtb[4244+k].hh.rh:=k+32;
eqtb[4244+k+32].hh.rh:=k+32;eqtb[4500+k].hh.rh:=k;
eqtb[4500+k+32].hh.rh:=k;eqtb[4756+k].hh.rh:=999;end;
{:232}{240:}for k:=5268 to 5588 do eqtb[k].int:=0;eqtb[5285].int:=1000;
eqtb[5269].int:=10000;eqtb[5309].int:=1;eqtb[5308].int:=25;
eqtb[5313].int:=92;eqtb[5316].int:=13;
for k:=0 to 255 do eqtb[5589+k].int:=-1;eqtb[5635].int:=0;
{:240}{250:}for k:=5845 to 6121 do eqtb[k].int:=0;
{:250}{258:}hashused:=2614;cscount:=0;eqtb[2623].hh.b0:=116;
hash[2623].rh:=505;{:258}{552:}fontptr:=0;fmemptr:=7;fontname[0]:=811;
fontarea[0]:=339;hyphenchar[0]:=45;skewchar[0]:=-1;bcharlabel[0]:=0;
fontbchar[0]:=256;fontfalsebchar[0]:=256;fontbc[0]:=1;fontec[0]:=0;
fontsize[0]:=0;fontdsize[0]:=0;charbase[0]:=0;widthbase[0]:=0;
heightbase[0]:=0;depthbase[0]:=0;italicbase[0]:=0;ligkernbase[0]:=0;
kernbase[0]:=0;extenbase[0]:=0;fontglue[0]:=0;fontparams[0]:=7;
parambase[0]:=-1;for k:=0 to 6 do fontinfo[k].int:=0;
{:552}{946:}for k:=-trieopsize to trieopsize do trieophash[k]:=0;
for k:=0 to 255 do trieused[k]:=0;trieopptr:=0;
{:946}{951:}trienotready:=true;triel[0]:=0;triec[0]:=0;trieptr:=0;
{:951}{1216:}hash[2614].rh:=1205;{:1216}{1301:}formatident:=1270;
{:1301}{1369:}hash[2622].rh:=1309;eqtb[2622].hh.b1:=1;
eqtb[2622].hh.b0:=113;eqtb[2622].hh.rh:=0;{:1369}{1384:}eTeXmode:=0;
{1545:}maxregnum:=255;maxreghelpline:=697;
{:1545}{:1384}{1551:}for i:=0 to 5 do saroot[i]:=0;
{:1551}{1587:}trier[0]:=0;hyphstart:=0;{:1587}{:8}end;
{57:}procedure println;begin case selector of 19:begin writeln(termout);
writeln(logfile);termoffset:=0;fileoffset:=0;end;
18:begin writeln(logfile);fileoffset:=0;end;17:begin writeln(termout);
termoffset:=0;end;16,20,21:;others:writeln(writefile[selector])end;end;
{:57}{58:}procedure printchar(s:ASCIIcode);label 10;
begin if{244:}s=eqtb[5317].int{:244}then if selector<20 then begin
println;goto 10;end;case selector of 19:begin write(termout,xchr[s]);
write(logfile,xchr[s]);termoffset:=termoffset+1;
fileoffset:=fileoffset+1;
if termoffset=maxprintline then begin writeln(termout);termoffset:=0;
end;if fileoffset=maxprintline then begin writeln(logfile);
fileoffset:=0;end;end;18:begin write(logfile,xchr[s]);
fileoffset:=fileoffset+1;if fileoffset=maxprintline then println;end;
17:begin write(termout,xchr[s]);termoffset:=termoffset+1;
if termoffset=maxprintline then println;end;16:;
20:if tally<trickcount then trickbuf[tally mod errorline]:=s;
21:begin if poolptr<poolsize then begin strpool[poolptr]:=s;
poolptr:=poolptr+1;end;end;others:write(writefile[selector],xchr[s])end;
tally:=tally+1;10:end;{:58}{59:}procedure print(s:integer);label 10;
var j:poolpointer;nl:integer;
begin if s>=strptr then s:=260 else if s<256 then if s<0 then s:=260
else begin if selector>20 then begin printchar(s);goto 10;end;
if({244:}s=eqtb[5317].int{:244})then if selector<20 then begin println;
goto 10;end;nl:=eqtb[5317].int;eqtb[5317].int:=-1;j:=strstart[s];
while j<strstart[s+1]do begin printchar(strpool[j]);j:=j+1;end;
eqtb[5317].int:=nl;goto 10;end;j:=strstart[s];
while j<strstart[s+1]do begin printchar(strpool[j]);j:=j+1;end;10:end;
{:59}{60:}procedure slowprint(s:integer);var j:poolpointer;
begin if(s>=strptr)or(s<256)then print(s)else begin j:=strstart[s];
while j<strstart[s+1]do begin print(strpool[j]);j:=j+1;end;end;end;
{:60}{62:}procedure printnl(s:strnumber);
begin if((termoffset>0)and(odd(selector)))or((fileoffset>0)and(selector
>=18))then println;print(s);end;
{:62}{63:}procedure printesc(s:strnumber);var c:integer;
begin{243:}c:=eqtb[5313].int{:243};if c>=0 then if c<256 then print(c);
slowprint(s);end;{:63}{64:}procedure printthedigs(k:eightbits);
begin while k>0 do begin k:=k-1;
if dig[k]<10 then printchar(48+dig[k])else printchar(55+dig[k]);end;end;
{:64}{65:}procedure printint(n:integer);var k:0..23;m:integer;
begin k:=0;if n<0 then begin printchar(45);
if n>-100000000 then n:=-n else begin m:=-1-n;n:=m div 10;
m:=(m mod 10)+1;k:=1;if m<10 then dig[0]:=m else begin dig[0]:=0;n:=n+1;
end;end;end;repeat dig[k]:=n mod 10;n:=n div 10;k:=k+1;until n=0;
printthedigs(k);end;{:65}{262:}procedure printcs(p:integer);
begin if p<514 then if p>=257 then if p=513 then begin printesc(507);
printesc(508);end else begin printesc(p-257);
if eqtb[3988+p-257].hh.rh=11 then printchar(32);
end else if p<1 then printesc(509)else print(p-1)else if p>=2881 then
printesc(509)else if(hash[p].rh<0)or(hash[p].rh>=strptr)then printesc(
510)else begin printesc(hash[p].rh);printchar(32);end;end;
{:262}{263:}procedure sprintcs(p:halfword);
begin if p<514 then if p<257 then print(p-1)else if p<513 then printesc(
p-257)else begin printesc(507);printesc(508);
end else printesc(hash[p].rh);end;
{:263}{518:}procedure printfilename(n,a,e:integer);begin slowprint(a);
slowprint(n);slowprint(e);end;
{:518}{699:}procedure printsize(s:integer);
begin if s=0 then printesc(415)else if s=16 then printesc(416)else
printesc(417);end;{:699}{1355:}procedure printwritewhatsit(s:strnumber;
p:halfword);begin printesc(s);
if mem[p+1].hh.lh<16 then printint(mem[p+1].hh.lh)else if mem[p+1].hh.lh
=16 then printchar(42)else printchar(45);end;
{:1355}{1555:}procedure printsanum(q:halfword);var n:halfword;
begin if mem[q].hh.b0<32 then n:=mem[q+1].hh.rh else begin n:=mem[q].hh.
b0 mod 16;q:=mem[q].hh.rh;n:=n+16*mem[q].hh.b0;q:=mem[q].hh.rh;
n:=n+256*(mem[q].hh.b0+16*mem[mem[q].hh.rh].hh.b0);end;printint(n);end;
{:1555}{78:}procedure normalizeselector;forward;procedure gettoken;
forward;procedure terminput;forward;procedure showcontext;forward;
procedure beginfilereading;forward;procedure openlogfile;forward;
procedure closefilesandterminate;forward;procedure clearforerrorprompt;
forward;procedure giveerrhelp;forward;{procedure debughelp;forward;}
{:78}{81:}procedure jumpout;begin goto 9998;end;
{:81}{82:}procedure error;label 22,10;var c:ASCIIcode;
s1,s2,s3,s4:integer;begin if history<2 then history:=2;printchar(46);
showcontext;
if interaction=3 then{83:}while true do begin 22:clearforerrorprompt;
begin;print(265);terminput;end;if last=first then goto 10;
c:=buffer[first];if c>=97 then c:=c-32;
{84:}case c of 48,49,50,51,52,53,54,55,56,57:if deletionsallowed then
{88:}begin s1:=curtok;s2:=curcmd;s3:=curchr;s4:=alignstate;
alignstate:=1000000;OKtointerrupt:=false;
if(last>first+1)and(buffer[first+1]>=48)and(buffer[first+1]<=57)then c:=
c*10+buffer[first+1]-48*11 else c:=c-48;while c>0 do begin gettoken;
c:=c-1;end;curtok:=s1;curcmd:=s2;curchr:=s3;alignstate:=s4;
OKtointerrupt:=true;begin helpptr:=2;helpline[1]:=280;helpline[0]:=281;
end;showcontext;goto 22;end{:88};{68:begin debughelp;goto 22;end;}
69:if baseptr>0 then begin printnl(266);
slowprint(inputstack[baseptr].namefield);print(267);printint(line);
interaction:=2;jumpout;end;
72:{89:}begin if useerrhelp then begin giveerrhelp;useerrhelp:=false;
end else begin if helpptr=0 then begin helpptr:=2;helpline[1]:=282;
helpline[0]:=283;end;repeat helpptr:=helpptr-1;print(helpline[helpptr]);
println;until helpptr=0;end;begin helpptr:=4;helpline[3]:=284;
helpline[2]:=283;helpline[1]:=285;helpline[0]:=286;end;goto 22;end{:89};
73:{87:}begin beginfilereading;
if last>first+1 then begin curinput.locfield:=first+1;buffer[first]:=32;
end else begin begin;print(279);terminput;end;curinput.locfield:=first;
end;first:=last;curinput.limitfield:=last-1;goto 10;end{:87};
81,82,83:{86:}begin errorcount:=0;interaction:=0+c-81;print(274);
case c of 81:begin printesc(275);selector:=selector-1;end;
82:printesc(276);83:printesc(277);end;print(278);println;break(termout);
goto 10;end{:86};88:begin interaction:=2;jumpout;end;others:end;
{85:}begin print(268);printnl(269);printnl(270);
if baseptr>0 then print(271);if deletionsallowed then printnl(272);
printnl(273);end{:85}{:84};end{:83};errorcount:=errorcount+1;
if errorcount=100 then begin printnl(264);history:=3;jumpout;end;
{90:}if interaction>0 then selector:=selector-1;
if useerrhelp then begin println;giveerrhelp;
end else while helpptr>0 do begin helpptr:=helpptr-1;
printnl(helpline[helpptr]);end;println;
if interaction>0 then selector:=selector+1;println{:90};10:end;
{:82}{93:}procedure fatalerror(s:strnumber);begin normalizeselector;
begin if interaction=3 then;printnl(263);print(288);end;
begin helpptr:=1;helpline[0]:=s;end;
begin if interaction=3 then interaction:=2;if logopened then error;
{if interaction>0 then debughelp;}history:=3;jumpout;end;end;
{:93}{94:}procedure overflow(s:strnumber;n:integer);
begin normalizeselector;begin if interaction=3 then;printnl(263);
print(289);end;print(s);printchar(61);printint(n);printchar(93);
begin helpptr:=2;helpline[1]:=290;helpline[0]:=291;end;
begin if interaction=3 then interaction:=2;if logopened then error;
{if interaction>0 then debughelp;}history:=3;jumpout;end;end;
{:94}{95:}procedure confusion(s:strnumber);begin normalizeselector;
if history<2 then begin begin if interaction=3 then;printnl(263);
print(292);end;print(s);printchar(41);begin helpptr:=1;helpline[0]:=293;
end;end else begin begin if interaction=3 then;printnl(263);print(294);
end;begin helpptr:=2;helpline[1]:=295;helpline[0]:=296;end;end;
begin if interaction=3 then interaction:=2;if logopened then error;
{if interaction>0 then debughelp;}history:=3;jumpout;end;end;
{:95}{:4}{27:}function aopenin(var f:alphafile):boolean;
begin reset(f,nameoffile,'/O');aopenin:=erstat(f)=0;end;
function aopenout(var f:alphafile):boolean;
begin rewrite(f,nameoffile,'/O');aopenout:=erstat(f)=0;end;
function bopenin(var f:bytefile):boolean;begin reset(f,nameoffile,'/O');
bopenin:=erstat(f)=0;end;function bopenout(var f:bytefile):boolean;
begin rewrite(f,nameoffile,'/O');bopenout:=erstat(f)=0;end;
function wopenin(var f:wordfile):boolean;begin reset(f,nameoffile,'/O');
wopenin:=erstat(f)=0;end;function wopenout(var f:wordfile):boolean;
begin rewrite(f,nameoffile,'/O');wopenout:=erstat(f)=0;end;
{:27}{28:}procedure aclose(var f:alphafile);begin close(f);end;
procedure bclose(var f:bytefile);begin close(f);end;
procedure wclose(var f:wordfile);begin close(f);end;
{:28}{31:}function inputln(var f:alphafile;bypasseoln:boolean):boolean;
var lastnonblank:0..bufsize;
begin if bypasseoln then if not eof(f)then get(f);last:=first;
if eof(f)then inputln:=false else begin lastnonblank:=first;
while not eoln(f)do begin if last>=maxbufstack then begin maxbufstack:=
last+1;
if maxbufstack=bufsize then{35:}if formatident=0 then begin writeln(
termout,'Buffer size exceeded!');goto 9999;
end else begin curinput.locfield:=first;curinput.limitfield:=last-1;
overflow(257,bufsize);end{:35};end;buffer[last]:=xord[f^];get(f);
last:=last+1;if buffer[last-1]<>32 then lastnonblank:=last;end;
last:=lastnonblank;inputln:=true;end;end;
{:31}{37:}function initterminal:boolean;label 10;
begin reset(termin,'TTY:','/O/I');while true do begin;
write(termout,'**');break(termout);
if not inputln(termin,true)then begin writeln(termout);
write(termout,'! End of file on the terminal... why?');
initterminal:=false;goto 10;end;curinput.locfield:=first;
while(curinput.locfield<last)and(buffer[curinput.locfield]=32)do
curinput.locfield:=curinput.locfield+1;
if curinput.locfield<last then begin initterminal:=true;goto 10;end;
writeln(termout,'Please type the name of your input file.');end;10:end;
{:37}{43:}function makestring:strnumber;
begin if strptr=maxstrings then overflow(259,maxstrings-initstrptr);
strptr:=strptr+1;strstart[strptr]:=poolptr;makestring:=strptr-1;end;
{:43}{45:}function streqbuf(s:strnumber;k:integer):boolean;label 45;
var j:poolpointer;result:boolean;begin j:=strstart[s];
while j<strstart[s+1]do begin if strpool[j]<>buffer[k]then begin result
:=false;goto 45;end;j:=j+1;k:=k+1;end;result:=true;45:streqbuf:=result;
end;{:45}{46:}function streqstr(s,t:strnumber):boolean;label 45;
var j,k:poolpointer;result:boolean;begin result:=false;
if(strstart[s+1]-strstart[s])<>(strstart[t+1]-strstart[t])then goto 45;
j:=strstart[s];k:=strstart[t];
while j<strstart[s+1]do begin if strpool[j]<>strpool[k]then goto 45;
j:=j+1;k:=k+1;end;result:=true;45:streqstr:=result;end;
{:46}{47:}function getstringsstarted:boolean;label 30,10;var k,l:0..255;
m,n:char;g:strnumber;a:integer;c:boolean;begin poolptr:=0;strptr:=0;
strstart[0]:=0;
{48:}for k:=0 to 255 do begin if({49:}(k<32)or(k>126){:49})then begin
begin strpool[poolptr]:=94;poolptr:=poolptr+1;end;
begin strpool[poolptr]:=94;poolptr:=poolptr+1;end;
if k<64 then begin strpool[poolptr]:=k+64;poolptr:=poolptr+1;
end else if k<128 then begin strpool[poolptr]:=k-64;poolptr:=poolptr+1;
end else begin l:=k div 16;if l<10 then begin strpool[poolptr]:=l+48;
poolptr:=poolptr+1;end else begin strpool[poolptr]:=l+87;
poolptr:=poolptr+1;end;l:=k mod 16;
if l<10 then begin strpool[poolptr]:=l+48;poolptr:=poolptr+1;
end else begin strpool[poolptr]:=l+87;poolptr:=poolptr+1;end;end;
end else begin strpool[poolptr]:=k;poolptr:=poolptr+1;end;g:=makestring;
end{:48};{51:}nameoffile:=poolname;
if aopenin(poolfile)then begin c:=false;
repeat{52:}begin if eof(poolfile)then begin;
writeln(termout,'! TEX.POOL has no check sum.');aclose(poolfile);
getstringsstarted:=false;goto 10;end;read(poolfile,m,n);
if m='*'then{53:}begin a:=0;k:=1;
while true do begin if(xord[n]<48)or(xord[n]>57)then begin;
writeln(termout,'! TEX.POOL check sum doesn''t have nine digits.');
aclose(poolfile);getstringsstarted:=false;goto 10;end;
a:=10*a+xord[n]-48;if k=9 then goto 30;k:=k+1;read(poolfile,n);end;
30:if a<>274155489 then begin;
writeln(termout,'! TEX.POOL doesn''t match; TANGLE me again.');
aclose(poolfile);getstringsstarted:=false;goto 10;end;c:=true;
end{:53}else begin if(xord[m]<48)or(xord[m]>57)or(xord[n]<48)or(xord[n]>
57)then begin;
writeln(termout,'! TEX.POOL line doesn''t begin with two digits.');
aclose(poolfile);getstringsstarted:=false;goto 10;end;
l:=xord[m]*10+xord[n]-48*11;
if poolptr+l+stringvacancies>poolsize then begin;
writeln(termout,'! You have to increase POOLSIZE.');aclose(poolfile);
getstringsstarted:=false;goto 10;end;
for k:=1 to l do begin if eoln(poolfile)then m:=' 'else read(poolfile,m)
;begin strpool[poolptr]:=xord[m];poolptr:=poolptr+1;end;end;
readln(poolfile);g:=makestring;end;end{:52};until c;aclose(poolfile);
getstringsstarted:=true;end else begin;
writeln(termout,'! I can''t read TEX.POOL.');aclose(poolfile);
getstringsstarted:=false;goto 10;end{:51};10:end;
{:47}{66:}procedure printtwo(n:integer);begin n:=abs(n)mod 100;
printchar(48+(n div 10));printchar(48+(n mod 10));end;
{:66}{67:}procedure printhex(n:integer);var k:0..22;begin k:=0;
printchar(34);repeat dig[k]:=n mod 16;n:=n div 16;k:=k+1;until n=0;
printthedigs(k);end;{:67}{69:}procedure printromanint(n:integer);
label 10;var j,k:poolpointer;u,v:nonnegativeinteger;
begin j:=strstart[261];v:=1000;
while true do begin while n>=v do begin printchar(strpool[j]);n:=n-v;
end;if n<=0 then goto 10;k:=j+2;u:=v div(strpool[k-1]-48);
if strpool[k-1]=50 then begin k:=k+2;u:=u div(strpool[k-1]-48);end;
if n+u>=v then begin printchar(strpool[k]);n:=n+u;end else begin j:=j+2;
v:=v div(strpool[j-1]-48);end;end;10:end;
{:69}{70:}procedure printcurrentstring;var j:poolpointer;
begin j:=strstart[strptr];
while j<poolptr do begin printchar(strpool[j]);j:=j+1;end;end;
{:70}{71:}procedure terminput;var k:0..bufsize;begin break(termout);
if not inputln(termin,true)then fatalerror(262);termoffset:=0;
selector:=selector-1;
if last<>first then for k:=first to last-1 do print(buffer[k]);println;
selector:=selector+1;end;{:71}{91:}procedure interror(n:integer);
begin print(287);printint(n);printchar(41);error;end;
{:91}{92:}procedure normalizeselector;
begin if logopened then selector:=19 else selector:=17;
if jobname=0 then openlogfile;
if interaction=0 then selector:=selector-1;end;
{:92}{98:}procedure pauseforinstructions;
begin if OKtointerrupt then begin interaction:=3;
if(selector=18)or(selector=16)then selector:=selector+1;
begin if interaction=3 then;printnl(263);print(297);end;
begin helpptr:=3;helpline[2]:=298;helpline[1]:=299;helpline[0]:=300;end;
deletionsallowed:=false;error;deletionsallowed:=true;interrupt:=0;end;
end;{:98}{100:}function half(x:integer):integer;
begin if odd(x)then half:=(x+1)div 2 else half:=x div 2;end;
{:100}{102:}function rounddecimals(k:smallnumber):scaled;var a:integer;
begin a:=0;while k>0 do begin k:=k-1;a:=(a+dig[k]*131072)div 10;end;
rounddecimals:=(a+1)div 2;end;
{:102}{103:}procedure printscaled(s:scaled);var delta:scaled;
begin if s<0 then begin printchar(45);s:=-s;end;printint(s div 65536);
printchar(46);s:=10*(s mod 65536)+5;delta:=10;
repeat if delta>65536 then s:=s-17232;printchar(48+(s div 65536));
s:=10*(s mod 65536);delta:=delta*10;until s<=delta;end;
{:103}{105:}function multandadd(n:integer;x,y,maxanswer:scaled):scaled;
begin if n<0 then begin x:=-x;n:=-n;end;
if n=0 then multandadd:=y else if((x<=(maxanswer-y)div n)and(-x<=(
maxanswer+y)div n))then multandadd:=n*x+y else begin aritherror:=true;
multandadd:=0;end;end;{:105}{106:}function xovern(x:scaled;
n:integer):scaled;var negative:boolean;begin negative:=false;
if n=0 then begin aritherror:=true;xovern:=0;remainder:=x;
end else begin if n<0 then begin x:=-x;n:=-n;negative:=true;end;
if x>=0 then begin xovern:=x div n;remainder:=x mod n;
end else begin xovern:=-((-x)div n);remainder:=-((-x)mod n);end;end;
if negative then remainder:=-remainder;end;
{:106}{107:}function xnoverd(x:scaled;n,d:integer):scaled;
var positive:boolean;t,u,v:nonnegativeinteger;
begin if x>=0 then positive:=true else begin x:=-x;positive:=false;end;
t:=(x mod 32768)*n;u:=(x div 32768)*n+(t div 32768);
v:=(u mod d)*32768+(t mod 32768);
if u div d>=32768 then aritherror:=true else u:=32768*(u div d)+(v div d
);if positive then begin xnoverd:=u;remainder:=v mod d;
end else begin xnoverd:=-u;remainder:=-(v mod d);end;end;
{:107}{108:}function badness(t,s:scaled):halfword;var r:integer;
begin if t=0 then badness:=0 else if s<=0 then badness:=10000 else begin
if t<=7230584 then r:=(t*297)div s else if s>=1663497 then r:=t div(s
div 297)else r:=t;
if r>1290 then badness:=10000 else badness:=(r*r*r+131072)div 262144;
end;end;{:108}{114:}{procedure printword(w:memoryword);
begin printint(w.int);printchar(32);printscaled(w.int);printchar(32);
printscaled(round(65536*w.gr));println;printint(w.hh.lh);printchar(61);
printint(w.hh.b0);printchar(58);printint(w.hh.b1);printchar(59);
printint(w.hh.rh);printchar(32);printint(w.qqqq.b0);printchar(58);
printint(w.qqqq.b1);printchar(58);printint(w.qqqq.b2);printchar(58);
printint(w.qqqq.b3);end;}
{:114}{119:}{292:}procedure showtokenlist(p,q:integer;l:integer);
label 10;var m,c:integer;matchchr:ASCIIcode;n:ASCIIcode;
begin matchchr:=35;n:=48;tally:=0;
while(p<>0)and(tally<l)do begin if p=q then{320:}begin firstcount:=tally
;trickcount:=tally+1+errorline-halferrorline;
if trickcount<errorline then trickcount:=errorline;end{:320};
{293:}if(p<himemmin)or(p>memend)then begin printesc(310);goto 10;end;
if mem[p].hh.lh>=4095 then printcs(mem[p].hh.lh-4095)else begin m:=mem[p
].hh.lh div 256;c:=mem[p].hh.lh mod 256;
if mem[p].hh.lh<0 then printesc(562)else{294:}case m of 1,2,3,4,7,8,10,
11,12:print(c);6:begin print(c);print(c);end;5:begin print(matchchr);
if c<=9 then printchar(c+48)else begin printchar(33);goto 10;end;end;
13:begin matchchr:=c;print(c);n:=n+1;printchar(n);if n>57 then goto 10;
end;14:if c=0 then print(563);others:printesc(562)end{:294};end{:293};
p:=mem[p].hh.rh;end;if p<>0 then printesc(411);10:end;
{:292}{306:}procedure runaway;var p:halfword;
begin if scannerstatus>1 then begin printnl(577);
case scannerstatus of 2:begin print(578);p:=defref;end;
3:begin print(579);p:=29997;end;4:begin print(580);p:=29996;end;
5:begin print(581);p:=defref;end;end;printchar(63);println;
showtokenlist(mem[p].hh.rh,0,errorline-10);end;end;
{:306}{:119}{120:}function getavail:halfword;var p:halfword;
begin p:=avail;
if p<>0 then avail:=mem[avail].hh.rh else if memend<memmax then begin
memend:=memend+1;p:=memend;end else begin himemmin:=himemmin-1;
p:=himemmin;if himemmin<=lomemmax then begin runaway;
overflow(301,memmax+1-memmin);end;end;mem[p].hh.rh:=0;
{dynused:=dynused+1;}getavail:=p;end;
{:120}{123:}procedure flushlist(p:halfword);var q,r:halfword;
begin if p<>0 then begin r:=p;repeat q:=r;r:=mem[r].hh.rh;
{dynused:=dynused-1;}until r=0;mem[q].hh.rh:=avail;avail:=p;end;end;
{:123}{125:}function getnode(s:integer):halfword;label 40,10,20;
var p:halfword;q:halfword;r:integer;t:integer;begin 20:p:=rover;
repeat{127:}q:=p+mem[p].hh.lh;
while(mem[q].hh.rh=65535)do begin t:=mem[q+1].hh.rh;
if q=rover then rover:=t;mem[t+1].hh.lh:=mem[q+1].hh.lh;
mem[mem[q+1].hh.lh+1].hh.rh:=t;q:=q+mem[q].hh.lh;end;r:=q-s;
if r>p+1 then{128:}begin mem[p].hh.lh:=r-p;rover:=p;goto 40;end{:128};
if r=p then if mem[p+1].hh.rh<>p then{129:}begin rover:=mem[p+1].hh.rh;
t:=mem[p+1].hh.lh;mem[rover+1].hh.lh:=t;mem[t+1].hh.rh:=rover;goto 40;
end{:129};mem[p].hh.lh:=q-p{:127};p:=mem[p+1].hh.rh;until p=rover;
if s=1073741824 then begin getnode:=65535;goto 10;end;
if lomemmax+2<himemmin then if lomemmax+2<=65535 then{126:}begin if
himemmin-lomemmax>=1998 then t:=lomemmax+1000 else t:=lomemmax+1+(
himemmin-lomemmax)div 2;p:=mem[rover+1].hh.lh;q:=lomemmax;
mem[p+1].hh.rh:=q;mem[rover+1].hh.lh:=q;if t>65535 then t:=65535;
mem[q+1].hh.rh:=rover;mem[q+1].hh.lh:=p;mem[q].hh.rh:=65535;
mem[q].hh.lh:=t-lomemmax;lomemmax:=t;mem[lomemmax].hh.rh:=0;
mem[lomemmax].hh.lh:=0;rover:=q;goto 20;end{:126};
overflow(301,memmax+1-memmin);40:mem[r].hh.rh:=0;{varused:=varused+s;}
getnode:=r;10:end;{:125}{130:}procedure freenode(p:halfword;s:halfword);
var q:halfword;begin mem[p].hh.lh:=s;mem[p].hh.rh:=65535;
q:=mem[rover+1].hh.lh;mem[p+1].hh.lh:=q;mem[p+1].hh.rh:=rover;
mem[rover+1].hh.lh:=p;mem[q+1].hh.rh:=p;{varused:=varused-s;}end;
{:130}{131:}procedure sortavail;var p,q,r:halfword;oldrover:halfword;
begin p:=getnode(1073741824);p:=mem[rover+1].hh.rh;
mem[rover+1].hh.rh:=65535;oldrover:=rover;
while p<>oldrover do{132:}if p<rover then begin q:=p;p:=mem[q+1].hh.rh;
mem[q+1].hh.rh:=rover;rover:=q;end else begin q:=rover;
while mem[q+1].hh.rh<p do q:=mem[q+1].hh.rh;r:=mem[p+1].hh.rh;
mem[p+1].hh.rh:=mem[q+1].hh.rh;mem[q+1].hh.rh:=p;p:=r;end{:132};
p:=rover;
while mem[p+1].hh.rh<>65535 do begin mem[mem[p+1].hh.rh+1].hh.lh:=p;
p:=mem[p+1].hh.rh;end;mem[p+1].hh.rh:=rover;mem[rover+1].hh.lh:=p;end;
{:131}{136:}function newnullbox:halfword;var p:halfword;
begin p:=getnode(7);mem[p].hh.b0:=0;mem[p].hh.b1:=0;mem[p+1].int:=0;
mem[p+2].int:=0;mem[p+3].int:=0;mem[p+4].int:=0;mem[p+5].hh.rh:=0;
mem[p+5].hh.b0:=0;mem[p+5].hh.b1:=0;mem[p+6].gr:=0.0;newnullbox:=p;end;
{:136}{139:}function newrule:halfword;var p:halfword;
begin p:=getnode(4);mem[p].hh.b0:=2;mem[p].hh.b1:=0;
mem[p+1].int:=-1073741824;mem[p+2].int:=-1073741824;
mem[p+3].int:=-1073741824;newrule:=p;end;
{:139}{144:}function newligature(f,c:quarterword;q:halfword):halfword;
var p:halfword;begin p:=getnode(2);mem[p].hh.b0:=6;mem[p+1].hh.b0:=f;
mem[p+1].hh.b1:=c;mem[p+1].hh.rh:=q;mem[p].hh.b1:=0;newligature:=p;end;
function newligitem(c:quarterword):halfword;var p:halfword;
begin p:=getnode(2);mem[p].hh.b1:=c;mem[p+1].hh.rh:=0;newligitem:=p;end;
{:144}{145:}function newdisc:halfword;var p:halfword;
begin p:=getnode(2);mem[p].hh.b0:=7;mem[p].hh.b1:=0;mem[p+1].hh.lh:=0;
mem[p+1].hh.rh:=0;newdisc:=p;end;{:145}{147:}function newmath(w:scaled;
s:smallnumber):halfword;var p:halfword;begin p:=getnode(2);
mem[p].hh.b0:=9;mem[p].hh.b1:=s;mem[p+1].int:=w;newmath:=p;end;
{:147}{151:}function newspec(p:halfword):halfword;var q:halfword;
begin q:=getnode(4);mem[q]:=mem[p];mem[q].hh.rh:=0;
mem[q+1].int:=mem[p+1].int;mem[q+2].int:=mem[p+2].int;
mem[q+3].int:=mem[p+3].int;newspec:=q;end;
{:151}{152:}function newparamglue(n:smallnumber):halfword;
var p:halfword;q:halfword;begin p:=getnode(2);mem[p].hh.b0:=10;
mem[p].hh.b1:=n+1;mem[p+1].hh.rh:=0;q:={224:}eqtb[2882+n].hh.rh{:224};
mem[p+1].hh.lh:=q;mem[q].hh.rh:=mem[q].hh.rh+1;newparamglue:=p;end;
{:152}{153:}function newglue(q:halfword):halfword;var p:halfword;
begin p:=getnode(2);mem[p].hh.b0:=10;mem[p].hh.b1:=0;mem[p+1].hh.rh:=0;
mem[p+1].hh.lh:=q;mem[q].hh.rh:=mem[q].hh.rh+1;newglue:=p;end;
{:153}{154:}function newskipparam(n:smallnumber):halfword;
var p:halfword;begin tempptr:=newspec({224:}eqtb[2882+n].hh.rh{:224});
p:=newglue(tempptr);mem[tempptr].hh.rh:=0;mem[p].hh.b1:=n+1;
newskipparam:=p;end;{:154}{156:}function newkern(w:scaled):halfword;
var p:halfword;begin p:=getnode(2);mem[p].hh.b0:=11;mem[p].hh.b1:=0;
mem[p+1].int:=w;newkern:=p;end;
{:156}{158:}function newpenalty(m:integer):halfword;var p:halfword;
begin p:=getnode(2);mem[p].hh.b0:=12;mem[p].hh.b1:=0;mem[p+1].int:=m;
newpenalty:=p;end;{:158}{167:}{procedure checkmem(printlocs:boolean);
label 31,32;var p,q:halfword;clobbered:boolean;
begin for p:=memmin to lomemmax do free[p]:=false;
for p:=himemmin to memend do free[p]:=false;[168:]p:=avail;q:=0;
clobbered:=false;
while p<>0 do begin if(p>memend)or(p<himemmin)then clobbered:=true else
if free[p]then clobbered:=true;if clobbered then begin printnl(302);
printint(q);goto 31;end;free[p]:=true;q:=p;p:=mem[q].hh.rh;end;
31:[:168];[169:]p:=rover;q:=0;clobbered:=false;
repeat if(p>=lomemmax)or(p<memmin)then clobbered:=true else if(mem[p+1].
hh.rh>=lomemmax)or(mem[p+1].hh.rh<memmin)then clobbered:=true else if
not((mem[p].hh.rh=65535))or(mem[p].hh.lh<2)or(p+mem[p].hh.lh>lomemmax)or
(mem[mem[p+1].hh.rh+1].hh.lh<>p)then clobbered:=true;
if clobbered then begin printnl(303);printint(q);goto 32;end;
for q:=p to p+mem[p].hh.lh-1 do begin if free[q]then begin printnl(304);
printint(q);goto 32;end;free[q]:=true;end;q:=p;p:=mem[p+1].hh.rh;
until p=rover;32:[:169];[170:]p:=memmin;
while p<=lomemmax do begin if(mem[p].hh.rh=65535)then begin printnl(305)
;printint(p);end;while(p<=lomemmax)and not free[p]do p:=p+1;
while(p<=lomemmax)and free[p]do p:=p+1;end[:170];
if printlocs then[171:]begin printnl(306);
for p:=memmin to lomemmax do if not free[p]and((p>waslomax)or wasfree[p]
)then begin printchar(32);printint(p);end;
for p:=himemmin to memend do if not free[p]and((p<washimin)or(p>
wasmemend)or wasfree[p])then begin printchar(32);printint(p);end;
end[:171];for p:=memmin to lomemmax do wasfree[p]:=free[p];
for p:=himemmin to memend do wasfree[p]:=free[p];wasmemend:=memend;
waslomax:=lomemmax;washimin:=himemmin;end;}
{:167}{172:}{procedure searchmem(p:halfword);var q:integer;
begin for q:=memmin to lomemmax do begin if mem[q].hh.rh=p then begin
printnl(307);printint(q);printchar(41);end;
if mem[q].hh.lh=p then begin printnl(308);printint(q);printchar(41);end;
end;
for q:=himemmin to memend do begin if mem[q].hh.rh=p then begin printnl(
307);printint(q);printchar(41);end;
if mem[q].hh.lh=p then begin printnl(308);printint(q);printchar(41);end;
end;
[255:]for q:=1 to 3938 do begin if eqtb[q].hh.rh=p then begin printnl(
504);printint(q);printchar(41);end;end[:255];
[285:]if saveptr>0 then for q:=0 to saveptr-1 do begin if savestack[q].
hh.rh=p then begin printnl(554);printint(q);printchar(41);end;end[:285];
[933:]for q:=0 to 307 do begin if hyphlist[q]=p then begin printnl(951);
printint(q);printchar(41);end;end[:933];end;}
{:172}{174:}procedure shortdisplay(p:integer);var n:integer;
begin while p>memmin do begin if(p>=himemmin)then begin if p<=memend
then begin if mem[p].hh.b0<>fontinshortdisplay then begin if(mem[p].hh.
b0<0)or(mem[p].hh.b0>fontmax)then printchar(42)else{267:}printesc(hash[
2624+mem[p].hh.b0].rh){:267};printchar(32);
fontinshortdisplay:=mem[p].hh.b0;end;print(mem[p].hh.b1-0);end;
end else{175:}case mem[p].hh.b0 of 0,1,3,8,4,5,13:print(309);
2:printchar(124);10:if mem[p+1].hh.lh<>0 then printchar(32);
9:if mem[p].hh.b1>=4 then print(309)else printchar(36);
6:shortdisplay(mem[p+1].hh.rh);7:begin shortdisplay(mem[p+1].hh.lh);
shortdisplay(mem[p+1].hh.rh);n:=mem[p].hh.b1;
while n>0 do begin if mem[p].hh.rh<>0 then p:=mem[p].hh.rh;n:=n-1;end;
end;others:end{:175};p:=mem[p].hh.rh;end;end;
{:174}{176:}procedure printfontandchar(p:integer);
begin if p>memend then printesc(310)else begin if(mem[p].hh.b0<0)or(mem[
p].hh.b0>fontmax)then printchar(42)else{267:}printesc(hash[2624+mem[p].
hh.b0].rh){:267};printchar(32);print(mem[p].hh.b1-0);end;end;
procedure printmark(p:integer);begin printchar(123);
if(p<himemmin)or(p>memend)then printesc(310)else showtokenlist(mem[p].hh
.rh,0,maxprintline-10);printchar(125);end;
procedure printruledimen(d:scaled);
begin if(d=-1073741824)then printchar(42)else printscaled(d);end;
{:176}{177:}procedure printglue(d:scaled;order:integer;s:strnumber);
begin printscaled(d);
if(order<0)or(order>3)then print(311)else if order>0 then begin print(
312);while order>1 do begin printchar(108);order:=order-1;end;
end else if s<>0 then print(s);end;
{:177}{178:}procedure printspec(p:integer;s:strnumber);
begin if(p<memmin)or(p>=lomemmax)then printchar(42)else begin
printscaled(mem[p+1].int);if s<>0 then print(s);
if mem[p+2].int<>0 then begin print(313);
printglue(mem[p+2].int,mem[p].hh.b0,s);end;
if mem[p+3].int<>0 then begin print(314);
printglue(mem[p+3].int,mem[p].hh.b1,s);end;end;end;
{:178}{179:}{691:}procedure printfamandchar(p:halfword);
begin printesc(467);printint(mem[p].hh.b0);printchar(32);
print(mem[p].hh.b1-0);end;procedure printdelimiter(p:halfword);
var a:integer;begin a:=mem[p].qqqq.b0*256+mem[p].qqqq.b1-0;
a:=a*4096+mem[p].qqqq.b2*256+mem[p].qqqq.b3-0;
if a<0 then printint(a)else printhex(a);end;
{:691}{692:}procedure showinfo;forward;
procedure printsubsidiarydata(p:halfword;c:ASCIIcode);
begin if(poolptr-strstart[strptr])>=depththreshold then begin if mem[p].
hh.rh<>0 then print(315);end else begin begin strpool[poolptr]:=c;
poolptr:=poolptr+1;end;tempptr:=p;case mem[p].hh.rh of 1:begin println;
printcurrentstring;printfamandchar(p);end;2:showinfo;
3:if mem[p].hh.lh=0 then begin println;printcurrentstring;print(870);
end else showinfo;others:end;poolptr:=poolptr-1;end;end;
{:692}{694:}procedure printstyle(c:integer);
begin case c div 2 of 0:printesc(871);1:printesc(872);2:printesc(873);
3:printesc(874);others:print(875)end;end;
{:694}{225:}procedure printskipparam(n:integer);
begin case n of 0:printesc(379);1:printesc(380);2:printesc(381);
3:printesc(382);4:printesc(383);5:printesc(384);6:printesc(385);
7:printesc(386);8:printesc(387);9:printesc(388);10:printesc(389);
11:printesc(390);12:printesc(391);13:printesc(392);14:printesc(393);
15:printesc(394);16:printesc(395);17:printesc(396);others:print(397)end;
end;{:225}{:179}{182:}procedure shownodelist(p:integer);label 10;
var n:integer;g:real;
begin if(poolptr-strstart[strptr])>depththreshold then begin if p>0 then
print(315);goto 10;end;n:=0;while p>memmin do begin println;
printcurrentstring;if p>memend then begin print(316);goto 10;end;n:=n+1;
if n>breadthmax then begin print(317);goto 10;end;
{183:}if(p>=himemmin)then printfontandchar(p)else case mem[p].hh.b0 of 0
,1,13:{184:}begin if mem[p].hh.b0=0 then printesc(104)else if mem[p].hh.
b0=1 then printesc(118)else printesc(319);print(320);
printscaled(mem[p+3].int);printchar(43);printscaled(mem[p+2].int);
print(321);printscaled(mem[p+1].int);
if mem[p].hh.b0=13 then{185:}begin if mem[p].hh.b1<>0 then begin print(
287);printint(mem[p].hh.b1+1);print(323);end;
if mem[p+6].int<>0 then begin print(324);
printglue(mem[p+6].int,mem[p+5].hh.b1,0);end;
if mem[p+4].int<>0 then begin print(325);
printglue(mem[p+4].int,mem[p+5].hh.b0,0);end;
end{:185}else begin{186:}g:=mem[p+6].gr;
if(g<>0.0)and(mem[p+5].hh.b0<>0)then begin print(326);
if mem[p+5].hh.b0=2 then print(327);
if abs(mem[p+6].int)<1048576 then print(328)else if abs(g)>20000.0 then
begin if g>0.0 then printchar(62)else print(329);
printglue(20000*65536,mem[p+5].hh.b1,0);
end else printglue(round(65536*g),mem[p+5].hh.b1,0);end{:186};
if mem[p+4].int<>0 then begin print(322);printscaled(mem[p+4].int);end;
if(eTeXmode=1)then{1435:}if(mem[p].hh.b0=0)and((mem[p].hh.b1-0)=2)then
print(1370){:1435};end;begin begin strpool[poolptr]:=46;
poolptr:=poolptr+1;end;shownodelist(mem[p+5].hh.rh);poolptr:=poolptr-1;
end;end{:184};2:{187:}begin printesc(330);printruledimen(mem[p+3].int);
printchar(43);printruledimen(mem[p+2].int);print(321);
printruledimen(mem[p+1].int);end{:187};3:{188:}begin printesc(331);
printint(mem[p].hh.b1-0);print(332);printscaled(mem[p+3].int);
print(333);printspec(mem[p+4].hh.rh,0);printchar(44);
printscaled(mem[p+2].int);print(334);printint(mem[p+1].int);
begin begin strpool[poolptr]:=46;poolptr:=poolptr+1;end;
shownodelist(mem[p+4].hh.lh);poolptr:=poolptr-1;end;end{:188};
8:{1356:}case mem[p].hh.b1 of 0:begin printwritewhatsit(1298,p);
printchar(61);
printfilename(mem[p+1].hh.rh,mem[p+2].hh.lh,mem[p+2].hh.rh);end;
1:begin printwritewhatsit(603,p);printmark(mem[p+1].hh.rh);end;
2:printwritewhatsit(1299,p);3:begin printesc(1300);
printmark(mem[p+1].hh.rh);end;4:begin printesc(1302);
printint(mem[p+1].hh.rh);print(1305);printint(mem[p+1].hh.b0);
printchar(44);printint(mem[p+1].hh.b1);printchar(41);end;
others:print(1306)end{:1356};
10:{189:}if mem[p].hh.b1>=100 then{190:}begin printesc(339);
if mem[p].hh.b1=101 then printchar(99)else if mem[p].hh.b1=102 then
printchar(120);print(340);printspec(mem[p+1].hh.lh,0);
begin begin strpool[poolptr]:=46;poolptr:=poolptr+1;end;
shownodelist(mem[p+1].hh.rh);poolptr:=poolptr-1;end;
end{:190}else begin printesc(335);
if mem[p].hh.b1<>0 then begin printchar(40);
if mem[p].hh.b1<98 then printskipparam(mem[p].hh.b1-1)else if mem[p].hh.
b1=98 then printesc(336)else printesc(337);printchar(41);end;
if mem[p].hh.b1<>98 then begin printchar(32);
if mem[p].hh.b1<98 then printspec(mem[p+1].hh.lh,0)else printspec(mem[p
+1].hh.lh,338);end;end{:189};
11:{191:}if mem[p].hh.b1<>99 then begin printesc(341);
if mem[p].hh.b1<>0 then printchar(32);printscaled(mem[p+1].int);
if mem[p].hh.b1=2 then print(342);end else begin printesc(343);
printscaled(mem[p+1].int);print(338);end{:191};
9:{192:}if mem[p].hh.b1>1 then begin if odd(mem[p].hh.b1)then printesc(
344)else printesc(345);
if mem[p].hh.b1>8 then printchar(82)else if mem[p].hh.b1>4 then
printchar(76)else printchar(77);end else begin printesc(346);
if mem[p].hh.b1=0 then print(347)else print(348);
if mem[p+1].int<>0 then begin print(349);printscaled(mem[p+1].int);end;
end{:192};6:{193:}begin printfontandchar(p+1);print(350);
if mem[p].hh.b1>1 then printchar(124);
fontinshortdisplay:=mem[p+1].hh.b0;shortdisplay(mem[p+1].hh.rh);
if odd(mem[p].hh.b1)then printchar(124);printchar(41);end{:193};
12:{194:}begin printesc(351);printint(mem[p+1].int);end{:194};
7:{195:}begin printesc(352);if mem[p].hh.b1>0 then begin print(353);
printint(mem[p].hh.b1);end;begin begin strpool[poolptr]:=46;
poolptr:=poolptr+1;end;shownodelist(mem[p+1].hh.lh);poolptr:=poolptr-1;
end;begin strpool[poolptr]:=124;poolptr:=poolptr+1;end;
shownodelist(mem[p+1].hh.rh);poolptr:=poolptr-1;end{:195};
4:{196:}begin printesc(354);
if mem[p+1].hh.lh<>0 then begin printchar(115);printint(mem[p+1].hh.lh);
end;printmark(mem[p+1].hh.rh);end{:196};5:{197:}begin printesc(355);
begin begin strpool[poolptr]:=46;poolptr:=poolptr+1;end;
shownodelist(mem[p+1].int);poolptr:=poolptr-1;end;end{:197};
{690:}14:printstyle(mem[p].hh.b1);15:{695:}begin printesc(528);
begin strpool[poolptr]:=68;poolptr:=poolptr+1;end;
shownodelist(mem[p+1].hh.lh);poolptr:=poolptr-1;
begin strpool[poolptr]:=84;poolptr:=poolptr+1;end;
shownodelist(mem[p+1].hh.rh);poolptr:=poolptr-1;
begin strpool[poolptr]:=83;poolptr:=poolptr+1;end;
shownodelist(mem[p+2].hh.lh);poolptr:=poolptr-1;
begin strpool[poolptr]:=115;poolptr:=poolptr+1;end;
shownodelist(mem[p+2].hh.rh);poolptr:=poolptr-1;end{:695};
16,17,18,19,20,21,22,23,24,27,26,29,28,30,31:{696:}begin case mem[p].hh.
b0 of 16:printesc(876);17:printesc(877);18:printesc(878);
19:printesc(879);20:printesc(880);21:printesc(881);22:printesc(882);
23:printesc(883);27:printesc(884);26:printesc(885);29:printesc(543);
24:begin printesc(537);printdelimiter(p+4);end;28:begin printesc(511);
printfamandchar(p+4);end;30:begin printesc(886);printdelimiter(p+1);end;
31:begin if mem[p].hh.b1=0 then printesc(887)else printesc(888);
printdelimiter(p+1);end;end;
if mem[p].hh.b0<30 then begin if mem[p].hh.b1<>0 then if mem[p].hh.b1=1
then printesc(889)else printesc(890);printsubsidiarydata(p+1,46);end;
printsubsidiarydata(p+2,94);printsubsidiarydata(p+3,95);end{:696};
25:{697:}begin printesc(891);
if mem[p+1].int=1073741824 then print(892)else printscaled(mem[p+1].int)
;
if(mem[p+4].qqqq.b0<>0)or(mem[p+4].qqqq.b1<>0)or(mem[p+4].qqqq.b2<>0)or(
mem[p+4].qqqq.b3<>0)then begin print(893);printdelimiter(p+4);end;
if(mem[p+5].qqqq.b0<>0)or(mem[p+5].qqqq.b1<>0)or(mem[p+5].qqqq.b2<>0)or(
mem[p+5].qqqq.b3<>0)then begin print(894);printdelimiter(p+5);end;
printsubsidiarydata(p+2,92);printsubsidiarydata(p+3,47);end{:697};
{:690}others:print(318)end{:183};p:=mem[p].hh.rh;end;10:end;
{:182}{198:}procedure showbox(p:halfword);
begin{236:}depththreshold:=eqtb[5293].int;
breadthmax:=eqtb[5292].int{:236};if breadthmax<=0 then breadthmax:=5;
if poolptr+depththreshold>=poolsize then depththreshold:=poolsize-
poolptr-1;shownodelist(p);println;end;
{:198}{200:}procedure deletetokenref(p:halfword);
begin if mem[p].hh.lh=0 then flushlist(p)else mem[p].hh.lh:=mem[p].hh.lh
-1;end;{:200}{201:}procedure deleteglueref(p:halfword);
begin if mem[p].hh.rh=0 then freenode(p,4)else mem[p].hh.rh:=mem[p].hh.
rh-1;end;{:201}{202:}procedure flushnodelist(p:halfword);label 30;
var q:halfword;begin while p<>0 do begin q:=mem[p].hh.rh;
if(p>=himemmin)then begin mem[p].hh.rh:=avail;avail:=p;
{dynused:=dynused-1;}
end else begin case mem[p].hh.b0 of 0,1,13:begin flushnodelist(mem[p+5].
hh.rh);freenode(p,7);goto 30;end;2:begin freenode(p,4);goto 30;end;
3:begin flushnodelist(mem[p+4].hh.lh);deleteglueref(mem[p+4].hh.rh);
freenode(p,5);goto 30;end;
8:{1358:}begin case mem[p].hh.b1 of 0:freenode(p,3);
1,3:begin deletetokenref(mem[p+1].hh.rh);freenode(p,2);goto 30;end;
2,4:freenode(p,2);others:confusion(1308)end;goto 30;end{:1358};
10:begin begin if mem[mem[p+1].hh.lh].hh.rh=0 then freenode(mem[p+1].hh.
lh,4)else mem[mem[p+1].hh.lh].hh.rh:=mem[mem[p+1].hh.lh].hh.rh-1;end;
if mem[p+1].hh.rh<>0 then flushnodelist(mem[p+1].hh.rh);end;11,9,12:;
6:flushnodelist(mem[p+1].hh.rh);4:deletetokenref(mem[p+1].hh.rh);
7:begin flushnodelist(mem[p+1].hh.lh);flushnodelist(mem[p+1].hh.rh);end;
5:flushnodelist(mem[p+1].int);{698:}14:begin freenode(p,3);goto 30;end;
15:begin flushnodelist(mem[p+1].hh.lh);flushnodelist(mem[p+1].hh.rh);
flushnodelist(mem[p+2].hh.lh);flushnodelist(mem[p+2].hh.rh);
freenode(p,3);goto 30;end;
16,17,18,19,20,21,22,23,24,27,26,29,28:begin if mem[p+1].hh.rh>=2 then
flushnodelist(mem[p+1].hh.lh);
if mem[p+2].hh.rh>=2 then flushnodelist(mem[p+2].hh.lh);
if mem[p+3].hh.rh>=2 then flushnodelist(mem[p+3].hh.lh);
if mem[p].hh.b0=24 then freenode(p,5)else if mem[p].hh.b0=28 then
freenode(p,5)else freenode(p,4);goto 30;end;30,31:begin freenode(p,4);
goto 30;end;25:begin flushnodelist(mem[p+2].hh.lh);
flushnodelist(mem[p+3].hh.lh);freenode(p,6);goto 30;end;
{:698}others:confusion(356)end;freenode(p,2);30:end;p:=q;end;end;
{:202}{204:}function copynodelist(p:halfword):halfword;var h:halfword;
q:halfword;r:halfword;words:0..5;begin h:=getavail;q:=h;
while p<>0 do begin{205:}words:=1;
if(p>=himemmin)then r:=getavail else{206:}case mem[p].hh.b0 of 0,1,13:
begin r:=getnode(7);mem[r+6]:=mem[p+6];mem[r+5]:=mem[p+5];
mem[r+5].hh.rh:=copynodelist(mem[p+5].hh.rh);words:=5;end;
2:begin r:=getnode(4);words:=4;end;3:begin r:=getnode(5);
mem[r+4]:=mem[p+4];
mem[mem[p+4].hh.rh].hh.rh:=mem[mem[p+4].hh.rh].hh.rh+1;
mem[r+4].hh.lh:=copynodelist(mem[p+4].hh.lh);words:=4;end;
8:{1357:}case mem[p].hh.b1 of 0:begin r:=getnode(3);words:=3;end;
1,3:begin r:=getnode(2);
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;words:=2;end;
2,4:begin r:=getnode(2);words:=2;end;others:confusion(1307)end{:1357};
10:begin r:=getnode(2);
mem[mem[p+1].hh.lh].hh.rh:=mem[mem[p+1].hh.lh].hh.rh+1;
mem[r+1].hh.lh:=mem[p+1].hh.lh;
mem[r+1].hh.rh:=copynodelist(mem[p+1].hh.rh);end;
11,9,12:begin r:=getnode(2);words:=2;end;6:begin r:=getnode(2);
mem[r+1]:=mem[p+1];mem[r+1].hh.rh:=copynodelist(mem[p+1].hh.rh);end;
7:begin r:=getnode(2);mem[r+1].hh.lh:=copynodelist(mem[p+1].hh.lh);
mem[r+1].hh.rh:=copynodelist(mem[p+1].hh.rh);end;4:begin r:=getnode(2);
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;words:=2;end;
5:begin r:=getnode(2);mem[r+1].int:=copynodelist(mem[p+1].int);end;
others:confusion(357)end{:206};while words>0 do begin words:=words-1;
mem[r+words]:=mem[p+words];end{:205};mem[q].hh.rh:=r;q:=r;
p:=mem[p].hh.rh;end;mem[q].hh.rh:=0;q:=mem[h].hh.rh;
begin mem[h].hh.rh:=avail;avail:=h;{dynused:=dynused-1;}end;
copynodelist:=q;end;{:204}{211:}procedure printmode(m:integer);
begin if m>0 then case m div(101)of 0:print(358);1:print(359);
2:print(360);
end else if m=0 then print(361)else case(-m)div(101)of 0:print(362);
1:print(363);2:print(346);end;print(364);end;
{:211}{216:}procedure pushnest;
begin if nestptr>maxneststack then begin maxneststack:=nestptr;
if nestptr=nestsize then overflow(365,nestsize);end;
nest[nestptr]:=curlist;nestptr:=nestptr+1;curlist.headfield:=getavail;
curlist.tailfield:=curlist.headfield;curlist.pgfield:=0;
curlist.mlfield:=line;curlist.eTeXauxfield:=0;end;
{:216}{217:}procedure popnest;
begin begin mem[curlist.headfield].hh.rh:=avail;
avail:=curlist.headfield;{dynused:=dynused-1;}end;nestptr:=nestptr-1;
curlist:=nest[nestptr];end;{:217}{218:}procedure printtotals;forward;
procedure showactivities;var p:0..nestsize;m:-203..203;a:memoryword;
q,r:halfword;t:integer;begin nest[nestptr]:=curlist;printnl(339);
println;for p:=nestptr downto 0 do begin m:=nest[p].modefield;
a:=nest[p].auxfield;printnl(366);printmode(m);print(367);
printint(abs(nest[p].mlfield));
if m=102 then if nest[p].pgfield<>8585216 then begin print(368);
printint(nest[p].pgfield mod 65536);print(369);
printint(nest[p].pgfield div 4194304);printchar(44);
printint((nest[p].pgfield div 65536)mod 64);printchar(41);end;
if nest[p].mlfield<0 then print(370);
if p=0 then begin{986:}if 29998<>pagetail then begin printnl(991);
if outputactive then print(992);showbox(mem[29998].hh.rh);
if pagecontents>0 then begin printnl(993);printtotals;printnl(994);
printscaled(pagesofar[0]);r:=mem[30000].hh.rh;
while r<>30000 do begin println;printesc(331);t:=mem[r].hh.b1-0;
printint(t);print(995);
if eqtb[5333+t].int=1000 then t:=mem[r+3].int else t:=xovern(mem[r+3].
int,1000)*eqtb[5333+t].int;printscaled(t);
if mem[r].hh.b0=1 then begin q:=29998;t:=0;repeat q:=mem[q].hh.rh;
if(mem[q].hh.b0=3)and(mem[q].hh.b1=mem[r].hh.b1)then t:=t+1;
until q=mem[r+1].hh.lh;print(996);printint(t);print(997);end;
r:=mem[r].hh.rh;end;end;end{:986};
if mem[29999].hh.rh<>0 then printnl(371);end;
showbox(mem[nest[p].headfield].hh.rh);
{219:}case abs(m)div(101)of 0:begin printnl(372);
if a.int<=-65536000 then print(373)else printscaled(a.int);
if nest[p].pgfield<>0 then begin print(374);printint(nest[p].pgfield);
print(375);if nest[p].pgfield<>1 then printchar(115);end;end;
1:begin printnl(376);printint(a.hh.lh);
if m>0 then if a.hh.rh>0 then begin print(377);printint(a.hh.rh);end;
end;2:if a.int<>0 then begin print(378);showbox(a.int);end;end{:219};
end;end;{:218}{237:}procedure printparam(n:integer);
begin case n of 0:printesc(423);1:printesc(424);2:printesc(425);
3:printesc(426);4:printesc(427);5:printesc(428);6:printesc(429);
7:printesc(430);8:printesc(431);9:printesc(432);10:printesc(433);
11:printesc(434);12:printesc(435);13:printesc(436);14:printesc(437);
15:printesc(438);16:printesc(439);17:printesc(440);18:printesc(441);
19:printesc(442);20:printesc(443);21:printesc(444);22:printesc(445);
23:printesc(446);24:printesc(447);25:printesc(448);26:printesc(449);
27:printesc(450);28:printesc(451);29:printesc(452);30:printesc(453);
31:printesc(454);32:printesc(455);33:printesc(456);34:printesc(457);
35:printesc(458);36:printesc(459);37:printesc(460);38:printesc(461);
39:printesc(462);40:printesc(463);41:printesc(464);42:printesc(465);
43:printesc(466);44:printesc(467);45:printesc(468);46:printesc(469);
47:printesc(470);48:printesc(471);49:printesc(472);50:printesc(473);
51:printesc(474);52:printesc(475);53:printesc(476);54:printesc(477);
{1390:}55:printesc(1318);56:printesc(1319);57:printesc(1320);
58:printesc(1321);59:printesc(1322);60:printesc(1323);61:printesc(1324);
62:printesc(1325);63:printesc(1326);{:1390}{1431:}64:printesc(1365);
{:1431}others:print(478)end;end;{:237}{241:}procedure fixdateandtime;
begin eqtb[5288].int:=12*60;eqtb[5289].int:=4;eqtb[5290].int:=7;
eqtb[5291].int:=1776;end;{:241}{245:}procedure begindiagnostic;
begin oldsetting:=selector;
if(eqtb[5297].int<=0)and(selector=19)then begin selector:=selector-1;
if history=0 then history:=1;end;end;
procedure enddiagnostic(blankline:boolean);begin printnl(339);
if blankline then println;selector:=oldsetting;end;
{:245}{247:}procedure printlengthparam(n:integer);
begin case n of 0:printesc(481);1:printesc(482);2:printesc(483);
3:printesc(484);4:printesc(485);5:printesc(486);6:printesc(487);
7:printesc(488);8:printesc(489);9:printesc(490);10:printesc(491);
11:printesc(492);12:printesc(493);13:printesc(494);14:printesc(495);
15:printesc(496);16:printesc(497);17:printesc(498);18:printesc(499);
19:printesc(500);20:printesc(501);others:print(502)end;end;
{:247}{252:}{298:}procedure printcmdchr(cmd:quarterword;
chrcode:halfword);var n:integer;begin case cmd of 1:begin print(564);
print(chrcode);end;2:begin print(565);print(chrcode);end;
3:begin print(566);print(chrcode);end;6:begin print(567);print(chrcode);
end;7:begin print(568);print(chrcode);end;8:begin print(569);
print(chrcode);end;9:print(570);10:begin print(571);print(chrcode);end;
11:begin print(572);print(chrcode);end;12:begin print(573);
print(chrcode);end;
{227:}75,76:if chrcode<2900 then printskipparam(chrcode-2882)else if
chrcode<3156 then begin printesc(398);printint(chrcode-2900);
end else begin printesc(399);printint(chrcode-3156);end;
{:227}{231:}72:if chrcode>=3423 then begin printesc(410);
printint(chrcode-3423);end else case chrcode of 3413:printesc(401);
3414:printesc(402);3415:printesc(403);3416:printesc(404);
3417:printesc(405);3418:printesc(406);3419:printesc(407);
3420:printesc(408);{1389:}3422:printesc(1317);
{:1389}others:printesc(409)end;
{:231}{239:}73:if chrcode<5333 then printparam(chrcode-5268)else begin
printesc(479);printint(chrcode-5333);end;
{:239}{249:}74:if chrcode<5866 then printlengthparam(chrcode-5845)else
begin printesc(503);printint(chrcode-5866);end;
{:249}{266:}45:printesc(511);90:printesc(512);40:printesc(513);
41:printesc(514);77:printesc(522);61:printesc(515);42:printesc(535);
16:printesc(516);107:printesc(507);88:printesc(521);15:printesc(517);
92:printesc(518);67:printesc(508);62:printesc(519);64:printesc(32);
102:if chrcode=0 then printesc(520){1496:}else printesc(783){:1496};
32:printesc(523);36:printesc(524);39:printesc(525);37:printesc(331);
44:printesc(47);18:begin printesc(354);if chrcode>0 then printchar(115);
end;46:printesc(526);17:printesc(527);54:printesc(528);91:printesc(529);
34:printesc(530);65:printesc(531);103:printesc(532);55:printesc(336);
63:printesc(533);66:printesc(537);
96:if chrcode=0 then printesc(538){1493:}else printesc(1380){:1493};
0:printesc(539);98:printesc(540);80:printesc(536);
84:case chrcode of 3412:printesc(534);{1598:}3679:printesc(1413);
3680:printesc(1414);3681:printesc(1415);3682:printesc(1416);{:1598}end;
109:if chrcode=0 then printesc(541){1418:}else if chrcode=1 then
printesc(1355)else printesc(1356){:1418};71:{1566:}begin printesc(410);
if chrcode<>0 then printsanum(chrcode);end{:1566};38:printesc(355);
33:if chrcode=0 then printesc(542){1433:}else case chrcode of 6:printesc
(1366);7:printesc(1367);10:printesc(1368);
others:printesc(1369)end{:1433};56:printesc(543);35:printesc(544);
{:266}{335:}13:printesc(606);
{:335}{377:}104:if chrcode=0 then printesc(638){1481:}else if chrcode=2
then printesc(1378){:1481}else printesc(639);
{:377}{385:}110:begin case(chrcode mod 5)of 1:printesc(641);
2:printesc(642);3:printesc(643);4:printesc(644);others:printesc(640)end;
if chrcode>=5 then printchar(115);end;
{:385}{412:}89:{1565:}begin if(chrcode<0)or(chrcode>19)then cmd:=(mem[
chrcode].hh.b0 div 16)else begin cmd:=chrcode-0;chrcode:=0;end;
if cmd=0 then printesc(479)else if cmd=1 then printesc(503)else if cmd=2
then printesc(398)else printesc(399);
if chrcode<>0 then printsanum(chrcode);end{:1565};
{:412}{417:}79:if chrcode=1 then printesc(678)else printesc(677);
82:if chrcode=0 then printesc(679){1424:}else if chrcode=2 then printesc
(1361){:1424}else printesc(680);
83:if chrcode=1 then printesc(681)else if chrcode=3 then printesc(682)
else printesc(683);70:case chrcode of 0:printesc(684);1:printesc(685);
2:printesc(686);4:printesc(687);{1381:}3:printesc(1314);
6:printesc(1315);{:1381}{1395:}7:printesc(1340);8:printesc(1341);
{:1395}{1398:}9:printesc(1342);10:printesc(1343);11:printesc(1344);
{:1398}{1401:}14:printesc(1345);15:printesc(1346);16:printesc(1347);
17:printesc(1348);{:1401}{1404:}18:printesc(1349);19:printesc(1350);
20:printesc(1351);{:1404}{1512:}25:printesc(1389);26:printesc(1390);
27:printesc(1391);28:printesc(1392);{:1512}{1535:}12:printesc(1396);
13:printesc(1397);21:printesc(1398);22:printesc(1399);
{:1535}{1539:}23:printesc(1400);24:printesc(1401);
{:1539}others:printesc(688)end;
{:417}{469:}108:case chrcode of 0:printesc(744);1:printesc(745);
2:printesc(746);3:printesc(747);4:printesc(748);5:printesc(750);
others:printesc(749)end;
{:469}{488:}105:begin if chrcode>=32 then printesc(783);
case chrcode mod 32 of 1:printesc(767);2:printesc(768);3:printesc(769);
4:printesc(770);5:printesc(771);6:printesc(772);7:printesc(773);
8:printesc(774);9:printesc(775);10:printesc(776);11:printesc(777);
12:printesc(778);13:printesc(779);14:printesc(780);15:printesc(781);
16:printesc(782);{1497:}17:printesc(1381);18:printesc(1382);
19:printesc(1383);{:1497}others:printesc(766)end;end;
{:488}{492:}106:if chrcode=2 then printesc(784)else if chrcode=4 then
printesc(785)else printesc(786);
{:492}{781:}4:if chrcode=256 then printesc(909)else begin print(913);
print(chrcode);end;
5:if chrcode=257 then printesc(910)else printesc(911);
{:781}{984:}81:case chrcode of 0:printesc(981);1:printesc(982);
2:printesc(983);3:printesc(984);4:printesc(985);5:printesc(986);
6:printesc(987);others:printesc(988)end;
{:984}{1053:}14:if chrcode=1 then printesc(1036)else printesc(344);
{:1053}{1059:}26:case chrcode of 4:printesc(1037);0:printesc(1038);
1:printesc(1039);2:printesc(1040);others:printesc(1041)end;
27:case chrcode of 4:printesc(1042);0:printesc(1043);1:printesc(1044);
2:printesc(1045);others:printesc(1046)end;28:printesc(337);
29:printesc(341);30:printesc(343);
{:1059}{1072:}21:if chrcode=1 then printesc(1064)else printesc(1065);
22:if chrcode=1 then printesc(1066)else printesc(1067);
20:case chrcode of 0:printesc(412);1:printesc(1068);2:printesc(1069);
3:printesc(976);4:printesc(1070);5:printesc(978);
others:printesc(1071)end;
31:if chrcode=100 then printesc(1073)else if chrcode=101 then printesc(
1074)else if chrcode=102 then printesc(1075)else printesc(1072);
{:1072}{1089:}43:if chrcode=0 then printesc(1092)else printesc(1091);
{:1089}{1108:}25:if chrcode=10 then printesc(1103)else if chrcode=11
then printesc(1102)else printesc(1101);
23:if chrcode=1 then printesc(1105)else printesc(1104);
24:if chrcode=1 then printesc(1107){1595:}else if chrcode=2 then
printesc(1411)else if chrcode=3 then printesc(1412){:1595}else printesc(
1106);{:1108}{1115:}47:if chrcode=1 then printesc(45)else printesc(352);
{:1115}{1143:}48:if chrcode=1 then printesc(1139)else printesc(1138);
{:1143}{1157:}50:case chrcode of 16:printesc(876);17:printesc(877);
18:printesc(878);19:printesc(879);20:printesc(880);21:printesc(881);
22:printesc(882);23:printesc(883);26:printesc(885);
others:printesc(884)end;
51:if chrcode=1 then printesc(889)else if chrcode=2 then printesc(890)
else printesc(1140);{:1157}{1170:}53:printstyle(chrcode);
{:1170}{1179:}52:case chrcode of 1:printesc(1159);2:printesc(1160);
3:printesc(1161);4:printesc(1162);5:printesc(1163);
others:printesc(1158)end;
{:1179}{1189:}49:if chrcode=30 then printesc(886){1429:}else if chrcode=
1 then printesc(888){:1429}else printesc(887);
{:1189}{1209:}93:if chrcode=1 then printesc(1183)else if chrcode=2 then
printesc(1184){1504:}else if chrcode=8 then printesc(1197){:1504}else
printesc(1185);
97:if chrcode=0 then printesc(1186)else if chrcode=1 then printesc(1187)
else if chrcode=2 then printesc(1188)else printesc(1189);
{:1209}{1220:}94:if chrcode<>0 then printesc(1207)else printesc(1206);
{:1220}{1223:}95:case chrcode of 0:printesc(1208);1:printesc(1209);
2:printesc(1210);3:printesc(1211);4:printesc(1212);5:printesc(1213);
others:printesc(1214)end;68:begin printesc(516);printhex(chrcode);end;
69:begin printesc(527);printhex(chrcode);end;
{:1223}{1231:}85:if chrcode=3988 then printesc(418)else if chrcode=5012
then printesc(422)else if chrcode=4244 then printesc(419)else if chrcode
=4500 then printesc(420)else if chrcode=4756 then printesc(421)else
printesc(480);86:printsize(chrcode-3940);
{:1231}{1251:}99:if chrcode=1 then printesc(964)else printesc(952);
{:1251}{1255:}78:if chrcode=0 then printesc(1232)else printesc(1233);
{:1255}{1261:}87:begin print(1241);slowprint(fontname[chrcode]);
if fontsize[chrcode]<>fontdsize[chrcode]then begin print(751);
printscaled(fontsize[chrcode]);print(400);end;end;
{:1261}{1263:}100:case chrcode of 0:printesc(275);1:printesc(276);
2:printesc(277);others:printesc(1242)end;
{:1263}{1273:}60:if chrcode=0 then printesc(1244)else printesc(1243);
{:1273}{1278:}58:if chrcode=0 then printesc(1245)else printesc(1246);
{:1278}{1287:}57:if chrcode=4244 then printesc(1252)else printesc(1253);
{:1287}{1292:}19:case chrcode of 1:printesc(1255);2:printesc(1256);
3:printesc(1257);{1407:}4:printesc(1352);{:1407}{1416:}5:printesc(1354);
{:1416}{1421:}6:printesc(1357);{:1421}others:printesc(1254)end;
{:1292}{1295:}101:print(1264);111,112,113,114:begin n:=cmd-111;
if mem[mem[chrcode].hh.rh].hh.lh=3585 then n:=n+4;
if odd(n div 4)then printesc(1197);if odd(n)then printesc(1183);
if odd(n div 2)then printesc(1184);if n>0 then printchar(32);
print(1265);end;115:printesc(1266);
{:1295}{1346:}59:case chrcode of 0:printesc(1298);1:printesc(603);
2:printesc(1299);3:printesc(1300);4:printesc(1301);5:printesc(1302);
others:print(1303)end;{:1346}others:print(574)end;end;
{:298}{procedure showeqtb(n:halfword);
begin if n<1 then printchar(63)else if n<2882 then[223:]begin sprintcs(n
);printchar(61);printcmdchr(eqtb[n].hh.b0,eqtb[n].hh.rh);
if eqtb[n].hh.b0>=111 then begin printchar(58);
showtokenlist(mem[eqtb[n].hh.rh].hh.rh,0,32);end;
end[:223]else if n<3412 then[229:]if n<2900 then begin printskipparam(n
-2882);printchar(61);
if n<2897 then printspec(eqtb[n].hh.rh,400)else printspec(eqtb[n].hh.rh,
338);end else if n<3156 then begin printesc(398);printint(n-2900);
printchar(61);printspec(eqtb[n].hh.rh,400);end else begin printesc(399);
printint(n-3156);printchar(61);printspec(eqtb[n].hh.rh,338);
end[:229]else if n<5268 then[233:]if(n=3412)or((n>=3679)and(n<3683))then
begin printcmdchr(84,n);printchar(61);
if eqtb[n].hh.rh=0 then printchar(48)else if n>3412 then begin printint(
mem[eqtb[n].hh.rh+1].int);printchar(32);
printint(mem[eqtb[n].hh.rh+2].int);
if mem[eqtb[n].hh.rh+1].int>1 then printesc(411);
end else printint(mem[eqtb[3412].hh.rh].hh.lh);
end else if n<3423 then begin printcmdchr(72,n);printchar(61);
if eqtb[n].hh.rh<>0 then showtokenlist(mem[eqtb[n].hh.rh].hh.rh,0,32);
end else if n<3683 then begin printesc(410);printint(n-3423);
printchar(61);
if eqtb[n].hh.rh<>0 then showtokenlist(mem[eqtb[n].hh.rh].hh.rh,0,32);
end else if n<3939 then begin printesc(412);printint(n-3683);
printchar(61);
if eqtb[n].hh.rh=0 then print(413)else begin depththreshold:=0;
breadthmax:=1;shownodelist(eqtb[n].hh.rh);end;
end else if n<3988 then[234:]begin if n=3939 then print(414)else if n<
3956 then begin printesc(415);printint(n-3940);
end else if n<3972 then begin printesc(416);printint(n-3956);
end else begin printesc(417);printint(n-3972);end;printchar(61);
printesc(hash[2624+eqtb[n].hh.rh].rh);
end[:234]else[235:]if n<5012 then begin if n<4244 then begin printesc(
418);printint(n-3988);end else if n<4500 then begin printesc(419);
printint(n-4244);end else if n<4756 then begin printesc(420);
printint(n-4500);end else begin printesc(421);printint(n-4756);end;
printchar(61);printint(eqtb[n].hh.rh);end else begin printesc(422);
printint(n-5012);printchar(61);printint(eqtb[n].hh.rh-0);
end[:235][:233]else if n<5845 then[242:]begin if n<5333 then printparam(
n-5268)else if n<5589 then begin printesc(479);printint(n-5333);
end else begin printesc(480);printint(n-5589);end;printchar(61);
printint(eqtb[n].int);
end[:242]else if n<=6121 then[251:]begin if n<5866 then printlengthparam
(n-5845)else begin printesc(503);printint(n-5866);end;printchar(61);
printscaled(eqtb[n].int);print(400);end[:251]else printchar(63);end;}
{:252}{259:}function idlookup(j,l:integer):halfword;label 40;
var h:integer;d:integer;p:halfword;k:halfword;begin{261:}h:=buffer[j];
for k:=j+1 to j+l-1 do begin h:=h+h+buffer[k];
while h>=1777 do h:=h-1777;end{:261};p:=h+514;
while true do begin if hash[p].rh>0 then if(strstart[hash[p].rh+1]-
strstart[hash[p].rh])=l then if streqbuf(hash[p].rh,j)then goto 40;
if hash[p].lh=0 then begin if nonewcontrolsequence then p:=2881 else
{260:}begin if hash[p].rh>0 then begin repeat if(hashused=514)then
overflow(506,2100);hashused:=hashused-1;until hash[hashused].rh=0;
hash[p].lh:=hashused;p:=hashused;end;
begin if poolptr+l>poolsize then overflow(258,poolsize-initpoolptr);end;
d:=(poolptr-strstart[strptr]);
while poolptr>strstart[strptr]do begin poolptr:=poolptr-1;
strpool[poolptr+l]:=strpool[poolptr];end;
for k:=j to j+l-1 do begin strpool[poolptr]:=buffer[k];
poolptr:=poolptr+1;end;hash[p].rh:=makestring;poolptr:=poolptr+d;
{cscount:=cscount+1;}end{:260};goto 40;end;p:=hash[p].lh;end;
40:idlookup:=p;end;{:259}{264:}procedure primitive(s:strnumber;
c:quarterword;o:halfword);var k:poolpointer;j:0..bufsize;l:smallnumber;
begin if s<256 then curval:=s+257 else begin k:=strstart[s];
l:=strstart[s+1]-k;if first+l>bufsize+1 then overflow(257,bufsize);
for j:=0 to l-1 do buffer[first+j]:=strpool[k+j];
curval:=idlookup(first,l);begin strptr:=strptr-1;
poolptr:=strstart[strptr];end;hash[curval].rh:=s;end;
eqtb[curval].hh.b1:=1;eqtb[curval].hh.b0:=c;eqtb[curval].hh.rh:=o;end;
{:264}{268:}{284:}{procedure restoretrace(p:halfword;s:strnumber);
begin begindiagnostic;printchar(123);print(s);printchar(32);showeqtb(p);
printchar(125);enddiagnostic(false);end;}
{:284}{1392:}procedure printgroup(e:boolean);label 10;
begin case curgroup of 0:begin print(1327);goto 10;end;
1,14:begin if curgroup=14 then print(1328);print(1329);end;
2,3:begin if curgroup=3 then print(1330);print(1071);end;4:print(978);
5:print(1070);6,7:begin if curgroup=7 then print(1331);print(1332);end;
8:print(401);10:print(1333);11:print(331);12:print(543);
9,13,15,16:begin print(346);
if curgroup=13 then print(1334)else if curgroup=15 then print(1335)else
if curgroup=16 then print(1336);end;end;print(1337);
printint(curlevel-0);printchar(41);
if savestack[saveptr-1].int<>0 then begin if e then print(367)else print
(267);printint(savestack[saveptr-1].int);end;10:end;
{:1392}{1393:}{procedure grouptrace(e:boolean);begin begindiagnostic;
printchar(123);if e then print(1338)else print(1339);printgroup(e);
printchar(125);enddiagnostic(false);end;}
{:1393}{1489:}function pseudoinput:boolean;var p:halfword;sz:integer;
w:fourquarters;r:halfword;begin last:=first;p:=mem[pseudofiles].hh.lh;
if p=0 then pseudoinput:=false else begin mem[pseudofiles].hh.lh:=mem[p]
.hh.rh;sz:=mem[p].hh.lh-0;
if 4*sz-3>=bufsize-last then{35:}if formatident=0 then begin writeln(
termout,'Buffer size exceeded!');goto 9999;
end else begin curinput.locfield:=first;curinput.limitfield:=last-1;
overflow(257,bufsize);end{:35};last:=first;
for r:=p+1 to p+sz-1 do begin w:=mem[r].qqqq;buffer[last]:=w.b0;
buffer[last+1]:=w.b1;buffer[last+2]:=w.b2;buffer[last+3]:=w.b3;
last:=last+4;end;if last>=maxbufstack then maxbufstack:=last+1;
while(last>first)and(buffer[last-1]=32)do last:=last-1;freenode(p,sz);
pseudoinput:=true;end;end;{:1489}{1490:}procedure pseudoclose;
var p,q:halfword;begin p:=mem[pseudofiles].hh.rh;
q:=mem[pseudofiles].hh.lh;begin mem[pseudofiles].hh.rh:=avail;
avail:=pseudofiles;{dynused:=dynused-1;}end;pseudofiles:=p;
while q<>0 do begin p:=q;q:=mem[p].hh.rh;freenode(p,mem[p].hh.lh-0);end;
end;{:1490}{1507:}procedure groupwarning;var i:0..maxinopen;w:boolean;
begin baseptr:=inputptr;inputstack[baseptr]:=curinput;i:=inopen;
w:=false;
while(grpstack[i]=curboundary)and(i>0)do begin{1508:}if eqtb[5327].int>0
then begin while(inputstack[baseptr].statefield=0)or(inputstack[baseptr]
.indexfield>i)do baseptr:=baseptr-1;
if inputstack[baseptr].namefield>17 then w:=true;end{:1508};
grpstack[i]:=savestack[saveptr].hh.rh;i:=i-1;end;
if w then begin printnl(1385);printgroup(true);print(1386);println;
if eqtb[5327].int>1 then showcontext;if history=0 then history:=1;end;
end;{:1507}{1509:}procedure ifwarning;var i:0..maxinopen;w:boolean;
begin baseptr:=inputptr;inputstack[baseptr]:=curinput;i:=inopen;
w:=false;
while ifstack[i]=condptr do begin{1508:}if eqtb[5327].int>0 then begin
while(inputstack[baseptr].statefield=0)or(inputstack[baseptr].indexfield
>i)do baseptr:=baseptr-1;
if inputstack[baseptr].namefield>17 then w:=true;end{:1508};
ifstack[i]:=mem[condptr].hh.rh;i:=i-1;end;if w then begin printnl(1385);
printcmdchr(105,curif);if ifline<>0 then begin print(1358);
printint(ifline);end;print(1386);println;
if eqtb[5327].int>1 then showcontext;if history=0 then history:=1;end;
end;{:1509}{1510:}procedure filewarning;var p:halfword;l:quarterword;
c:quarterword;i:integer;begin p:=saveptr;l:=curlevel;c:=curgroup;
saveptr:=curboundary;
while grpstack[inopen]<>saveptr do begin curlevel:=curlevel-1;
printnl(1387);printgroup(true);print(1388);
curgroup:=savestack[saveptr].hh.b1;
saveptr:=savestack[saveptr].hh.rh end;saveptr:=p;curlevel:=l;
curgroup:=c;p:=condptr;l:=iflimit;c:=curif;i:=ifline;
while ifstack[inopen]<>condptr do begin printnl(1387);
printcmdchr(105,curif);if iflimit=2 then printesc(786);
if ifline<>0 then begin print(1358);printint(ifline);end;print(1388);
ifline:=mem[condptr+1].int;curif:=mem[condptr].hh.b1;
iflimit:=mem[condptr].hh.b0;condptr:=mem[condptr].hh.rh;end;condptr:=p;
iflimit:=l;curif:=c;ifline:=i;println;
if eqtb[5327].int>1 then showcontext;if history=0 then history:=1;end;
{:1510}{1554:}procedure deletesaref(q:halfword);label 10;var p:halfword;
i:smallnumber;s:smallnumber;begin mem[q+1].hh.lh:=mem[q+1].hh.lh-1;
if mem[q+1].hh.lh<>0 then goto 10;
if mem[q].hh.b0<32 then if mem[q+2].int=0 then s:=3 else goto 10 else
begin if mem[q].hh.b0<64 then if mem[q+1].hh.rh=0 then deleteglueref(0)
else goto 10 else if mem[q+1].hh.rh<>0 then goto 10;s:=2;end;
repeat i:=mem[q].hh.b0 mod 16;p:=q;q:=mem[p].hh.rh;freenode(p,s);
if q=0 then begin saroot[i]:=0;goto 10;end;
begin if odd(i)then mem[q+(i div 2)+1].hh.rh:=0 else mem[q+(i div 2)+1].
hh.lh:=0;mem[q].hh.b1:=mem[q].hh.b1-1;end;s:=9;until mem[q].hh.b1>0;
10:end;{:1554}{1556:}{procedure showsa(p:halfword;s:strnumber);
var t:smallnumber;begin begindiagnostic;printchar(123);print(s);
printchar(32);
if p=0 then printchar(63)else begin t:=(mem[p].hh.b0 div 16);
if t<4 then printcmdchr(89,p)else if t=4 then begin printesc(412);
printsanum(p);end else if t=5 then printcmdchr(71,p)else printchar(63);
printchar(61);
if t=0 then printint(mem[p+2].int)else if t=1 then begin printscaled(mem
[p+2].int);print(400);end else begin p:=mem[p+1].hh.rh;
if t=2 then printspec(p,400)else if t=3 then printspec(p,338)else if t=4
then if p=0 then print(413)else begin depththreshold:=0;breadthmax:=1;
shownodelist(p);
end else if t=5 then begin if p<>0 then showtokenlist(mem[p].hh.rh,0,32)
;end else printchar(63);end;end;printchar(125);enddiagnostic(false);end;
}{:1556}{1570:}procedure sasave(p:halfword);var q:halfword;
i:quarterword;
begin if curlevel<>salevel then begin if saveptr>maxsavestack then begin
maxsavestack:=saveptr;
if maxsavestack>savesize-7 then overflow(545,savesize);end;
savestack[saveptr].hh.b0:=4;savestack[saveptr].hh.b1:=salevel;
savestack[saveptr].hh.rh:=sachain;saveptr:=saveptr+1;sachain:=0;
salevel:=curlevel;end;i:=mem[p].hh.b0;
if i<32 then begin if mem[p+2].int=0 then begin q:=getnode(2);i:=96;
end else begin q:=getnode(3);mem[q+2].int:=mem[p+2].int;end;
mem[q+1].hh.rh:=0;end else begin q:=getnode(2);
mem[q+1].hh.rh:=mem[p+1].hh.rh;end;mem[q+1].hh.lh:=p;mem[q].hh.b0:=i;
mem[q].hh.b1:=mem[p].hh.b1;mem[q].hh.rh:=sachain;sachain:=q;
mem[p+1].hh.lh:=mem[p+1].hh.lh+1;end;
{:1570}{1571:}procedure sadestroy(p:halfword);
begin if mem[p].hh.b0<64 then deleteglueref(mem[p+1].hh.rh)else if mem[p
+1].hh.rh<>0 then if mem[p].hh.b0<80 then flushnodelist(mem[p+1].hh.rh)
else deletetokenref(mem[p+1].hh.rh);end;
{:1571}{1572:}procedure sadef(p:halfword;e:halfword);
begin mem[p+1].hh.lh:=mem[p+1].hh.lh+1;
if mem[p+1].hh.rh=e then begin{if eqtb[5323].int>0 then showsa(p,547);}
sadestroy(p);end else begin{if eqtb[5323].int>0 then showsa(p,548);}
if mem[p].hh.b1=curlevel then sadestroy(p)else sasave(p);
mem[p].hh.b1:=curlevel;mem[p+1].hh.rh:=e;
{if eqtb[5323].int>0 then showsa(p,549);}end;deletesaref(p);end;
procedure sawdef(p:halfword;w:integer);
begin mem[p+1].hh.lh:=mem[p+1].hh.lh+1;
if mem[p+2].int=w then begin{if eqtb[5323].int>0 then showsa(p,547);}
end else begin{if eqtb[5323].int>0 then showsa(p,548);}
if mem[p].hh.b1<>curlevel then sasave(p);mem[p].hh.b1:=curlevel;
mem[p+2].int:=w;{if eqtb[5323].int>0 then showsa(p,549);}end;
deletesaref(p);end;{:1572}{1573:}procedure gsadef(p:halfword;
e:halfword);begin mem[p+1].hh.lh:=mem[p+1].hh.lh+1;
{if eqtb[5323].int>0 then showsa(p,550);}sadestroy(p);mem[p].hh.b1:=1;
mem[p+1].hh.rh:=e;{if eqtb[5323].int>0 then showsa(p,549);}
deletesaref(p);end;procedure gsawdef(p:halfword;w:integer);
begin mem[p+1].hh.lh:=mem[p+1].hh.lh+1;
{if eqtb[5323].int>0 then showsa(p,550);}mem[p].hh.b1:=1;
mem[p+2].int:=w;{if eqtb[5323].int>0 then showsa(p,549);}deletesaref(p);
end;{:1573}{1574:}procedure sarestore;var p:halfword;
begin repeat p:=mem[sachain+1].hh.lh;
if mem[p].hh.b1=1 then begin if mem[p].hh.b0>=32 then sadestroy(sachain)
;{if eqtb[5305].int>0 then showsa(p,552);}
end else begin if mem[p].hh.b0<32 then if mem[sachain].hh.b0<32 then mem
[p+2].int:=mem[sachain+2].int else mem[p+2].int:=0 else begin sadestroy(
p);mem[p+1].hh.rh:=mem[sachain+1].hh.rh;end;
mem[p].hh.b1:=mem[sachain].hh.b1;
{if eqtb[5305].int>0 then showsa(p,553);}end;deletesaref(p);p:=sachain;
sachain:=mem[p].hh.rh;
if mem[p].hh.b0<32 then freenode(p,3)else freenode(p,2);until sachain=0;
end;{:1574}{:268}{274:}procedure newsavelevel(c:groupcode);
begin if saveptr>maxsavestack then begin maxsavestack:=saveptr;
if maxsavestack>savesize-7 then overflow(545,savesize);end;
if(eTeXmode=1)then begin savestack[saveptr+0].int:=line;
saveptr:=saveptr+1;end;savestack[saveptr].hh.b0:=3;
savestack[saveptr].hh.b1:=curgroup;
savestack[saveptr].hh.rh:=curboundary;
if curlevel=255 then overflow(546,255);curboundary:=saveptr;curgroup:=c;
{if eqtb[5324].int>0 then grouptrace(false);}curlevel:=curlevel+1;
saveptr:=saveptr+1;end;{:274}{275:}procedure eqdestroy(w:memoryword);
var q:halfword;
begin case w.hh.b0 of 111,112,113,114:deletetokenref(w.hh.rh);
117:deleteglueref(w.hh.rh);118:begin q:=w.hh.rh;
if q<>0 then freenode(q,mem[q].hh.lh+mem[q].hh.lh+1);end;
119:flushnodelist(w.hh.rh);
{1567:}71,89:if(w.hh.rh<0)or(w.hh.rh>19)then deletesaref(w.hh.rh);
{:1567}others:end;end;{:275}{276:}procedure eqsave(p:halfword;
l:quarterword);
begin if saveptr>maxsavestack then begin maxsavestack:=saveptr;
if maxsavestack>savesize-7 then overflow(545,savesize);end;
if l=0 then savestack[saveptr].hh.b0:=1 else begin savestack[saveptr]:=
eqtb[p];saveptr:=saveptr+1;savestack[saveptr].hh.b0:=0;end;
savestack[saveptr].hh.b1:=l;savestack[saveptr].hh.rh:=p;
saveptr:=saveptr+1;end;{:276}{277:}procedure eqdefine(p:halfword;
t:quarterword;e:halfword);label 10;
begin if(eTeXmode=1)and(eqtb[p].hh.b0=t)and(eqtb[p].hh.rh=e)then begin{
if eqtb[5323].int>0 then restoretrace(p,547);}eqdestroy(eqtb[p]);
goto 10;end;{if eqtb[5323].int>0 then restoretrace(p,548);}
if eqtb[p].hh.b1=curlevel then eqdestroy(eqtb[p])else if curlevel>1 then
eqsave(p,eqtb[p].hh.b1);eqtb[p].hh.b1:=curlevel;eqtb[p].hh.b0:=t;
eqtb[p].hh.rh:=e;{if eqtb[5323].int>0 then restoretrace(p,549);}10:end;
{:277}{278:}procedure eqworddefine(p:halfword;w:integer);label 10;
begin if(eTeXmode=1)and(eqtb[p].int=w)then begin{if eqtb[5323].int>0
then restoretrace(p,547);}goto 10;end;
{if eqtb[5323].int>0 then restoretrace(p,548);}
if xeqlevel[p]<>curlevel then begin eqsave(p,xeqlevel[p]);
xeqlevel[p]:=curlevel;end;eqtb[p].int:=w;
{if eqtb[5323].int>0 then restoretrace(p,549);}10:end;
{:278}{279:}procedure geqdefine(p:halfword;t:quarterword;e:halfword);
begin{if eqtb[5323].int>0 then restoretrace(p,550);}
begin eqdestroy(eqtb[p]);eqtb[p].hh.b1:=1;eqtb[p].hh.b0:=t;
eqtb[p].hh.rh:=e;end;{if eqtb[5323].int>0 then restoretrace(p,549);}end;
procedure geqworddefine(p:halfword;w:integer);
begin{if eqtb[5323].int>0 then restoretrace(p,550);}
begin eqtb[p].int:=w;xeqlevel[p]:=1;end;
{if eqtb[5323].int>0 then restoretrace(p,549);}end;
{:279}{280:}procedure saveforafter(t:halfword);
begin if curlevel>1 then begin if saveptr>maxsavestack then begin
maxsavestack:=saveptr;
if maxsavestack>savesize-7 then overflow(545,savesize);end;
savestack[saveptr].hh.b0:=2;savestack[saveptr].hh.b1:=0;
savestack[saveptr].hh.rh:=t;saveptr:=saveptr+1;end;end;
{:280}{281:}procedure backinput;forward;procedure unsave;label 30;
var p:halfword;l:quarterword;t:halfword;a:boolean;begin a:=false;
if curlevel>1 then begin curlevel:=curlevel-1;
{282:}while true do begin saveptr:=saveptr-1;
if savestack[saveptr].hh.b0=3 then goto 30;p:=savestack[saveptr].hh.rh;
if savestack[saveptr].hh.b0=2 then{326:}begin t:=curtok;curtok:=p;
if a then begin p:=getavail;mem[p].hh.lh:=curtok;
mem[p].hh.rh:=curinput.locfield;curinput.locfield:=p;
curinput.startfield:=p;
if curtok<768 then if curtok<512 then alignstate:=alignstate-1 else
alignstate:=alignstate+1;end else begin backinput;a:=(eTeXmode=1);end;
curtok:=t;
end{:326}else if savestack[saveptr].hh.b0=4 then begin sarestore;
sachain:=p;salevel:=savestack[saveptr].hh.b1;
end else begin if savestack[saveptr].hh.b0=0 then begin l:=savestack[
saveptr].hh.b1;saveptr:=saveptr-1;
end else savestack[saveptr]:=eqtb[2881];
{283:}if p<5268 then if eqtb[p].hh.b1=1 then begin eqdestroy(savestack[
saveptr]);{if eqtb[5305].int>0 then restoretrace(p,552);}
end else begin eqdestroy(eqtb[p]);eqtb[p]:=savestack[saveptr];
{if eqtb[5305].int>0 then restoretrace(p,553);}
end else if xeqlevel[p]<>1 then begin eqtb[p]:=savestack[saveptr];
xeqlevel[p]:=l;{if eqtb[5305].int>0 then restoretrace(p,553);}
end else begin{if eqtb[5305].int>0 then restoretrace(p,552);}end{:283};
end;end;30:{if eqtb[5324].int>0 then grouptrace(true);}
if grpstack[inopen]=curboundary then groupwarning;
curgroup:=savestack[saveptr].hh.b1;
curboundary:=savestack[saveptr].hh.rh;
if(eTeXmode=1)then saveptr:=saveptr-1{:282};end else confusion(551);end;
{:281}{288:}procedure preparemag;
begin if(magset>0)and(eqtb[5285].int<>magset)then begin begin if
interaction=3 then;printnl(263);print(555);end;printint(eqtb[5285].int);
print(556);printnl(557);begin helpptr:=2;helpline[1]:=558;
helpline[0]:=559;end;interror(magset);geqworddefine(5285,magset);end;
if(eqtb[5285].int<=0)or(eqtb[5285].int>32768)then begin begin if
interaction=3 then;printnl(263);print(560);end;begin helpptr:=1;
helpline[0]:=561;end;interror(eqtb[5285].int);geqworddefine(5285,1000);
end;magset:=eqtb[5285].int;end;
{:288}{295:}procedure tokenshow(p:halfword);
begin if p<>0 then showtokenlist(mem[p].hh.rh,0,10000000);end;
{:295}{296:}procedure printmeaning;begin printcmdchr(curcmd,curchr);
if curcmd>=111 then begin printchar(58);println;tokenshow(curchr);
end else if(curcmd=110)and(curchr<5)then begin printchar(58);println;
tokenshow(curmark[curchr]);end;end;{:296}{299:}procedure showcurcmdchr;
var n:integer;l:integer;p:halfword;begin begindiagnostic;printnl(123);
if curlist.modefield<>shownmode then begin printmode(curlist.modefield);
print(575);shownmode:=curlist.modefield;end;printcmdchr(curcmd,curchr);
if eqtb[5325].int>0 then if curcmd>=105 then if curcmd<=106 then begin
print(575);if curcmd=106 then begin printcmdchr(105,curif);
printchar(32);n:=0;l:=ifline;end else begin n:=1;l:=line;end;p:=condptr;
while p<>0 do begin n:=n+1;p:=mem[p].hh.rh;end;print(576);printint(n);
printchar(41);if l<>0 then begin print(1358);printint(l);end;end;
printchar(125);enddiagnostic(false);end;
{:299}{311:}procedure showcontext;label 30;var oldsetting:0..21;
nn:integer;bottomline:boolean;{315:}i:0..bufsize;j:0..bufsize;
l:0..halferrorline;m:integer;n:0..errorline;p:integer;q:integer;
{:315}begin baseptr:=inputptr;inputstack[baseptr]:=curinput;nn:=-1;
bottomline:=false;while true do begin curinput:=inputstack[baseptr];
if(curinput.statefield<>0)then if(curinput.namefield>19)or(baseptr=0)
then bottomline:=true;
if(baseptr=inputptr)or bottomline or(nn<eqtb[5322].int)then{312:}begin
if(baseptr=inputptr)or(curinput.statefield<>0)or(curinput.indexfield<>3)
or(curinput.locfield<>0)then begin tally:=0;oldsetting:=selector;
if curinput.statefield<>0 then begin{313:}if curinput.namefield<=17 then
if(curinput.namefield=0)then if baseptr=0 then printnl(582)else printnl(
583)else begin printnl(584);
if curinput.namefield=17 then printchar(42)else printint(curinput.
namefield-1);printchar(62);
end else if curinput.indexfield<>inopen then begin printnl(585);
printint(linestack[curinput.indexfield+1]);end else begin printnl(585);
printint(line);end;printchar(32){:313};{318:}begin l:=tally;tally:=0;
selector:=20;trickcount:=1000000;end;
if buffer[curinput.limitfield]=eqtb[5316].int then j:=curinput.
limitfield else j:=curinput.limitfield+1;
if j>0 then for i:=curinput.startfield to j-1 do begin if i=curinput.
locfield then begin firstcount:=tally;
trickcount:=tally+1+errorline-halferrorline;
if trickcount<errorline then trickcount:=errorline;end;print(buffer[i]);
end{:318};
end else begin{314:}case curinput.indexfield of 0:printnl(586);
1,2:printnl(587);
3:if curinput.locfield=0 then printnl(588)else printnl(589);
4:printnl(590);5:begin println;printcs(curinput.namefield);end;
6:printnl(591);7:printnl(592);8:printnl(593);9:printnl(594);
10:printnl(595);11:printnl(596);12:printnl(597);13:printnl(598);
14:printnl(599);15:printnl(600);16:printnl(601);
others:printnl(63)end{:314};{319:}begin l:=tally;tally:=0;selector:=20;
trickcount:=1000000;end;
if curinput.indexfield<5 then showtokenlist(curinput.startfield,curinput
.locfield,100000)else showtokenlist(mem[curinput.startfield].hh.rh,
curinput.locfield,100000){:319};end;selector:=oldsetting;
{317:}if trickcount=1000000 then begin firstcount:=tally;
trickcount:=tally+1+errorline-halferrorline;
if trickcount<errorline then trickcount:=errorline;end;
if tally<trickcount then m:=tally-firstcount else m:=trickcount-
firstcount;if l+firstcount<=halferrorline then begin p:=0;
n:=l+firstcount;end else begin print(278);
p:=l+firstcount-halferrorline+3;n:=halferrorline;end;
for q:=p to firstcount-1 do printchar(trickbuf[q mod errorline]);
println;for q:=1 to n do printchar(32);
if m+n<=errorline then p:=firstcount+m else p:=firstcount+(errorline-n-3
);for q:=firstcount to p-1 do printchar(trickbuf[q mod errorline]);
if m+n>errorline then print(278){:317};nn:=nn+1;end;
end{:312}else if nn=eqtb[5322].int then begin printnl(278);nn:=nn+1;end;
if bottomline then goto 30;baseptr:=baseptr-1;end;
30:curinput:=inputstack[inputptr];end;
{:311}{323:}procedure begintokenlist(p:halfword;t:quarterword);
begin begin if inputptr>maxinstack then begin maxinstack:=inputptr;
if inputptr=stacksize then overflow(602,stacksize);end;
inputstack[inputptr]:=curinput;inputptr:=inputptr+1;end;
curinput.statefield:=0;curinput.startfield:=p;curinput.indexfield:=t;
if t>=5 then begin mem[p].hh.lh:=mem[p].hh.lh+1;
if t=5 then curinput.limitfield:=paramptr else begin curinput.locfield:=
mem[p].hh.rh;if eqtb[5298].int>1 then begin begindiagnostic;
printnl(339);case t of 14:printesc(354);16:printesc(603);
others:printcmdchr(72,t+3407)end;print(563);tokenshow(p);
enddiagnostic(false);end;end;end else curinput.locfield:=p;end;
{:323}{324:}procedure endtokenlist;
begin if curinput.indexfield>=3 then begin if curinput.indexfield<=4
then flushlist(curinput.startfield)else begin deletetokenref(curinput.
startfield);
if curinput.indexfield=5 then while paramptr>curinput.limitfield do
begin paramptr:=paramptr-1;flushlist(paramstack[paramptr]);end;end;
end else if curinput.indexfield=1 then if alignstate>500000 then
alignstate:=0 else fatalerror(604);begin inputptr:=inputptr-1;
curinput:=inputstack[inputptr];end;
begin if interrupt<>0 then pauseforinstructions;end;end;
{:324}{325:}procedure backinput;var p:halfword;
begin while(curinput.statefield=0)and(curinput.locfield=0)and(curinput.
indexfield<>2)do endtokenlist;p:=getavail;mem[p].hh.lh:=curtok;
if curtok<768 then if curtok<512 then alignstate:=alignstate-1 else
alignstate:=alignstate+1;
begin if inputptr>maxinstack then begin maxinstack:=inputptr;
if inputptr=stacksize then overflow(602,stacksize);end;
inputstack[inputptr]:=curinput;inputptr:=inputptr+1;end;
curinput.statefield:=0;curinput.startfield:=p;curinput.indexfield:=3;
curinput.locfield:=p;end;{:325}{327:}procedure backerror;
begin OKtointerrupt:=false;backinput;OKtointerrupt:=true;error;end;
procedure inserror;begin OKtointerrupt:=false;backinput;
curinput.indexfield:=4;OKtointerrupt:=true;error;end;
{:327}{328:}procedure beginfilereading;
begin if inopen=maxinopen then overflow(605,maxinopen);
if first=bufsize then overflow(257,bufsize);inopen:=inopen+1;
begin if inputptr>maxinstack then begin maxinstack:=inputptr;
if inputptr=stacksize then overflow(602,stacksize);end;
inputstack[inputptr]:=curinput;inputptr:=inputptr+1;end;
curinput.indexfield:=inopen;eofseen[curinput.indexfield]:=false;
grpstack[curinput.indexfield]:=curboundary;
ifstack[curinput.indexfield]:=condptr;
linestack[curinput.indexfield]:=line;curinput.startfield:=first;
curinput.statefield:=1;curinput.namefield:=0;end;
{:328}{329:}procedure endfilereading;begin first:=curinput.startfield;
line:=linestack[curinput.indexfield];
if(curinput.namefield=18)or(curinput.namefield=19)then pseudoclose else
if curinput.namefield>17 then aclose(inputfile[curinput.indexfield]);
begin inputptr:=inputptr-1;curinput:=inputstack[inputptr];end;
inopen:=inopen-1;end;{:329}{330:}procedure clearforerrorprompt;
begin while(curinput.statefield<>0)and(curinput.namefield=0)and(inputptr
>0)and(curinput.locfield>curinput.limitfield)do endfilereading;println;
breakin(termin,true);end;{:330}{336:}procedure checkoutervalidity;
var p:halfword;q:halfword;
begin if scannerstatus<>0 then begin deletionsallowed:=false;
{337:}if curcs<>0 then begin if(curinput.statefield=0)or(curinput.
namefield<1)or(curinput.namefield>17)then begin p:=getavail;
mem[p].hh.lh:=4095+curcs;begintokenlist(p,3);end;curcmd:=10;curchr:=32;
end{:337};if scannerstatus>1 then{338:}begin runaway;
if curcs=0 then begin if interaction=3 then;printnl(263);print(613);
end else begin curcs:=0;begin if interaction=3 then;printnl(263);
print(614);end;end;print(615);{339:}p:=getavail;
case scannerstatus of 2:begin print(578);mem[p].hh.lh:=637;end;
3:begin print(621);mem[p].hh.lh:=partoken;longstate:=113;end;
4:begin print(580);mem[p].hh.lh:=637;q:=p;p:=getavail;mem[p].hh.rh:=q;
mem[p].hh.lh:=6710;alignstate:=-1000000;end;5:begin print(581);
mem[p].hh.lh:=637;end;end;begintokenlist(p,4){:339};print(616);
sprintcs(warningindex);begin helpptr:=4;helpline[3]:=617;
helpline[2]:=618;helpline[1]:=619;helpline[0]:=620;end;error;
end{:338}else begin begin if interaction=3 then;printnl(263);print(607);
end;printcmdchr(105,curif);print(608);printint(skipline);
begin helpptr:=3;helpline[2]:=609;helpline[1]:=610;helpline[0]:=611;end;
if curcs<>0 then curcs:=0 else helpline[2]:=612;curtok:=6713;inserror;
end;deletionsallowed:=true;end;end;{:336}{340:}procedure firmuptheline;
forward;{:340}{341:}procedure getnext;label 20,25,21,26,40,10;
var k:0..bufsize;t:halfword;cat:0..15;c,cc:ASCIIcode;d:2..3;
begin 20:curcs:=0;
if curinput.statefield<>0 then{343:}begin 25:if curinput.locfield<=
curinput.limitfield then begin curchr:=buffer[curinput.locfield];
curinput.locfield:=curinput.locfield+1;
21:curcmd:=eqtb[3988+curchr].hh.rh;
{344:}case curinput.statefield+curcmd of{345:}10,26,42,27,43{:345}:goto
25;
1,17,33:{354:}begin if curinput.locfield>curinput.limitfield then curcs
:=513 else begin 26:k:=curinput.locfield;curchr:=buffer[k];
cat:=eqtb[3988+curchr].hh.rh;k:=k+1;
if cat=11 then curinput.statefield:=17 else if cat=10 then curinput.
statefield:=17 else curinput.statefield:=1;
if(cat=11)and(k<=curinput.limitfield)then{356:}begin repeat curchr:=
buffer[k];cat:=eqtb[3988+curchr].hh.rh;k:=k+1;
until(cat<>11)or(k>curinput.limitfield);
{355:}begin if buffer[k]=curchr then if cat=7 then if k<curinput.
limitfield then begin c:=buffer[k+1];if c<128 then begin d:=2;
if(((c>=48)and(c<=57))or((c>=97)and(c<=102)))then if k+2<=curinput.
limitfield then begin cc:=buffer[k+2];
if(((cc>=48)and(cc<=57))or((cc>=97)and(cc<=102)))then d:=d+1;end;
if d>2 then begin if c<=57 then curchr:=c-48 else curchr:=c-87;
if cc<=57 then curchr:=16*curchr+cc-48 else curchr:=16*curchr+cc-87;
buffer[k-1]:=curchr;
end else if c<64 then buffer[k-1]:=c+64 else buffer[k-1]:=c-64;
curinput.limitfield:=curinput.limitfield-d;first:=first-d;
while k<=curinput.limitfield do begin buffer[k]:=buffer[k+d];k:=k+1;end;
goto 26;end;end;end{:355};if cat<>11 then k:=k-1;
if k>curinput.locfield+1 then begin curcs:=idlookup(curinput.locfield,k-
curinput.locfield);curinput.locfield:=k;goto 40;end;
end{:356}else{355:}begin if buffer[k]=curchr then if cat=7 then if k<
curinput.limitfield then begin c:=buffer[k+1];if c<128 then begin d:=2;
if(((c>=48)and(c<=57))or((c>=97)and(c<=102)))then if k+2<=curinput.
limitfield then begin cc:=buffer[k+2];
if(((cc>=48)and(cc<=57))or((cc>=97)and(cc<=102)))then d:=d+1;end;
if d>2 then begin if c<=57 then curchr:=c-48 else curchr:=c-87;
if cc<=57 then curchr:=16*curchr+cc-48 else curchr:=16*curchr+cc-87;
buffer[k-1]:=curchr;
end else if c<64 then buffer[k-1]:=c+64 else buffer[k-1]:=c-64;
curinput.limitfield:=curinput.limitfield-d;first:=first-d;
while k<=curinput.limitfield do begin buffer[k]:=buffer[k+d];k:=k+1;end;
goto 26;end;end;end{:355};curcs:=257+buffer[curinput.locfield];
curinput.locfield:=curinput.locfield+1;end;40:curcmd:=eqtb[curcs].hh.b0;
curchr:=eqtb[curcs].hh.rh;if curcmd>=113 then checkoutervalidity;
end{:354};14,30,46:{353:}begin curcs:=curchr+1;
curcmd:=eqtb[curcs].hh.b0;curchr:=eqtb[curcs].hh.rh;
curinput.statefield:=1;if curcmd>=113 then checkoutervalidity;end{:353};
8,24,40:{352:}begin if curchr=buffer[curinput.locfield]then if curinput.
locfield<curinput.limitfield then begin c:=buffer[curinput.locfield+1];
if c<128 then begin curinput.locfield:=curinput.locfield+2;
if(((c>=48)and(c<=57))or((c>=97)and(c<=102)))then if curinput.locfield<=
curinput.limitfield then begin cc:=buffer[curinput.locfield];
if(((cc>=48)and(cc<=57))or((cc>=97)and(cc<=102)))then begin curinput.
locfield:=curinput.locfield+1;
if c<=57 then curchr:=c-48 else curchr:=c-87;
if cc<=57 then curchr:=16*curchr+cc-48 else curchr:=16*curchr+cc-87;
goto 21;end;end;if c<64 then curchr:=c+64 else curchr:=c-64;goto 21;end;
end;curinput.statefield:=1;end{:352};
16,32,48:{346:}begin begin if interaction=3 then;printnl(263);
print(622);end;begin helpptr:=2;helpline[1]:=623;helpline[0]:=624;end;
deletionsallowed:=false;error;deletionsallowed:=true;goto 20;end{:346};
{347:}11:{349:}begin curinput.statefield:=17;curchr:=32;end{:349};
6:{348:}begin curinput.locfield:=curinput.limitfield+1;curcmd:=10;
curchr:=32;end{:348};
22,15,31,47:{350:}begin curinput.locfield:=curinput.limitfield+1;
goto 25;end{:350};
38:{351:}begin curinput.locfield:=curinput.limitfield+1;curcs:=parloc;
curcmd:=eqtb[curcs].hh.b0;curchr:=eqtb[curcs].hh.rh;
if curcmd>=113 then checkoutervalidity;end{:351};
2:alignstate:=alignstate+1;18,34:begin curinput.statefield:=1;
alignstate:=alignstate+1;end;3:alignstate:=alignstate-1;
19,35:begin curinput.statefield:=1;alignstate:=alignstate-1;end;
20,21,23,25,28,29,36,37,39,41,44,45:curinput.statefield:=1;
{:347}others:end{:344};end else begin curinput.statefield:=33;
{360:}if curinput.namefield>17 then{362:}begin line:=line+1;
first:=curinput.startfield;
if not forceeof then if curinput.namefield<=19 then begin if pseudoinput
then firmuptheline else if(eqtb[3422].hh.rh<>0)and not eofseen[curinput.
indexfield]then begin curinput.limitfield:=first-1;
eofseen[curinput.indexfield]:=true;begintokenlist(eqtb[3422].hh.rh,15);
goto 20;end else forceeof:=true;
end else begin if inputln(inputfile[curinput.indexfield],true)then
firmuptheline else if(eqtb[3422].hh.rh<>0)and not eofseen[curinput.
indexfield]then begin curinput.limitfield:=first-1;
eofseen[curinput.indexfield]:=true;begintokenlist(eqtb[3422].hh.rh,15);
goto 20;end else forceeof:=true;end;
if forceeof then begin if eqtb[5327].int>0 then if(grpstack[inopen]<>
curboundary)or(ifstack[inopen]<>condptr)then filewarning;
if curinput.namefield>=19 then begin printchar(41);
openparens:=openparens-1;break(termout);end;forceeof:=false;
endfilereading;checkoutervalidity;goto 20;end;
if(eqtb[5316].int<0)or(eqtb[5316].int>255)then curinput.limitfield:=
curinput.limitfield-1 else buffer[curinput.limitfield]:=eqtb[5316].int;
first:=curinput.limitfield+1;curinput.locfield:=curinput.startfield;
end{:362}else begin if not(curinput.namefield=0)then begin curcmd:=0;
curchr:=0;goto 10;end;if inputptr>0 then begin endfilereading;goto 20;
end;if selector<18 then openlogfile;
if interaction>1 then begin if(eqtb[5316].int<0)or(eqtb[5316].int>255)
then curinput.limitfield:=curinput.limitfield+1;
if curinput.limitfield=curinput.startfield then printnl(625);println;
first:=curinput.startfield;begin;print(42);terminput;end;
curinput.limitfield:=last;
if(eqtb[5316].int<0)or(eqtb[5316].int>255)then curinput.limitfield:=
curinput.limitfield-1 else buffer[curinput.limitfield]:=eqtb[5316].int;
first:=curinput.limitfield+1;curinput.locfield:=curinput.startfield;
end else fatalerror(626);end{:360};
begin if interrupt<>0 then pauseforinstructions;end;goto 25;end;
end{:343}else{357:}if curinput.locfield<>0 then begin t:=mem[curinput.
locfield].hh.lh;curinput.locfield:=mem[curinput.locfield].hh.rh;
if t>=4095 then begin curcs:=t-4095;curcmd:=eqtb[curcs].hh.b0;
curchr:=eqtb[curcs].hh.rh;
if curcmd>=113 then if curcmd=116 then{358:}begin curcs:=mem[curinput.
locfield].hh.lh-4095;curinput.locfield:=0;curcmd:=eqtb[curcs].hh.b0;
curchr:=eqtb[curcs].hh.rh;if curcmd>100 then begin curcmd:=0;
curchr:=257;end;end{:358}else checkoutervalidity;
end else begin curcmd:=t div 256;curchr:=t mod 256;
case curcmd of 1:alignstate:=alignstate+1;2:alignstate:=alignstate-1;
5:{359:}begin begintokenlist(paramstack[curinput.limitfield+curchr-1],0)
;goto 20;end{:359};others:end;end;end else begin endtokenlist;goto 20;
end{:357};
{342:}if curcmd<=5 then if curcmd>=4 then if alignstate=0 then{789:}
begin if(scannerstatus=4)or(curalign=0)then fatalerror(604);
curcmd:=mem[curalign+5].hh.lh;mem[curalign+5].hh.lh:=curchr;
if curcmd=63 then begintokenlist(29990,2)else begintokenlist(mem[
curalign+2].int,2);alignstate:=1000000;goto 20;end{:789}{:342};10:end;
{:341}{363:}procedure firmuptheline;var k:0..bufsize;
begin curinput.limitfield:=last;
if eqtb[5296].int>0 then if interaction>1 then begin;println;
if curinput.startfield<curinput.limitfield then for k:=curinput.
startfield to curinput.limitfield-1 do print(buffer[k]);
first:=curinput.limitfield;begin;print(627);terminput;end;
if last>first then begin for k:=first to last-1 do buffer[k+curinput.
startfield-first]:=buffer[k];
curinput.limitfield:=curinput.startfield+last-first;end;end;end;
{:363}{365:}procedure gettoken;begin nonewcontrolsequence:=false;
getnext;nonewcontrolsequence:=true;
if curcs=0 then curtok:=(curcmd*256)+curchr else curtok:=4095+curcs;end;
{:365}{366:}{389:}procedure macrocall;label 10,22,30,31,40;
var r:halfword;p:halfword;q:halfword;s:halfword;t:halfword;u,v:halfword;
rbraceptr:halfword;n:smallnumber;unbalance:halfword;m:halfword;
refcount:halfword;savescannerstatus:smallnumber;
savewarningindex:halfword;matchchr:ASCIIcode;
begin savescannerstatus:=scannerstatus;savewarningindex:=warningindex;
warningindex:=curcs;refcount:=curchr;r:=mem[refcount].hh.rh;n:=0;
if eqtb[5298].int>0 then{401:}begin begindiagnostic;println;
printcs(warningindex);tokenshow(refcount);enddiagnostic(false);
end{:401};if mem[r].hh.lh=3585 then r:=mem[r].hh.rh;
if mem[r].hh.lh<>3584 then{391:}begin scannerstatus:=3;unbalance:=0;
longstate:=eqtb[curcs].hh.b0;
if longstate>=113 then longstate:=longstate-2;
repeat mem[29997].hh.rh:=0;
if(mem[r].hh.lh>3583)or(mem[r].hh.lh<3328)then s:=0 else begin matchchr
:=mem[r].hh.lh-3328;s:=mem[r].hh.rh;r:=s;p:=29997;m:=0;end;
{392:}22:gettoken;
if curtok=mem[r].hh.lh then{394:}begin r:=mem[r].hh.rh;
if(mem[r].hh.lh>=3328)and(mem[r].hh.lh<=3584)then begin if curtok<512
then alignstate:=alignstate-1;goto 40;end else goto 22;end{:394};
{397:}if s<>r then if s=0 then{398:}begin begin if interaction=3 then;
printnl(263);print(659);end;sprintcs(warningindex);print(660);
begin helpptr:=4;helpline[3]:=661;helpline[2]:=662;helpline[1]:=663;
helpline[0]:=664;end;error;goto 10;end{:398}else begin t:=s;
repeat begin q:=getavail;mem[p].hh.rh:=q;mem[q].hh.lh:=mem[t].hh.lh;
p:=q;end;m:=m+1;u:=mem[t].hh.rh;v:=s;
while true do begin if u=r then if curtok<>mem[v].hh.lh then goto 30
else begin r:=mem[v].hh.rh;goto 22;end;
if mem[u].hh.lh<>mem[v].hh.lh then goto 30;u:=mem[u].hh.rh;
v:=mem[v].hh.rh;end;30:t:=mem[t].hh.rh;until t=r;r:=s;end{:397};
if curtok=partoken then if longstate<>112 then{396:}begin if longstate=
111 then begin runaway;begin if interaction=3 then;printnl(263);
print(654);end;sprintcs(warningindex);print(655);begin helpptr:=3;
helpline[2]:=656;helpline[1]:=657;helpline[0]:=658;end;backerror;end;
pstack[n]:=mem[29997].hh.rh;alignstate:=alignstate-unbalance;
for m:=0 to n do flushlist(pstack[m]);goto 10;end{:396};
if curtok<768 then if curtok<512 then{399:}begin unbalance:=1;
while true do begin begin begin q:=avail;
if q=0 then q:=getavail else begin avail:=mem[q].hh.rh;mem[q].hh.rh:=0;
{dynused:=dynused+1;}end;end;mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;p:=q;
end;gettoken;
if curtok=partoken then if longstate<>112 then{396:}begin if longstate=
111 then begin runaway;begin if interaction=3 then;printnl(263);
print(654);end;sprintcs(warningindex);print(655);begin helpptr:=3;
helpline[2]:=656;helpline[1]:=657;helpline[0]:=658;end;backerror;end;
pstack[n]:=mem[29997].hh.rh;alignstate:=alignstate-unbalance;
for m:=0 to n do flushlist(pstack[m]);goto 10;end{:396};
if curtok<768 then if curtok<512 then unbalance:=unbalance+1 else begin
unbalance:=unbalance-1;if unbalance=0 then goto 31;end;end;
31:rbraceptr:=p;begin q:=getavail;mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;
p:=q;end;end{:399}else{395:}begin backinput;begin if interaction=3 then;
printnl(263);print(646);end;sprintcs(warningindex);print(647);
begin helpptr:=6;helpline[5]:=648;helpline[4]:=649;helpline[3]:=650;
helpline[2]:=651;helpline[1]:=652;helpline[0]:=653;end;
alignstate:=alignstate+1;longstate:=111;curtok:=partoken;inserror;
goto 22;
end{:395}else{393:}begin if curtok=2592 then if mem[r].hh.lh<=3584 then
if mem[r].hh.lh>=3328 then goto 22;begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=curtok;p:=q;end;end{:393};m:=m+1;
if mem[r].hh.lh>3584 then goto 22;if mem[r].hh.lh<3328 then goto 22;
40:if s<>0 then{400:}begin if(m=1)and(mem[p].hh.lh<768)and(p<>29997)then
begin mem[rbraceptr].hh.rh:=0;begin mem[p].hh.rh:=avail;avail:=p;
{dynused:=dynused-1;}end;p:=mem[29997].hh.rh;pstack[n]:=mem[p].hh.rh;
begin mem[p].hh.rh:=avail;avail:=p;{dynused:=dynused-1;}end;
end else pstack[n]:=mem[29997].hh.rh;n:=n+1;
if eqtb[5298].int>0 then begin begindiagnostic;printnl(matchchr);
printint(n);print(665);showtokenlist(pstack[n-1],0,1000);
enddiagnostic(false);end;end{:400}{:392};until mem[r].hh.lh=3584;
end{:391};
{390:}while(curinput.statefield=0)and(curinput.locfield=0)and(curinput.
indexfield<>2)do endtokenlist;begintokenlist(refcount,5);
curinput.namefield:=warningindex;curinput.locfield:=mem[r].hh.rh;
if n>0 then begin if paramptr+n>maxparamstack then begin maxparamstack:=
paramptr+n;if maxparamstack>paramsize then overflow(645,paramsize);end;
for m:=0 to n-1 do paramstack[paramptr+m]:=pstack[m];
paramptr:=paramptr+n;end{:390};10:scannerstatus:=savescannerstatus;
warningindex:=savewarningindex;end;{:389}{379:}procedure insertrelax;
begin curtok:=4095+curcs;backinput;curtok:=6716;backinput;
curinput.indexfield:=4;end;{:379}{1485:}procedure pseudostart;forward;
{:1485}{1543:}procedure scanregisternum;forward;
{:1543}{1548:}procedure newindex(i:quarterword;q:halfword);
var k:smallnumber;begin curptr:=getnode(9);mem[curptr].hh.b0:=i;
mem[curptr].hh.b1:=0;mem[curptr].hh.rh:=q;
for k:=1 to 8 do mem[curptr+k]:=sanull;end;
{:1548}{1552:}procedure findsaelement(t:smallnumber;n:halfword;
w:boolean);label 45,46,47,48,49,10;var q:halfword;i:smallnumber;
begin curptr:=saroot[t];
begin if curptr=0 then if w then goto 45 else goto 10;end;q:=curptr;
i:=n div 4096;
if odd(i)then curptr:=mem[q+(i div 2)+1].hh.rh else curptr:=mem[q+(i div
2)+1].hh.lh;begin if curptr=0 then if w then goto 46 else goto 10;end;
q:=curptr;i:=(n div 256)mod 16;
if odd(i)then curptr:=mem[q+(i div 2)+1].hh.rh else curptr:=mem[q+(i div
2)+1].hh.lh;begin if curptr=0 then if w then goto 47 else goto 10;end;
q:=curptr;i:=(n div 16)mod 16;
if odd(i)then curptr:=mem[q+(i div 2)+1].hh.rh else curptr:=mem[q+(i div
2)+1].hh.lh;begin if curptr=0 then if w then goto 48 else goto 10;end;
q:=curptr;i:=n mod 16;
if odd(i)then curptr:=mem[q+(i div 2)+1].hh.rh else curptr:=mem[q+(i div
2)+1].hh.lh;if(curptr=0)and w then goto 49;goto 10;45:newindex(t,0);
saroot[t]:=curptr;q:=curptr;i:=n div 4096;46:newindex(i,q);
begin if odd(i)then mem[q+(i div 2)+1].hh.rh:=curptr else mem[q+(i div 2
)+1].hh.lh:=curptr;mem[q].hh.b1:=mem[q].hh.b1+1;end;q:=curptr;
i:=(n div 256)mod 16;47:newindex(i,q);
begin if odd(i)then mem[q+(i div 2)+1].hh.rh:=curptr else mem[q+(i div 2
)+1].hh.lh:=curptr;mem[q].hh.b1:=mem[q].hh.b1+1;end;q:=curptr;
i:=(n div 16)mod 16;48:newindex(i,q);
begin if odd(i)then mem[q+(i div 2)+1].hh.rh:=curptr else mem[q+(i div 2
)+1].hh.lh:=curptr;mem[q].hh.b1:=mem[q].hh.b1+1;end;q:=curptr;
i:=n mod 16;49:{1553:}if t=6 then begin curptr:=getnode(4);
mem[curptr+1]:=sanull;mem[curptr+2]:=sanull;mem[curptr+3]:=sanull;
end else begin if t<=1 then begin curptr:=getnode(3);
mem[curptr+2].int:=0;mem[curptr+1].hh.rh:=n;
end else begin curptr:=getnode(2);
if t<=3 then begin mem[curptr+1].hh.rh:=0;mem[0].hh.rh:=mem[0].hh.rh+1;
end else mem[curptr+1].hh.rh:=0;end;mem[curptr+1].hh.lh:=0;end;
mem[curptr].hh.b0:=16*t+i;mem[curptr].hh.b1:=1{:1553};
mem[curptr].hh.rh:=q;
begin if odd(i)then mem[q+(i div 2)+1].hh.rh:=curptr else mem[q+(i div 2
)+1].hh.lh:=curptr;mem[q].hh.b1:=mem[q].hh.b1+1;end;10:end;
{:1552}procedure passtext;forward;procedure startinput;forward;
procedure conditional;forward;procedure getxtoken;forward;
procedure convtoks;forward;procedure insthetoks;forward;
procedure expand;label 21;var t:halfword;p,q,r:halfword;j:0..bufsize;
cvbackup:integer;cvlbackup,radixbackup,cobackup:smallnumber;
backupbackup:halfword;savescannerstatus:smallnumber;
begin cvbackup:=curval;cvlbackup:=curvallevel;radixbackup:=radix;
cobackup:=curorder;backupbackup:=mem[29987].hh.rh;
21:if curcmd<111 then{367:}begin if eqtb[5304].int>1 then showcurcmdchr;
case curcmd of 110:{386:}begin t:=curchr mod 5;
if curchr>=5 then scanregisternum else curval:=0;
if curval=0 then curptr:=curmark[t]else{1557:}begin findsaelement(6,
curval,false);
if curptr<>0 then if odd(t)then curptr:=mem[curptr+(t div 2)+1].hh.rh
else curptr:=mem[curptr+(t div 2)+1].hh.lh;end{:1557};
if curptr<>0 then begintokenlist(curptr,14);end{:386};
102:if curchr=0 then{368:}begin gettoken;t:=curtok;gettoken;
if curcmd>100 then expand else backinput;curtok:=t;backinput;
end{:368}else{1498:}begin gettoken;
if(curcmd=105)and(curchr<>16)then begin curchr:=curchr+32;goto 21;end;
begin if interaction=3 then;printnl(263);print(694);end;printesc(783);
print(1384);printcmdchr(curcmd,curchr);printchar(39);begin helpptr:=1;
helpline[0]:=624;end;backerror;end{:1498};
103:{369:}begin savescannerstatus:=scannerstatus;scannerstatus:=0;
gettoken;scannerstatus:=savescannerstatus;t:=curtok;backinput;
if t>=4095 then begin p:=getavail;mem[p].hh.lh:=6718;
mem[p].hh.rh:=curinput.locfield;curinput.startfield:=p;
curinput.locfield:=p;end;end{:369};107:{372:}begin r:=getavail;p:=r;
repeat getxtoken;if curcs=0 then begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=curtok;p:=q;end;until curcs<>0;
if curcmd<>67 then{373:}begin begin if interaction=3 then;printnl(263);
print(634);end;printesc(508);print(635);begin helpptr:=2;
helpline[1]:=636;helpline[0]:=637;end;backerror;end{:373};
{374:}j:=first;p:=mem[r].hh.rh;
while p<>0 do begin if j>=maxbufstack then begin maxbufstack:=j+1;
if maxbufstack=bufsize then overflow(257,bufsize);end;
buffer[j]:=mem[p].hh.lh mod 256;j:=j+1;p:=mem[p].hh.rh;end;
if j>first+1 then begin nonewcontrolsequence:=false;
curcs:=idlookup(first,j-first);nonewcontrolsequence:=true;
end else if j=first then curcs:=513 else curcs:=257+buffer[first]{:374};
flushlist(r);if eqtb[curcs].hh.b0=101 then begin eqdefine(curcs,0,256);
end;curtok:=curcs+4095;backinput;end{:372};108:convtoks;109:insthetoks;
105:conditional;
106:{510:}begin if eqtb[5325].int>0 then if eqtb[5304].int<=1 then
showcurcmdchr;
if curchr>iflimit then if iflimit=1 then insertrelax else begin begin if
interaction=3 then;printnl(263);print(787);end;printcmdchr(106,curchr);
begin helpptr:=1;helpline[0]:=788;end;error;
end else begin while curchr<>2 do passtext;
{496:}begin if ifstack[inopen]=condptr then ifwarning;p:=condptr;
ifline:=mem[p+1].int;curif:=mem[p].hh.b1;iflimit:=mem[p].hh.b0;
condptr:=mem[p].hh.rh;freenode(p,2);end{:496};end;end{:510};
104:{378:}if curchr=1 then forceeof:=true{1482:}else if curchr=2 then
pseudostart{:1482}else if nameinprogress then insertrelax else
startinput{:378};others:{370:}begin begin if interaction=3 then;
printnl(263);print(628);end;begin helpptr:=5;helpline[4]:=629;
helpline[3]:=630;helpline[2]:=631;helpline[1]:=632;helpline[0]:=633;end;
error;end{:370}end;
end{:367}else if curcmd<115 then macrocall else{375:}begin curtok:=6715;
backinput;end{:375};curval:=cvbackup;curvallevel:=cvlbackup;
radix:=radixbackup;curorder:=cobackup;mem[29987].hh.rh:=backupbackup;
end;{:366}{380:}procedure getxtoken;label 20,30;begin 20:getnext;
if curcmd<=100 then goto 30;
if curcmd>=111 then if curcmd<115 then macrocall else begin curcs:=2620;
curcmd:=9;goto 30;end else expand;goto 20;
30:if curcs=0 then curtok:=(curcmd*256)+curchr else curtok:=4095+curcs;
end;{:380}{381:}procedure xtoken;begin while curcmd>100 do begin expand;
getnext;end;
if curcs=0 then curtok:=(curcmd*256)+curchr else curtok:=4095+curcs;end;
{:381}{403:}procedure scanleftbrace;begin{404:}repeat getxtoken;
until(curcmd<>10)and(curcmd<>0){:404};
if curcmd<>1 then begin begin if interaction=3 then;printnl(263);
print(666);end;begin helpptr:=4;helpline[3]:=667;helpline[2]:=668;
helpline[1]:=669;helpline[0]:=670;end;backerror;curtok:=379;curcmd:=1;
curchr:=123;alignstate:=alignstate+1;end;end;
{:403}{405:}procedure scanoptionalequals;begin{406:}repeat getxtoken;
until curcmd<>10{:406};if curtok<>3133 then backinput;end;
{:405}{407:}function scankeyword(s:strnumber):boolean;label 10;
var p:halfword;q:halfword;k:poolpointer;begin p:=29987;mem[p].hh.rh:=0;
k:=strstart[s];while k<strstart[s+1]do begin getxtoken;
if(curcs=0)and((curchr=strpool[k])or(curchr=strpool[k]-32))then begin
begin q:=getavail;mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;p:=q;end;k:=k+1;
end else if(curcmd<>10)or(p<>29987)then begin backinput;
if p<>29987 then begintokenlist(mem[29987].hh.rh,3);scankeyword:=false;
goto 10;end;end;flushlist(mem[29987].hh.rh);scankeyword:=true;10:end;
{:407}{408:}procedure muerror;begin begin if interaction=3 then;
printnl(263);print(671);end;begin helpptr:=1;helpline[0]:=672;end;error;
end;{:408}{409:}procedure scanint;forward;
{433:}procedure scaneightbitint;begin scanint;
if(curval<0)or(curval>255)then begin begin if interaction=3 then;
printnl(263);print(696);end;begin helpptr:=2;helpline[1]:=697;
helpline[0]:=698;end;interror(curval);curval:=0;end;end;
{:433}{434:}procedure scancharnum;begin scanint;
if(curval<0)or(curval>255)then begin begin if interaction=3 then;
printnl(263);print(699);end;begin helpptr:=2;helpline[1]:=700;
helpline[0]:=698;end;interror(curval);curval:=0;end;end;
{:434}{435:}procedure scanfourbitint;begin scanint;
if(curval<0)or(curval>15)then begin begin if interaction=3 then;
printnl(263);print(701);end;begin helpptr:=2;helpline[1]:=702;
helpline[0]:=698;end;interror(curval);curval:=0;end;end;
{:435}{436:}procedure scanfifteenbitint;begin scanint;
if(curval<0)or(curval>32767)then begin begin if interaction=3 then;
printnl(263);print(703);end;begin helpptr:=2;helpline[1]:=704;
helpline[0]:=698;end;interror(curval);curval:=0;end;end;
{:436}{437:}procedure scantwentysevenbitint;begin scanint;
if(curval<0)or(curval>134217727)then begin begin if interaction=3 then;
printnl(263);print(705);end;begin helpptr:=2;helpline[1]:=706;
helpline[0]:=698;end;interror(curval);curval:=0;end;end;
{:437}{1544:}procedure scanregisternum;begin scanint;
if(curval<0)or(curval>maxregnum)then begin begin if interaction=3 then;
printnl(263);print(696);end;begin helpptr:=2;
helpline[1]:=maxreghelpline;helpline[0]:=698;end;interror(curval);
curval:=0;end;end;{:1544}{1413:}procedure scangeneraltext;forward;
{:1413}{1441:}procedure removeendM;var p:halfword;
begin p:=curlist.headfield;
while mem[p].hh.rh<>curlist.tailfield do p:=mem[p].hh.rh;
if not(p>=himemmin)then begin LRtemp:=curlist.tailfield;mem[p].hh.rh:=0;
curlist.tailfield:=p;end;end;{:1441}{1442:}procedure insertendM;
label 30;var p:halfword;
begin if not(curlist.tailfield>=himemmin)then if(mem[curlist.tailfield].
hh.b0=9)and(mem[curlist.tailfield].hh.b1=2)then begin freenode(LRtemp,2)
;p:=curlist.headfield;
while mem[p].hh.rh<>curlist.tailfield do p:=mem[p].hh.rh;
freenode(curlist.tailfield,2);mem[p].hh.rh:=0;curlist.tailfield:=p;
goto 30;end;mem[curlist.tailfield].hh.rh:=LRtemp;
curlist.tailfield:=LRtemp;30:LRtemp:=0;end;
{:1442}{1505:}procedure getxorprotected;label 10;
begin while true do begin gettoken;if curcmd<=100 then goto 10;
if(curcmd>=111)and(curcmd<115)then if mem[mem[curchr].hh.rh].hh.lh=3585
then goto 10;expand;end;10:end;{:1505}{1514:}procedure scanexpr;forward;
{:1514}{1519:}procedure scannormalglue;forward;procedure scanmuglue;
forward;{:1519}{577:}procedure scanfontident;var f:internalfontnumber;
m:halfword;begin{406:}repeat getxtoken;until curcmd<>10{:406};
if curcmd=88 then f:=eqtb[3939].hh.rh else if curcmd=87 then f:=curchr
else if curcmd=86 then begin m:=curchr;scanfourbitint;
f:=eqtb[m+curval].hh.rh;end else begin begin if interaction=3 then;
printnl(263);print(827);end;begin helpptr:=2;helpline[1]:=828;
helpline[0]:=829;end;backerror;f:=0;end;curval:=f;end;
{:577}{578:}procedure findfontdimen(writing:boolean);
var f:internalfontnumber;n:integer;begin scanint;n:=curval;
scanfontident;f:=curval;
if n<=0 then curval:=fmemptr else begin if writing and(n<=4)and(n>=2)and
(fontglue[f]<>0)then begin deleteglueref(fontglue[f]);fontglue[f]:=0;
end;
if n>fontparams[f]then if f<fontptr then curval:=fmemptr else{580:}begin
repeat if fmemptr=fontmemsize then overflow(834,fontmemsize);
fontinfo[fmemptr].int:=0;fmemptr:=fmemptr+1;
fontparams[f]:=fontparams[f]+1;until n=fontparams[f];curval:=fmemptr-1;
end{:580}else curval:=n+parambase[f];end;
{579:}if curval=fmemptr then begin begin if interaction=3 then;
printnl(263);print(812);end;printesc(hash[2624+f].rh);print(830);
printint(fontparams[f]);print(831);begin helpptr:=2;helpline[1]:=832;
helpline[0]:=833;end;error;end{:579};end;
{:578}{:409}{413:}procedure scansomethinginternal(level:smallnumber;
negative:boolean);label 10;var m:halfword;q,r:halfword;tx:halfword;
i:fourquarters;p:0..nestsize;begin m:=curchr;
case curcmd of 85:{414:}begin scancharnum;
if m=5012 then begin curval:=eqtb[5012+curval].hh.rh-0;curvallevel:=0;
end else if m<5012 then begin curval:=eqtb[m+curval].hh.rh;
curvallevel:=0;end else begin curval:=eqtb[m+curval].int;curvallevel:=0;
end;end{:414};
71,72,86,87,88:{415:}if level<>5 then begin begin if interaction=3 then;
printnl(263);print(673);end;begin helpptr:=3;helpline[2]:=674;
helpline[1]:=675;helpline[0]:=676;end;backerror;begin curval:=0;
curvallevel:=1;end;
end else if curcmd<=72 then begin if curcmd<72 then if m=0 then begin
scanregisternum;
if curval<256 then curval:=eqtb[3423+curval].hh.rh else begin
findsaelement(5,curval,false);
if curptr=0 then curval:=0 else curval:=mem[curptr+1].hh.rh;end;
end else curval:=mem[m+1].hh.rh else curval:=eqtb[m].hh.rh;
curvallevel:=5;end else begin backinput;scanfontident;
begin curval:=2624+curval;curvallevel:=4;end;end{:415};
73:begin curval:=eqtb[m].int;curvallevel:=0;end;
74:begin curval:=eqtb[m].int;curvallevel:=1;end;
75:begin curval:=eqtb[m].hh.rh;curvallevel:=2;end;
76:begin curval:=eqtb[m].hh.rh;curvallevel:=3;end;
79:{418:}if abs(curlist.modefield)<>m then begin begin if interaction=3
then;printnl(263);print(689);end;printcmdchr(79,m);begin helpptr:=4;
helpline[3]:=690;helpline[2]:=691;helpline[1]:=692;helpline[0]:=693;end;
error;if level<>5 then begin curval:=0;curvallevel:=1;
end else begin curval:=0;curvallevel:=0;end;
end else if m=1 then begin curval:=curlist.auxfield.int;curvallevel:=1;
end else begin curval:=curlist.auxfield.hh.lh;curvallevel:=0;end{:418};
80:{422:}if curlist.modefield=0 then begin curval:=0;curvallevel:=0;
end else begin nest[nestptr]:=curlist;p:=nestptr;
while abs(nest[p].modefield)<>1 do p:=p-1;begin curval:=nest[p].pgfield;
curvallevel:=0;end;end{:422};
82:{419:}begin if m=0 then curval:=deadcycles{1425:}else if m=2 then
curval:=interaction{:1425}else curval:=insertpenalties;curvallevel:=0;
end{:419};
81:{421:}begin if(pagecontents=0)and(not outputactive)then if m=0 then
curval:=1073741823 else curval:=0 else curval:=pagesofar[m];
curvallevel:=1;end{:421};
84:{423:}begin if m>3412 then{1599:}begin scanint;
if(eqtb[m].hh.rh=0)or(curval<0)then curval:=0 else begin if curval>mem[
eqtb[m].hh.rh+1].int then curval:=mem[eqtb[m].hh.rh+1].int;
curval:=mem[eqtb[m].hh.rh+curval+1].int;end;
end{:1599}else if eqtb[3412].hh.rh=0 then curval:=0 else curval:=mem[
eqtb[3412].hh.rh].hh.lh;curvallevel:=0;end{:423};
83:{420:}begin scanregisternum;
if curval<256 then q:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then q:=0 else q:=mem[curptr+1].hh.rh;end;
if q=0 then curval:=0 else curval:=mem[q+m].int;curvallevel:=1;
end{:420};68,69:begin curval:=curchr;curvallevel:=0;end;
77:{425:}begin findfontdimen(false);fontinfo[fmemptr].int:=0;
begin curval:=fontinfo[curval].int;curvallevel:=1;end;end{:425};
78:{426:}begin scanfontident;
if m=0 then begin curval:=hyphenchar[curval];curvallevel:=0;
end else begin curval:=skewchar[curval];curvallevel:=0;end;end{:426};
89:{427:}begin if(m<0)or(m>19)then begin curvallevel:=(mem[m].hh.b0 div
16);
if curvallevel<2 then curval:=mem[m+2].int else curval:=mem[m+1].hh.rh;
end else begin scanregisternum;curvallevel:=m-0;
if curval>255 then begin findsaelement(curvallevel,curval,false);
if curptr=0 then if curvallevel<2 then curval:=0 else curval:=0 else if
curvallevel<2 then curval:=mem[curptr+2].int else curval:=mem[curptr+1].
hh.rh;end else case curvallevel of 0:curval:=eqtb[5333+curval].int;
1:curval:=eqtb[5866+curval].int;2:curval:=eqtb[2900+curval].hh.rh;
3:curval:=eqtb[3156+curval].hh.rh;end;end;end{:427};
70:{424:}if m>=4 then if m>=23 then{1513:}begin if m<24 then begin case
m of{1540:}23:scanmuglue;{:1540}end;curvallevel:=2;
end else if m<25 then begin case m of{1541:}24:scannormalglue;
{:1541}end;curvallevel:=3;end else begin curvallevel:=m-25;scanexpr;end;
while curvallevel>level do begin if curvallevel=2 then begin m:=curval;
curval:=mem[m+1].int;deleteglueref(m);
end else if curvallevel=3 then muerror;curvallevel:=curvallevel-1;end;
if negative then if curvallevel>=2 then begin m:=curval;
curval:=newspec(m);deleteglueref(m);
{431:}begin mem[curval+1].int:=-mem[curval+1].int;
mem[curval+2].int:=-mem[curval+2].int;
mem[curval+3].int:=-mem[curval+3].int;end{:431};
end else curval:=-curval;goto 10;
end{:1513}else if m>=14 then begin case m of{1402:}14,15,16,17:begin
scanfontident;q:=curval;scancharnum;
if(fontbc[q]<=curval)and(fontec[q]>=curval)then begin i:=fontinfo[
charbase[q]+curval+0].qqqq;
case m of 14:curval:=fontinfo[widthbase[q]+i.b0].int;
15:curval:=fontinfo[heightbase[q]+(i.b1-0)div 16].int;
16:curval:=fontinfo[depthbase[q]+(i.b1-0)mod 16].int;
17:curval:=fontinfo[italicbase[q]+(i.b2-0)div 4].int;end;
end else curval:=0;end;{:1402}{1405:}18,19,20:begin q:=curchr-18;
scanint;
if(eqtb[3412].hh.rh=0)or(curval<=0)then curval:=0 else begin if q=2 then
begin q:=curval mod 2;curval:=(curval+q)div 2;end;
if curval>mem[eqtb[3412].hh.rh].hh.lh then curval:=mem[eqtb[3412].hh.rh]
.hh.lh;curval:=mem[eqtb[3412].hh.rh+2*curval-q].int;end;curvallevel:=1;
end;{:1405}{1537:}21,22:begin scannormalglue;q:=curval;
if m=21 then curval:=mem[q+2].int else curval:=mem[q+3].int;
deleteglueref(q);end;{:1537}end;curvallevel:=1;
end else begin case m of 4:curval:=line;5:curval:=lastbadness;
{1382:}6:curval:=2;{:1382}{1396:}7:curval:=curlevel-1;
8:curval:=curgroup;{:1396}{1399:}9:begin q:=condptr;curval:=0;
while q<>0 do begin curval:=curval+1;q:=mem[q].hh.rh;end;end;
10:if condptr=0 then curval:=0 else if curif<32 then curval:=curif+1
else curval:=-(curif-31);
11:if(iflimit=4)or(iflimit=3)then curval:=1 else if iflimit=2 then
curval:=-1 else curval:=0;{:1399}{1536:}12,13:begin scannormalglue;
q:=curval;if m=12 then curval:=mem[q].hh.b0 else curval:=mem[q].hh.b1;
deleteglueref(q);end;{:1536}end;curvallevel:=0;
end else begin if curchr=2 then curval:=0 else curval:=0;
tx:=curlist.tailfield;
if not(tx>=himemmin)then if(mem[tx].hh.b0=9)and(mem[tx].hh.b1=3)then
begin r:=curlist.headfield;repeat q:=r;r:=mem[q].hh.rh;until r=tx;tx:=q;
end;if curchr=3 then begin curvallevel:=0;
if(tx=curlist.headfield)or(curlist.modefield=0)then curval:=-1;
end else curvallevel:=curchr;
if not(tx>=himemmin)and(curlist.modefield<>0)then case curchr of 0:if
mem[tx].hh.b0=12 then curval:=mem[tx+1].int;
1:if mem[tx].hh.b0=11 then curval:=mem[tx+1].int;
2:if mem[tx].hh.b0=10 then begin curval:=mem[tx+1].hh.lh;
if mem[tx].hh.b1=99 then curvallevel:=3;end;
3:if mem[tx].hh.b0<=13 then curval:=mem[tx].hh.b0+1 else curval:=15;
end else if(curlist.modefield=1)and(tx=curlist.headfield)then case
curchr of 0:curval:=lastpenalty;1:curval:=lastkern;
2:if lastglue<>65535 then curval:=lastglue;3:curval:=lastnodetype;end;
end{:424};others:{428:}begin begin if interaction=3 then;printnl(263);
print(694);end;printcmdchr(curcmd,curchr);print(695);printesc(541);
begin helpptr:=1;helpline[0]:=693;end;error;
if level<>5 then begin curval:=0;curvallevel:=1;
end else begin curval:=0;curvallevel:=0;end;end{:428}end;
while curvallevel>level do{429:}begin if curvallevel=2 then curval:=mem[
curval+1].int else if curvallevel=3 then muerror;
curvallevel:=curvallevel-1;end{:429};
{430:}if negative then if curvallevel>=2 then begin curval:=newspec(
curval);{431:}begin mem[curval+1].int:=-mem[curval+1].int;
mem[curval+2].int:=-mem[curval+2].int;
mem[curval+3].int:=-mem[curval+3].int;end{:431};
end else curval:=-curval else if(curvallevel>=2)and(curvallevel<=3)then
mem[curval].hh.rh:=mem[curval].hh.rh+1{:430};10:end;
{:413}{440:}procedure scanint;label 30;var negative:boolean;m:integer;
d:smallnumber;vacuous:boolean;OKsofar:boolean;begin radix:=0;
OKsofar:=true;{441:}negative:=false;repeat{406:}repeat getxtoken;
until curcmd<>10{:406};if curtok=3117 then begin negative:=not negative;
curtok:=3115;end;until curtok<>3115{:441};
if curtok=3168 then{442:}begin gettoken;
if curtok<4095 then begin curval:=curchr;
if curcmd<=2 then if curcmd=2 then alignstate:=alignstate+1 else
alignstate:=alignstate-1;
end else if curtok<4352 then curval:=curtok-4096 else curval:=curtok
-4352;if curval>255 then begin begin if interaction=3 then;printnl(263);
print(707);end;begin helpptr:=2;helpline[1]:=708;helpline[0]:=709;end;
curval:=48;backerror;end else{443:}begin getxtoken;
if curcmd<>10 then backinput;end{:443};
end{:442}else if(curcmd>=68)and(curcmd<=89)then scansomethinginternal(0,
false)else{444:}begin radix:=10;m:=214748364;
if curtok=3111 then begin radix:=8;m:=268435456;getxtoken;
end else if curtok=3106 then begin radix:=16;m:=134217728;getxtoken;end;
vacuous:=true;curval:=0;
{445:}while true do begin if(curtok<3120+radix)and(curtok>=3120)and(
curtok<=3129)then d:=curtok-3120 else if radix=16 then if(curtok<=2886)
and(curtok>=2881)then d:=curtok-2871 else if(curtok<=3142)and(curtok>=
3137)then d:=curtok-3127 else goto 30 else goto 30;vacuous:=false;
if(curval>=m)and((curval>m)or(d>7)or(radix<>10))then begin if OKsofar
then begin begin if interaction=3 then;printnl(263);print(710);end;
begin helpptr:=2;helpline[1]:=711;helpline[0]:=712;end;error;
curval:=2147483647;OKsofar:=false;end;end else curval:=curval*radix+d;
getxtoken;end;30:{:445};
if vacuous then{446:}begin begin if interaction=3 then;printnl(263);
print(673);end;begin helpptr:=3;helpline[2]:=674;helpline[1]:=675;
helpline[0]:=676;end;backerror;
end{:446}else if curcmd<>10 then backinput;end{:444};
if negative then curval:=-curval;end;
{:440}{448:}procedure scandimen(mu,inf,shortcut:boolean);
label 30,31,32,40,45,88,89;var negative:boolean;f:integer;
{450:}num,denom:1..65536;k,kk:smallnumber;p,q:halfword;v:scaled;
savecurval:integer;{:450}begin f:=0;aritherror:=false;curorder:=0;
negative:=false;if not shortcut then begin{441:}negative:=false;
repeat{406:}repeat getxtoken;until curcmd<>10{:406};
if curtok=3117 then begin negative:=not negative;curtok:=3115;end;
until curtok<>3115{:441};
if(curcmd>=68)and(curcmd<=89)then{449:}if mu then begin
scansomethinginternal(3,false);
{451:}if curvallevel>=2 then begin v:=mem[curval+1].int;
deleteglueref(curval);curval:=v;end{:451};if curvallevel=3 then goto 89;
if curvallevel<>0 then muerror;
end else begin scansomethinginternal(1,false);
if curvallevel=1 then goto 89;end{:449}else begin backinput;
if curtok=3116 then curtok:=3118;
if curtok<>3118 then scanint else begin radix:=10;curval:=0;end;
if curtok=3116 then curtok:=3118;
if(radix=10)and(curtok=3118)then{452:}begin k:=0;p:=0;gettoken;
while true do begin getxtoken;
if(curtok>3129)or(curtok<3120)then goto 31;
if k<17 then begin q:=getavail;mem[q].hh.rh:=p;
mem[q].hh.lh:=curtok-3120;p:=q;k:=k+1;end;end;
31:for kk:=k downto 1 do begin dig[kk-1]:=mem[p].hh.lh;q:=p;
p:=mem[p].hh.rh;begin mem[q].hh.rh:=avail;avail:=q;{dynused:=dynused-1;}
end;end;f:=rounddecimals(k);if curcmd<>10 then backinput;end{:452};end;
end;if curval<0 then begin negative:=not negative;curval:=-curval;end;
{453:}if inf then{454:}if scankeyword(312)then begin curorder:=1;
while scankeyword(108)do begin if curorder=3 then begin begin if
interaction=3 then;printnl(263);print(714);end;print(715);
begin helpptr:=1;helpline[0]:=716;end;error;
end else curorder:=curorder+1;end;goto 88;end{:454};
{455:}savecurval:=curval;{406:}repeat getxtoken;until curcmd<>10{:406};
if(curcmd<68)or(curcmd>89)then backinput else begin if mu then begin
scansomethinginternal(3,false);
{451:}if curvallevel>=2 then begin v:=mem[curval+1].int;
deleteglueref(curval);curval:=v;end{:451};
if curvallevel<>3 then muerror;end else scansomethinginternal(1,false);
v:=curval;goto 40;end;if mu then goto 45;
if scankeyword(717)then v:=({558:}fontinfo[6+parambase[eqtb[3939].hh.rh]
].int{:558})else if scankeyword(718)then v:=({559:}fontinfo[5+parambase[
eqtb[3939].hh.rh]].int{:559})else goto 45;{443:}begin getxtoken;
if curcmd<>10 then backinput;end{:443};
40:curval:=multandadd(savecurval,v,xnoverd(v,f,65536),1073741823);
goto 89;45:{:455};
if mu then{456:}if scankeyword(338)then goto 88 else begin begin if
interaction=3 then;printnl(263);print(714);end;print(719);
begin helpptr:=4;helpline[3]:=720;helpline[2]:=721;helpline[1]:=722;
helpline[0]:=723;end;error;goto 88;end{:456};
if scankeyword(713)then{457:}begin preparemag;
if eqtb[5285].int<>1000 then begin curval:=xnoverd(curval,1000,eqtb[5285
].int);f:=(1000*f+65536*remainder)div eqtb[5285].int;
curval:=curval+(f div 65536);f:=f mod 65536;end;end{:457};
if scankeyword(400)then goto 88;
{458:}if scankeyword(724)then begin num:=7227;denom:=100;
end else if scankeyword(725)then begin num:=12;denom:=1;
end else if scankeyword(726)then begin num:=7227;denom:=254;
end else if scankeyword(727)then begin num:=7227;denom:=2540;
end else if scankeyword(728)then begin num:=7227;denom:=7200;
end else if scankeyword(729)then begin num:=1238;denom:=1157;
end else if scankeyword(730)then begin num:=14856;denom:=1157;
end else if scankeyword(731)then goto 30 else{459:}begin begin if
interaction=3 then;printnl(263);print(714);end;print(732);
begin helpptr:=6;helpline[5]:=733;helpline[4]:=734;helpline[3]:=735;
helpline[2]:=721;helpline[1]:=722;helpline[0]:=723;end;error;goto 32;
end{:459};curval:=xnoverd(curval,num,denom);
f:=(num*f+65536*remainder)div denom;curval:=curval+(f div 65536);
f:=f mod 65536;32:{:458};
88:if curval>=16384 then aritherror:=true else curval:=curval*65536+f;
30:{:453};{443:}begin getxtoken;if curcmd<>10 then backinput;end{:443};
89:if aritherror or(abs(curval)>=1073741824)then{460:}begin begin if
interaction=3 then;printnl(263);print(736);end;begin helpptr:=2;
helpline[1]:=737;helpline[0]:=738;end;error;curval:=1073741823;
aritherror:=false;end{:460};if negative then curval:=-curval;end;
{:448}{461:}procedure scanglue(level:smallnumber);label 10;
var negative:boolean;q:halfword;mu:boolean;begin mu:=(level=3);
{441:}negative:=false;repeat{406:}repeat getxtoken;
until curcmd<>10{:406};if curtok=3117 then begin negative:=not negative;
curtok:=3115;end;until curtok<>3115{:441};
if(curcmd>=68)and(curcmd<=89)then begin scansomethinginternal(level,
negative);
if curvallevel>=2 then begin if curvallevel<>level then muerror;goto 10;
end;if curvallevel=0 then scandimen(mu,false,true)else if level=3 then
muerror;end else begin backinput;scandimen(mu,false,false);
if negative then curval:=-curval;end;{462:}q:=newspec(0);
mem[q+1].int:=curval;
if scankeyword(739)then begin scandimen(mu,true,false);
mem[q+2].int:=curval;mem[q].hh.b0:=curorder;end;
if scankeyword(740)then begin scandimen(mu,true,false);
mem[q+3].int:=curval;mem[q].hh.b1:=curorder;end;curval:=q{:462};10:end;
{1515:}{1526:}function addorsub(x,y,maxanswer:integer;
negative:boolean):integer;var a:integer;begin if negative then y:=-y;
if x>=0 then if y<=maxanswer-x then a:=x+y else begin aritherror:=true;
a:=0;
end else if y>=-maxanswer-x then a:=x+y else begin aritherror:=true;
a:=0;end;addorsub:=a;end;
{:1526}{1530:}function quotient(n,d:integer):integer;
var negative:boolean;a:integer;begin if d=0 then begin aritherror:=true;
a:=0;end else begin if d>0 then negative:=false else begin d:=-d;
negative:=true;end;if n<0 then begin n:=-n;negative:=not negative;end;
a:=n div d;n:=n-a*d;d:=n-d;if d+n>=0 then a:=a+1;if negative then a:=-a;
end;quotient:=a;end;
{:1530}{1532:}function fract(x,n,d,maxanswer:integer):integer;
label 40,41,88,30;var negative:boolean;a:integer;f:integer;h:integer;
r:integer;t:integer;begin if d=0 then goto 88;a:=0;
if d>0 then negative:=false else begin d:=-d;negative:=true;end;
if x<0 then begin x:=-x;negative:=not negative;
end else if x=0 then goto 30;if n<0 then begin n:=-n;
negative:=not negative;end;t:=n div d;if t>maxanswer div x then goto 88;
a:=t*x;n:=n-t*d;if n=0 then goto 40;t:=x div d;
if t>(maxanswer-a)div n then goto 88;a:=a+t*n;x:=x-t*d;
if x=0 then goto 40;if x<n then begin t:=x;x:=n;n:=t;end;{1533:}f:=0;
r:=(d div 2)-d;h:=-r;while true do begin if odd(n)then begin r:=r+x;
if r>=0 then begin r:=r-d;f:=f+1;end;end;n:=n div 2;if n=0 then goto 41;
if x<h then x:=x+x else begin t:=x-d;x:=t+x;f:=f+n;
if x<n then begin if x=0 then goto 41;t:=x;x:=n;n:=t;end;end;end;
41:{:1533}if f>(maxanswer-a)then goto 88;a:=a+f;
40:if negative then a:=-a;goto 30;88:begin aritherror:=true;a:=0;end;
30:fract:=a;end;{:1532}procedure scanexpr;label 20,22,40;
var a,b:boolean;l:smallnumber;r:smallnumber;s:smallnumber;o:smallnumber;
e:integer;t:integer;f:integer;n:integer;p:halfword;q:halfword;
begin l:=curvallevel;a:=aritherror;b:=false;p:=0;{1516:}20:r:=0;e:=0;
s:=0;t:=0;n:=0;22:if s=0 then o:=l else o:=0;
{1518:}{406:}repeat getxtoken;until curcmd<>10{:406};
if curtok=3112 then{1521:}begin q:=getnode(4);mem[q].hh.rh:=p;
mem[q].hh.b0:=l;mem[q].hh.b1:=4*s+r;mem[q+1].int:=e;mem[q+2].int:=t;
mem[q+3].int:=n;p:=q;l:=o;goto 20;end{:1521};backinput;
if o=0 then scanint else if o=1 then scandimen(false,false,false)else if
o=2 then scannormalglue else scanmuglue;f:=curval{:1518};
40:{1517:}{406:}repeat getxtoken;until curcmd<>10{:406};
if curtok=3115 then o:=1 else if curtok=3117 then o:=2 else if curtok=
3114 then o:=3 else if curtok=3119 then o:=4 else begin o:=0;
if p=0 then begin if curcmd<>0 then backinput;
end else if curtok<>3113 then begin begin if interaction=3 then;
printnl(263);print(1394);end;begin helpptr:=1;helpline[0]:=1395;end;
backerror;end;end{:1517};aritherror:=b;
{1523:}if(l=0)or(s>2)then begin if(f>2147483647)or(f<-2147483647)then
begin aritherror:=true;f:=0;end;
end else if l=1 then begin if abs(f)>1073741823 then begin aritherror:=
true;f:=0;end;
end else begin if(abs(mem[f+1].int)>1073741823)or(abs(mem[f+2].int)>
1073741823)or(abs(mem[f+3].int)>1073741823)then begin aritherror:=true;
deleteglueref(f);f:=newspec(0);end;end{:1523};
case s of{1524:}0:if(l>=2)and(o<>0)then begin t:=newspec(f);
deleteglueref(f);if mem[t+2].int=0 then mem[t].hh.b0:=0;
if mem[t+3].int=0 then mem[t].hh.b1:=0;end else t:=f;
{:1524}{1528:}3:if o=4 then begin n:=f;o:=5;
end else if l=0 then t:=multandadd(t,f,0,2147483647)else if l=1 then t:=
multandadd(t,f,0,1073741823)else begin mem[t+1].int:=multandadd(mem[t+1]
.int,f,0,1073741823);
mem[t+2].int:=multandadd(mem[t+2].int,f,0,1073741823);
mem[t+3].int:=multandadd(mem[t+3].int,f,0,1073741823);end;
{:1528}{1529:}4:if l<2 then t:=quotient(t,f)else begin mem[t+1].int:=
quotient(mem[t+1].int,f);mem[t+2].int:=quotient(mem[t+2].int,f);
mem[t+3].int:=quotient(mem[t+3].int,f);end;
{:1529}{1531:}5:if l=0 then t:=fract(t,n,f,2147483647)else if l=1 then t
:=fract(t,n,f,1073741823)else begin mem[t+1].int:=fract(mem[t+1].int,n,f
,1073741823);mem[t+2].int:=fract(mem[t+2].int,n,f,1073741823);
mem[t+3].int:=fract(mem[t+3].int,n,f,1073741823);end;{:1531}end;
if o>2 then s:=o else{1525:}begin s:=0;
if r=0 then e:=t else if l=0 then e:=addorsub(e,t,2147483647,r=2)else if
l=1 then e:=addorsub(e,t,1073741823,r=2)else{1527:}begin mem[e+1].int:=
addorsub(mem[e+1].int,mem[t+1].int,1073741823,r=2);
if mem[e].hh.b0=mem[t].hh.b0 then mem[e+2].int:=addorsub(mem[e+2].int,
mem[t+2].int,1073741823,r=2)else if(mem[e].hh.b0<mem[t].hh.b0)and(mem[t
+2].int<>0)then begin mem[e+2].int:=mem[t+2].int;
mem[e].hh.b0:=mem[t].hh.b0;end;
if mem[e].hh.b1=mem[t].hh.b1 then mem[e+3].int:=addorsub(mem[e+3].int,
mem[t+3].int,1073741823,r=2)else if(mem[e].hh.b1<mem[t].hh.b1)and(mem[t
+3].int<>0)then begin mem[e+3].int:=mem[t+3].int;
mem[e].hh.b1:=mem[t].hh.b1;end;deleteglueref(t);
if mem[e+2].int=0 then mem[e].hh.b0:=0;
if mem[e+3].int=0 then mem[e].hh.b1:=0;end{:1527};r:=o;end{:1525};
b:=aritherror;if o<>0 then goto 22;if p<>0 then{1522:}begin f:=e;q:=p;
e:=mem[q+1].int;t:=mem[q+2].int;n:=mem[q+3].int;s:=mem[q].hh.b1 div 4;
r:=mem[q].hh.b1 mod 4;l:=mem[q].hh.b0;p:=mem[q].hh.rh;freenode(q,4);
goto 40;end{:1522}{:1516};if b then begin begin if interaction=3 then;
printnl(263);print(1222);end;begin helpptr:=2;helpline[1]:=1393;
helpline[0]:=1224;end;error;if l>=2 then begin deleteglueref(e);e:=0;
mem[e].hh.rh:=mem[e].hh.rh+1;end else e:=0;end;aritherror:=a;curval:=e;
curvallevel:=l;end;{:1515}{1520:}procedure scannormalglue;
begin scanglue(2);end;procedure scanmuglue;begin scanglue(3);end;
{:1520}{:461}{463:}function scanrulespec:halfword;label 21;
var q:halfword;begin q:=newrule;
if curcmd=35 then mem[q+1].int:=26214 else begin mem[q+3].int:=26214;
mem[q+2].int:=0;end;
21:if scankeyword(741)then begin scandimen(false,false,false);
mem[q+1].int:=curval;goto 21;end;
if scankeyword(742)then begin scandimen(false,false,false);
mem[q+3].int:=curval;goto 21;end;
if scankeyword(743)then begin scandimen(false,false,false);
mem[q+2].int:=curval;goto 21;end;scanrulespec:=q;end;
{:463}{464:}{1414:}procedure scangeneraltext;label 40;var s:0..5;
w:halfword;d:halfword;p:halfword;q:halfword;unbalance:halfword;
begin s:=scannerstatus;w:=warningindex;d:=defref;scannerstatus:=5;
warningindex:=curcs;defref:=getavail;mem[defref].hh.lh:=0;p:=defref;
scanleftbrace;unbalance:=1;while true do begin gettoken;
if curtok<768 then if curcmd<2 then unbalance:=unbalance+1 else begin
unbalance:=unbalance-1;if unbalance=0 then goto 40;end;
begin q:=getavail;mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;p:=q;end;end;
40:q:=mem[defref].hh.rh;begin mem[defref].hh.rh:=avail;avail:=defref;
{dynused:=dynused-1;}end;if q=0 then curval:=29997 else curval:=p;
mem[29997].hh.rh:=q;scannerstatus:=s;warningindex:=w;defref:=d;end;
{:1414}{1486:}procedure pseudostart;var oldsetting:0..21;s:strnumber;
l,m:poolpointer;p,q,r:halfword;w:fourquarters;nl,sz:integer;
begin scangeneraltext;oldsetting:=selector;selector:=21;
tokenshow(29997);selector:=oldsetting;flushlist(mem[29997].hh.rh);
begin if poolptr+1>poolsize then overflow(258,poolsize-initpoolptr);end;
s:=makestring;{1487:}strpool[poolptr]:=32;l:=strstart[s];
nl:=eqtb[5317].int;p:=getavail;q:=p;while l<poolptr do begin m:=l;
while(l<poolptr)and(strpool[l]<>nl)do l:=l+1;sz:=(l-m+7)div 4;
if sz=1 then sz:=2;r:=getnode(sz);mem[q].hh.rh:=r;q:=r;
mem[q].hh.lh:=sz+0;while sz>2 do begin sz:=sz-1;r:=r+1;
w.b0:=strpool[m]+0;w.b1:=strpool[m+1]+0;w.b2:=strpool[m+2]+0;
w.b3:=strpool[m+3]+0;mem[r].qqqq:=w;m:=m+4;end;w.b0:=32;w.b1:=32;
w.b2:=32;w.b3:=32;if l>m then begin w.b0:=strpool[m]+0;
if l>m+1 then begin w.b1:=strpool[m+1]+0;
if l>m+2 then begin w.b2:=strpool[m+2]+0;
if l>m+3 then w.b3:=strpool[m+3]+0;end;end;end;mem[r+1].qqqq:=w;
if strpool[l]=nl then l:=l+1;end;mem[p].hh.lh:=mem[p].hh.rh;
mem[p].hh.rh:=pseudofiles;pseudofiles:=p{:1487};begin strptr:=strptr-1;
poolptr:=strstart[strptr];end;{1488:}beginfilereading;line:=0;
curinput.limitfield:=curinput.startfield;
curinput.locfield:=curinput.limitfield+1;
if eqtb[5326].int>0 then begin if termoffset>maxprintline-3 then println
else if(termoffset>0)or(fileoffset>0)then printchar(32);
curinput.namefield:=19;print(1379);openparens:=openparens+1;
break(termout);end else curinput.namefield:=18{:1488};end;
{:1486}function strtoks(b:poolpointer):halfword;var p:halfword;
q:halfword;t:halfword;k:poolpointer;
begin begin if poolptr+1>poolsize then overflow(258,poolsize-initpoolptr
);end;p:=29997;mem[p].hh.rh:=0;k:=b;
while k<poolptr do begin t:=strpool[k];
if t=32 then t:=2592 else t:=3072+t;begin begin q:=avail;
if q=0 then q:=getavail else begin avail:=mem[q].hh.rh;mem[q].hh.rh:=0;
{dynused:=dynused+1;}end;end;mem[p].hh.rh:=q;mem[q].hh.lh:=t;p:=q;end;
k:=k+1;end;poolptr:=b;strtoks:=p;end;
{:464}{465:}function thetoks:halfword;label 10;var oldsetting:0..21;
p,q,r:halfword;b:poolpointer;c:smallnumber;
begin{1419:}if odd(curchr)then begin c:=curchr;scangeneraltext;
if c=1 then thetoks:=curval else begin oldsetting:=selector;
selector:=21;b:=poolptr;p:=getavail;mem[p].hh.rh:=mem[29997].hh.rh;
tokenshow(p);flushlist(p);selector:=oldsetting;thetoks:=strtoks(b);end;
goto 10;end{:1419};getxtoken;scansomethinginternal(5,false);
if curvallevel>=4 then{466:}begin p:=29997;mem[p].hh.rh:=0;
if curvallevel=4 then begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=4095+curval;p:=q;
end else if curval<>0 then begin r:=mem[curval].hh.rh;
while r<>0 do begin begin begin q:=avail;
if q=0 then q:=getavail else begin avail:=mem[q].hh.rh;mem[q].hh.rh:=0;
{dynused:=dynused+1;}end;end;mem[p].hh.rh:=q;mem[q].hh.lh:=mem[r].hh.lh;
p:=q;end;r:=mem[r].hh.rh;end;end;thetoks:=p;
end{:466}else begin oldsetting:=selector;selector:=21;b:=poolptr;
case curvallevel of 0:printint(curval);1:begin printscaled(curval);
print(400);end;2:begin printspec(curval,400);deleteglueref(curval);end;
3:begin printspec(curval,338);deleteglueref(curval);end;end;
selector:=oldsetting;thetoks:=strtoks(b);end;10:end;
{:465}{467:}procedure insthetoks;begin mem[29988].hh.rh:=thetoks;
begintokenlist(mem[29997].hh.rh,4);end;{:467}{470:}procedure convtoks;
var oldsetting:0..21;c:0..6;savescannerstatus:smallnumber;b:poolpointer;
begin c:=curchr;{471:}case c of 0,1:scanint;
2,3:begin savescannerstatus:=scannerstatus;scannerstatus:=0;gettoken;
scannerstatus:=savescannerstatus;end;4:scanfontident;5:;
6:if jobname=0 then openlogfile;end{:471};oldsetting:=selector;
selector:=21;b:=poolptr;{472:}case c of 0:printint(curval);
1:printromanint(curval);
2:if curcs<>0 then sprintcs(curcs)else printchar(curchr);3:printmeaning;
4:begin print(fontname[curval]);
if fontsize[curval]<>fontdsize[curval]then begin print(751);
printscaled(fontsize[curval]);print(400);end;end;5:print(256);
6:print(jobname);end{:472};selector:=oldsetting;
mem[29988].hh.rh:=strtoks(b);begintokenlist(mem[29997].hh.rh,4);end;
{:470}{473:}function scantoks(macrodef,xpand:boolean):halfword;
label 40,30,31,32;var t:halfword;s:halfword;p:halfword;q:halfword;
unbalance:halfword;hashbrace:halfword;
begin if macrodef then scannerstatus:=2 else scannerstatus:=5;
warningindex:=curcs;defref:=getavail;mem[defref].hh.lh:=0;p:=defref;
hashbrace:=0;t:=3120;
if macrodef then{474:}begin while true do begin gettoken;
if curtok<768 then goto 31;if curcmd=6 then{476:}begin s:=3328+curchr;
gettoken;if curcmd=1 then begin hashbrace:=curtok;begin q:=getavail;
mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;p:=q;end;begin q:=getavail;
mem[p].hh.rh:=q;mem[q].hh.lh:=3584;p:=q;end;goto 30;end;
if t=3129 then begin begin if interaction=3 then;printnl(263);
print(754);end;begin helpptr:=1;helpline[0]:=755;end;error;
end else begin t:=t+1;
if curtok<>t then begin begin if interaction=3 then;printnl(263);
print(756);end;begin helpptr:=2;helpline[1]:=757;helpline[0]:=758;end;
backerror;end;curtok:=s;end;end{:476};begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=curtok;p:=q;end;end;31:begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=3584;p:=q;end;
if curcmd=2 then{475:}begin begin if interaction=3 then;printnl(263);
print(666);end;alignstate:=alignstate+1;begin helpptr:=2;
helpline[1]:=752;helpline[0]:=753;end;error;goto 40;end{:475};
30:end{:474}else scanleftbrace;{477:}unbalance:=1;
while true do begin if xpand then{478:}begin while true do begin getnext
;if curcmd>=111 then if mem[mem[curchr].hh.rh].hh.lh=3585 then begin
curcmd:=0;curchr:=257;end;if curcmd<=100 then goto 32;
if curcmd<>109 then expand else begin q:=thetoks;
if mem[29997].hh.rh<>0 then begin mem[p].hh.rh:=mem[29997].hh.rh;p:=q;
end;end;end;32:xtoken end{:478}else gettoken;
if curtok<768 then if curcmd<2 then unbalance:=unbalance+1 else begin
unbalance:=unbalance-1;if unbalance=0 then goto 40;
end else if curcmd=6 then if macrodef then{479:}begin s:=curtok;
if xpand then getxtoken else gettoken;
if curcmd<>6 then if(curtok<=3120)or(curtok>t)then begin begin if
interaction=3 then;printnl(263);print(759);end;sprintcs(warningindex);
begin helpptr:=3;helpline[2]:=760;helpline[1]:=761;helpline[0]:=762;end;
backerror;curtok:=s;end else curtok:=1232+curchr;end{:479};
begin q:=getavail;mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;p:=q;end;
end{:477};40:scannerstatus:=0;if hashbrace<>0 then begin q:=getavail;
mem[p].hh.rh:=q;mem[q].hh.lh:=hashbrace;p:=q;end;scantoks:=p;end;
{:473}{482:}procedure readtoks(n:integer;r:halfword;j:halfword);
label 30;var p:halfword;q:halfword;s:integer;m:smallnumber;
begin scannerstatus:=2;warningindex:=r;defref:=getavail;
mem[defref].hh.lh:=0;p:=defref;begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=3584;p:=q;end;if(n<0)or(n>15)then m:=16 else m:=n;
s:=alignstate;alignstate:=1000000;repeat{483:}beginfilereading;
curinput.namefield:=m+1;
if readopen[m]=2 then{484:}if interaction>1 then if n<0 then begin;
print(339);terminput;end else begin;println;sprintcs(r);begin;print(61);
terminput;end;n:=-1;
end else fatalerror(763){:484}else if readopen[m]=1 then{485:}if inputln
(readfile[m],false)then readopen[m]:=0 else begin aclose(readfile[m]);
readopen[m]:=2;
end{:485}else{486:}begin if not inputln(readfile[m],true)then begin
aclose(readfile[m]);readopen[m]:=2;
if alignstate<>1000000 then begin runaway;begin if interaction=3 then;
printnl(263);print(764);end;printesc(538);begin helpptr:=1;
helpline[0]:=765;end;alignstate:=1000000;error;end;end;end{:486};
curinput.limitfield:=last;
if(eqtb[5316].int<0)or(eqtb[5316].int>255)then curinput.limitfield:=
curinput.limitfield-1 else buffer[curinput.limitfield]:=eqtb[5316].int;
first:=curinput.limitfield+1;curinput.locfield:=curinput.startfield;
curinput.statefield:=33;
{1494:}if j=1 then begin while curinput.locfield<=curinput.limitfield do
begin curchr:=buffer[curinput.locfield];
curinput.locfield:=curinput.locfield+1;
if curchr=32 then curtok:=2592 else curtok:=curchr+3072;
begin q:=getavail;mem[p].hh.rh:=q;mem[q].hh.lh:=curtok;p:=q;end;end;
goto 30;end{:1494};while true do begin gettoken;
if curtok=0 then goto 30;
if alignstate<1000000 then begin repeat gettoken;until curtok=0;
alignstate:=1000000;goto 30;end;begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=curtok;p:=q;end;end;30:endfilereading{:483};
until alignstate=1000000;curval:=defref;scannerstatus:=0;alignstate:=s;
end;{:482}{494:}procedure passtext;label 30;var l:integer;
savescannerstatus:smallnumber;begin savescannerstatus:=scannerstatus;
scannerstatus:=1;l:=0;skipline:=line;while true do begin getnext;
if curcmd=106 then begin if l=0 then goto 30;if curchr=2 then l:=l-1;
end else if curcmd=105 then l:=l+1;end;
30:scannerstatus:=savescannerstatus;
if eqtb[5325].int>0 then showcurcmdchr;end;
{:494}{497:}procedure changeiflimit(l:smallnumber;p:halfword);label 10;
var q:halfword;begin if p=condptr then iflimit:=l else begin q:=condptr;
while true do begin if q=0 then confusion(766);
if mem[q].hh.rh=p then begin mem[q].hh.b0:=l;goto 10;end;
q:=mem[q].hh.rh;end;end;10:end;{:497}{498:}procedure conditional;
label 10,50;var b:boolean;r:60..62;m,n:integer;p,q:halfword;
savescannerstatus:smallnumber;savecondptr:halfword;thisif:smallnumber;
isunless:boolean;
begin if eqtb[5325].int>0 then if eqtb[5304].int<=1 then showcurcmdchr;
{495:}begin p:=getnode(2);mem[p].hh.rh:=condptr;mem[p].hh.b0:=iflimit;
mem[p].hh.b1:=curif;mem[p+1].int:=ifline;condptr:=p;curif:=curchr;
iflimit:=1;ifline:=line;end{:495};savecondptr:=condptr;
isunless:=(curchr>=32);thisif:=curchr mod 32;
{501:}case thisif of 0,1:{506:}begin begin getxtoken;
if curcmd=0 then if curchr=257 then begin curcmd:=13;
curchr:=curtok-4096;end;end;if(curcmd>13)or(curchr>255)then begin m:=0;
n:=256;end else begin m:=curcmd;n:=curchr;end;begin getxtoken;
if curcmd=0 then if curchr=257 then begin curcmd:=13;
curchr:=curtok-4096;end;end;
if(curcmd>13)or(curchr>255)then begin curcmd:=0;curchr:=256;end;
if thisif=0 then b:=(n=curchr)else b:=(m=curcmd);end{:506};
2,3:{503:}begin if thisif=2 then scanint else scandimen(false,false,
false);n:=curval;{406:}repeat getxtoken;until curcmd<>10{:406};
if(curtok>=3132)and(curtok<=3134)then r:=curtok-3072 else begin begin if
interaction=3 then;printnl(263);print(791);end;printcmdchr(105,thisif);
begin helpptr:=1;helpline[0]:=792;end;backerror;r:=61;end;
if thisif=2 then scanint else scandimen(false,false,false);
case r of 60:b:=(n<curval);61:b:=(n=curval);62:b:=(n>curval);end;
end{:503};4:{504:}begin scanint;b:=odd(curval);end{:504};
5:b:=(abs(curlist.modefield)=1);6:b:=(abs(curlist.modefield)=102);
7:b:=(abs(curlist.modefield)=203);8:b:=(curlist.modefield<0);
9,10,11:{505:}begin scanregisternum;
if curval<256 then p:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then p:=0 else p:=mem[curptr+1].hh.rh;end;
if thisif=9 then b:=(p=0)else if p=0 then b:=false else if thisif=10
then b:=(mem[p].hh.b0=0)else b:=(mem[p].hh.b0=1);end{:505};
12:{507:}begin savescannerstatus:=scannerstatus;scannerstatus:=0;
getnext;n:=curcs;p:=curcmd;q:=curchr;getnext;
if curcmd<>p then b:=false else if curcmd<111 then b:=(curchr=q)else
{508:}begin p:=mem[curchr].hh.rh;q:=mem[eqtb[n].hh.rh].hh.rh;
if p=q then b:=true else begin while(p<>0)and(q<>0)do if mem[p].hh.lh<>
mem[q].hh.lh then p:=0 else begin p:=mem[p].hh.rh;q:=mem[q].hh.rh;end;
b:=((p=0)and(q=0));end;end{:508};scannerstatus:=savescannerstatus;
end{:507};13:begin scanfourbitint;b:=(readopen[curval]=2);end;
14:b:=true;15:b:=false;{1499:}17:begin savescannerstatus:=scannerstatus;
scannerstatus:=0;getnext;b:=(curcmd<>101);
scannerstatus:=savescannerstatus;end;{:1499}{1500:}18:begin n:=getavail;
p:=n;repeat getxtoken;if curcs=0 then begin q:=getavail;mem[p].hh.rh:=q;
mem[q].hh.lh:=curtok;p:=q;end;until curcs<>0;
if curcmd<>67 then{373:}begin begin if interaction=3 then;printnl(263);
print(634);end;printesc(508);print(635);begin helpptr:=2;
helpline[1]:=636;helpline[0]:=637;end;backerror;end{:373};
{1501:}m:=first;p:=mem[n].hh.rh;
while p<>0 do begin if m>=maxbufstack then begin maxbufstack:=m+1;
if maxbufstack=bufsize then overflow(257,bufsize);end;
buffer[m]:=mem[p].hh.lh mod 256;m:=m+1;p:=mem[p].hh.rh;end;
if m>first+1 then curcs:=idlookup(first,m-first)else if m=first then
curcs:=513 else curcs:=257+buffer[first]{:1501};flushlist(n);
b:=(eqtb[curcs].hh.b0<>101);end;{:1500}{1502:}19:begin scanfontident;
n:=curval;scancharnum;
if(fontbc[n]<=curval)and(fontec[n]>=curval)then b:=(fontinfo[charbase[n]
+curval+0].qqqq.b0>0)else b:=false;end;{:1502}16:{509:}begin scanint;
n:=curval;if eqtb[5304].int>1 then begin begindiagnostic;print(793);
printint(n);printchar(125);enddiagnostic(false);end;
while n<>0 do begin passtext;
if condptr=savecondptr then if curchr=4 then n:=n-1 else goto 50 else if
curchr=2 then{496:}begin if ifstack[inopen]=condptr then ifwarning;
p:=condptr;ifline:=mem[p+1].int;curif:=mem[p].hh.b1;
iflimit:=mem[p].hh.b0;condptr:=mem[p].hh.rh;freenode(p,2);end{:496};end;
changeiflimit(4,savecondptr);goto 10;end{:509};end{:501};
if isunless then b:=not b;
if eqtb[5304].int>1 then{502:}begin begindiagnostic;
if b then print(789)else print(790);enddiagnostic(false);end{:502};
if b then begin changeiflimit(3,savecondptr);goto 10;end;
{500:}while true do begin passtext;
if condptr=savecondptr then begin if curchr<>4 then goto 50;
begin if interaction=3 then;printnl(263);print(787);end;printesc(785);
begin helpptr:=1;helpline[0]:=788;end;error;
end else if curchr=2 then{496:}begin if ifstack[inopen]=condptr then
ifwarning;p:=condptr;ifline:=mem[p+1].int;curif:=mem[p].hh.b1;
iflimit:=mem[p].hh.b0;condptr:=mem[p].hh.rh;freenode(p,2);end{:496};
end{:500};
50:if curchr=2 then{496:}begin if ifstack[inopen]=condptr then ifwarning
;p:=condptr;ifline:=mem[p+1].int;curif:=mem[p].hh.b1;
iflimit:=mem[p].hh.b0;condptr:=mem[p].hh.rh;freenode(p,2);
end{:496}else iflimit:=2;10:end;{:498}{515:}procedure beginname;
begin areadelimiter:=0;extdelimiter:=0;end;
{:515}{516:}function morename(c:ASCIIcode):boolean;
begin if c=32 then morename:=false else begin begin if poolptr+1>
poolsize then overflow(258,poolsize-initpoolptr);end;
begin strpool[poolptr]:=c;poolptr:=poolptr+1;end;
if(c=62)or(c=58)then begin areadelimiter:=(poolptr-strstart[strptr]);
extdelimiter:=0;
end else if(c=46)and(extdelimiter=0)then extdelimiter:=(poolptr-strstart
[strptr]);morename:=true;end;end;{:516}{517:}procedure endname;
begin if strptr+3>maxstrings then overflow(259,maxstrings-initstrptr);
if areadelimiter=0 then curarea:=339 else begin curarea:=strptr;
strstart[strptr+1]:=strstart[strptr]+areadelimiter;strptr:=strptr+1;end;
if extdelimiter=0 then begin curext:=339;curname:=makestring;
end else begin curname:=strptr;
strstart[strptr+1]:=strstart[strptr]+extdelimiter-areadelimiter-1;
strptr:=strptr+1;curext:=makestring;end;end;
{:517}{519:}procedure packfilename(n,a,e:strnumber);var k:integer;
c:ASCIIcode;j:poolpointer;begin k:=0;
for j:=strstart[a]to strstart[a+1]-1 do begin c:=strpool[j];k:=k+1;
if k<=filenamesize then nameoffile[k]:=xchr[c];end;
for j:=strstart[n]to strstart[n+1]-1 do begin c:=strpool[j];k:=k+1;
if k<=filenamesize then nameoffile[k]:=xchr[c];end;
for j:=strstart[e]to strstart[e+1]-1 do begin c:=strpool[j];k:=k+1;
if k<=filenamesize then nameoffile[k]:=xchr[c];end;
if k<=filenamesize then namelength:=k else namelength:=filenamesize;
for k:=namelength+1 to filenamesize do nameoffile[k]:=' ';end;
{:519}{523:}procedure packbufferedname(n:smallnumber;a,b:integer);
var k:integer;c:ASCIIcode;j:integer;
begin if n+b-a+5>filenamesize then b:=a+filenamesize-n-5;k:=0;
for j:=1 to n do begin c:=xord[TEXformatdefault[j]];k:=k+1;
if k<=filenamesize then nameoffile[k]:=xchr[c];end;
for j:=a to b do begin c:=buffer[j];k:=k+1;
if k<=filenamesize then nameoffile[k]:=xchr[c];end;
for j:=17 to 20 do begin c:=xord[TEXformatdefault[j]];k:=k+1;
if k<=filenamesize then nameoffile[k]:=xchr[c];end;
if k<=filenamesize then namelength:=k else namelength:=filenamesize;
for k:=namelength+1 to filenamesize do nameoffile[k]:=' ';end;
{:523}{525:}function makenamestring:strnumber;var k:1..filenamesize;
begin if(poolptr+namelength>poolsize)or(strptr=maxstrings)or((poolptr-
strstart[strptr])>0)then makenamestring:=63 else begin for k:=1 to
namelength do begin strpool[poolptr]:=xord[nameoffile[k]];
poolptr:=poolptr+1;end;makenamestring:=makestring;end;end;
function amakenamestring(var f:alphafile):strnumber;
begin amakenamestring:=makenamestring;end;
function bmakenamestring(var f:bytefile):strnumber;
begin bmakenamestring:=makenamestring;end;
function wmakenamestring(var f:wordfile):strnumber;
begin wmakenamestring:=makenamestring;end;
{:525}{526:}procedure scanfilename;label 30;begin nameinprogress:=true;
beginname;{406:}repeat getxtoken;until curcmd<>10{:406};
while true do begin if(curcmd>12)or(curchr>255)then begin backinput;
goto 30;end;if not morename(curchr)then goto 30;getxtoken;end;
30:endname;nameinprogress:=false;end;
{:526}{529:}procedure packjobname(s:strnumber);begin curarea:=339;
curext:=s;curname:=jobname;packfilename(curname,curarea,curext);end;
{:529}{530:}procedure promptfilename(s,e:strnumber);label 30;
var k:0..bufsize;begin if interaction=2 then;
if s=797 then begin if interaction=3 then;printnl(263);print(798);
end else begin if interaction=3 then;printnl(263);print(799);end;
printfilename(curname,curarea,curext);print(800);
if e=801 then showcontext;printnl(802);print(s);
if interaction<2 then fatalerror(803);breakin(termin,true);begin;
print(575);terminput;end;{531:}begin beginname;k:=first;
while(buffer[k]=32)and(k<last)do k:=k+1;
while true do begin if k=last then goto 30;
if not morename(buffer[k])then goto 30;k:=k+1;end;30:endname;end{:531};
if curext=339 then curext:=e;packfilename(curname,curarea,curext);end;
{:530}{534:}procedure openlogfile;var oldsetting:0..21;k:0..bufsize;
l:0..bufsize;months:packed array[1..36]of char;
begin oldsetting:=selector;if jobname=0 then jobname:=806;
packjobname(807);while not aopenout(logfile)do{535:}begin selector:=17;
promptfilename(809,807);end{:535};logname:=amakenamestring(logfile);
selector:=18;logopened:=true;
{536:}begin write(logfile,'This is e-TeX, Version 3.1415926','-2.2');
slowprint(formatident);print(810);printint(eqtb[5289].int);
printchar(32);months:='JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC';
for k:=3*eqtb[5290].int-2 to 3*eqtb[5290].int do write(logfile,months[k]
);printchar(32);printint(eqtb[5291].int);printchar(32);
printtwo(eqtb[5288].int div 60);printchar(58);
printtwo(eqtb[5288].int mod 60);if(eTeXmode=1)then begin;
writeln(logfile);write(logfile,'entering extended mode');end;end{:536};
inputstack[inputptr]:=curinput;printnl(808);l:=inputstack[0].limitfield;
if buffer[l]=eqtb[5316].int then l:=l-1;
for k:=1 to l do print(buffer[k]);println;selector:=oldsetting+2;end;
{:534}{537:}procedure startinput;label 30;begin scanfilename;
if curext=339 then curext:=801;packfilename(curname,curarea,curext);
while true do begin beginfilereading;
if aopenin(inputfile[curinput.indexfield])then goto 30;
if curarea=339 then begin packfilename(curname,794,curext);
if aopenin(inputfile[curinput.indexfield])then goto 30;end;
endfilereading;promptfilename(797,801);end;
30:curinput.namefield:=amakenamestring(inputfile[curinput.indexfield]);
if jobname=0 then begin jobname:=curname;openlogfile;end;
if termoffset+(strstart[curinput.namefield+1]-strstart[curinput.
namefield])>maxprintline-2 then println else if(termoffset>0)or(
fileoffset>0)then printchar(32);printchar(40);openparens:=openparens+1;
slowprint(curinput.namefield);break(termout);curinput.statefield:=33;
if curinput.namefield=strptr-1 then begin begin strptr:=strptr-1;
poolptr:=strstart[strptr];end;curinput.namefield:=curname;end;
{538:}begin line:=1;
if inputln(inputfile[curinput.indexfield],false)then;firmuptheline;
if(eqtb[5316].int<0)or(eqtb[5316].int>255)then curinput.limitfield:=
curinput.limitfield-1 else buffer[curinput.limitfield]:=eqtb[5316].int;
first:=curinput.limitfield+1;curinput.locfield:=curinput.startfield;
end{:538};end;{:537}{560:}function readfontinfo(u:halfword;
nom,aire:strnumber;s:scaled):internalfontnumber;label 30,11,45;
var k:fontindex;fileopened:boolean;
lf,lh,bc,ec,nw,nh,nd,ni,nl,nk,ne,np:halfword;f:internalfontnumber;
g:internalfontnumber;a,b,c,d:eightbits;qw:fourquarters;sw:scaled;
bchlabel:integer;bchar:0..256;z:scaled;alpha:integer;beta:1..16;
begin g:=0;{562:}{563:}fileopened:=false;
if aire=339 then packfilename(nom,795,821)else packfilename(nom,aire,821
);if not bopenin(tfmfile)then goto 11;fileopened:=true{:563};
{565:}begin begin lf:=tfmfile^;if lf>127 then goto 11;get(tfmfile);
lf:=lf*256+tfmfile^;end;get(tfmfile);begin lh:=tfmfile^;
if lh>127 then goto 11;get(tfmfile);lh:=lh*256+tfmfile^;end;
get(tfmfile);begin bc:=tfmfile^;if bc>127 then goto 11;get(tfmfile);
bc:=bc*256+tfmfile^;end;get(tfmfile);begin ec:=tfmfile^;
if ec>127 then goto 11;get(tfmfile);ec:=ec*256+tfmfile^;end;
if(bc>ec+1)or(ec>255)then goto 11;if bc>255 then begin bc:=1;ec:=0;end;
get(tfmfile);begin nw:=tfmfile^;if nw>127 then goto 11;get(tfmfile);
nw:=nw*256+tfmfile^;end;get(tfmfile);begin nh:=tfmfile^;
if nh>127 then goto 11;get(tfmfile);nh:=nh*256+tfmfile^;end;
get(tfmfile);begin nd:=tfmfile^;if nd>127 then goto 11;get(tfmfile);
nd:=nd*256+tfmfile^;end;get(tfmfile);begin ni:=tfmfile^;
if ni>127 then goto 11;get(tfmfile);ni:=ni*256+tfmfile^;end;
get(tfmfile);begin nl:=tfmfile^;if nl>127 then goto 11;get(tfmfile);
nl:=nl*256+tfmfile^;end;get(tfmfile);begin nk:=tfmfile^;
if nk>127 then goto 11;get(tfmfile);nk:=nk*256+tfmfile^;end;
get(tfmfile);begin ne:=tfmfile^;if ne>127 then goto 11;get(tfmfile);
ne:=ne*256+tfmfile^;end;get(tfmfile);begin np:=tfmfile^;
if np>127 then goto 11;get(tfmfile);np:=np*256+tfmfile^;end;
if lf<>6+lh+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np then goto 11;
if(nw=0)or(nh=0)or(nd=0)or(ni=0)then goto 11;end{:565};
{566:}lf:=lf-6-lh;if np<7 then lf:=lf+7-np;
if(fontptr=fontmax)or(fmemptr+lf>fontmemsize)then{567:}begin begin if
interaction=3 then;printnl(263);print(812);end;sprintcs(u);
printchar(61);printfilename(nom,aire,339);if s>=0 then begin print(751);
printscaled(s);print(400);end else if s<>-1000 then begin print(813);
printint(-s);end;print(822);begin helpptr:=4;helpline[3]:=823;
helpline[2]:=824;helpline[1]:=825;helpline[0]:=826;end;error;goto 30;
end{:567};f:=fontptr+1;charbase[f]:=fmemptr-bc;
widthbase[f]:=charbase[f]+ec+1;heightbase[f]:=widthbase[f]+nw;
depthbase[f]:=heightbase[f]+nh;italicbase[f]:=depthbase[f]+nd;
ligkernbase[f]:=italicbase[f]+ni;
kernbase[f]:=ligkernbase[f]+nl-256*(128);
extenbase[f]:=kernbase[f]+256*(128)+nk;
parambase[f]:=extenbase[f]+ne{:566};{568:}begin if lh<2 then goto 11;
begin get(tfmfile);a:=tfmfile^;qw.b0:=a+0;get(tfmfile);b:=tfmfile^;
qw.b1:=b+0;get(tfmfile);c:=tfmfile^;qw.b2:=c+0;get(tfmfile);d:=tfmfile^;
qw.b3:=d+0;fontcheck[f]:=qw;end;get(tfmfile);begin z:=tfmfile^;
if z>127 then goto 11;get(tfmfile);z:=z*256+tfmfile^;end;get(tfmfile);
z:=z*256+tfmfile^;get(tfmfile);z:=(z*16)+(tfmfile^div 16);
if z<65536 then goto 11;while lh>2 do begin get(tfmfile);get(tfmfile);
get(tfmfile);get(tfmfile);lh:=lh-1;end;fontdsize[f]:=z;
if s<>-1000 then if s>=0 then z:=s else z:=xnoverd(z,-s,1000);
fontsize[f]:=z;end{:568};
{569:}for k:=fmemptr to widthbase[f]-1 do begin begin get(tfmfile);
a:=tfmfile^;qw.b0:=a+0;get(tfmfile);b:=tfmfile^;qw.b1:=b+0;get(tfmfile);
c:=tfmfile^;qw.b2:=c+0;get(tfmfile);d:=tfmfile^;qw.b3:=d+0;
fontinfo[k].qqqq:=qw;end;
if(a>=nw)or(b div 16>=nh)or(b mod 16>=nd)or(c div 4>=ni)then goto 11;
case c mod 4 of 1:if d>=nl then goto 11;3:if d>=ne then goto 11;
2:{570:}begin begin if(d<bc)or(d>ec)then goto 11 end;
while d<k+bc-fmemptr do begin qw:=fontinfo[charbase[f]+d].qqqq;
if((qw.b2-0)mod 4)<>2 then goto 45;d:=qw.b3-0;end;
if d=k+bc-fmemptr then goto 11;45:end{:570};others:end;end{:569};
{571:}begin{572:}begin alpha:=16;while z>=8388608 do begin z:=z div 2;
alpha:=alpha+alpha;end;beta:=256 div alpha;alpha:=alpha*z;end{:572};
for k:=widthbase[f]to ligkernbase[f]-1 do begin get(tfmfile);
a:=tfmfile^;get(tfmfile);b:=tfmfile^;get(tfmfile);c:=tfmfile^;
get(tfmfile);d:=tfmfile^;
sw:=(((((d*z)div 256)+(c*z))div 256)+(b*z))div beta;
if a=0 then fontinfo[k].int:=sw else if a=255 then fontinfo[k].int:=sw-
alpha else goto 11;end;if fontinfo[widthbase[f]].int<>0 then goto 11;
if fontinfo[heightbase[f]].int<>0 then goto 11;
if fontinfo[depthbase[f]].int<>0 then goto 11;
if fontinfo[italicbase[f]].int<>0 then goto 11;end{:571};
{573:}bchlabel:=32767;bchar:=256;
if nl>0 then begin for k:=ligkernbase[f]to kernbase[f]+256*(128)-1 do
begin begin get(tfmfile);a:=tfmfile^;qw.b0:=a+0;get(tfmfile);
b:=tfmfile^;qw.b1:=b+0;get(tfmfile);c:=tfmfile^;qw.b2:=c+0;get(tfmfile);
d:=tfmfile^;qw.b3:=d+0;fontinfo[k].qqqq:=qw;end;
if a>128 then begin if 256*c+d>=nl then goto 11;
if a=255 then if k=ligkernbase[f]then bchar:=b;
end else begin if b<>bchar then begin begin if(b<bc)or(b>ec)then goto 11
end;qw:=fontinfo[charbase[f]+b].qqqq;if not(qw.b0>0)then goto 11;end;
if c<128 then begin begin if(d<bc)or(d>ec)then goto 11 end;
qw:=fontinfo[charbase[f]+d].qqqq;if not(qw.b0>0)then goto 11;
end else if 256*(c-128)+d>=nk then goto 11;
if a<128 then if k-ligkernbase[f]+a+1>=nl then goto 11;end;end;
if a=255 then bchlabel:=256*c+d;end;
for k:=kernbase[f]+256*(128)to extenbase[f]-1 do begin get(tfmfile);
a:=tfmfile^;get(tfmfile);b:=tfmfile^;get(tfmfile);c:=tfmfile^;
get(tfmfile);d:=tfmfile^;
sw:=(((((d*z)div 256)+(c*z))div 256)+(b*z))div beta;
if a=0 then fontinfo[k].int:=sw else if a=255 then fontinfo[k].int:=sw-
alpha else goto 11;end;{:573};
{574:}for k:=extenbase[f]to parambase[f]-1 do begin begin get(tfmfile);
a:=tfmfile^;qw.b0:=a+0;get(tfmfile);b:=tfmfile^;qw.b1:=b+0;get(tfmfile);
c:=tfmfile^;qw.b2:=c+0;get(tfmfile);d:=tfmfile^;qw.b3:=d+0;
fontinfo[k].qqqq:=qw;end;
if a<>0 then begin begin if(a<bc)or(a>ec)then goto 11 end;
qw:=fontinfo[charbase[f]+a].qqqq;if not(qw.b0>0)then goto 11;end;
if b<>0 then begin begin if(b<bc)or(b>ec)then goto 11 end;
qw:=fontinfo[charbase[f]+b].qqqq;if not(qw.b0>0)then goto 11;end;
if c<>0 then begin begin if(c<bc)or(c>ec)then goto 11 end;
qw:=fontinfo[charbase[f]+c].qqqq;if not(qw.b0>0)then goto 11;end;
begin begin if(d<bc)or(d>ec)then goto 11 end;
qw:=fontinfo[charbase[f]+d].qqqq;if not(qw.b0>0)then goto 11;end;
end{:574};{575:}begin for k:=1 to np do if k=1 then begin get(tfmfile);
sw:=tfmfile^;if sw>127 then sw:=sw-256;get(tfmfile);sw:=sw*256+tfmfile^;
get(tfmfile);sw:=sw*256+tfmfile^;get(tfmfile);
fontinfo[parambase[f]].int:=(sw*16)+(tfmfile^div 16);
end else begin get(tfmfile);a:=tfmfile^;get(tfmfile);b:=tfmfile^;
get(tfmfile);c:=tfmfile^;get(tfmfile);d:=tfmfile^;
sw:=(((((d*z)div 256)+(c*z))div 256)+(b*z))div beta;
if a=0 then fontinfo[parambase[f]+k-1].int:=sw else if a=255 then
fontinfo[parambase[f]+k-1].int:=sw-alpha else goto 11;end;
if eof(tfmfile)then goto 11;
for k:=np+1 to 7 do fontinfo[parambase[f]+k-1].int:=0;end{:575};
{576:}if np>=7 then fontparams[f]:=np else fontparams[f]:=7;
hyphenchar[f]:=eqtb[5314].int;skewchar[f]:=eqtb[5315].int;
if bchlabel<nl then bcharlabel[f]:=bchlabel+ligkernbase[f]else
bcharlabel[f]:=0;fontbchar[f]:=bchar+0;fontfalsebchar[f]:=bchar+0;
if bchar<=ec then if bchar>=bc then begin qw:=fontinfo[charbase[f]+bchar
].qqqq;if(qw.b0>0)then fontfalsebchar[f]:=256;end;fontname[f]:=nom;
fontarea[f]:=aire;fontbc[f]:=bc;fontec[f]:=ec;fontglue[f]:=0;
charbase[f]:=charbase[f]-0;widthbase[f]:=widthbase[f]-0;
ligkernbase[f]:=ligkernbase[f]-0;kernbase[f]:=kernbase[f]-0;
extenbase[f]:=extenbase[f]-0;parambase[f]:=parambase[f]-1;
fmemptr:=fmemptr+lf;fontptr:=f;g:=f;goto 30{:576}{:562};
11:{561:}begin if interaction=3 then;printnl(263);print(812);end;
sprintcs(u);printchar(61);printfilename(nom,aire,339);
if s>=0 then begin print(751);printscaled(s);print(400);
end else if s<>-1000 then begin print(813);printint(-s);end;
if fileopened then print(814)else print(815);begin helpptr:=5;
helpline[4]:=816;helpline[3]:=817;helpline[2]:=818;helpline[1]:=819;
helpline[0]:=820;end;error{:561};30:if fileopened then bclose(tfmfile);
readfontinfo:=g;end;
{:560}{581:}procedure charwarning(f:internalfontnumber;c:eightbits);
var oldsetting:integer;
begin if eqtb[5303].int>0 then begin oldsetting:=eqtb[5297].int;
if(eTeXmode=1)and(eqtb[5303].int>1)then eqtb[5297].int:=1;
begin begindiagnostic;printnl(835);print(c);print(836);
slowprint(fontname[f]);printchar(33);enddiagnostic(false);end;
eqtb[5297].int:=oldsetting;end;end;
{:581}{582:}function newcharacter(f:internalfontnumber;
c:eightbits):halfword;label 10;var p:halfword;
begin if fontbc[f]<=c then if fontec[f]>=c then if(fontinfo[charbase[f]+
c+0].qqqq.b0>0)then begin p:=getavail;mem[p].hh.b0:=f;mem[p].hh.b1:=c+0;
newcharacter:=p;goto 10;end;charwarning(f,c);newcharacter:=0;10:end;
{:582}{597:}procedure writedvi(a,b:dviindex);var k:dviindex;
begin for k:=a to b do write(dvifile,dvibuf[k]);end;
{:597}{598:}procedure dviswap;
begin if dvilimit=dvibufsize then begin writedvi(0,halfbuf-1);
dvilimit:=halfbuf;dvioffset:=dvioffset+dvibufsize;dviptr:=0;
end else begin writedvi(halfbuf,dvibufsize-1);dvilimit:=dvibufsize;end;
dvigone:=dvigone+halfbuf;end;{:598}{600:}procedure dvifour(x:integer);
begin if x>=0 then begin dvibuf[dviptr]:=x div 16777216;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;
end else begin x:=x+1073741824;x:=x+1073741824;
begin dvibuf[dviptr]:=(x div 16777216)+128;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;end;x:=x mod 16777216;
begin dvibuf[dviptr]:=x div 65536;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;x:=x mod 65536;
begin dvibuf[dviptr]:=x div 256;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;begin dvibuf[dviptr]:=x mod 256;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;end;
{:600}{601:}procedure dvipop(l:integer);
begin if(l=dvioffset+dviptr)and(dviptr>0)then dviptr:=dviptr-1 else
begin dvibuf[dviptr]:=142;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;end;
{:601}{602:}procedure dvifontdef(f:internalfontnumber);
var k:poolpointer;begin begin dvibuf[dviptr]:=243;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;begin dvibuf[dviptr]:=f-1;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=fontcheck[f].b0-0;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=fontcheck[f].b1-0;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=fontcheck[f].b2-0;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=fontcheck[f].b3-0;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;dvifour(fontsize[f]);
dvifour(fontdsize[f]);
begin dvibuf[dviptr]:=(strstart[fontarea[f]+1]-strstart[fontarea[f]]);
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=(strstart[fontname[f]+1]-strstart[fontname[f]]);
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
{603:}for k:=strstart[fontarea[f]]to strstart[fontarea[f]+1]-1 do begin
dvibuf[dviptr]:=strpool[k];dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
for k:=strstart[fontname[f]]to strstart[fontname[f]+1]-1 do begin dvibuf
[dviptr]:=strpool[k];dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;
end{:603};end;{:602}{607:}procedure movement(w:scaled;o:eightbits);
label 10,40,45,2,1;var mstate:smallnumber;p,q:halfword;k:integer;
begin q:=getnode(3);mem[q+1].int:=w;mem[q+2].int:=dvioffset+dviptr;
if o=157 then begin mem[q].hh.rh:=downptr;downptr:=q;
end else begin mem[q].hh.rh:=rightptr;rightptr:=q;end;
{611:}p:=mem[q].hh.rh;mstate:=0;
while p<>0 do begin if mem[p+1].int=w then{612:}case mstate+mem[p].hh.lh
of 3,4,15,16:if mem[p+2].int<dvigone then goto 45 else{613:}begin k:=mem
[p+2].int-dvioffset;if k<0 then k:=k+dvibufsize;dvibuf[k]:=dvibuf[k]+5;
mem[p].hh.lh:=1;goto 40;end{:613};
5,9,11:if mem[p+2].int<dvigone then goto 45 else{614:}begin k:=mem[p+2].
int-dvioffset;if k<0 then k:=k+dvibufsize;dvibuf[k]:=dvibuf[k]+10;
mem[p].hh.lh:=2;goto 40;end{:614};1,2,8,13:goto 40;
others:end{:612}else case mstate+mem[p].hh.lh of 1:mstate:=6;
2:mstate:=12;8,13:goto 45;others:end;p:=mem[p].hh.rh;end;45:{:611};
{610:}mem[q].hh.lh:=3;
if abs(w)>=8388608 then begin begin dvibuf[dviptr]:=o+3;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;dvifour(w);goto 10;
end;if abs(w)>=32768 then begin begin dvibuf[dviptr]:=o+2;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
if w<0 then w:=w+16777216;begin dvibuf[dviptr]:=w div 65536;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;w:=w mod 65536;
goto 2;end;if abs(w)>=128 then begin begin dvibuf[dviptr]:=o+1;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
if w<0 then w:=w+65536;goto 2;end;begin dvibuf[dviptr]:=o;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
if w<0 then w:=w+256;goto 1;2:begin dvibuf[dviptr]:=w div 256;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
1:begin dvibuf[dviptr]:=w mod 256;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;goto 10{:610};
40:{609:}mem[q].hh.lh:=mem[p].hh.lh;
if mem[q].hh.lh=1 then begin begin dvibuf[dviptr]:=o+4;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
while mem[q].hh.rh<>p do begin q:=mem[q].hh.rh;
case mem[q].hh.lh of 3:mem[q].hh.lh:=5;4:mem[q].hh.lh:=6;others:end;end;
end else begin begin dvibuf[dviptr]:=o+9;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
while mem[q].hh.rh<>p do begin q:=mem[q].hh.rh;
case mem[q].hh.lh of 3:mem[q].hh.lh:=4;5:mem[q].hh.lh:=6;others:end;end;
end{:609};10:end;{:607}{615:}procedure prunemovements(l:integer);
label 30,10;var p:halfword;
begin while downptr<>0 do begin if mem[downptr+2].int<l then goto 30;
p:=downptr;downptr:=mem[p].hh.rh;freenode(p,3);end;
30:while rightptr<>0 do begin if mem[rightptr+2].int<l then goto 10;
p:=rightptr;rightptr:=mem[p].hh.rh;freenode(p,3);end;10:end;
{:615}{618:}procedure vlistout;forward;
{:618}{619:}{1368:}procedure specialout(p:halfword);
var oldsetting:0..21;k:poolpointer;
begin if curh<>dvih then begin movement(curh-dvih,143);dvih:=curh;end;
if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
oldsetting:=selector;selector:=21;
showtokenlist(mem[mem[p+1].hh.rh].hh.rh,0,poolsize-poolptr);
selector:=oldsetting;
begin if poolptr+1>poolsize then overflow(258,poolsize-initpoolptr);end;
if(poolptr-strstart[strptr])<256 then begin begin dvibuf[dviptr]:=239;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=(poolptr-strstart[strptr]);dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
end else begin begin dvibuf[dviptr]:=242;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;dvifour((poolptr-strstart[strptr]));
end;
for k:=strstart[strptr]to poolptr-1 do begin dvibuf[dviptr]:=strpool[k];
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
poolptr:=strstart[strptr];end;
{:1368}{1370:}procedure writeout(p:halfword);var oldsetting:0..21;
oldmode:integer;j:smallnumber;q,r:halfword;begin{1371:}q:=getavail;
mem[q].hh.lh:=637;r:=getavail;mem[q].hh.rh:=r;mem[r].hh.lh:=6717;
begintokenlist(q,4);begintokenlist(mem[p+1].hh.rh,16);q:=getavail;
mem[q].hh.lh:=379;begintokenlist(q,4);oldmode:=curlist.modefield;
curlist.modefield:=0;curcs:=writeloc;q:=scantoks(false,true);gettoken;
if curtok<>6717 then{1372:}begin begin if interaction=3 then;
printnl(263);print(1310);end;begin helpptr:=2;helpline[1]:=1311;
helpline[0]:=1023;end;error;repeat gettoken;until curtok=6717;
end{:1372};curlist.modefield:=oldmode;endtokenlist{:1371};
oldsetting:=selector;j:=mem[p+1].hh.lh;
if writeopen[j]then selector:=j else begin if(j=17)and(selector=19)then
selector:=18;printnl(339);end;tokenshow(defref);println;
flushlist(defref);selector:=oldsetting;end;
{:1370}{1373:}procedure outwhat(p:halfword);var j:smallnumber;
begin case mem[p].hh.b1 of 0,1,2:{1374:}if not doingleaders then begin j
:=mem[p+1].hh.lh;
if mem[p].hh.b1=1 then writeout(p)else begin if writeopen[j]then aclose(
writefile[j]);
if mem[p].hh.b1=2 then writeopen[j]:=false else if j<16 then begin
curname:=mem[p+1].hh.rh;curarea:=mem[p+2].hh.lh;curext:=mem[p+2].hh.rh;
if curext=339 then curext:=801;packfilename(curname,curarea,curext);
while not aopenout(writefile[j])do promptfilename(1313,801);
writeopen[j]:=true;end;end;end{:1374};3:specialout(p);4:;
others:confusion(1312)end;end;
{:1373}{1452:}function newedge(s:smallnumber;w:scaled):halfword;
var p:halfword;begin p:=getnode(3);mem[p].hh.b0:=14;mem[p].hh.b1:=s;
mem[p+1].int:=w;mem[p+2].int:=0;newedge:=p;end;
{:1452}{1456:}function reverse(thisbox,t:halfword;var curg:scaled;
var curglue:real):halfword;label 21,15,30;var l:halfword;p:halfword;
q:halfword;gorder:glueord;gsign:0..2;gluetemp:real;m,n:halfword;
begin gorder:=mem[thisbox+5].hh.b1;gsign:=mem[thisbox+5].hh.b0;l:=t;
p:=tempptr;m:=0;n:=0;
while true do begin while p<>0 do{1457:}21:if(p>=himemmin)then repeat f
:=mem[p].hh.b0;c:=mem[p].hh.b1;
curh:=curh+fontinfo[widthbase[f]+fontinfo[charbase[f]+c].qqqq.b0].int;
q:=mem[p].hh.rh;mem[p].hh.rh:=l;l:=p;p:=q;
until not(p>=himemmin)else{1458:}begin q:=mem[p].hh.rh;
case mem[p].hh.b0 of 0,1,2,11:rulewd:=mem[p+1].int;
{1459:}10:begin g:=mem[p+1].hh.lh;rulewd:=mem[g+1].int-curg;
if gsign<>0 then begin if gsign=1 then begin if mem[g].hh.b0=gorder then
begin curglue:=curglue+mem[g+2].int;gluetemp:=mem[thisbox+6].gr*curglue;
if gluetemp>1000000000.0 then gluetemp:=1000000000.0 else if gluetemp<
-1000000000.0 then gluetemp:=-1000000000.0;curg:=round(gluetemp);end;
end else if mem[g].hh.b1=gorder then begin curglue:=curglue-mem[g+3].int
;gluetemp:=mem[thisbox+6].gr*curglue;
if gluetemp>1000000000.0 then gluetemp:=1000000000.0 else if gluetemp<
-1000000000.0 then gluetemp:=-1000000000.0;curg:=round(gluetemp);end;
end;rulewd:=rulewd+curg;
{1430:}if(((gsign=1)and(mem[g].hh.b0=gorder))or((gsign=2)and(mem[g].hh.
b1=gorder)))then begin begin if mem[g].hh.rh=0 then freenode(g,4)else
mem[g].hh.rh:=mem[g].hh.rh-1;end;
if mem[p].hh.b1<100 then begin mem[p].hh.b0:=11;mem[p+1].int:=rulewd;
end else begin g:=getnode(4);mem[g].hh.b0:=4;mem[g].hh.b1:=4;
mem[g+1].int:=rulewd;mem[g+2].int:=0;mem[g+3].int:=0;mem[p+1].hh.lh:=g;
end;end{:1430};end;{:1459}{1460:}6:begin flushnodelist(mem[p+1].hh.rh);
tempptr:=p;p:=getavail;mem[p]:=mem[tempptr+1];mem[p].hh.rh:=q;
freenode(tempptr,2);goto 21;end;
{:1460}{1461:}9:begin rulewd:=mem[p+1].int;
if odd(mem[p].hh.b1)then if mem[LRptr].hh.lh<>(4*(mem[p].hh.b1 div 4)+3)
then begin mem[p].hh.b0:=11;LRproblems:=LRproblems+1;
end else begin begin tempptr:=LRptr;LRptr:=mem[tempptr].hh.rh;
begin mem[tempptr].hh.rh:=avail;avail:=tempptr;{dynused:=dynused-1;}end;
end;if n>0 then begin n:=n-1;mem[p].hh.b1:=mem[p].hh.b1-1;
end else begin mem[p].hh.b0:=11;
if m>0 then m:=m-1 else{1462:}begin freenode(p,2);mem[t].hh.rh:=q;
mem[t+1].int:=rulewd;mem[t+2].int:=-curh-rulewd;goto 30;end{:1462};end;
end else begin begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[p].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end;
if(n>0)or((mem[p].hh.b1 div 8)<>curdir)then begin n:=n+1;
mem[p].hh.b1:=mem[p].hh.b1+1;end else begin mem[p].hh.b0:=11;m:=m+1;end;
end;end;{:1461}14:confusion(1375);others:goto 15 end;curh:=curh+rulewd;
15:mem[p].hh.rh:=l;
if mem[p].hh.b0=11 then if(rulewd=0)or(l=0)then begin freenode(p,2);
p:=l;end;l:=p;p:=q;end{:1458}{:1457};
if(t=0)and(m=0)and(n=0)then goto 30;p:=newmath(0,mem[LRptr].hh.lh);
LRproblems:=LRproblems+10000;end;30:reverse:=l;end;
{:1456}procedure hlistout;label 21,13,14,15;var baseline:scaled;
leftedge:scaled;saveh,savev:scaled;thisbox:halfword;gorder:glueord;
gsign:0..2;p:halfword;saveloc:integer;leaderbox:halfword;
leaderwd:scaled;lx:scaled;outerdoingleaders:boolean;edge:scaled;
prevp:halfword;gluetemp:real;curglue:real;curg:scaled;begin curg:=0;
curglue:=0.0;thisbox:=tempptr;gorder:=mem[thisbox+5].hh.b1;
gsign:=mem[thisbox+5].hh.b0;p:=mem[thisbox+5].hh.rh;curs:=curs+1;
if curs>0 then begin dvibuf[dviptr]:=141;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;if curs>maxpush then maxpush:=curs;
saveloc:=dvioffset+dviptr;baseline:=curv;prevp:=thisbox+5;
{1447:}if(eTeXmode=1)then begin{1443:}begin tempptr:=getavail;
mem[tempptr].hh.lh:=0;mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;
end{:1443};
if(mem[thisbox].hh.b1-0)=2 then if curdir=1 then begin curdir:=0;
curh:=curh-mem[thisbox+1].int;end else mem[thisbox].hh.b1:=0;
if(curdir=1)and((mem[thisbox].hh.b1-0)<>1)then{1454:}begin saveh:=curh;
tempptr:=p;p:=newkern(0);mem[prevp].hh.rh:=p;curh:=0;
mem[p].hh.rh:=reverse(thisbox,0,curg,curglue);mem[p+1].int:=-curh;
curh:=saveh;mem[thisbox].hh.b1:=1;end{:1454};end{:1447};leftedge:=curh;
while p<>0 do{620:}21:if(p>=himemmin)then begin if curh<>dvih then begin
movement(curh-dvih,143);dvih:=curh;end;
if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
repeat f:=mem[p].hh.b0;c:=mem[p].hh.b1;
if f<>dvif then{621:}begin if not fontused[f]then begin dvifontdef(f);
fontused[f]:=true;end;if f<=64 then begin dvibuf[dviptr]:=f+170;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;
end else begin begin dvibuf[dviptr]:=235;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;begin dvibuf[dviptr]:=f-1;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;end;dvif:=f;
end{:621};if c>=128 then begin dvibuf[dviptr]:=128;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;begin dvibuf[dviptr]:=c-0;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
curh:=curh+fontinfo[widthbase[f]+fontinfo[charbase[f]+c].qqqq.b0].int;
prevp:=mem[prevp].hh.rh;p:=mem[p].hh.rh;until not(p>=himemmin);
dvih:=curh;
end else{622:}begin case mem[p].hh.b0 of 0,1:{623:}if mem[p+5].hh.rh=0
then curh:=curh+mem[p+1].int else begin saveh:=dvih;savev:=dviv;
curv:=baseline+mem[p+4].int;tempptr:=p;edge:=curh+mem[p+1].int;
if curdir=1 then curh:=edge;
if mem[p].hh.b0=1 then vlistout else hlistout;dvih:=saveh;dviv:=savev;
curh:=edge;curv:=baseline;end{:623};2:begin ruleht:=mem[p+3].int;
ruledp:=mem[p+2].int;rulewd:=mem[p+1].int;goto 14;end;
8:{1367:}outwhat(p){:1367};10:{625:}begin g:=mem[p+1].hh.lh;
rulewd:=mem[g+1].int-curg;
if gsign<>0 then begin if gsign=1 then begin if mem[g].hh.b0=gorder then
begin curglue:=curglue+mem[g+2].int;gluetemp:=mem[thisbox+6].gr*curglue;
if gluetemp>1000000000.0 then gluetemp:=1000000000.0 else if gluetemp<
-1000000000.0 then gluetemp:=-1000000000.0;curg:=round(gluetemp);end;
end else if mem[g].hh.b1=gorder then begin curglue:=curglue-mem[g+3].int
;gluetemp:=mem[thisbox+6].gr*curglue;
if gluetemp>1000000000.0 then gluetemp:=1000000000.0 else if gluetemp<
-1000000000.0 then gluetemp:=-1000000000.0;curg:=round(gluetemp);end;
end;rulewd:=rulewd+curg;
if(eTeXmode=1)then{1430:}if(((gsign=1)and(mem[g].hh.b0=gorder))or((gsign
=2)and(mem[g].hh.b1=gorder)))then begin begin if mem[g].hh.rh=0 then
freenode(g,4)else mem[g].hh.rh:=mem[g].hh.rh-1;end;
if mem[p].hh.b1<100 then begin mem[p].hh.b0:=11;mem[p+1].int:=rulewd;
end else begin g:=getnode(4);mem[g].hh.b0:=4;mem[g].hh.b1:=4;
mem[g+1].int:=rulewd;mem[g+2].int:=0;mem[g+3].int:=0;mem[p+1].hh.lh:=g;
end;end{:1430};
if mem[p].hh.b1>=100 then{626:}begin leaderbox:=mem[p+1].hh.rh;
if mem[leaderbox].hh.b0=2 then begin ruleht:=mem[leaderbox+3].int;
ruledp:=mem[leaderbox+2].int;goto 14;end;leaderwd:=mem[leaderbox+1].int;
if(leaderwd>0)and(rulewd>0)then begin rulewd:=rulewd+10;
if curdir=1 then curh:=curh-10;edge:=curh+rulewd;lx:=0;
{627:}if mem[p].hh.b1=100 then begin saveh:=curh;
curh:=leftedge+leaderwd*((curh-leftedge)div leaderwd);
if curh<saveh then curh:=curh+leaderwd;
end else begin lq:=rulewd div leaderwd;lr:=rulewd mod leaderwd;
if mem[p].hh.b1=101 then curh:=curh+(lr div 2)else begin lx:=lr div(lq+1
);curh:=curh+((lr-(lq-1)*lx)div 2);end;end{:627};
while curh+leaderwd<=edge do{628:}begin curv:=baseline+mem[leaderbox+4].
int;if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
savev:=dviv;if curh<>dvih then begin movement(curh-dvih,143);dvih:=curh;
end;saveh:=dvih;tempptr:=leaderbox;if curdir=1 then curh:=curh+leaderwd;
outerdoingleaders:=doingleaders;doingleaders:=true;
if mem[leaderbox].hh.b0=1 then vlistout else hlistout;
doingleaders:=outerdoingleaders;dviv:=savev;dvih:=saveh;curv:=baseline;
curh:=saveh+leaderwd+lx;end{:628};
if curdir=1 then curh:=edge else curh:=edge-10;goto 15;end;end{:626};
goto 13;end{:625};11:curh:=curh+mem[p+1].int;
9:{1449:}begin if(eTeXmode=1)then{1450:}begin if odd(mem[p].hh.b1)then
if mem[LRptr].hh.lh=(4*(mem[p].hh.b1 div 4)+3)then begin tempptr:=LRptr;
LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;
end else begin if mem[p].hh.b1>4 then LRproblems:=LRproblems+1;
end else begin begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[p].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end;
if(mem[p].hh.b1 div 8)<>curdir then{1455:}begin saveh:=curh;
tempptr:=mem[p].hh.rh;rulewd:=mem[p+1].int;freenode(p,2);
curdir:=1-curdir;p:=newedge(curdir,rulewd);mem[prevp].hh.rh:=p;
curh:=curh-leftedge+rulewd;
mem[p].hh.rh:=reverse(thisbox,newedge(1-curdir,0),curg,curglue);
mem[p+2].int:=curh;curdir:=1-curdir;curh:=saveh;goto 21;end{:1455};end;
mem[p].hh.b0:=11;end{:1450};curh:=curh+mem[p+1].int;end{:1449};
6:{652:}begin mem[29988]:=mem[p+1];mem[29988].hh.rh:=mem[p].hh.rh;
p:=29988;goto 21;end{:652};{1453:}14:begin curh:=curh+mem[p+1].int;
leftedge:=curh+mem[p+2].int;curdir:=mem[p].hh.b1;end;{:1453}others:end;
goto 15;14:{624:}if(ruleht=-1073741824)then ruleht:=mem[thisbox+3].int;
if(ruledp=-1073741824)then ruledp:=mem[thisbox+2].int;
ruleht:=ruleht+ruledp;
if(ruleht>0)and(rulewd>0)then begin if curh<>dvih then begin movement(
curh-dvih,143);dvih:=curh;end;curv:=baseline+ruledp;
if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
begin dvibuf[dviptr]:=132;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;dvifour(ruleht);dvifour(rulewd);
curv:=baseline;dvih:=dvih+rulewd;end{:624};13:curh:=curh+rulewd;
15:prevp:=p;p:=mem[p].hh.rh;end{:622}{:620};
{1448:}if(eTeXmode=1)then begin{1451:}begin while mem[LRptr].hh.lh<>0 do
begin if mem[LRptr].hh.lh>4 then LRproblems:=LRproblems+10000;
begin tempptr:=LRptr;LRptr:=mem[tempptr].hh.rh;
begin mem[tempptr].hh.rh:=avail;avail:=tempptr;{dynused:=dynused-1;}end;
end;end;begin tempptr:=LRptr;LRptr:=mem[tempptr].hh.rh;
begin mem[tempptr].hh.rh:=avail;avail:=tempptr;{dynused:=dynused-1;}end;
end;end{:1451};if(mem[thisbox].hh.b1-0)=2 then curdir:=1;end{:1448};
prunemovements(saveloc);if curs>0 then dvipop(saveloc);curs:=curs-1;end;
{:619}{629:}procedure vlistout;label 13,14,15;var leftedge:scaled;
topedge:scaled;saveh,savev:scaled;thisbox:halfword;gorder:glueord;
gsign:0..2;p:halfword;saveloc:integer;leaderbox:halfword;
leaderht:scaled;lx:scaled;outerdoingleaders:boolean;edge:scaled;
gluetemp:real;curglue:real;curg:scaled;begin curg:=0;curglue:=0.0;
thisbox:=tempptr;gorder:=mem[thisbox+5].hh.b1;
gsign:=mem[thisbox+5].hh.b0;p:=mem[thisbox+5].hh.rh;curs:=curs+1;
if curs>0 then begin dvibuf[dviptr]:=141;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;if curs>maxpush then maxpush:=curs;
saveloc:=dvioffset+dviptr;leftedge:=curh;curv:=curv-mem[thisbox+3].int;
topedge:=curv;
while p<>0 do{630:}begin if(p>=himemmin)then confusion(838)else{631:}
begin case mem[p].hh.b0 of 0,1:{632:}if mem[p+5].hh.rh=0 then curv:=curv
+mem[p+3].int+mem[p+2].int else begin curv:=curv+mem[p+3].int;
if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
saveh:=dvih;savev:=dviv;
if curdir=1 then curh:=leftedge-mem[p+4].int else curh:=leftedge+mem[p+4
].int;tempptr:=p;if mem[p].hh.b0=1 then vlistout else hlistout;
dvih:=saveh;dviv:=savev;curv:=savev+mem[p+2].int;curh:=leftedge;
end{:632};2:begin ruleht:=mem[p+3].int;ruledp:=mem[p+2].int;
rulewd:=mem[p+1].int;goto 14;end;8:{1366:}outwhat(p){:1366};
10:{634:}begin g:=mem[p+1].hh.lh;ruleht:=mem[g+1].int-curg;
if gsign<>0 then begin if gsign=1 then begin if mem[g].hh.b0=gorder then
begin curglue:=curglue+mem[g+2].int;gluetemp:=mem[thisbox+6].gr*curglue;
if gluetemp>1000000000.0 then gluetemp:=1000000000.0 else if gluetemp<
-1000000000.0 then gluetemp:=-1000000000.0;curg:=round(gluetemp);end;
end else if mem[g].hh.b1=gorder then begin curglue:=curglue-mem[g+3].int
;gluetemp:=mem[thisbox+6].gr*curglue;
if gluetemp>1000000000.0 then gluetemp:=1000000000.0 else if gluetemp<
-1000000000.0 then gluetemp:=-1000000000.0;curg:=round(gluetemp);end;
end;ruleht:=ruleht+curg;
if mem[p].hh.b1>=100 then{635:}begin leaderbox:=mem[p+1].hh.rh;
if mem[leaderbox].hh.b0=2 then begin rulewd:=mem[leaderbox+1].int;
ruledp:=0;goto 14;end;
leaderht:=mem[leaderbox+3].int+mem[leaderbox+2].int;
if(leaderht>0)and(ruleht>0)then begin ruleht:=ruleht+10;
edge:=curv+ruleht;lx:=0;
{636:}if mem[p].hh.b1=100 then begin savev:=curv;
curv:=topedge+leaderht*((curv-topedge)div leaderht);
if curv<savev then curv:=curv+leaderht;
end else begin lq:=ruleht div leaderht;lr:=ruleht mod leaderht;
if mem[p].hh.b1=101 then curv:=curv+(lr div 2)else begin lx:=lr div(lq+1
);curv:=curv+((lr-(lq-1)*lx)div 2);end;end{:636};
while curv+leaderht<=edge do{637:}begin if curdir=1 then curh:=leftedge-
mem[leaderbox+4].int else curh:=leftedge+mem[leaderbox+4].int;
if curh<>dvih then begin movement(curh-dvih,143);dvih:=curh;end;
saveh:=dvih;curv:=curv+mem[leaderbox+3].int;
if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
savev:=dviv;tempptr:=leaderbox;outerdoingleaders:=doingleaders;
doingleaders:=true;
if mem[leaderbox].hh.b0=1 then vlistout else hlistout;
doingleaders:=outerdoingleaders;dviv:=savev;dvih:=saveh;curh:=leftedge;
curv:=savev-mem[leaderbox+3].int+leaderht+lx;end{:637};curv:=edge-10;
goto 15;end;end{:635};goto 13;end{:634};11:curv:=curv+mem[p+1].int;
others:end;goto 15;
14:{633:}if(rulewd=-1073741824)then rulewd:=mem[thisbox+1].int;
ruleht:=ruleht+ruledp;curv:=curv+ruleht;
if(ruleht>0)and(rulewd>0)then begin if curdir=1 then curh:=curh-rulewd;
if curh<>dvih then begin movement(curh-dvih,143);dvih:=curh;end;
if curv<>dviv then begin movement(curv-dviv,157);dviv:=curv;end;
begin dvibuf[dviptr]:=137;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;dvifour(ruleht);dvifour(rulewd);
curh:=leftedge;end;goto 15{:633};13:curv:=curv+ruleht;end{:631};
15:p:=mem[p].hh.rh;end{:630};prunemovements(saveloc);
if curs>0 then dvipop(saveloc);curs:=curs-1;end;
{:629}{638:}procedure shipout(p:halfword);label 30;var pageloc:integer;
j,k:0..9;s:poolpointer;oldsetting:0..21;
begin if eqtb[5302].int>0 then begin printnl(339);println;print(839);
end;if termoffset>maxprintline-9 then println else if(termoffset>0)or(
fileoffset>0)then printchar(32);printchar(91);j:=9;
while(eqtb[5333+j].int=0)and(j>0)do j:=j-1;
for k:=0 to j do begin printint(eqtb[5333+k].int);
if k<j then printchar(46);end;break(termout);
if eqtb[5302].int>0 then begin printchar(93);begindiagnostic;showbox(p);
enddiagnostic(true);end;
{640:}{641:}if(mem[p+3].int>1073741823)or(mem[p+2].int>1073741823)or(mem
[p+3].int+mem[p+2].int+eqtb[5864].int>1073741823)or(mem[p+1].int+eqtb[
5863].int>1073741823)then begin begin if interaction=3 then;
printnl(263);print(843);end;begin helpptr:=2;helpline[1]:=844;
helpline[0]:=845;end;error;
if eqtb[5302].int<=0 then begin begindiagnostic;printnl(846);showbox(p);
enddiagnostic(true);end;goto 30;end;
if mem[p+3].int+mem[p+2].int+eqtb[5864].int>maxv then maxv:=mem[p+3].int
+mem[p+2].int+eqtb[5864].int;
if mem[p+1].int+eqtb[5863].int>maxh then maxh:=mem[p+1].int+eqtb[5863].
int{:641};{617:}dvih:=0;dviv:=0;curh:=eqtb[5863].int;dvif:=0;
if outputfilename=0 then begin if jobname=0 then openlogfile;
packjobname(804);while not bopenout(dvifile)do promptfilename(805,804);
outputfilename:=bmakenamestring(dvifile);end;
if totalpages=0 then begin begin dvibuf[dviptr]:=247;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;begin dvibuf[dviptr]:=2;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;dvifour(25400000);
dvifour(473628672);preparemag;dvifour(eqtb[5285].int);
oldsetting:=selector;selector:=21;print(837);printint(eqtb[5291].int);
printchar(46);printtwo(eqtb[5290].int);printchar(46);
printtwo(eqtb[5289].int);printchar(58);printtwo(eqtb[5288].int div 60);
printtwo(eqtb[5288].int mod 60);selector:=oldsetting;
begin dvibuf[dviptr]:=(poolptr-strstart[strptr]);dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
for s:=strstart[strptr]to poolptr-1 do begin dvibuf[dviptr]:=strpool[s];
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
poolptr:=strstart[strptr];end{:617};pageloc:=dvioffset+dviptr;
begin dvibuf[dviptr]:=139;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
for k:=0 to 9 do dvifour(eqtb[5333+k].int);dvifour(lastbop);
lastbop:=pageloc;curv:=mem[p+3].int+eqtb[5864].int;tempptr:=p;
if mem[p].hh.b0=1 then vlistout else hlistout;begin dvibuf[dviptr]:=140;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;
totalpages:=totalpages+1;curs:=-1;30:{:640};
if(eTeXmode=1)then{1463:}begin if LRproblems>0 then begin{1446:}begin
println;printnl(1372);printint(LRproblems div 10000);print(1373);
printint(LRproblems mod 10000);print(1374);LRproblems:=0;end{:1446};
printchar(41);println;end;if(LRptr<>0)or(curdir<>0)then confusion(1376);
end{:1463};if eqtb[5302].int<=0 then printchar(93);deadcycles:=0;
break(termout);{639:}{if eqtb[5299].int>1 then begin printnl(840);
printint(varused);printchar(38);printint(dynused);printchar(59);end;}
flushnodelist(p);{if eqtb[5299].int>1 then begin print(841);
printint(varused);printchar(38);printint(dynused);print(842);
printint(himemmin-lomemmax-1);println;end;}{:639};end;
{:638}{645:}procedure scanspec(c:groupcode;threecodes:boolean);label 40;
var s:integer;speccode:0..1;
begin if threecodes then s:=savestack[saveptr+0].int;
if scankeyword(852)then speccode:=0 else if scankeyword(853)then
speccode:=1 else begin speccode:=1;curval:=0;goto 40;end;
scandimen(false,false,false);
40:if threecodes then begin savestack[saveptr+0].int:=s;
saveptr:=saveptr+1;end;savestack[saveptr+0].int:=speccode;
savestack[saveptr+1].int:=curval;saveptr:=saveptr+2;newsavelevel(c);
scanleftbrace;end;{:645}{649:}function hpack(p:halfword;w:scaled;
m:smallnumber):halfword;label 21,50,10;var r:halfword;q:halfword;
h,d,x:scaled;s:scaled;g:halfword;o:glueord;f:internalfontnumber;
i:fourquarters;hd:eightbits;begin lastbadness:=0;r:=getnode(7);
mem[r].hh.b0:=0;mem[r].hh.b1:=0;mem[r+4].int:=0;q:=r+5;mem[q].hh.rh:=p;
h:=0;{650:}d:=0;x:=0;totalstretch[0]:=0;totalshrink[0]:=0;
totalstretch[1]:=0;totalshrink[1]:=0;totalstretch[2]:=0;
totalshrink[2]:=0;totalstretch[3]:=0;totalshrink[3]:=0{:650};
if(eqtb[5332].int>0)then{1443:}begin tempptr:=getavail;
mem[tempptr].hh.lh:=0;mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;
end{:1443};
while p<>0 do{651:}begin 21:while(p>=himemmin)do{654:}begin f:=mem[p].hh
.b0;i:=fontinfo[charbase[f]+mem[p].hh.b1].qqqq;hd:=i.b1-0;
x:=x+fontinfo[widthbase[f]+i.b0].int;
s:=fontinfo[heightbase[f]+(hd)div 16].int;if s>h then h:=s;
s:=fontinfo[depthbase[f]+(hd)mod 16].int;if s>d then d:=s;
p:=mem[p].hh.rh;end{:654};
if p<>0 then begin case mem[p].hh.b0 of 0,1,2,13:{653:}begin x:=x+mem[p
+1].int;if mem[p].hh.b0>=2 then s:=0 else s:=mem[p+4].int;
if mem[p+3].int-s>h then h:=mem[p+3].int-s;
if mem[p+2].int+s>d then d:=mem[p+2].int+s;end{:653};
3,4,5:if adjusttail<>0 then{655:}begin while mem[q].hh.rh<>p do q:=mem[q
].hh.rh;
if mem[p].hh.b0=5 then begin mem[adjusttail].hh.rh:=mem[p+1].int;
while mem[adjusttail].hh.rh<>0 do adjusttail:=mem[adjusttail].hh.rh;
p:=mem[p].hh.rh;freenode(mem[q].hh.rh,2);
end else begin mem[adjusttail].hh.rh:=p;adjusttail:=p;p:=mem[p].hh.rh;
end;mem[q].hh.rh:=p;p:=q;end{:655};8:{1360:}{:1360};
10:{656:}begin g:=mem[p+1].hh.lh;x:=x+mem[g+1].int;o:=mem[g].hh.b0;
totalstretch[o]:=totalstretch[o]+mem[g+2].int;o:=mem[g].hh.b1;
totalshrink[o]:=totalshrink[o]+mem[g+3].int;
if mem[p].hh.b1>=100 then begin g:=mem[p+1].hh.rh;
if mem[g+3].int>h then h:=mem[g+3].int;
if mem[g+2].int>d then d:=mem[g+2].int;end;end{:656};
11:x:=x+mem[p+1].int;9:begin x:=x+mem[p+1].int;
if(eqtb[5332].int>0)then{1444:}if odd(mem[p].hh.b1)then if mem[LRptr].hh
.lh=(4*(mem[p].hh.b1 div 4)+3)then begin tempptr:=LRptr;
LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;
end else begin LRproblems:=LRproblems+1;mem[p].hh.b0:=11;
mem[p].hh.b1:=1;end else begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[p].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end{:1444};end;
6:{652:}begin mem[29988]:=mem[p+1];mem[29988].hh.rh:=mem[p].hh.rh;
p:=29988;goto 21;end{:652};others:end;p:=mem[p].hh.rh;end;end{:651};
if adjusttail<>0 then mem[adjusttail].hh.rh:=0;mem[r+3].int:=h;
mem[r+2].int:=d;{657:}if m=1 then w:=x+w;mem[r+1].int:=w;x:=w-x;
if x=0 then begin mem[r+5].hh.b0:=0;mem[r+5].hh.b1:=0;mem[r+6].gr:=0.0;
goto 10;
end else if x>0 then{658:}begin{659:}if totalstretch[3]<>0 then o:=3
else if totalstretch[2]<>0 then o:=2 else if totalstretch[1]<>0 then o:=
1 else o:=0{:659};mem[r+5].hh.b1:=o;mem[r+5].hh.b0:=1;
if totalstretch[o]<>0 then mem[r+6].gr:=x/totalstretch[o]else begin mem[
r+5].hh.b0:=0;mem[r+6].gr:=0.0;end;
if o=0 then if mem[r+5].hh.rh<>0 then{660:}begin lastbadness:=badness(x,
totalstretch[0]);if lastbadness>eqtb[5294].int then begin println;
if lastbadness>100 then printnl(854)else printnl(855);print(856);
printint(lastbadness);goto 50;end;end{:660};goto 10;
end{:658}else{664:}begin{665:}if totalshrink[3]<>0 then o:=3 else if
totalshrink[2]<>0 then o:=2 else if totalshrink[1]<>0 then o:=1 else o:=
0{:665};mem[r+5].hh.b1:=o;mem[r+5].hh.b0:=2;
if totalshrink[o]<>0 then mem[r+6].gr:=(-x)/totalshrink[o]else begin mem
[r+5].hh.b0:=0;mem[r+6].gr:=0.0;end;
if(totalshrink[o]<-x)and(o=0)and(mem[r+5].hh.rh<>0)then begin
lastbadness:=1000000;mem[r+6].gr:=1.0;
{666:}if(-x-totalshrink[0]>eqtb[5853].int)or(eqtb[5294].int<100)then
begin if(eqtb[5861].int>0)and(-x-totalshrink[0]>eqtb[5853].int)then
begin while mem[q].hh.rh<>0 do q:=mem[q].hh.rh;mem[q].hh.rh:=newrule;
mem[mem[q].hh.rh+1].int:=eqtb[5861].int;end;println;printnl(862);
printscaled(-x-totalshrink[0]);print(863);goto 50;end{:666};
end else if o=0 then if mem[r+5].hh.rh<>0 then{667:}begin lastbadness:=
badness(-x,totalshrink[0]);
if lastbadness>eqtb[5294].int then begin println;printnl(864);
printint(lastbadness);goto 50;end;end{:667};goto 10;end{:664}{:657};
50:{663:}if outputactive then print(857)else begin if packbeginline<>0
then begin if packbeginline>0 then print(858)else print(859);
printint(abs(packbeginline));print(860);end else print(861);
printint(line);end;println;fontinshortdisplay:=0;
shortdisplay(mem[r+5].hh.rh);println;begindiagnostic;showbox(r);
enddiagnostic(true){:663};
10:if(eqtb[5332].int>0)then{1445:}begin if mem[LRptr].hh.lh<>0 then
begin while mem[q].hh.rh<>0 do q:=mem[q].hh.rh;repeat tempptr:=q;
q:=newmath(0,mem[LRptr].hh.lh);mem[tempptr].hh.rh:=q;
LRproblems:=LRproblems+10000;begin tempptr:=LRptr;
LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;end;until mem[LRptr].hh.lh=0;
end;if LRproblems>0 then begin{1446:}begin println;printnl(1372);
printint(LRproblems div 10000);print(1373);
printint(LRproblems mod 10000);print(1374);LRproblems:=0;end{:1446};
goto 50;end;begin tempptr:=LRptr;LRptr:=mem[tempptr].hh.rh;
begin mem[tempptr].hh.rh:=avail;avail:=tempptr;{dynused:=dynused-1;}end;
end;if LRptr<>0 then confusion(1371);end{:1445};hpack:=r;end;
{:649}{668:}function vpackage(p:halfword;h:scaled;m:smallnumber;
l:scaled):halfword;label 50,10;var r:halfword;w,d,x:scaled;s:scaled;
g:halfword;o:glueord;begin lastbadness:=0;r:=getnode(7);mem[r].hh.b0:=1;
mem[r].hh.b1:=0;mem[r+4].int:=0;mem[r+5].hh.rh:=p;w:=0;{650:}d:=0;x:=0;
totalstretch[0]:=0;totalshrink[0]:=0;totalstretch[1]:=0;
totalshrink[1]:=0;totalstretch[2]:=0;totalshrink[2]:=0;
totalstretch[3]:=0;totalshrink[3]:=0{:650};
while p<>0 do{669:}begin if(p>=himemmin)then confusion(865)else case mem
[p].hh.b0 of 0,1,2,13:{670:}begin x:=x+d+mem[p+3].int;d:=mem[p+2].int;
if mem[p].hh.b0>=2 then s:=0 else s:=mem[p+4].int;
if mem[p+1].int+s>w then w:=mem[p+1].int+s;end{:670};8:{1359:}{:1359};
10:{671:}begin x:=x+d;d:=0;g:=mem[p+1].hh.lh;x:=x+mem[g+1].int;
o:=mem[g].hh.b0;totalstretch[o]:=totalstretch[o]+mem[g+2].int;
o:=mem[g].hh.b1;totalshrink[o]:=totalshrink[o]+mem[g+3].int;
if mem[p].hh.b1>=100 then begin g:=mem[p+1].hh.rh;
if mem[g+1].int>w then w:=mem[g+1].int;end;end{:671};
11:begin x:=x+d+mem[p+1].int;d:=0;end;others:end;p:=mem[p].hh.rh;
end{:669};mem[r+1].int:=w;if d>l then begin x:=x+d-l;mem[r+2].int:=l;
end else mem[r+2].int:=d;{672:}if m=1 then h:=x+h;mem[r+3].int:=h;
x:=h-x;if x=0 then begin mem[r+5].hh.b0:=0;mem[r+5].hh.b1:=0;
mem[r+6].gr:=0.0;goto 10;
end else if x>0 then{673:}begin{659:}if totalstretch[3]<>0 then o:=3
else if totalstretch[2]<>0 then o:=2 else if totalstretch[1]<>0 then o:=
1 else o:=0{:659};mem[r+5].hh.b1:=o;mem[r+5].hh.b0:=1;
if totalstretch[o]<>0 then mem[r+6].gr:=x/totalstretch[o]else begin mem[
r+5].hh.b0:=0;mem[r+6].gr:=0.0;end;
if o=0 then if mem[r+5].hh.rh<>0 then{674:}begin lastbadness:=badness(x,
totalstretch[0]);if lastbadness>eqtb[5295].int then begin println;
if lastbadness>100 then printnl(854)else printnl(855);print(866);
printint(lastbadness);goto 50;end;end{:674};goto 10;
end{:673}else{676:}begin{665:}if totalshrink[3]<>0 then o:=3 else if
totalshrink[2]<>0 then o:=2 else if totalshrink[1]<>0 then o:=1 else o:=
0{:665};mem[r+5].hh.b1:=o;mem[r+5].hh.b0:=2;
if totalshrink[o]<>0 then mem[r+6].gr:=(-x)/totalshrink[o]else begin mem
[r+5].hh.b0:=0;mem[r+6].gr:=0.0;end;
if(totalshrink[o]<-x)and(o=0)and(mem[r+5].hh.rh<>0)then begin
lastbadness:=1000000;mem[r+6].gr:=1.0;
{677:}if(-x-totalshrink[0]>eqtb[5854].int)or(eqtb[5295].int<100)then
begin println;printnl(867);printscaled(-x-totalshrink[0]);print(868);
goto 50;end{:677};
end else if o=0 then if mem[r+5].hh.rh<>0 then{678:}begin lastbadness:=
badness(-x,totalshrink[0]);
if lastbadness>eqtb[5295].int then begin println;printnl(869);
printint(lastbadness);goto 50;end;end{:678};goto 10;end{:676}{:672};
50:{675:}if outputactive then print(857)else begin if packbeginline<>0
then begin print(859);printint(abs(packbeginline));print(860);
end else print(861);printint(line);println;end;begindiagnostic;
showbox(r);enddiagnostic(true){:675};10:vpackage:=r;end;
{:668}{679:}procedure appendtovlist(b:halfword);var d:scaled;p:halfword;
begin if curlist.auxfield.int>-65536000 then begin d:=mem[eqtb[2883].hh.
rh+1].int-curlist.auxfield.int-mem[b+3].int;
if d<eqtb[5847].int then p:=newparamglue(0)else begin p:=newskipparam(1)
;mem[tempptr+1].int:=d;end;mem[curlist.tailfield].hh.rh:=p;
curlist.tailfield:=p;end;mem[curlist.tailfield].hh.rh:=b;
curlist.tailfield:=b;curlist.auxfield.int:=mem[b+2].int;end;
{:679}{686:}function newnoad:halfword;var p:halfword;
begin p:=getnode(4);mem[p].hh.b0:=16;mem[p].hh.b1:=0;
mem[p+1].hh:=emptyfield;mem[p+3].hh:=emptyfield;mem[p+2].hh:=emptyfield;
newnoad:=p;end;{:686}{688:}function newstyle(s:smallnumber):halfword;
var p:halfword;begin p:=getnode(3);mem[p].hh.b0:=14;mem[p].hh.b1:=s;
mem[p+1].int:=0;mem[p+2].int:=0;newstyle:=p;end;
{:688}{689:}function newchoice:halfword;var p:halfword;
begin p:=getnode(3);mem[p].hh.b0:=15;mem[p].hh.b1:=0;mem[p+1].hh.lh:=0;
mem[p+1].hh.rh:=0;mem[p+2].hh.lh:=0;mem[p+2].hh.rh:=0;newchoice:=p;end;
{:689}{693:}procedure showinfo;begin shownodelist(mem[tempptr].hh.lh);
end;{:693}{704:}function fractionrule(t:scaled):halfword;var p:halfword;
begin p:=newrule;mem[p+3].int:=t;mem[p+2].int:=0;fractionrule:=p;end;
{:704}{705:}function overbar(b:halfword;k,t:scaled):halfword;
var p,q:halfword;begin p:=newkern(k);mem[p].hh.rh:=b;q:=fractionrule(t);
mem[q].hh.rh:=p;p:=newkern(t);mem[p].hh.rh:=q;
overbar:=vpackage(p,0,1,1073741823);end;
{:705}{706:}{709:}function charbox(f:internalfontnumber;
c:quarterword):halfword;var q:fourquarters;hd:eightbits;b,p:halfword;
begin q:=fontinfo[charbase[f]+c].qqqq;hd:=q.b1-0;b:=newnullbox;
mem[b+1].int:=fontinfo[widthbase[f]+q.b0].int+fontinfo[italicbase[f]+(q.
b2-0)div 4].int;mem[b+3].int:=fontinfo[heightbase[f]+(hd)div 16].int;
mem[b+2].int:=fontinfo[depthbase[f]+(hd)mod 16].int;p:=getavail;
mem[p].hh.b1:=c;mem[p].hh.b0:=f;mem[b+5].hh.rh:=p;charbox:=b;end;
{:709}{711:}procedure stackintobox(b:halfword;f:internalfontnumber;
c:quarterword);var p:halfword;begin p:=charbox(f,c);
mem[p].hh.rh:=mem[b+5].hh.rh;mem[b+5].hh.rh:=p;
mem[b+3].int:=mem[p+3].int;end;
{:711}{712:}function heightplusdepth(f:internalfontnumber;
c:quarterword):scaled;var q:fourquarters;hd:eightbits;
begin q:=fontinfo[charbase[f]+c].qqqq;hd:=q.b1-0;
heightplusdepth:=fontinfo[heightbase[f]+(hd)div 16].int+fontinfo[
depthbase[f]+(hd)mod 16].int;end;{:712}function vardelimiter(d:halfword;
s:smallnumber;v:scaled):halfword;label 40,22;var b:halfword;
f,g:internalfontnumber;c,x,y:quarterword;m,n:integer;u:scaled;w:scaled;
q:fourquarters;hd:eightbits;r:fourquarters;z:smallnumber;
largeattempt:boolean;begin f:=0;w:=0;largeattempt:=false;
z:=mem[d].qqqq.b0;x:=mem[d].qqqq.b1;
while true do begin{707:}if(z<>0)or(x<>0)then begin z:=z+s+16;
repeat z:=z-16;g:=eqtb[3940+z].hh.rh;if g<>0 then{708:}begin y:=x;
if(y-0>=fontbc[g])and(y-0<=fontec[g])then begin 22:q:=fontinfo[charbase[
g]+y].qqqq;if(q.b0>0)then begin if((q.b2-0)mod 4)=3 then begin f:=g;
c:=y;goto 40;end;hd:=q.b1-0;
u:=fontinfo[heightbase[g]+(hd)div 16].int+fontinfo[depthbase[g]+(hd)mod
16].int;if u>w then begin f:=g;c:=y;w:=u;if u>=v then goto 40;end;
if((q.b2-0)mod 4)=2 then begin y:=q.b3;goto 22;end;end;end;end{:708};
until z<16;end{:707};if largeattempt then goto 40;largeattempt:=true;
z:=mem[d].qqqq.b2;x:=mem[d].qqqq.b3;end;
40:if f<>0 then{710:}if((q.b2-0)mod 4)=3 then{713:}begin b:=newnullbox;
mem[b].hh.b0:=1;r:=fontinfo[extenbase[f]+q.b3].qqqq;{714:}c:=r.b3;
u:=heightplusdepth(f,c);w:=0;q:=fontinfo[charbase[f]+c].qqqq;
mem[b+1].int:=fontinfo[widthbase[f]+q.b0].int+fontinfo[italicbase[f]+(q.
b2-0)div 4].int;c:=r.b2;if c<>0 then w:=w+heightplusdepth(f,c);c:=r.b1;
if c<>0 then w:=w+heightplusdepth(f,c);c:=r.b0;
if c<>0 then w:=w+heightplusdepth(f,c);n:=0;
if u>0 then while w<v do begin w:=w+u;n:=n+1;if r.b1<>0 then w:=w+u;
end{:714};c:=r.b2;if c<>0 then stackintobox(b,f,c);c:=r.b3;
for m:=1 to n do stackintobox(b,f,c);c:=r.b1;
if c<>0 then begin stackintobox(b,f,c);c:=r.b3;
for m:=1 to n do stackintobox(b,f,c);end;c:=r.b0;
if c<>0 then stackintobox(b,f,c);mem[b+2].int:=w-mem[b+3].int;
end{:713}else b:=charbox(f,c){:710}else begin b:=newnullbox;
mem[b+1].int:=eqtb[5856].int;end;
mem[b+4].int:=half(mem[b+3].int-mem[b+2].int)-fontinfo[22+parambase[eqtb
[3942+s].hh.rh]].int;vardelimiter:=b;end;
{:706}{715:}function rebox(b:halfword;w:scaled):halfword;var p:halfword;
f:internalfontnumber;v:scaled;
begin if(mem[b+1].int<>w)and(mem[b+5].hh.rh<>0)then begin if mem[b].hh.
b0=1 then b:=hpack(b,0,1);p:=mem[b+5].hh.rh;
if((p>=himemmin))and(mem[p].hh.rh=0)then begin f:=mem[p].hh.b0;
v:=fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b0].int
;if v<>mem[b+1].int then mem[p].hh.rh:=newkern(mem[b+1].int-v);end;
freenode(b,7);b:=newglue(12);mem[b].hh.rh:=p;
while mem[p].hh.rh<>0 do p:=mem[p].hh.rh;mem[p].hh.rh:=newglue(12);
rebox:=hpack(b,w,0);end else begin mem[b+1].int:=w;rebox:=b;end;end;
{:715}{716:}function mathglue(g:halfword;m:scaled):halfword;
var p:halfword;n:integer;f:scaled;begin n:=xovern(m,65536);f:=remainder;
if f<0 then begin n:=n-1;f:=f+65536;end;p:=getnode(4);
mem[p+1].int:=multandadd(n,mem[g+1].int,xnoverd(mem[g+1].int,f,65536),
1073741823);mem[p].hh.b0:=mem[g].hh.b0;
if mem[p].hh.b0=0 then mem[p+2].int:=multandadd(n,mem[g+2].int,xnoverd(
mem[g+2].int,f,65536),1073741823)else mem[p+2].int:=mem[g+2].int;
mem[p].hh.b1:=mem[g].hh.b1;
if mem[p].hh.b1=0 then mem[p+3].int:=multandadd(n,mem[g+3].int,xnoverd(
mem[g+3].int,f,65536),1073741823)else mem[p+3].int:=mem[g+3].int;
mathglue:=p;end;{:716}{717:}procedure mathkern(p:halfword;m:scaled);
var n:integer;f:scaled;
begin if mem[p].hh.b1=99 then begin n:=xovern(m,65536);f:=remainder;
if f<0 then begin n:=n-1;f:=f+65536;end;
mem[p+1].int:=multandadd(n,mem[p+1].int,xnoverd(mem[p+1].int,f,65536),
1073741823);mem[p].hh.b1:=1;end;end;{:717}{718:}procedure flushmath;
begin flushnodelist(mem[curlist.headfield].hh.rh);
flushnodelist(curlist.auxfield.int);mem[curlist.headfield].hh.rh:=0;
curlist.tailfield:=curlist.headfield;curlist.auxfield.int:=0;end;
{:718}{720:}procedure mlisttohlist;forward;function cleanbox(p:halfword;
s:smallnumber):halfword;label 40;var q:halfword;savestyle:smallnumber;
x:halfword;r:halfword;
begin case mem[p].hh.rh of 1:begin curmlist:=newnoad;
mem[curmlist+1]:=mem[p];end;2:begin q:=mem[p].hh.lh;goto 40;end;
3:curmlist:=mem[p].hh.lh;others:begin q:=newnullbox;goto 40;end end;
savestyle:=curstyle;curstyle:=s;mlistpenalties:=false;mlisttohlist;
q:=mem[29997].hh.rh;curstyle:=savestyle;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};
40:if(q>=himemmin)or(q=0)then x:=hpack(q,0,1)else if(mem[q].hh.rh=0)and(
mem[q].hh.b0<=1)and(mem[q+4].int=0)then x:=q else x:=hpack(q,0,1);
{721:}q:=mem[x+5].hh.rh;if(q>=himemmin)then begin r:=mem[q].hh.rh;
if r<>0 then if mem[r].hh.rh=0 then if not(r>=himemmin)then if mem[r].hh
.b0=11 then begin freenode(r,2);mem[q].hh.rh:=0;end;end{:721};
cleanbox:=x;end;{:720}{722:}procedure fetch(a:halfword);
begin curc:=mem[a].hh.b1;curf:=eqtb[3940+mem[a].hh.b0+cursize].hh.rh;
if curf=0 then{723:}begin begin if interaction=3 then;printnl(263);
print(339);end;printsize(cursize);printchar(32);printint(mem[a].hh.b0);
print(895);print(curc-0);printchar(41);begin helpptr:=4;
helpline[3]:=896;helpline[2]:=897;helpline[1]:=898;helpline[0]:=899;end;
error;curi:=nullcharacter;mem[a].hh.rh:=0;
end{:723}else begin if(curc-0>=fontbc[curf])and(curc-0<=fontec[curf])
then curi:=fontinfo[charbase[curf]+curc].qqqq else curi:=nullcharacter;
if not((curi.b0>0))then begin charwarning(curf,curc-0);mem[a].hh.rh:=0;
end;end;end;{:722}{726:}{734:}procedure makeover(q:halfword);
begin mem[q+1].hh.lh:=overbar(cleanbox(q+1,2*(curstyle div 2)+1),3*
fontinfo[8+parambase[eqtb[3943+cursize].hh.rh]].int,fontinfo[8+parambase
[eqtb[3943+cursize].hh.rh]].int);mem[q+1].hh.rh:=2;end;
{:734}{735:}procedure makeunder(q:halfword);var p,x,y:halfword;
delta:scaled;begin x:=cleanbox(q+1,curstyle);
p:=newkern(3*fontinfo[8+parambase[eqtb[3943+cursize].hh.rh]].int);
mem[x].hh.rh:=p;
mem[p].hh.rh:=fractionrule(fontinfo[8+parambase[eqtb[3943+cursize].hh.rh
]].int);y:=vpackage(x,0,1,1073741823);
delta:=mem[y+3].int+mem[y+2].int+fontinfo[8+parambase[eqtb[3943+cursize]
.hh.rh]].int;mem[y+3].int:=mem[x+3].int;
mem[y+2].int:=delta-mem[y+3].int;mem[q+1].hh.lh:=y;mem[q+1].hh.rh:=2;
end;{:735}{736:}procedure makevcenter(q:halfword);var v:halfword;
delta:scaled;begin v:=mem[q+1].hh.lh;
if mem[v].hh.b0<>1 then confusion(543);delta:=mem[v+3].int+mem[v+2].int;
mem[v+3].int:=fontinfo[22+parambase[eqtb[3942+cursize].hh.rh]].int+half(
delta);mem[v+2].int:=delta-mem[v+3].int;end;
{:736}{737:}procedure makeradical(q:halfword);var x,y:halfword;
delta,clr:scaled;begin x:=cleanbox(q+1,2*(curstyle div 2)+1);
if curstyle<2 then clr:=fontinfo[8+parambase[eqtb[3943+cursize].hh.rh]].
int+(abs(fontinfo[5+parambase[eqtb[3942+cursize].hh.rh]].int)div 4)else
begin clr:=fontinfo[8+parambase[eqtb[3943+cursize].hh.rh]].int;
clr:=clr+(abs(clr)div 4);end;
y:=vardelimiter(q+4,cursize,mem[x+3].int+mem[x+2].int+clr+fontinfo[8+
parambase[eqtb[3943+cursize].hh.rh]].int);
delta:=mem[y+2].int-(mem[x+3].int+mem[x+2].int+clr);
if delta>0 then clr:=clr+half(delta);mem[y+4].int:=-(mem[x+3].int+clr);
mem[y].hh.rh:=overbar(x,clr,mem[y+3].int);mem[q+1].hh.lh:=hpack(y,0,1);
mem[q+1].hh.rh:=2;end;{:737}{738:}procedure makemathaccent(q:halfword);
label 30,31;var p,x,y:halfword;a:integer;c:quarterword;
f:internalfontnumber;i:fourquarters;s:scaled;h:scaled;delta:scaled;
w:scaled;begin fetch(q+4);if(curi.b0>0)then begin i:=curi;c:=curc;
f:=curf;{741:}s:=0;if mem[q+1].hh.rh=1 then begin fetch(q+1);
if((curi.b2-0)mod 4)=1 then begin a:=ligkernbase[curf]+curi.b3;
curi:=fontinfo[a].qqqq;
if curi.b0>128 then begin a:=ligkernbase[curf]+256*curi.b2+curi.b3
+32768-256*(128);curi:=fontinfo[a].qqqq;end;
while true do begin if curi.b1-0=skewchar[curf]then begin if curi.b2>=
128 then if curi.b0<=128 then s:=fontinfo[kernbase[curf]+256*curi.b2+
curi.b3].int;goto 31;end;if curi.b0>=128 then goto 31;a:=a+curi.b0+1;
curi:=fontinfo[a].qqqq;end;end;end;31:{:741};
x:=cleanbox(q+1,2*(curstyle div 2)+1);w:=mem[x+1].int;h:=mem[x+3].int;
{740:}while true do begin if((i.b2-0)mod 4)<>2 then goto 30;y:=i.b3;
i:=fontinfo[charbase[f]+y].qqqq;if not(i.b0>0)then goto 30;
if fontinfo[widthbase[f]+i.b0].int>w then goto 30;c:=y;end;30:{:740};
if h<fontinfo[5+parambase[f]].int then delta:=h else delta:=fontinfo[5+
parambase[f]].int;
if(mem[q+2].hh.rh<>0)or(mem[q+3].hh.rh<>0)then if mem[q+1].hh.rh=1 then
{742:}begin flushnodelist(x);x:=newnoad;mem[x+1]:=mem[q+1];
mem[x+2]:=mem[q+2];mem[x+3]:=mem[q+3];mem[q+2].hh:=emptyfield;
mem[q+3].hh:=emptyfield;mem[q+1].hh.rh:=3;mem[q+1].hh.lh:=x;
x:=cleanbox(q+1,curstyle);delta:=delta+mem[x+3].int-h;h:=mem[x+3].int;
end{:742};y:=charbox(f,c);mem[y+4].int:=s+half(w-mem[y+1].int);
mem[y+1].int:=0;p:=newkern(-delta);mem[p].hh.rh:=x;mem[y].hh.rh:=p;
y:=vpackage(y,0,1,1073741823);mem[y+1].int:=mem[x+1].int;
if mem[y+3].int<h then{739:}begin p:=newkern(h-mem[y+3].int);
mem[p].hh.rh:=mem[y+5].hh.rh;mem[y+5].hh.rh:=p;mem[y+3].int:=h;
end{:739};mem[q+1].hh.lh:=y;mem[q+1].hh.rh:=2;end;end;
{:738}{743:}procedure makefraction(q:halfword);var p,v,x,y,z:halfword;
delta,delta1,delta2,shiftup,shiftdown,clr:scaled;
begin if mem[q+1].int=1073741824 then mem[q+1].int:=fontinfo[8+parambase
[eqtb[3943+cursize].hh.rh]].int;
{744:}x:=cleanbox(q+2,curstyle+2-2*(curstyle div 6));
z:=cleanbox(q+3,2*(curstyle div 2)+3-2*(curstyle div 6));
if mem[x+1].int<mem[z+1].int then x:=rebox(x,mem[z+1].int)else z:=rebox(
z,mem[x+1].int);
if curstyle<2 then begin shiftup:=fontinfo[8+parambase[eqtb[3942+cursize
].hh.rh]].int;
shiftdown:=fontinfo[11+parambase[eqtb[3942+cursize].hh.rh]].int;
end else begin shiftdown:=fontinfo[12+parambase[eqtb[3942+cursize].hh.rh
]].int;
if mem[q+1].int<>0 then shiftup:=fontinfo[9+parambase[eqtb[3942+cursize]
.hh.rh]].int else shiftup:=fontinfo[10+parambase[eqtb[3942+cursize].hh.
rh]].int;end{:744};
if mem[q+1].int=0 then{745:}begin if curstyle<2 then clr:=7*fontinfo[8+
parambase[eqtb[3943+cursize].hh.rh]].int else clr:=3*fontinfo[8+
parambase[eqtb[3943+cursize].hh.rh]].int;
delta:=half(clr-((shiftup-mem[x+2].int)-(mem[z+3].int-shiftdown)));
if delta>0 then begin shiftup:=shiftup+delta;shiftdown:=shiftdown+delta;
end;
end{:745}else{746:}begin if curstyle<2 then clr:=3*mem[q+1].int else clr
:=mem[q+1].int;delta:=half(mem[q+1].int);
delta1:=clr-((shiftup-mem[x+2].int)-(fontinfo[22+parambase[eqtb[3942+
cursize].hh.rh]].int+delta));
delta2:=clr-((fontinfo[22+parambase[eqtb[3942+cursize].hh.rh]].int-delta
)-(mem[z+3].int-shiftdown));if delta1>0 then shiftup:=shiftup+delta1;
if delta2>0 then shiftdown:=shiftdown+delta2;end{:746};
{747:}v:=newnullbox;mem[v].hh.b0:=1;mem[v+3].int:=shiftup+mem[x+3].int;
mem[v+2].int:=mem[z+2].int+shiftdown;mem[v+1].int:=mem[x+1].int;
if mem[q+1].int=0 then begin p:=newkern((shiftup-mem[x+2].int)-(mem[z+3]
.int-shiftdown));mem[p].hh.rh:=z;
end else begin y:=fractionrule(mem[q+1].int);
p:=newkern((fontinfo[22+parambase[eqtb[3942+cursize].hh.rh]].int-delta)-
(mem[z+3].int-shiftdown));mem[y].hh.rh:=p;mem[p].hh.rh:=z;
p:=newkern((shiftup-mem[x+2].int)-(fontinfo[22+parambase[eqtb[3942+
cursize].hh.rh]].int+delta));mem[p].hh.rh:=y;end;mem[x].hh.rh:=p;
mem[v+5].hh.rh:=x{:747};
{748:}if curstyle<2 then delta:=fontinfo[20+parambase[eqtb[3942+cursize]
.hh.rh]].int else delta:=fontinfo[21+parambase[eqtb[3942+cursize].hh.rh]
].int;x:=vardelimiter(q+4,cursize,delta);mem[x].hh.rh:=v;
z:=vardelimiter(q+5,cursize,delta);mem[v].hh.rh:=z;
mem[q+1].int:=hpack(x,0,1){:748};end;
{:743}{749:}function makeop(q:halfword):scaled;var delta:scaled;
p,v,x,y,z:halfword;c:quarterword;i:fourquarters;
shiftup,shiftdown:scaled;
begin if(mem[q].hh.b1=0)and(curstyle<2)then mem[q].hh.b1:=1;
if mem[q+1].hh.rh=1 then begin fetch(q+1);
if(curstyle<2)and(((curi.b2-0)mod 4)=2)then begin c:=curi.b3;
i:=fontinfo[charbase[curf]+c].qqqq;if(i.b0>0)then begin curc:=c;curi:=i;
mem[q+1].hh.b1:=c;end;end;
delta:=fontinfo[italicbase[curf]+(curi.b2-0)div 4].int;
x:=cleanbox(q+1,curstyle);
if(mem[q+3].hh.rh<>0)and(mem[q].hh.b1<>1)then mem[x+1].int:=mem[x+1].int
-delta;
mem[x+4].int:=half(mem[x+3].int-mem[x+2].int)-fontinfo[22+parambase[eqtb
[3942+cursize].hh.rh]].int;mem[q+1].hh.rh:=2;mem[q+1].hh.lh:=x;
end else delta:=0;
if mem[q].hh.b1=1 then{750:}begin x:=cleanbox(q+2,2*(curstyle div 4)+4+(
curstyle mod 2));y:=cleanbox(q+1,curstyle);
z:=cleanbox(q+3,2*(curstyle div 4)+5);v:=newnullbox;mem[v].hh.b0:=1;
mem[v+1].int:=mem[y+1].int;
if mem[x+1].int>mem[v+1].int then mem[v+1].int:=mem[x+1].int;
if mem[z+1].int>mem[v+1].int then mem[v+1].int:=mem[z+1].int;
x:=rebox(x,mem[v+1].int);y:=rebox(y,mem[v+1].int);
z:=rebox(z,mem[v+1].int);mem[x+4].int:=half(delta);
mem[z+4].int:=-mem[x+4].int;mem[v+3].int:=mem[y+3].int;
mem[v+2].int:=mem[y+2].int;
{751:}if mem[q+2].hh.rh=0 then begin freenode(x,7);mem[v+5].hh.rh:=y;
end else begin shiftup:=fontinfo[11+parambase[eqtb[3943+cursize].hh.rh]]
.int-mem[x+2].int;
if shiftup<fontinfo[9+parambase[eqtb[3943+cursize].hh.rh]].int then
shiftup:=fontinfo[9+parambase[eqtb[3943+cursize].hh.rh]].int;
p:=newkern(shiftup);mem[p].hh.rh:=y;mem[x].hh.rh:=p;
p:=newkern(fontinfo[13+parambase[eqtb[3943+cursize].hh.rh]].int);
mem[p].hh.rh:=x;mem[v+5].hh.rh:=p;
mem[v+3].int:=mem[v+3].int+fontinfo[13+parambase[eqtb[3943+cursize].hh.
rh]].int+mem[x+3].int+mem[x+2].int+shiftup;end;
if mem[q+3].hh.rh=0 then freenode(z,7)else begin shiftdown:=fontinfo[12+
parambase[eqtb[3943+cursize].hh.rh]].int-mem[z+3].int;
if shiftdown<fontinfo[10+parambase[eqtb[3943+cursize].hh.rh]].int then
shiftdown:=fontinfo[10+parambase[eqtb[3943+cursize].hh.rh]].int;
p:=newkern(shiftdown);mem[y].hh.rh:=p;mem[p].hh.rh:=z;
p:=newkern(fontinfo[13+parambase[eqtb[3943+cursize].hh.rh]].int);
mem[z].hh.rh:=p;
mem[v+2].int:=mem[v+2].int+fontinfo[13+parambase[eqtb[3943+cursize].hh.
rh]].int+mem[z+3].int+mem[z+2].int+shiftdown;end{:751};mem[q+1].int:=v;
end{:750};makeop:=delta;end;{:749}{752:}procedure makeord(q:halfword);
label 20,10;var a:integer;p,r:halfword;
begin 20:if mem[q+3].hh.rh=0 then if mem[q+2].hh.rh=0 then if mem[q+1].
hh.rh=1 then begin p:=mem[q].hh.rh;
if p<>0 then if(mem[p].hh.b0>=16)and(mem[p].hh.b0<=22)then if mem[p+1].
hh.rh=1 then if mem[p+1].hh.b0=mem[q+1].hh.b0 then begin mem[q+1].hh.rh
:=4;fetch(q+1);
if((curi.b2-0)mod 4)=1 then begin a:=ligkernbase[curf]+curi.b3;
curc:=mem[p+1].hh.b1;curi:=fontinfo[a].qqqq;
if curi.b0>128 then begin a:=ligkernbase[curf]+256*curi.b2+curi.b3
+32768-256*(128);curi:=fontinfo[a].qqqq;end;
while true do begin{753:}if curi.b1=curc then if curi.b0<=128 then if
curi.b2>=128 then begin p:=newkern(fontinfo[kernbase[curf]+256*curi.b2+
curi.b3].int);mem[p].hh.rh:=mem[q].hh.rh;mem[q].hh.rh:=p;goto 10;
end else begin begin if interrupt<>0 then pauseforinstructions;end;
case curi.b2 of 1,5:mem[q+1].hh.b1:=curi.b3;2,6:mem[p+1].hh.b1:=curi.b3;
3,7,11:begin r:=newnoad;mem[r+1].hh.b1:=curi.b3;
mem[r+1].hh.b0:=mem[q+1].hh.b0;mem[q].hh.rh:=r;mem[r].hh.rh:=p;
if curi.b2<11 then mem[r+1].hh.rh:=1 else mem[r+1].hh.rh:=4;end;
others:begin mem[q].hh.rh:=mem[p].hh.rh;mem[q+1].hh.b1:=curi.b3;
mem[q+3]:=mem[p+3];mem[q+2]:=mem[p+2];freenode(p,4);end end;
if curi.b2>3 then goto 10;mem[q+1].hh.rh:=1;goto 20;end{:753};
if curi.b0>=128 then goto 10;a:=a+curi.b0+1;curi:=fontinfo[a].qqqq;end;
end;end;end;10:end;{:752}{756:}procedure makescripts(q:halfword;
delta:scaled);var p,x,y,z:halfword;shiftup,shiftdown,clr:scaled;
t:smallnumber;begin p:=mem[q+1].int;
if(p>=himemmin)then begin shiftup:=0;shiftdown:=0;
end else begin z:=hpack(p,0,1);if curstyle<4 then t:=16 else t:=32;
shiftup:=mem[z+3].int-fontinfo[18+parambase[eqtb[3942+t].hh.rh]].int;
shiftdown:=mem[z+2].int+fontinfo[19+parambase[eqtb[3942+t].hh.rh]].int;
freenode(z,7);end;
if mem[q+2].hh.rh=0 then{757:}begin x:=cleanbox(q+3,2*(curstyle div 4)+5
);mem[x+1].int:=mem[x+1].int+eqtb[5857].int;
if shiftdown<fontinfo[16+parambase[eqtb[3942+cursize].hh.rh]].int then
shiftdown:=fontinfo[16+parambase[eqtb[3942+cursize].hh.rh]].int;
clr:=mem[x+3].int-(abs(fontinfo[5+parambase[eqtb[3942+cursize].hh.rh]].
int*4)div 5);if shiftdown<clr then shiftdown:=clr;
mem[x+4].int:=shiftdown;
end{:757}else begin{758:}begin x:=cleanbox(q+2,2*(curstyle div 4)+4+(
curstyle mod 2));mem[x+1].int:=mem[x+1].int+eqtb[5857].int;
if odd(curstyle)then clr:=fontinfo[15+parambase[eqtb[3942+cursize].hh.rh
]].int else if curstyle<2 then clr:=fontinfo[13+parambase[eqtb[3942+
cursize].hh.rh]].int else clr:=fontinfo[14+parambase[eqtb[3942+cursize].
hh.rh]].int;if shiftup<clr then shiftup:=clr;
clr:=mem[x+2].int+(abs(fontinfo[5+parambase[eqtb[3942+cursize].hh.rh]].
int)div 4);if shiftup<clr then shiftup:=clr;end{:758};
if mem[q+3].hh.rh=0 then mem[x+4].int:=-shiftup else{759:}begin y:=
cleanbox(q+3,2*(curstyle div 4)+5);
mem[y+1].int:=mem[y+1].int+eqtb[5857].int;
if shiftdown<fontinfo[17+parambase[eqtb[3942+cursize].hh.rh]].int then
shiftdown:=fontinfo[17+parambase[eqtb[3942+cursize].hh.rh]].int;
clr:=4*fontinfo[8+parambase[eqtb[3943+cursize].hh.rh]].int-((shiftup-mem
[x+2].int)-(mem[y+3].int-shiftdown));
if clr>0 then begin shiftdown:=shiftdown+clr;
clr:=(abs(fontinfo[5+parambase[eqtb[3942+cursize].hh.rh]].int*4)div 5)-(
shiftup-mem[x+2].int);if clr>0 then begin shiftup:=shiftup+clr;
shiftdown:=shiftdown-clr;end;end;mem[x+4].int:=delta;
p:=newkern((shiftup-mem[x+2].int)-(mem[y+3].int-shiftdown));
mem[x].hh.rh:=p;mem[p].hh.rh:=y;x:=vpackage(x,0,1,1073741823);
mem[x+4].int:=shiftdown;end{:759};end;
if mem[q+1].int=0 then mem[q+1].int:=x else begin p:=mem[q+1].int;
while mem[p].hh.rh<>0 do p:=mem[p].hh.rh;mem[p].hh.rh:=x;end;end;
{:756}{762:}function makeleftright(q:halfword;style:smallnumber;
maxd,maxh:scaled):smallnumber;var delta,delta1,delta2:scaled;
begin curstyle:=style;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};
delta2:=maxd+fontinfo[22+parambase[eqtb[3942+cursize].hh.rh]].int;
delta1:=maxh+maxd-delta2;if delta2>delta1 then delta1:=delta2;
delta:=(delta1 div 500)*eqtb[5286].int;
delta2:=delta1+delta1-eqtb[5855].int;if delta<delta2 then delta:=delta2;
mem[q+1].int:=vardelimiter(q+1,cursize,delta);
makeleftright:=mem[q].hh.b0-(10);end;{:762}procedure mlisttohlist;
label 21,82,80,81,83,30;var mlist:halfword;penalties:boolean;
style:smallnumber;savestyle:smallnumber;q:halfword;r:halfword;
rtype:smallnumber;t:smallnumber;p,x,y,z:halfword;pen:integer;
s:smallnumber;maxh,maxd:scaled;delta:scaled;begin mlist:=curmlist;
penalties:=mlistpenalties;style:=curstyle;q:=mlist;r:=0;rtype:=17;
maxh:=0;maxd:=0;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};while q<>0 do{727:}begin{728:}21:delta:=0;
case mem[q].hh.b0 of 18:case rtype of 18,17,19,20,22,30:begin mem[q].hh.
b0:=16;goto 21;end;others:end;
19,21,22,31:begin{729:}if rtype=18 then mem[r].hh.b0:=16{:729};
if mem[q].hh.b0=31 then goto 80;end;{733:}30:goto 80;
25:begin makefraction(q);goto 82;end;17:begin delta:=makeop(q);
if mem[q].hh.b1=1 then goto 82;end;16:makeord(q);20,23:;
24:makeradical(q);27:makeover(q);26:makeunder(q);28:makemathaccent(q);
29:makevcenter(q);{:733}{730:}14:begin curstyle:=mem[q].hh.b1;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};goto 81;end;
15:{731:}begin case curstyle div 2 of 0:begin p:=mem[q+1].hh.lh;
mem[q+1].hh.lh:=0;end;1:begin p:=mem[q+1].hh.rh;mem[q+1].hh.rh:=0;end;
2:begin p:=mem[q+2].hh.lh;mem[q+2].hh.lh:=0;end;
3:begin p:=mem[q+2].hh.rh;mem[q+2].hh.rh:=0;end;end;
flushnodelist(mem[q+1].hh.lh);flushnodelist(mem[q+1].hh.rh);
flushnodelist(mem[q+2].hh.lh);flushnodelist(mem[q+2].hh.rh);
mem[q].hh.b0:=14;mem[q].hh.b1:=curstyle;mem[q+1].int:=0;mem[q+2].int:=0;
if p<>0 then begin z:=mem[q].hh.rh;mem[q].hh.rh:=p;
while mem[p].hh.rh<>0 do p:=mem[p].hh.rh;mem[p].hh.rh:=z;end;goto 81;
end{:731};3,4,5,8,12,7:goto 81;
2:begin if mem[q+3].int>maxh then maxh:=mem[q+3].int;
if mem[q+2].int>maxd then maxd:=mem[q+2].int;goto 81;end;
10:begin{732:}if mem[q].hh.b1=99 then begin x:=mem[q+1].hh.lh;
y:=mathglue(x,curmu);deleteglueref(x);mem[q+1].hh.lh:=y;mem[q].hh.b1:=0;
end else if(cursize<>0)and(mem[q].hh.b1=98)then begin p:=mem[q].hh.rh;
if p<>0 then if(mem[p].hh.b0=10)or(mem[p].hh.b0=11)then begin mem[q].hh.
rh:=mem[p].hh.rh;mem[p].hh.rh:=0;flushnodelist(p);end;end{:732};goto 81;
end;11:begin mathkern(q,curmu);goto 81;end;
{:730}others:confusion(900)end;
{754:}case mem[q+1].hh.rh of 1,4:{755:}begin fetch(q+1);
if(curi.b0>0)then begin delta:=fontinfo[italicbase[curf]+(curi.b2-0)div
4].int;p:=newcharacter(curf,curc-0);
if(mem[q+1].hh.rh=4)and(fontinfo[2+parambase[curf]].int<>0)then delta:=0
;
if(mem[q+3].hh.rh=0)and(delta<>0)then begin mem[p].hh.rh:=newkern(delta)
;delta:=0;end;end else p:=0;end{:755};0:p:=0;2:p:=mem[q+1].hh.lh;
3:begin curmlist:=mem[q+1].hh.lh;savestyle:=curstyle;
mlistpenalties:=false;mlisttohlist;curstyle:=savestyle;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};p:=hpack(mem[29997].hh.rh,0,1);end;others:confusion(901)end;
mem[q+1].int:=p;if(mem[q+3].hh.rh=0)and(mem[q+2].hh.rh=0)then goto 82;
makescripts(q,delta){:754}{:728};82:z:=hpack(mem[q+1].int,0,1);
if mem[z+3].int>maxh then maxh:=mem[z+3].int;
if mem[z+2].int>maxd then maxd:=mem[z+2].int;freenode(z,7);80:r:=q;
rtype:=mem[r].hh.b0;if rtype=31 then begin rtype:=30;curstyle:=style;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};end;81:q:=mem[q].hh.rh;end{:727};
{729:}if rtype=18 then mem[r].hh.b0:=16{:729};{760:}p:=29997;
mem[p].hh.rh:=0;q:=mlist;rtype:=0;curstyle:=style;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};while q<>0 do begin{761:}t:=16;s:=4;pen:=10000;
case mem[q].hh.b0 of 17,20,21,22,23:t:=mem[q].hh.b0;18:begin t:=18;
pen:=eqtb[5277].int;end;19:begin t:=19;pen:=eqtb[5278].int;end;
16,29,27,26:;24:s:=5;28:s:=5;25:begin t:=23;s:=6;end;
30,31:t:=makeleftright(q,style,maxd,maxh);
14:{763:}begin curstyle:=mem[q].hh.b1;s:=3;
{703:}begin if curstyle<4 then cursize:=0 else cursize:=16*((curstyle-2)
div 2);
curmu:=xovern(fontinfo[6+parambase[eqtb[3942+cursize].hh.rh]].int,18);
end{:703};goto 83;end{:763};8,12,2,7,5,3,4,10,11:begin mem[p].hh.rh:=q;
p:=q;q:=mem[q].hh.rh;mem[p].hh.rh:=0;goto 30;end;
others:confusion(902)end{:761};
{766:}if rtype>0 then begin case strpool[rtype*8+t+magicoffset]of 48:x:=
0;49:if curstyle<4 then x:=15 else x:=0;50:x:=15;
51:if curstyle<4 then x:=16 else x:=0;
52:if curstyle<4 then x:=17 else x:=0;others:confusion(904)end;
if x<>0 then begin y:=mathglue(eqtb[2882+x].hh.rh,curmu);z:=newglue(y);
mem[y].hh.rh:=0;mem[p].hh.rh:=z;p:=z;mem[z].hh.b1:=x+1;end;end{:766};
{767:}if mem[q+1].int<>0 then begin mem[p].hh.rh:=mem[q+1].int;
repeat p:=mem[p].hh.rh;until mem[p].hh.rh=0;end;
if penalties then if mem[q].hh.rh<>0 then if pen<10000 then begin rtype
:=mem[mem[q].hh.rh].hh.b0;
if rtype<>12 then if rtype<>19 then begin z:=newpenalty(pen);
mem[p].hh.rh:=z;p:=z;end;end{:767};if mem[q].hh.b0=31 then t:=20;
rtype:=t;83:r:=q;q:=mem[q].hh.rh;freenode(r,s);30:end{:760};end;
{:726}{772:}procedure pushalignment;var p:halfword;begin p:=getnode(5);
mem[p].hh.rh:=alignptr;mem[p].hh.lh:=curalign;
mem[p+1].hh.lh:=mem[29992].hh.rh;mem[p+1].hh.rh:=curspan;
mem[p+2].int:=curloop;mem[p+3].int:=alignstate;mem[p+4].hh.lh:=curhead;
mem[p+4].hh.rh:=curtail;alignptr:=p;curhead:=getavail;end;
procedure popalignment;var p:halfword;
begin begin mem[curhead].hh.rh:=avail;avail:=curhead;
{dynused:=dynused-1;}end;p:=alignptr;curtail:=mem[p+4].hh.rh;
curhead:=mem[p+4].hh.lh;alignstate:=mem[p+3].int;curloop:=mem[p+2].int;
curspan:=mem[p+1].hh.rh;mem[29992].hh.rh:=mem[p+1].hh.lh;
curalign:=mem[p].hh.lh;alignptr:=mem[p].hh.rh;freenode(p,5);end;
{:772}{774:}{782:}procedure getpreambletoken;label 20;begin 20:gettoken;
while(curchr=256)and(curcmd=4)do begin gettoken;
if curcmd>100 then begin expand;gettoken;end;end;
if curcmd=9 then fatalerror(604);
if(curcmd=75)and(curchr=2893)then begin scanoptionalequals;scanglue(2);
if eqtb[5311].int>0 then geqdefine(2893,117,curval)else eqdefine(2893,
117,curval);goto 20;end;end;{:782}procedure alignpeek;forward;
procedure normalparagraph;forward;procedure initalign;label 30,31,32,22;
var savecsptr:halfword;p:halfword;begin savecsptr:=curcs;pushalignment;
alignstate:=-1000000;
{776:}if(curlist.modefield=203)and((curlist.tailfield<>curlist.headfield
)or(curlist.auxfield.int<>0))then begin begin if interaction=3 then;
printnl(263);print(689);end;printesc(523);print(905);begin helpptr:=3;
helpline[2]:=906;helpline[1]:=907;helpline[0]:=908;end;error;flushmath;
end{:776};pushnest;
{775:}if curlist.modefield=203 then begin curlist.modefield:=-1;
curlist.auxfield.int:=nest[nestptr-2].auxfield.int;
end else if curlist.modefield>0 then curlist.modefield:=-curlist.
modefield{:775};scanspec(6,false);{777:}mem[29992].hh.rh:=0;
curalign:=29992;curloop:=0;scannerstatus:=4;warningindex:=savecsptr;
alignstate:=-1000000;
while true do begin{778:}mem[curalign].hh.rh:=newparamglue(11);
curalign:=mem[curalign].hh.rh{:778};if curcmd=5 then goto 30;
{779:}{783:}p:=29996;mem[p].hh.rh:=0;
while true do begin getpreambletoken;if curcmd=6 then goto 31;
if(curcmd<=5)and(curcmd>=4)and(alignstate=-1000000)then if(p=29996)and(
curloop=0)and(curcmd=4)then curloop:=curalign else begin begin if
interaction=3 then;printnl(263);print(914);end;begin helpptr:=3;
helpline[2]:=915;helpline[1]:=916;helpline[0]:=917;end;backerror;
goto 31;
end else if(curcmd<>10)or(p<>29996)then begin mem[p].hh.rh:=getavail;
p:=mem[p].hh.rh;mem[p].hh.lh:=curtok;end;end;31:{:783};
mem[curalign].hh.rh:=newnullbox;curalign:=mem[curalign].hh.rh;
mem[curalign].hh.lh:=29991;mem[curalign+1].int:=-1073741824;
mem[curalign+3].int:=mem[29996].hh.rh;{784:}p:=29996;mem[p].hh.rh:=0;
while true do begin 22:getpreambletoken;
if(curcmd<=5)and(curcmd>=4)and(alignstate=-1000000)then goto 32;
if curcmd=6 then begin begin if interaction=3 then;printnl(263);
print(918);end;begin helpptr:=3;helpline[2]:=915;helpline[1]:=916;
helpline[0]:=919;end;error;goto 22;end;mem[p].hh.rh:=getavail;
p:=mem[p].hh.rh;mem[p].hh.lh:=curtok;end;32:mem[p].hh.rh:=getavail;
p:=mem[p].hh.rh;mem[p].hh.lh:=6714{:784};
mem[curalign+2].int:=mem[29996].hh.rh{:779};end;
30:scannerstatus:=0{:777};newsavelevel(6);
if eqtb[3420].hh.rh<>0 then begintokenlist(eqtb[3420].hh.rh,13);
alignpeek;end;{:774}{786:}{787:}procedure initspan(p:halfword);
begin pushnest;
if curlist.modefield=-102 then curlist.auxfield.hh.lh:=1000 else begin
curlist.auxfield.int:=-65536000;normalparagraph;end;curspan:=p;end;
{:787}procedure initrow;begin pushnest;
curlist.modefield:=(-103)-curlist.modefield;
if curlist.modefield=-102 then curlist.auxfield.hh.lh:=0 else curlist.
auxfield.int:=0;
begin mem[curlist.tailfield].hh.rh:=newglue(mem[mem[29992].hh.rh+1].hh.
lh);curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b1:=12;curalign:=mem[mem[29992].hh.rh].hh.rh;
curtail:=curhead;initspan(curalign);end;{:786}{788:}procedure initcol;
begin mem[curalign+5].hh.lh:=curcmd;
if curcmd=63 then alignstate:=0 else begin backinput;
begintokenlist(mem[curalign+3].int,1);end;end;
{:788}{791:}function fincol:boolean;label 10;var p:halfword;
q,r:halfword;s:halfword;u:halfword;w:scaled;o:glueord;n:halfword;
begin if curalign=0 then confusion(920);q:=mem[curalign].hh.rh;
if q=0 then confusion(920);if alignstate<500000 then fatalerror(604);
p:=mem[q].hh.rh;
{792:}if(p=0)and(mem[curalign+5].hh.lh<257)then if curloop<>0 then{793:}
begin mem[q].hh.rh:=newnullbox;p:=mem[q].hh.rh;mem[p].hh.lh:=29991;
mem[p+1].int:=-1073741824;curloop:=mem[curloop].hh.rh;{794:}q:=29996;
r:=mem[curloop+3].int;while r<>0 do begin mem[q].hh.rh:=getavail;
q:=mem[q].hh.rh;mem[q].hh.lh:=mem[r].hh.lh;r:=mem[r].hh.rh;end;
mem[q].hh.rh:=0;mem[p+3].int:=mem[29996].hh.rh;q:=29996;
r:=mem[curloop+2].int;while r<>0 do begin mem[q].hh.rh:=getavail;
q:=mem[q].hh.rh;mem[q].hh.lh:=mem[r].hh.lh;r:=mem[r].hh.rh;end;
mem[q].hh.rh:=0;mem[p+2].int:=mem[29996].hh.rh{:794};
curloop:=mem[curloop].hh.rh;mem[p].hh.rh:=newglue(mem[curloop+1].hh.lh);
end{:793}else begin begin if interaction=3 then;printnl(263);print(921);
end;printesc(910);begin helpptr:=3;helpline[2]:=922;helpline[1]:=923;
helpline[0]:=924;end;mem[curalign+5].hh.lh:=257;error;end{:792};
if mem[curalign+5].hh.lh<>256 then begin unsave;newsavelevel(6);
{796:}begin if curlist.modefield=-102 then begin adjusttail:=curtail;
u:=hpack(mem[curlist.headfield].hh.rh,0,1);w:=mem[u+1].int;
curtail:=adjusttail;adjusttail:=0;
end else begin u:=vpackage(mem[curlist.headfield].hh.rh,0,1,0);
w:=mem[u+3].int;end;n:=0;
if curspan<>curalign then{798:}begin q:=curspan;repeat n:=n+1;
q:=mem[mem[q].hh.rh].hh.rh;until q=curalign;
if n>255 then confusion(925);q:=curspan;
while mem[mem[q].hh.lh].hh.rh<n do q:=mem[q].hh.lh;
if mem[mem[q].hh.lh].hh.rh>n then begin s:=getnode(2);
mem[s].hh.lh:=mem[q].hh.lh;mem[s].hh.rh:=n;mem[q].hh.lh:=s;
mem[s+1].int:=w;
end else if mem[mem[q].hh.lh+1].int<w then mem[mem[q].hh.lh+1].int:=w;
end{:798}else if w>mem[curalign+1].int then mem[curalign+1].int:=w;
mem[u].hh.b0:=13;mem[u].hh.b1:=n;
{659:}if totalstretch[3]<>0 then o:=3 else if totalstretch[2]<>0 then o
:=2 else if totalstretch[1]<>0 then o:=1 else o:=0{:659};
mem[u+5].hh.b1:=o;mem[u+6].int:=totalstretch[o];
{665:}if totalshrink[3]<>0 then o:=3 else if totalshrink[2]<>0 then o:=2
else if totalshrink[1]<>0 then o:=1 else o:=0{:665};mem[u+5].hh.b0:=o;
mem[u+4].int:=totalshrink[o];popnest;mem[curlist.tailfield].hh.rh:=u;
curlist.tailfield:=u;end{:796};
{795:}begin mem[curlist.tailfield].hh.rh:=newglue(mem[mem[curalign].hh.
rh+1].hh.lh);curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b1:=12{:795};
if mem[curalign+5].hh.lh>=257 then begin fincol:=true;goto 10;end;
initspan(p);end;alignstate:=1000000;repeat getxorprotected;
until curcmd<>10;curalign:=p;initcol;fincol:=false;10:end;
{:791}{799:}procedure finrow;var p:halfword;
begin if curlist.modefield=-102 then begin p:=hpack(mem[curlist.
headfield].hh.rh,0,1);popnest;appendtovlist(p);
if curhead<>curtail then begin mem[curlist.tailfield].hh.rh:=mem[curhead
].hh.rh;curlist.tailfield:=curtail;end;
end else begin p:=vpackage(mem[curlist.headfield].hh.rh,0,1,1073741823);
popnest;mem[curlist.tailfield].hh.rh:=p;curlist.tailfield:=p;
curlist.auxfield.hh.lh:=1000;end;mem[p].hh.b0:=13;mem[p+6].int:=0;
if eqtb[3420].hh.rh<>0 then begintokenlist(eqtb[3420].hh.rh,13);
alignpeek;end;{:799}{800:}procedure doassignments;forward;
procedure resumeafterdisplay;forward;procedure buildpage;forward;
procedure finalign;var p,q,r,s,u,v:halfword;t,w:scaled;o:scaled;
n:halfword;rulesave:scaled;auxsave:memoryword;
begin if curgroup<>6 then confusion(926);unsave;
if curgroup<>6 then confusion(927);unsave;
if nest[nestptr-1].modefield=203 then o:=eqtb[5860].int else o:=0;
{801:}q:=mem[mem[29992].hh.rh].hh.rh;repeat flushlist(mem[q+3].int);
flushlist(mem[q+2].int);p:=mem[mem[q].hh.rh].hh.rh;
if mem[q+1].int=-1073741824 then{802:}begin mem[q+1].int:=0;
r:=mem[q].hh.rh;s:=mem[r+1].hh.lh;
if s<>0 then begin mem[0].hh.rh:=mem[0].hh.rh+1;deleteglueref(s);
mem[r+1].hh.lh:=0;end;end{:802};
if mem[q].hh.lh<>29991 then{803:}begin t:=mem[q+1].int+mem[mem[mem[q].hh
.rh+1].hh.lh+1].int;r:=mem[q].hh.lh;s:=29991;mem[s].hh.lh:=p;n:=1;
repeat mem[r+1].int:=mem[r+1].int-t;u:=mem[r].hh.lh;
while mem[r].hh.rh>n do begin s:=mem[s].hh.lh;
n:=mem[mem[s].hh.lh].hh.rh+1;end;
if mem[r].hh.rh<n then begin mem[r].hh.lh:=mem[s].hh.lh;mem[s].hh.lh:=r;
mem[r].hh.rh:=mem[r].hh.rh-1;s:=r;
end else begin if mem[r+1].int>mem[mem[s].hh.lh+1].int then mem[mem[s].
hh.lh+1].int:=mem[r+1].int;freenode(r,2);end;r:=u;until r=29991;
end{:803};mem[q].hh.b0:=13;mem[q].hh.b1:=0;mem[q+3].int:=0;
mem[q+2].int:=0;mem[q+5].hh.b1:=0;mem[q+5].hh.b0:=0;mem[q+6].int:=0;
mem[q+4].int:=0;q:=p;until q=0{:801};{804:}saveptr:=saveptr-2;
packbeginline:=-curlist.mlfield;
if curlist.modefield=-1 then begin rulesave:=eqtb[5861].int;
eqtb[5861].int:=0;
p:=hpack(mem[29992].hh.rh,savestack[saveptr+1].int,savestack[saveptr+0].
int);eqtb[5861].int:=rulesave;
end else begin q:=mem[mem[29992].hh.rh].hh.rh;
repeat mem[q+3].int:=mem[q+1].int;mem[q+1].int:=0;
q:=mem[mem[q].hh.rh].hh.rh;until q=0;
p:=vpackage(mem[29992].hh.rh,savestack[saveptr+1].int,savestack[saveptr
+0].int,1073741823);q:=mem[mem[29992].hh.rh].hh.rh;
repeat mem[q+1].int:=mem[q+3].int;mem[q+3].int:=0;
q:=mem[mem[q].hh.rh].hh.rh;until q=0;end;packbeginline:=0{:804};
{805:}q:=mem[curlist.headfield].hh.rh;s:=curlist.headfield;
while q<>0 do begin if not(q>=himemmin)then if mem[q].hh.b0=13 then
{807:}begin if curlist.modefield=-1 then begin mem[q].hh.b0:=0;
mem[q+1].int:=mem[p+1].int;
if nest[nestptr-1].modefield=203 then mem[q].hh.b1:=2;
end else begin mem[q].hh.b0:=1;mem[q+3].int:=mem[p+3].int;end;
mem[q+5].hh.b1:=mem[p+5].hh.b1;mem[q+5].hh.b0:=mem[p+5].hh.b0;
mem[q+6].gr:=mem[p+6].gr;mem[q+4].int:=o;r:=mem[mem[q+5].hh.rh].hh.rh;
s:=mem[mem[p+5].hh.rh].hh.rh;repeat{808:}n:=mem[r].hh.b1;
t:=mem[s+1].int;w:=t;u:=29996;mem[r].hh.b1:=0;while n>0 do begin n:=n-1;
{809:}s:=mem[s].hh.rh;v:=mem[s+1].hh.lh;mem[u].hh.rh:=newglue(v);
u:=mem[u].hh.rh;mem[u].hh.b1:=12;t:=t+mem[v+1].int;
if mem[p+5].hh.b0=1 then begin if mem[v].hh.b0=mem[p+5].hh.b1 then t:=t+
round(mem[p+6].gr*mem[v+2].int);
end else if mem[p+5].hh.b0=2 then begin if mem[v].hh.b1=mem[p+5].hh.b1
then t:=t-round(mem[p+6].gr*mem[v+3].int);end;s:=mem[s].hh.rh;
mem[u].hh.rh:=newnullbox;u:=mem[u].hh.rh;t:=t+mem[s+1].int;
if curlist.modefield=-1 then mem[u+1].int:=mem[s+1].int else begin mem[u
].hh.b0:=1;mem[u+3].int:=mem[s+1].int;end{:809};end;
if curlist.modefield=-1 then{810:}begin mem[r+3].int:=mem[q+3].int;
mem[r+2].int:=mem[q+2].int;
if t=mem[r+1].int then begin mem[r+5].hh.b0:=0;mem[r+5].hh.b1:=0;
mem[r+6].gr:=0.0;
end else if t>mem[r+1].int then begin mem[r+5].hh.b0:=1;
if mem[r+6].int=0 then mem[r+6].gr:=0.0 else mem[r+6].gr:=(t-mem[r+1].
int)/mem[r+6].int;end else begin mem[r+5].hh.b1:=mem[r+5].hh.b0;
mem[r+5].hh.b0:=2;
if mem[r+4].int=0 then mem[r+6].gr:=0.0 else if(mem[r+5].hh.b1=0)and(mem
[r+1].int-t>mem[r+4].int)then mem[r+6].gr:=1.0 else mem[r+6].gr:=(mem[r
+1].int-t)/mem[r+4].int;end;mem[r+1].int:=w;mem[r].hh.b0:=0;
end{:810}else{811:}begin mem[r+1].int:=mem[q+1].int;
if t=mem[r+3].int then begin mem[r+5].hh.b0:=0;mem[r+5].hh.b1:=0;
mem[r+6].gr:=0.0;
end else if t>mem[r+3].int then begin mem[r+5].hh.b0:=1;
if mem[r+6].int=0 then mem[r+6].gr:=0.0 else mem[r+6].gr:=(t-mem[r+3].
int)/mem[r+6].int;end else begin mem[r+5].hh.b1:=mem[r+5].hh.b0;
mem[r+5].hh.b0:=2;
if mem[r+4].int=0 then mem[r+6].gr:=0.0 else if(mem[r+5].hh.b1=0)and(mem
[r+3].int-t>mem[r+4].int)then mem[r+6].gr:=1.0 else mem[r+6].gr:=(mem[r
+3].int-t)/mem[r+4].int;end;mem[r+3].int:=w;mem[r].hh.b0:=1;end{:811};
mem[r+4].int:=0;if u<>29996 then begin mem[u].hh.rh:=mem[r].hh.rh;
mem[r].hh.rh:=mem[29996].hh.rh;r:=u;end{:808};
r:=mem[mem[r].hh.rh].hh.rh;s:=mem[mem[s].hh.rh].hh.rh;until r=0;
end{:807}else if mem[q].hh.b0=2 then{806:}begin if(mem[q+1].int=
-1073741824)then mem[q+1].int:=mem[p+1].int;
if(mem[q+3].int=-1073741824)then mem[q+3].int:=mem[p+3].int;
if(mem[q+2].int=-1073741824)then mem[q+2].int:=mem[p+2].int;
if o<>0 then begin r:=mem[q].hh.rh;mem[q].hh.rh:=0;q:=hpack(q,0,1);
mem[q+4].int:=o;mem[q].hh.rh:=r;mem[s].hh.rh:=q;end;end{:806};s:=q;
q:=mem[q].hh.rh;end{:805};flushnodelist(p);popalignment;
{812:}auxsave:=curlist.auxfield;p:=mem[curlist.headfield].hh.rh;
q:=curlist.tailfield;popnest;
if curlist.modefield=203 then{1206:}begin doassignments;
if curcmd<>3 then{1207:}begin begin if interaction=3 then;printnl(263);
print(1182);end;begin helpptr:=2;helpline[1]:=906;helpline[0]:=907;end;
backerror;end{:1207}else{1197:}begin getxtoken;
if curcmd<>3 then begin begin if interaction=3 then;printnl(263);
print(1178);end;begin helpptr:=2;helpline[1]:=1179;helpline[0]:=1180;
end;backerror;end;end{:1197};flushnodelist(curlist.eTeXauxfield);
popnest;begin mem[curlist.tailfield].hh.rh:=newpenalty(eqtb[5279].int);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
begin mem[curlist.tailfield].hh.rh:=newparamglue(3);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.rh:=p;if p<>0 then curlist.tailfield:=q;
begin mem[curlist.tailfield].hh.rh:=newpenalty(eqtb[5280].int);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
begin mem[curlist.tailfield].hh.rh:=newparamglue(4);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
curlist.auxfield.int:=auxsave.int;resumeafterdisplay;
end{:1206}else begin curlist.auxfield:=auxsave;
mem[curlist.tailfield].hh.rh:=p;if p<>0 then curlist.tailfield:=q;
if curlist.modefield=1 then buildpage;end{:812};end;
{785:}procedure alignpeek;label 20;begin 20:alignstate:=1000000;
repeat getxorprotected;until curcmd<>10;
if curcmd=34 then begin scanleftbrace;newsavelevel(7);
if curlist.modefield=-1 then normalparagraph;
end else if curcmd=2 then finalign else if(curcmd=5)and(curchr=258)then
goto 20 else begin initrow;initcol;end;end;
{:785}{:800}{815:}{826:}function finiteshrink(p:halfword):halfword;
var q:halfword;
begin if noshrinkerroryet then begin noshrinkerroryet:=false;
begin if interaction=3 then;printnl(263);print(928);end;
begin helpptr:=5;helpline[4]:=929;helpline[3]:=930;helpline[2]:=931;
helpline[1]:=932;helpline[0]:=933;end;error;end;q:=newspec(p);
mem[q].hh.b1:=0;deleteglueref(p);finiteshrink:=q;end;
{:826}{829:}procedure trybreak(pi:integer;breaktype:smallnumber);
label 10,30,31,22,60,40,45;var r:halfword;prevr:halfword;oldl:halfword;
nobreakyet:boolean;{830:}prevprevr:halfword;s:halfword;q:halfword;
v:halfword;t:integer;f:internalfontnumber;l:halfword;
noderstaysactive:boolean;linewidth:scaled;fitclass:0..3;b:halfword;
d:integer;artificialdemerits:boolean;savelink:halfword;shortfall:scaled;
{:830}{1577:}g:scaled;
{:1577}begin{831:}if abs(pi)>=10000 then if pi>0 then goto 10 else pi:=
-10000{:831};nobreakyet:=true;prevr:=29993;oldl:=0;
curactivewidth[1]:=activewidth[1];curactivewidth[2]:=activewidth[2];
curactivewidth[3]:=activewidth[3];curactivewidth[4]:=activewidth[4];
curactivewidth[5]:=activewidth[5];curactivewidth[6]:=activewidth[6];
while true do begin 22:r:=mem[prevr].hh.rh;
{832:}if mem[r].hh.b0=2 then begin curactivewidth[1]:=curactivewidth[1]+
mem[r+1].int;curactivewidth[2]:=curactivewidth[2]+mem[r+2].int;
curactivewidth[3]:=curactivewidth[3]+mem[r+3].int;
curactivewidth[4]:=curactivewidth[4]+mem[r+4].int;
curactivewidth[5]:=curactivewidth[5]+mem[r+5].int;
curactivewidth[6]:=curactivewidth[6]+mem[r+6].int;prevprevr:=prevr;
prevr:=r;goto 22;end{:832};{835:}begin l:=mem[r+1].hh.lh;
if l>oldl then begin if(minimumdemerits<1073741823)and((oldl<>easyline)
or(r=29993))then{836:}begin if nobreakyet then{837:}begin nobreakyet:=
false;breakwidth[1]:=background[1];breakwidth[2]:=background[2];
breakwidth[3]:=background[3];breakwidth[4]:=background[4];
breakwidth[5]:=background[5];breakwidth[6]:=background[6];s:=curp;
if breaktype>0 then if curp<>0 then{840:}begin t:=mem[curp].hh.b1;
v:=curp;s:=mem[curp+1].hh.rh;while t>0 do begin t:=t-1;v:=mem[v].hh.rh;
{841:}if(v>=himemmin)then begin f:=mem[v].hh.b0;
breakwidth[1]:=breakwidth[1]-fontinfo[widthbase[f]+fontinfo[charbase[f]+
mem[v].hh.b1].qqqq.b0].int;
end else case mem[v].hh.b0 of 6:begin f:=mem[v+1].hh.b0;
breakwidth[1]:=breakwidth[1]-fontinfo[widthbase[f]+fontinfo[charbase[f]+
mem[v+1].hh.b1].qqqq.b0].int;end;
0,1,2,11:breakwidth[1]:=breakwidth[1]-mem[v+1].int;
others:confusion(934)end{:841};end;
while s<>0 do begin{842:}if(s>=himemmin)then begin f:=mem[s].hh.b0;
breakwidth[1]:=breakwidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f]+
mem[s].hh.b1].qqqq.b0].int;
end else case mem[s].hh.b0 of 6:begin f:=mem[s+1].hh.b0;
breakwidth[1]:=breakwidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f]+
mem[s+1].hh.b1].qqqq.b0].int;end;
0,1,2,11:breakwidth[1]:=breakwidth[1]+mem[s+1].int;
others:confusion(935)end{:842};s:=mem[s].hh.rh;end;
breakwidth[1]:=breakwidth[1]+discwidth;
if mem[curp+1].hh.rh=0 then s:=mem[v].hh.rh;end{:840};
while s<>0 do begin if(s>=himemmin)then goto 30;
case mem[s].hh.b0 of 10:{838:}begin v:=mem[s+1].hh.lh;
breakwidth[1]:=breakwidth[1]-mem[v+1].int;
breakwidth[2+mem[v].hh.b0]:=breakwidth[2+mem[v].hh.b0]-mem[v+2].int;
breakwidth[6]:=breakwidth[6]-mem[v+3].int;end{:838};12:;
9:breakwidth[1]:=breakwidth[1]-mem[s+1].int;
11:if mem[s].hh.b1<>1 then goto 30 else breakwidth[1]:=breakwidth[1]-mem
[s+1].int;others:goto 30 end;s:=mem[s].hh.rh;end;30:end{:837};
{843:}if mem[prevr].hh.b0=2 then begin mem[prevr+1].int:=mem[prevr+1].
int-curactivewidth[1]+breakwidth[1];
mem[prevr+2].int:=mem[prevr+2].int-curactivewidth[2]+breakwidth[2];
mem[prevr+3].int:=mem[prevr+3].int-curactivewidth[3]+breakwidth[3];
mem[prevr+4].int:=mem[prevr+4].int-curactivewidth[4]+breakwidth[4];
mem[prevr+5].int:=mem[prevr+5].int-curactivewidth[5]+breakwidth[5];
mem[prevr+6].int:=mem[prevr+6].int-curactivewidth[6]+breakwidth[6];
end else if prevr=29993 then begin activewidth[1]:=breakwidth[1];
activewidth[2]:=breakwidth[2];activewidth[3]:=breakwidth[3];
activewidth[4]:=breakwidth[4];activewidth[5]:=breakwidth[5];
activewidth[6]:=breakwidth[6];end else begin q:=getnode(7);
mem[q].hh.rh:=r;mem[q].hh.b0:=2;mem[q].hh.b1:=0;
mem[q+1].int:=breakwidth[1]-curactivewidth[1];
mem[q+2].int:=breakwidth[2]-curactivewidth[2];
mem[q+3].int:=breakwidth[3]-curactivewidth[3];
mem[q+4].int:=breakwidth[4]-curactivewidth[4];
mem[q+5].int:=breakwidth[5]-curactivewidth[5];
mem[q+6].int:=breakwidth[6]-curactivewidth[6];mem[prevr].hh.rh:=q;
prevprevr:=prevr;prevr:=q;end{:843};
if abs(eqtb[5284].int)>=1073741823-minimumdemerits then minimumdemerits
:=1073741822 else minimumdemerits:=minimumdemerits+abs(eqtb[5284].int);
for fitclass:=0 to 3 do begin if minimaldemerits[fitclass]<=
minimumdemerits then{845:}begin q:=getnode(2);mem[q].hh.rh:=passive;
passive:=q;mem[q+1].hh.rh:=curp;{passnumber:=passnumber+1;
mem[q].hh.lh:=passnumber;}mem[q+1].hh.lh:=bestplace[fitclass];
q:=getnode(activenodesize);mem[q+1].hh.rh:=passive;
mem[q+1].hh.lh:=bestplline[fitclass]+1;mem[q].hh.b1:=fitclass;
mem[q].hh.b0:=breaktype;mem[q+2].int:=minimaldemerits[fitclass];
if dolastlinefit then{1584:}begin mem[q+3].int:=bestplshort[fitclass];
mem[q+4].int:=bestplglue[fitclass];end{:1584};mem[q].hh.rh:=r;
mem[prevr].hh.rh:=q;prevr:=q;
{if eqtb[5300].int>0 then[846:]begin printnl(936);
printint(mem[passive].hh.lh);print(937);printint(mem[q+1].hh.lh-1);
printchar(46);printint(fitclass);if breaktype=1 then printchar(45);
print(938);printint(mem[q+2].int);
if dolastlinefit then[1585:]begin print(1409);printscaled(mem[q+3].int);
if curp=0 then print(1410)else print(1007);printscaled(mem[q+4].int);
end[:1585];print(939);
if mem[passive+1].hh.lh=0 then printchar(48)else printint(mem[mem[
passive+1].hh.lh].hh.lh);end[:846];}end{:845};
minimaldemerits[fitclass]:=1073741823;end;minimumdemerits:=1073741823;
{844:}if r<>29993 then begin q:=getnode(7);mem[q].hh.rh:=r;
mem[q].hh.b0:=2;mem[q].hh.b1:=0;
mem[q+1].int:=curactivewidth[1]-breakwidth[1];
mem[q+2].int:=curactivewidth[2]-breakwidth[2];
mem[q+3].int:=curactivewidth[3]-breakwidth[3];
mem[q+4].int:=curactivewidth[4]-breakwidth[4];
mem[q+5].int:=curactivewidth[5]-breakwidth[5];
mem[q+6].int:=curactivewidth[6]-breakwidth[6];mem[prevr].hh.rh:=q;
prevprevr:=prevr;prevr:=q;end{:844};end{:836};if r=29993 then goto 10;
{850:}if l>easyline then begin linewidth:=secondwidth;oldl:=65534;
end else begin oldl:=l;
if l>lastspecialline then linewidth:=secondwidth else if eqtb[3412].hh.
rh=0 then linewidth:=firstwidth else linewidth:=mem[eqtb[3412].hh.rh+2*l
].int;end{:850};end;end{:835};{851:}begin artificialdemerits:=false;
shortfall:=linewidth-curactivewidth[1];
if shortfall>0 then{852:}if(curactivewidth[3]<>0)or(curactivewidth[4]<>0
)or(curactivewidth[5]<>0)then begin if dolastlinefit then begin if curp=
0 then{1579:}begin if(mem[r+3].int=0)or(mem[r+4].int<=0)then goto 45;
if(curactivewidth[3]<>fillwidth[0])or(curactivewidth[4]<>fillwidth[1])or
(curactivewidth[5]<>fillwidth[2])then goto 45;
if mem[r+3].int>0 then g:=curactivewidth[2]else g:=curactivewidth[6];
if g<=0 then goto 45;aritherror:=false;
g:=fract(g,mem[r+3].int,mem[r+4].int,1073741823);
if eqtb[5329].int<1000 then g:=fract(g,eqtb[5329].int,1000,1073741823);
if aritherror then if mem[r+3].int>0 then g:=1073741823 else g:=
-1073741823;if g>0 then{1580:}begin if g>shortfall then g:=shortfall;
if g>7230584 then if curactivewidth[2]<1663497 then begin b:=10000;
fitclass:=0;goto 40;end;b:=badness(g,curactivewidth[2]);
if b>12 then if b>99 then fitclass:=0 else fitclass:=1 else fitclass:=2;
goto 40;
end{:1580}else if g<0 then{1581:}begin if-g>curactivewidth[6]then g:=-
curactivewidth[6];b:=badness(-g,curactivewidth[6]);
if b>12 then fitclass:=3 else fitclass:=2;goto 40;end{:1581};
45:end{:1579};shortfall:=0;end;b:=0;fitclass:=2;
end else begin if shortfall>7230584 then if curactivewidth[2]<1663497
then begin b:=10000;fitclass:=0;goto 31;end;
b:=badness(shortfall,curactivewidth[2]);
if b>12 then if b>99 then fitclass:=0 else fitclass:=1 else fitclass:=2;
31:end{:852}else{853:}begin if-shortfall>curactivewidth[6]then b:=10001
else b:=badness(-shortfall,curactivewidth[6]);
if b>12 then fitclass:=3 else fitclass:=2;end{:853};
if dolastlinefit then{1582:}begin if curp=0 then shortfall:=0;
if shortfall>0 then g:=curactivewidth[2]else if shortfall<0 then g:=
curactivewidth[6]else g:=0;end{:1582};
40:if(b>10000)or(pi=-10000)then{854:}begin if finalpass and(
minimumdemerits=1073741823)and(mem[r].hh.rh=29993)and(prevr=29993)then
artificialdemerits:=true else if b>threshold then goto 60;
noderstaysactive:=false;end{:854}else begin prevr:=r;
if b>threshold then goto 22;noderstaysactive:=true;end;
{855:}if artificialdemerits then d:=0 else{859:}begin d:=eqtb[5270].int+
b;if abs(d)>=10000 then d:=100000000 else d:=d*d;
if pi<>0 then if pi>0 then d:=d+pi*pi else if pi>-10000 then d:=d-pi*pi;
if(breaktype=1)and(mem[r].hh.b0=1)then if curp<>0 then d:=d+eqtb[5282].
int else d:=d+eqtb[5283].int;
if abs(fitclass-mem[r].hh.b1)>1 then d:=d+eqtb[5284].int;end{:859};
{if eqtb[5300].int>0 then[856:]begin if printednode<>curp then[857:]
begin printnl(339);
if curp=0 then shortdisplay(mem[printednode].hh.rh)else begin savelink:=
mem[curp].hh.rh;mem[curp].hh.rh:=0;printnl(339);
shortdisplay(mem[printednode].hh.rh);mem[curp].hh.rh:=savelink;end;
printednode:=curp;end[:857];printnl(64);
if curp=0 then printesc(606)else if mem[curp].hh.b0<>10 then begin if
mem[curp].hh.b0=12 then printesc(535)else if mem[curp].hh.b0=7 then
printesc(352)else if mem[curp].hh.b0=11 then printesc(341)else printesc(
346);end;print(940);
if mem[r+1].hh.rh=0 then printchar(48)else printint(mem[mem[r+1].hh.rh].
hh.lh);print(941);if b>10000 then printchar(42)else printint(b);
print(942);printint(pi);print(943);
if artificialdemerits then printchar(42)else printint(d);end[:856];}
d:=d+mem[r+2].int;
if d<=minimaldemerits[fitclass]then begin minimaldemerits[fitclass]:=d;
bestplace[fitclass]:=mem[r+1].hh.rh;bestplline[fitclass]:=l;
if dolastlinefit then{1583:}begin bestplshort[fitclass]:=shortfall;
bestplglue[fitclass]:=g;end{:1583};
if d<minimumdemerits then minimumdemerits:=d;end{:855};
if noderstaysactive then goto 22;
60:{860:}mem[prevr].hh.rh:=mem[r].hh.rh;freenode(r,activenodesize);
if prevr=29993 then{861:}begin r:=mem[29993].hh.rh;
if mem[r].hh.b0=2 then begin activewidth[1]:=activewidth[1]+mem[r+1].int
;activewidth[2]:=activewidth[2]+mem[r+2].int;
activewidth[3]:=activewidth[3]+mem[r+3].int;
activewidth[4]:=activewidth[4]+mem[r+4].int;
activewidth[5]:=activewidth[5]+mem[r+5].int;
activewidth[6]:=activewidth[6]+mem[r+6].int;
curactivewidth[1]:=activewidth[1];curactivewidth[2]:=activewidth[2];
curactivewidth[3]:=activewidth[3];curactivewidth[4]:=activewidth[4];
curactivewidth[5]:=activewidth[5];curactivewidth[6]:=activewidth[6];
mem[29993].hh.rh:=mem[r].hh.rh;freenode(r,7);end;
end{:861}else if mem[prevr].hh.b0=2 then begin r:=mem[prevr].hh.rh;
if r=29993 then begin curactivewidth[1]:=curactivewidth[1]-mem[prevr+1].
int;curactivewidth[2]:=curactivewidth[2]-mem[prevr+2].int;
curactivewidth[3]:=curactivewidth[3]-mem[prevr+3].int;
curactivewidth[4]:=curactivewidth[4]-mem[prevr+4].int;
curactivewidth[5]:=curactivewidth[5]-mem[prevr+5].int;
curactivewidth[6]:=curactivewidth[6]-mem[prevr+6].int;
mem[prevprevr].hh.rh:=29993;freenode(prevr,7);prevr:=prevprevr;
end else if mem[r].hh.b0=2 then begin curactivewidth[1]:=curactivewidth[
1]+mem[r+1].int;curactivewidth[2]:=curactivewidth[2]+mem[r+2].int;
curactivewidth[3]:=curactivewidth[3]+mem[r+3].int;
curactivewidth[4]:=curactivewidth[4]+mem[r+4].int;
curactivewidth[5]:=curactivewidth[5]+mem[r+5].int;
curactivewidth[6]:=curactivewidth[6]+mem[r+6].int;
mem[prevr+1].int:=mem[prevr+1].int+mem[r+1].int;
mem[prevr+2].int:=mem[prevr+2].int+mem[r+2].int;
mem[prevr+3].int:=mem[prevr+3].int+mem[r+3].int;
mem[prevr+4].int:=mem[prevr+4].int+mem[r+4].int;
mem[prevr+5].int:=mem[prevr+5].int+mem[r+5].int;
mem[prevr+6].int:=mem[prevr+6].int+mem[r+6].int;
mem[prevr].hh.rh:=mem[r].hh.rh;freenode(r,7);end;end{:860};end{:851};
end;
10:{[858:]if curp=printednode then if curp<>0 then if mem[curp].hh.b0=7
then begin t:=mem[curp].hh.b1;while t>0 do begin t:=t-1;
printednode:=mem[printednode].hh.rh;end;end[:858]}end;
{:829}{877:}procedure postlinebreak(d:boolean);label 30,31;
var q,r,s:halfword;discbreak:boolean;postdiscbreak:boolean;
curwidth:scaled;curindent:scaled;t:quarterword;pen:integer;
curline:halfword;LRptr:halfword;begin LRptr:=curlist.eTeXauxfield;
{878:}q:=mem[bestbet+1].hh.rh;curp:=0;repeat r:=q;q:=mem[q+1].hh.lh;
mem[r+1].hh.lh:=curp;curp:=r;until q=0{:878};curline:=curlist.pgfield+1;
repeat{880:}if(eqtb[5332].int>0)then{1438:}begin q:=mem[29997].hh.rh;
if LRptr<>0 then begin tempptr:=LRptr;r:=q;
repeat s:=newmath(0,(mem[tempptr].hh.lh-1));mem[s].hh.rh:=r;r:=s;
tempptr:=mem[tempptr].hh.rh;until tempptr=0;mem[29997].hh.rh:=r;end;
while q<>mem[curp+1].hh.rh do begin if not(q>=himemmin)then if mem[q].hh
.b0=9 then{1439:}if odd(mem[q].hh.b1)then begin if LRptr<>0 then if mem[
LRptr].hh.lh=(4*(mem[q].hh.b1 div 4)+3)then begin tempptr:=LRptr;
LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;end;
end else begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[q].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end{:1439};q:=mem[q].hh.rh;end;
end{:1438};{881:}q:=mem[curp+1].hh.rh;discbreak:=false;
postdiscbreak:=false;
if q<>0 then if mem[q].hh.b0=10 then begin deleteglueref(mem[q+1].hh.lh)
;mem[q+1].hh.lh:=eqtb[2890].hh.rh;mem[q].hh.b1:=9;
mem[eqtb[2890].hh.rh].hh.rh:=mem[eqtb[2890].hh.rh].hh.rh+1;goto 30;
end else begin if mem[q].hh.b0=7 then{882:}begin t:=mem[q].hh.b1;
{883:}if t=0 then r:=mem[q].hh.rh else begin r:=q;
while t>1 do begin r:=mem[r].hh.rh;t:=t-1;end;s:=mem[r].hh.rh;
r:=mem[s].hh.rh;mem[s].hh.rh:=0;flushnodelist(mem[q].hh.rh);
mem[q].hh.b1:=0;end{:883};
if mem[q+1].hh.rh<>0 then{884:}begin s:=mem[q+1].hh.rh;
while mem[s].hh.rh<>0 do s:=mem[s].hh.rh;mem[s].hh.rh:=r;
r:=mem[q+1].hh.rh;mem[q+1].hh.rh:=0;postdiscbreak:=true;end{:884};
if mem[q+1].hh.lh<>0 then{885:}begin s:=mem[q+1].hh.lh;mem[q].hh.rh:=s;
while mem[s].hh.rh<>0 do s:=mem[s].hh.rh;mem[q+1].hh.lh:=0;q:=s;
end{:885};mem[q].hh.rh:=r;discbreak:=true;
end{:882}else if mem[q].hh.b0=11 then mem[q+1].int:=0 else if mem[q].hh.
b0=9 then begin mem[q+1].int:=0;
if(eqtb[5332].int>0)then{1439:}if odd(mem[q].hh.b1)then begin if LRptr<>
0 then if mem[LRptr].hh.lh=(4*(mem[q].hh.b1 div 4)+3)then begin tempptr
:=LRptr;LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;end;
end else begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[q].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end{:1439};end;
end else begin q:=29997;while mem[q].hh.rh<>0 do q:=mem[q].hh.rh;end;
{886:}r:=newparamglue(8);mem[r].hh.rh:=mem[q].hh.rh;mem[q].hh.rh:=r;
q:=r{:886};30:{:881};
if(eqtb[5332].int>0)then{1440:}if LRptr<>0 then begin s:=29997;
r:=mem[s].hh.rh;while r<>q do begin s:=r;r:=mem[s].hh.rh;end;r:=LRptr;
while r<>0 do begin tempptr:=newmath(0,mem[r].hh.lh);
mem[s].hh.rh:=tempptr;s:=tempptr;r:=mem[r].hh.rh;end;mem[s].hh.rh:=q;
end{:1440};{887:}r:=mem[q].hh.rh;mem[q].hh.rh:=0;q:=mem[29997].hh.rh;
mem[29997].hh.rh:=r;
if eqtb[2889].hh.rh<>0 then begin r:=newparamglue(7);mem[r].hh.rh:=q;
q:=r;end{:887};
{889:}if curline>lastspecialline then begin curwidth:=secondwidth;
curindent:=secondindent;
end else if eqtb[3412].hh.rh=0 then begin curwidth:=firstwidth;
curindent:=firstindent;
end else begin curwidth:=mem[eqtb[3412].hh.rh+2*curline].int;
curindent:=mem[eqtb[3412].hh.rh+2*curline-1].int;end;adjusttail:=29995;
justbox:=hpack(q,curwidth,0);mem[justbox+4].int:=curindent{:889};
{888:}appendtovlist(justbox);
if 29995<>adjusttail then begin mem[curlist.tailfield].hh.rh:=mem[29995]
.hh.rh;curlist.tailfield:=adjusttail;end;adjusttail:=0{:888};
{890:}if curline+1<>bestline then begin q:=eqtb[3679].hh.rh;
if q<>0 then begin r:=curline;if r>mem[q+1].int then r:=mem[q+1].int;
pen:=mem[q+r+1].int;end else pen:=eqtb[5281].int;q:=eqtb[3680].hh.rh;
if q<>0 then begin r:=curline-curlist.pgfield;
if r>mem[q+1].int then r:=mem[q+1].int;pen:=pen+mem[q+r+1].int;
end else if curline=curlist.pgfield+1 then pen:=pen+eqtb[5273].int;
if d then q:=eqtb[3682].hh.rh else q:=eqtb[3681].hh.rh;
if q<>0 then begin r:=bestline-curline-1;
if r>mem[q+1].int then r:=mem[q+1].int;pen:=pen+mem[q+r+1].int;
end else if curline+2=bestline then if d then pen:=pen+eqtb[5275].int
else pen:=pen+eqtb[5274].int;if discbreak then pen:=pen+eqtb[5276].int;
if pen<>0 then begin r:=newpenalty(pen);mem[curlist.tailfield].hh.rh:=r;
curlist.tailfield:=r;end;end{:890}{:880};curline:=curline+1;
curp:=mem[curp+1].hh.lh;
if curp<>0 then if not postdiscbreak then{879:}begin r:=29997;
while true do begin q:=mem[r].hh.rh;if q=mem[curp+1].hh.rh then goto 31;
if(q>=himemmin)then goto 31;if(mem[q].hh.b0<9)then goto 31;
if mem[q].hh.b0=11 then if mem[q].hh.b1<>1 then goto 31;r:=q;
if mem[q].hh.b0=9 then if(eqtb[5332].int>0)then{1439:}if odd(mem[q].hh.
b1)then begin if LRptr<>0 then if mem[LRptr].hh.lh=(4*(mem[q].hh.b1 div
4)+3)then begin tempptr:=LRptr;LRptr:=mem[tempptr].hh.rh;
begin mem[tempptr].hh.rh:=avail;avail:=tempptr;{dynused:=dynused-1;}end;
end;end else begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[q].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end{:1439};end;
31:if r<>29997 then begin mem[r].hh.rh:=0;
flushnodelist(mem[29997].hh.rh);mem[29997].hh.rh:=q;end;end{:879};
until curp=0;
if(curline<>bestline)or(mem[29997].hh.rh<>0)then confusion(950);
curlist.pgfield:=bestline-1;curlist.eTeXauxfield:=LRptr;end;
{:877}{895:}{906:}function reconstitute(j,n:smallnumber;
bchar,hchar:halfword):smallnumber;label 22,30;var p:halfword;t:halfword;
q:fourquarters;currh:halfword;testchar:halfword;w:scaled;k:fontindex;
begin hyphenpassed:=0;t:=29996;w:=0;mem[29996].hh.rh:=0;
{908:}curl:=hu[j]+0;curq:=t;if j=0 then begin ligaturepresent:=initlig;
p:=initlist;if ligaturepresent then lfthit:=initlft;
while p>0 do begin begin mem[t].hh.rh:=getavail;t:=mem[t].hh.rh;
mem[t].hh.b0:=hf;mem[t].hh.b1:=mem[p].hh.b1;end;p:=mem[p].hh.rh;end;
end else if curl<256 then begin mem[t].hh.rh:=getavail;t:=mem[t].hh.rh;
mem[t].hh.b0:=hf;mem[t].hh.b1:=curl;end;ligstack:=0;
begin if j<n then curr:=hu[j+1]+0 else curr:=bchar;
if odd(hyf[j])then currh:=hchar else currh:=256;end{:908};
22:{909:}if curl=256 then begin k:=bcharlabel[hf];
if k=0 then goto 30 else q:=fontinfo[k].qqqq;
end else begin q:=fontinfo[charbase[hf]+curl].qqqq;
if((q.b2-0)mod 4)<>1 then goto 30;k:=ligkernbase[hf]+q.b3;
q:=fontinfo[k].qqqq;
if q.b0>128 then begin k:=ligkernbase[hf]+256*q.b2+q.b3+32768-256*(128);
q:=fontinfo[k].qqqq;end;end;
if currh<256 then testchar:=currh else testchar:=curr;
while true do begin if q.b1=testchar then if q.b0<=128 then if currh<256
then begin hyphenpassed:=j;hchar:=256;currh:=256;goto 22;
end else begin if hchar<256 then if odd(hyf[j])then begin hyphenpassed:=
j;hchar:=256;end;
if q.b2<128 then{911:}begin if curl=256 then lfthit:=true;
if j=n then if ligstack=0 then rthit:=true;
begin if interrupt<>0 then pauseforinstructions;end;
case q.b2 of 1,5:begin curl:=q.b3;ligaturepresent:=true;end;
2,6:begin curr:=q.b3;
if ligstack>0 then mem[ligstack].hh.b1:=curr else begin ligstack:=
newligitem(curr);if j=n then bchar:=256 else begin p:=getavail;
mem[ligstack+1].hh.rh:=p;mem[p].hh.b1:=hu[j+1]+0;mem[p].hh.b0:=hf;end;
end;end;3:begin curr:=q.b3;p:=ligstack;ligstack:=newligitem(curr);
mem[ligstack].hh.rh:=p;end;
7,11:begin if ligaturepresent then begin p:=newligature(hf,curl,mem[curq
].hh.rh);if lfthit then begin mem[p].hh.b1:=2;lfthit:=false;end;
if false then if ligstack=0 then begin mem[p].hh.b1:=mem[p].hh.b1+1;
rthit:=false;end;mem[curq].hh.rh:=p;t:=p;ligaturepresent:=false;end;
curq:=t;curl:=q.b3;ligaturepresent:=true;end;others:begin curl:=q.b3;
ligaturepresent:=true;
if ligstack>0 then begin if mem[ligstack+1].hh.rh>0 then begin mem[t].hh
.rh:=mem[ligstack+1].hh.rh;t:=mem[t].hh.rh;j:=j+1;end;p:=ligstack;
ligstack:=mem[p].hh.rh;freenode(p,2);
if ligstack=0 then begin if j<n then curr:=hu[j+1]+0 else curr:=bchar;
if odd(hyf[j])then currh:=hchar else currh:=256;
end else curr:=mem[ligstack].hh.b1;
end else if j=n then goto 30 else begin begin mem[t].hh.rh:=getavail;
t:=mem[t].hh.rh;mem[t].hh.b0:=hf;mem[t].hh.b1:=curr;end;j:=j+1;
begin if j<n then curr:=hu[j+1]+0 else curr:=bchar;
if odd(hyf[j])then currh:=hchar else currh:=256;end;end;end end;
if q.b2>4 then if q.b2<>7 then goto 30;goto 22;end{:911};
w:=fontinfo[kernbase[hf]+256*q.b2+q.b3].int;goto 30;end;
if q.b0>=128 then if currh=256 then goto 30 else begin currh:=256;
goto 22;end;k:=k+q.b0+1;q:=fontinfo[k].qqqq;end;30:{:909};
{910:}if ligaturepresent then begin p:=newligature(hf,curl,mem[curq].hh.
rh);if lfthit then begin mem[p].hh.b1:=2;lfthit:=false;end;
if rthit then if ligstack=0 then begin mem[p].hh.b1:=mem[p].hh.b1+1;
rthit:=false;end;mem[curq].hh.rh:=p;t:=p;ligaturepresent:=false;end;
if w<>0 then begin mem[t].hh.rh:=newkern(w);t:=mem[t].hh.rh;w:=0;end;
if ligstack>0 then begin curq:=t;curl:=mem[ligstack].hh.b1;
ligaturepresent:=true;
begin if mem[ligstack+1].hh.rh>0 then begin mem[t].hh.rh:=mem[ligstack+1
].hh.rh;t:=mem[t].hh.rh;j:=j+1;end;p:=ligstack;ligstack:=mem[p].hh.rh;
freenode(p,2);
if ligstack=0 then begin if j<n then curr:=hu[j+1]+0 else curr:=bchar;
if odd(hyf[j])then currh:=hchar else currh:=256;
end else curr:=mem[ligstack].hh.b1;end;goto 22;end{:910};
reconstitute:=j;end;{:906}procedure hyphenate;
label 50,30,40,41,42,45,10;var{901:}i,j,l:0..65;q,r,s:halfword;
bchar:halfword;{:901}{912:}majortail,minortail:halfword;c:ASCIIcode;
cloc:0..63;rcount:integer;hyfnode:halfword;{:912}{922:}z:triepointer;
v:integer;{:922}{929:}h:hyphpointer;k:strnumber;u:poolpointer;
{:929}begin{923:}for j:=0 to hn do hyf[j]:=0;{930:}h:=hc[1];hn:=hn+1;
hc[hn]:=curlang;for j:=2 to hn do h:=(h+h+hc[j])mod 307;
while true do begin{931:}k:=hyphword[h];if k=0 then goto 45;
if(strstart[k+1]-strstart[k])<hn then goto 45;
if(strstart[k+1]-strstart[k])=hn then begin j:=1;u:=strstart[k];
repeat if strpool[u]<hc[j]then goto 45;if strpool[u]>hc[j]then goto 30;
j:=j+1;u:=u+1;until j>hn;{932:}s:=hyphlist[h];
while s<>0 do begin hyf[mem[s].hh.lh]:=1;s:=mem[s].hh.rh;end{:932};
hn:=hn-1;goto 40;end;30:{:931};if h>0 then h:=h-1 else h:=307;end;
45:hn:=hn-1{:930};if trie[curlang+1].b1<>curlang+0 then goto 10;
hc[0]:=0;hc[hn+1]:=0;hc[hn+2]:=256;
for j:=0 to hn-rhyf+1 do begin z:=trie[curlang+1].rh+hc[j];l:=j;
while hc[l]=trie[z].b1-0 do begin if trie[z].b0<>0 then{924:}begin v:=
trie[z].b0;repeat v:=v+opstart[curlang];i:=l-hyfdistance[v];
if hyfnum[v]>hyf[i]then hyf[i]:=hyfnum[v];v:=hyfnext[v];until v=0;
end{:924};l:=l+1;z:=trie[z].rh+hc[l];end;end;
40:for j:=0 to lhyf-1 do hyf[j]:=0;
for j:=0 to rhyf-1 do hyf[hn-j]:=0{:923};
{902:}for j:=lhyf to hn-rhyf do if odd(hyf[j])then goto 41;goto 10;
41:{:902};{903:}q:=mem[hb].hh.rh;mem[hb].hh.rh:=0;r:=mem[ha].hh.rh;
mem[ha].hh.rh:=0;bchar:=hyfbchar;
if(ha>=himemmin)then if mem[ha].hh.b0<>hf then goto 42 else begin
initlist:=ha;initlig:=false;hu[0]:=mem[ha].hh.b1-0;
end else if mem[ha].hh.b0=6 then if mem[ha+1].hh.b0<>hf then goto 42
else begin initlist:=mem[ha+1].hh.rh;initlig:=true;
initlft:=(mem[ha].hh.b1>1);hu[0]:=mem[ha+1].hh.b1-0;
if initlist=0 then if initlft then begin hu[0]:=256;initlig:=false;end;
freenode(ha,2);
end else begin if not(r>=himemmin)then if mem[r].hh.b0=6 then if mem[r].
hh.b1>1 then goto 42;j:=1;s:=ha;initlist:=0;goto 50;end;s:=curp;
while mem[s].hh.rh<>ha do s:=mem[s].hh.rh;j:=0;goto 50;42:s:=ha;j:=0;
hu[0]:=256;initlig:=false;initlist:=0;50:flushnodelist(r);
{913:}repeat l:=j;j:=reconstitute(j,hn,bchar,hyfchar+0)+1;
if hyphenpassed=0 then begin mem[s].hh.rh:=mem[29996].hh.rh;
while mem[s].hh.rh>0 do s:=mem[s].hh.rh;if odd(hyf[j-1])then begin l:=j;
hyphenpassed:=j-1;mem[29996].hh.rh:=0;end;end;
if hyphenpassed>0 then{914:}repeat r:=getnode(2);
mem[r].hh.rh:=mem[29996].hh.rh;mem[r].hh.b0:=7;majortail:=r;rcount:=0;
while mem[majortail].hh.rh>0 do begin majortail:=mem[majortail].hh.rh;
rcount:=rcount+1;end;i:=hyphenpassed;hyf[i]:=0;{915:}minortail:=0;
mem[r+1].hh.lh:=0;hyfnode:=newcharacter(hf,hyfchar);
if hyfnode<>0 then begin i:=i+1;c:=hu[i];hu[i]:=hyfchar;
begin mem[hyfnode].hh.rh:=avail;avail:=hyfnode;{dynused:=dynused-1;}end;
end;while l<=i do begin l:=reconstitute(l,i,fontbchar[hf],256)+1;
if mem[29996].hh.rh>0 then begin if minortail=0 then mem[r+1].hh.lh:=mem
[29996].hh.rh else mem[minortail].hh.rh:=mem[29996].hh.rh;
minortail:=mem[29996].hh.rh;
while mem[minortail].hh.rh>0 do minortail:=mem[minortail].hh.rh;end;end;
if hyfnode<>0 then begin hu[i]:=c;l:=i;i:=i-1;end{:915};
{916:}minortail:=0;mem[r+1].hh.rh:=0;cloc:=0;
if bcharlabel[hf]<>0 then begin l:=l-1;c:=hu[l];cloc:=l;hu[l]:=256;end;
while l<j do begin repeat l:=reconstitute(l,hn,bchar,256)+1;
if cloc>0 then begin hu[cloc]:=c;cloc:=0;end;
if mem[29996].hh.rh>0 then begin if minortail=0 then mem[r+1].hh.rh:=mem
[29996].hh.rh else mem[minortail].hh.rh:=mem[29996].hh.rh;
minortail:=mem[29996].hh.rh;
while mem[minortail].hh.rh>0 do minortail:=mem[minortail].hh.rh;end;
until l>=j;while l>j do{917:}begin j:=reconstitute(j,hn,bchar,256)+1;
mem[majortail].hh.rh:=mem[29996].hh.rh;
while mem[majortail].hh.rh>0 do begin majortail:=mem[majortail].hh.rh;
rcount:=rcount+1;end;end{:917};end{:916};
{918:}if rcount>127 then begin mem[s].hh.rh:=mem[r].hh.rh;
mem[r].hh.rh:=0;flushnodelist(r);end else begin mem[s].hh.rh:=r;
mem[r].hh.b1:=rcount;end;s:=majortail{:918};hyphenpassed:=j-1;
mem[29996].hh.rh:=0;until not odd(hyf[j-1]){:914};until j>hn;
mem[s].hh.rh:=q{:913};flushlist(initlist){:903};10:end;
{:895}{942:}{944:}function newtrieop(d,n:smallnumber;
v:quarterword):quarterword;label 10;var h:-trieopsize..trieopsize;
u:quarterword;l:0..trieopsize;
begin h:=abs(n+313*d+361*v+1009*curlang)mod(trieopsize+trieopsize)-
trieopsize;while true do begin l:=trieophash[h];
if l=0 then begin if trieopptr=trieopsize then overflow(960,trieopsize);
u:=trieused[curlang];if u=255 then overflow(961,255);
trieopptr:=trieopptr+1;u:=u+1;trieused[curlang]:=u;
hyfdistance[trieopptr]:=d;hyfnum[trieopptr]:=n;hyfnext[trieopptr]:=v;
trieoplang[trieopptr]:=curlang;trieophash[h]:=trieopptr;
trieopval[trieopptr]:=u;newtrieop:=u;goto 10;end;
if(hyfdistance[l]=d)and(hyfnum[l]=n)and(hyfnext[l]=v)and(trieoplang[l]=
curlang)then begin newtrieop:=trieopval[l];goto 10;end;
if h>-trieopsize then h:=h-1 else h:=trieopsize;end;10:end;
{:944}{948:}function trienode(p:triepointer):triepointer;label 10;
var h:triepointer;q:triepointer;
begin h:=abs(triec[p]+1009*trieo[p]+2718*triel[p]+3142*trier[p])mod
triesize;while true do begin q:=triehash[h];
if q=0 then begin triehash[h]:=p;trienode:=p;goto 10;end;
if(triec[q]=triec[p])and(trieo[q]=trieo[p])and(triel[q]=triel[p])and(
trier[q]=trier[p])then begin trienode:=q;goto 10;end;
if h>0 then h:=h-1 else h:=triesize;end;10:end;
{:948}{949:}function compresstrie(p:triepointer):triepointer;
begin if p=0 then compresstrie:=0 else begin triel[p]:=compresstrie(
triel[p]);trier[p]:=compresstrie(trier[p]);compresstrie:=trienode(p);
end;end;{:949}{953:}procedure firstfit(p:triepointer);label 45,40;
var h:triepointer;z:triepointer;q:triepointer;c:ASCIIcode;
l,r:triepointer;ll:1..256;begin c:=triec[p];z:=triemin[c];
while true do begin h:=z-c;
{954:}if triemax<h+256 then begin if triesize<=h+256 then overflow(962,
triesize);repeat triemax:=triemax+1;trietaken[triemax]:=false;
trie[triemax].rh:=triemax+1;trie[triemax].lh:=triemax-1;
until triemax=h+256;end{:954};if trietaken[h]then goto 45;
{955:}q:=trier[p];
while q>0 do begin if trie[h+triec[q]].rh=0 then goto 45;q:=trier[q];
end;goto 40{:955};45:z:=trie[z].rh;end;40:{956:}trietaken[h]:=true;
triehash[p]:=h;q:=p;repeat z:=h+triec[q];l:=trie[z].lh;r:=trie[z].rh;
trie[r].lh:=l;trie[l].rh:=r;trie[z].rh:=0;
if l<256 then begin if z<256 then ll:=z else ll:=256;
repeat triemin[l]:=r;l:=l+1;until l=ll;end;q:=trier[q];until q=0{:956};
end;{:953}{957:}procedure triepack(p:triepointer);var q:triepointer;
begin repeat q:=triel[p];
if(q>0)and(triehash[q]=0)then begin firstfit(q);triepack(q);end;
p:=trier[p];until p=0;end;{:957}{959:}procedure triefix(p:triepointer);
var q:triepointer;c:ASCIIcode;z:triepointer;begin z:=triehash[p];
repeat q:=triel[p];c:=triec[p];trie[z+c].rh:=triehash[q];
trie[z+c].b1:=c+0;trie[z+c].b0:=trieo[p];if q>0 then triefix(q);
p:=trier[p];until p=0;end;{:959}{960:}procedure newpatterns;label 30,31;
var k,l:0..64;digitsensed:boolean;v:quarterword;p,q:triepointer;
firstchild:boolean;c:ASCIIcode;
begin if trienotready then begin if eqtb[5318].int<=0 then curlang:=0
else if eqtb[5318].int>255 then curlang:=0 else curlang:=eqtb[5318].int;
scanleftbrace;{961:}k:=0;hyf[0]:=0;digitsensed:=false;
while true do begin getxtoken;
case curcmd of 11,12:{962:}if digitsensed or(curchr<48)or(curchr>57)then
begin if curchr=46 then curchr:=0 else begin curchr:=eqtb[4244+curchr].
hh.rh;if curchr=0 then begin begin if interaction=3 then;printnl(263);
print(968);end;begin helpptr:=1;helpline[0]:=967;end;error;end;end;
if k<63 then begin k:=k+1;hc[k]:=curchr;hyf[k]:=0;digitsensed:=false;
end;end else if k<63 then begin hyf[k]:=curchr-48;digitsensed:=true;
end{:962};
10,2:begin if k>0 then{963:}begin{965:}if hc[1]=0 then hyf[0]:=0;
if hc[k]=0 then hyf[k]:=0;l:=k;v:=0;
while true do begin if hyf[l]<>0 then v:=newtrieop(k-l,hyf[l],v);
if l>0 then l:=l-1 else goto 31;end;31:{:965};q:=0;hc[0]:=curlang;
while l<=k do begin c:=hc[l];l:=l+1;p:=triel[q];firstchild:=true;
while(p>0)and(c>triec[p])do begin q:=p;p:=trier[q];firstchild:=false;
end;
if(p=0)or(c<triec[p])then{964:}begin if trieptr=triesize then overflow(
962,triesize);trieptr:=trieptr+1;trier[trieptr]:=p;p:=trieptr;
triel[p]:=0;if firstchild then triel[q]:=p else trier[q]:=p;triec[p]:=c;
trieo[p]:=0;end{:964};q:=p;end;
if trieo[q]<>0 then begin begin if interaction=3 then;printnl(263);
print(969);end;begin helpptr:=1;helpline[0]:=967;end;error;end;
trieo[q]:=v;end{:963};if curcmd=2 then goto 30;k:=0;hyf[0]:=0;
digitsensed:=false;end;others:begin begin if interaction=3 then;
printnl(263);print(966);end;printesc(964);begin helpptr:=1;
helpline[0]:=967;end;error;end end;end;30:{:961};
if eqtb[5331].int>0 then{1588:}begin c:=curlang;firstchild:=false;p:=0;
repeat q:=p;p:=trier[q];until(p=0)or(c<=triec[p]);
if(p=0)or(c<triec[p])then{964:}begin if trieptr=triesize then overflow(
962,triesize);trieptr:=trieptr+1;trier[trieptr]:=p;p:=trieptr;
triel[p]:=0;if firstchild then triel[q]:=p else trier[q]:=p;triec[p]:=c;
trieo[p]:=0;end{:964};q:=p;{1589:}p:=triel[q];firstchild:=true;
for c:=0 to 255 do if(eqtb[4244+c].hh.rh>0)or((c=255)and firstchild)then
begin if p=0 then{964:}begin if trieptr=triesize then overflow(962,
triesize);trieptr:=trieptr+1;trier[trieptr]:=p;p:=trieptr;triel[p]:=0;
if firstchild then triel[q]:=p else trier[q]:=p;triec[p]:=c;trieo[p]:=0;
end{:964}else triec[p]:=c;trieo[p]:=eqtb[4244+c].hh.rh+0;q:=p;
p:=trier[q];firstchild:=false;end;
if firstchild then triel[q]:=0 else trier[q]:=0{:1589};end{:1588};
end else begin begin if interaction=3 then;printnl(263);print(963);end;
printesc(964);begin helpptr:=1;helpline[0]:=965;end;error;
mem[29988].hh.rh:=scantoks(false,false);flushlist(defref);end;end;
{:960}{966:}procedure inittrie;var p:triepointer;j,k,t:integer;
r,s:triepointer;h:twohalves;begin{952:}{945:}opstart[0]:=-0;
for j:=1 to 255 do opstart[j]:=opstart[j-1]+trieused[j-1]-0;
for j:=1 to trieopptr do trieophash[j]:=opstart[trieoplang[j]]+trieopval
[j];
for j:=1 to trieopptr do while trieophash[j]>j do begin k:=trieophash[j]
;t:=hyfdistance[k];hyfdistance[k]:=hyfdistance[j];hyfdistance[j]:=t;
t:=hyfnum[k];hyfnum[k]:=hyfnum[j];hyfnum[j]:=t;t:=hyfnext[k];
hyfnext[k]:=hyfnext[j];hyfnext[j]:=t;trieophash[j]:=trieophash[k];
trieophash[k]:=k;end{:945};for p:=0 to triesize do triehash[p]:=0;
trier[0]:=compresstrie(trier[0]);triel[0]:=compresstrie(triel[0]);
for p:=0 to trieptr do triehash[p]:=0;
for p:=0 to 255 do triemin[p]:=p+1;trie[0].rh:=1;triemax:=0{:952};
if triel[0]<>0 then begin firstfit(triel[0]);triepack(triel[0]);end;
if trier[0]<>0 then{1590:}begin if triel[0]=0 then for p:=0 to 255 do
triemin[p]:=p+2;firstfit(trier[0]);triepack(trier[0]);
hyphstart:=triehash[trier[0]];end{:1590};{958:}h.rh:=0;h.b0:=0;h.b1:=0;
if triemax=0 then begin for r:=0 to 256 do trie[r]:=h;triemax:=256;
end else begin if trier[0]>0 then triefix(trier[0]);
if triel[0]>0 then triefix(triel[0]);r:=0;repeat s:=trie[r].rh;
trie[r]:=h;r:=s;until r>triemax;end;trie[0].b1:=63;{:958};
trienotready:=false;end;{:966}{:942}procedure linebreak(d:boolean);
label 30,31,32,33,34,35,22;var{862:}autobreaking:boolean;prevp:halfword;
q,r,s,prevs:halfword;f:internalfontnumber;{:862}{893:}j:smallnumber;
c:0..255;{:893}begin packbeginline:=curlist.mlfield;
{816:}mem[29997].hh.rh:=mem[curlist.headfield].hh.rh;
if(curlist.tailfield>=himemmin)then begin mem[curlist.tailfield].hh.rh:=
newpenalty(10000);curlist.tailfield:=mem[curlist.tailfield].hh.rh;
end else if mem[curlist.tailfield].hh.b0<>10 then begin mem[curlist.
tailfield].hh.rh:=newpenalty(10000);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;
end else begin mem[curlist.tailfield].hh.b0:=12;
deleteglueref(mem[curlist.tailfield+1].hh.lh);
flushnodelist(mem[curlist.tailfield+1].hh.rh);
mem[curlist.tailfield+1].int:=10000;end;
mem[curlist.tailfield].hh.rh:=newparamglue(14);
lastlinefill:=mem[curlist.tailfield].hh.rh;
initcurlang:=curlist.pgfield mod 65536;
initlhyf:=curlist.pgfield div 4194304;
initrhyf:=(curlist.pgfield div 65536)mod 64;popnest;
{:816}{827:}noshrinkerroryet:=true;
if(mem[eqtb[2889].hh.rh].hh.b1<>0)and(mem[eqtb[2889].hh.rh+3].int<>0)
then begin eqtb[2889].hh.rh:=finiteshrink(eqtb[2889].hh.rh);end;
if(mem[eqtb[2890].hh.rh].hh.b1<>0)and(mem[eqtb[2890].hh.rh+3].int<>0)
then begin eqtb[2890].hh.rh:=finiteshrink(eqtb[2890].hh.rh);end;
q:=eqtb[2889].hh.rh;r:=eqtb[2890].hh.rh;
background[1]:=mem[q+1].int+mem[r+1].int;background[2]:=0;
background[3]:=0;background[4]:=0;background[5]:=0;
background[2+mem[q].hh.b0]:=mem[q+2].int;
background[2+mem[r].hh.b0]:=background[2+mem[r].hh.b0]+mem[r+2].int;
background[6]:=mem[q+3].int+mem[r+3].int;{1576:}dolastlinefit:=false;
activenodesize:=3;
if eqtb[5329].int>0 then begin q:=mem[lastlinefill+1].hh.lh;
if(mem[q+2].int>0)and(mem[q].hh.b0>0)then if(background[3]=0)and(
background[4]=0)and(background[5]=0)then begin dolastlinefit:=true;
activenodesize:=5;fillwidth[0]:=0;fillwidth[1]:=0;fillwidth[2]:=0;
fillwidth[mem[q].hh.b0-1]:=mem[q+2].int;end;end{:1576};
{:827}{834:}minimumdemerits:=1073741823;minimaldemerits[3]:=1073741823;
minimaldemerits[2]:=1073741823;minimaldemerits[1]:=1073741823;
minimaldemerits[0]:=1073741823;
{:834}{848:}if eqtb[3412].hh.rh=0 then if eqtb[5862].int=0 then begin
lastspecialline:=0;secondwidth:=eqtb[5848].int;secondindent:=0;
end else{849:}begin lastspecialline:=abs(eqtb[5309].int);
if eqtb[5309].int<0 then begin firstwidth:=eqtb[5848].int-abs(eqtb[5862]
.int);
if eqtb[5862].int>=0 then firstindent:=eqtb[5862].int else firstindent:=
0;secondwidth:=eqtb[5848].int;secondindent:=0;
end else begin firstwidth:=eqtb[5848].int;firstindent:=0;
secondwidth:=eqtb[5848].int-abs(eqtb[5862].int);
if eqtb[5862].int>=0 then secondindent:=eqtb[5862].int else secondindent
:=0;end;
end{:849}else begin lastspecialline:=mem[eqtb[3412].hh.rh].hh.lh-1;
secondwidth:=mem[eqtb[3412].hh.rh+2*(lastspecialline+1)].int;
secondindent:=mem[eqtb[3412].hh.rh+2*lastspecialline+1].int;end;
if eqtb[5287].int=0 then easyline:=lastspecialline else easyline:=65535
{:848};{863:}threshold:=eqtb[5268].int;
if threshold>=0 then begin{if eqtb[5300].int>0 then begin
begindiagnostic;printnl(944);end;}secondpass:=false;finalpass:=false;
end else begin threshold:=eqtb[5269].int;secondpass:=true;
finalpass:=(eqtb[5865].int<=0);
{if eqtb[5300].int>0 then begindiagnostic;}end;
while true do begin if threshold>10000 then threshold:=10000;
if secondpass then{891:}begin if trienotready then inittrie;
curlang:=initcurlang;lhyf:=initlhyf;rhyf:=initrhyf;
if trie[hyphstart+curlang].b1<>curlang+0 then hyphindex:=0 else
hyphindex:=trie[hyphstart+curlang].rh;end{:891};
{864:}q:=getnode(activenodesize);mem[q].hh.b0:=0;mem[q].hh.b1:=2;
mem[q].hh.rh:=29993;mem[q+1].hh.rh:=0;mem[q+1].hh.lh:=curlist.pgfield+1;
mem[q+2].int:=0;mem[29993].hh.rh:=q;
if dolastlinefit then{1578:}begin mem[q+3].int:=0;mem[q+4].int:=0;
end{:1578};activewidth[1]:=background[1];activewidth[2]:=background[2];
activewidth[3]:=background[3];activewidth[4]:=background[4];
activewidth[5]:=background[5];activewidth[6]:=background[6];passive:=0;
printednode:=29997;passnumber:=0;fontinshortdisplay:=0{:864};
curp:=mem[29997].hh.rh;autobreaking:=true;prevp:=curp;
while(curp<>0)and(mem[29993].hh.rh<>29993)do{866:}begin if(curp>=
himemmin)then{867:}begin prevp:=curp;repeat f:=mem[curp].hh.b0;
activewidth[1]:=activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
]+mem[curp].hh.b1].qqqq.b0].int;curp:=mem[curp].hh.rh;
until not(curp>=himemmin);end{:867};
case mem[curp].hh.b0 of 0,1,2:activewidth[1]:=activewidth[1]+mem[curp+1]
.int;
8:{1362:}if mem[curp].hh.b1=4 then begin curlang:=mem[curp+1].hh.rh;
lhyf:=mem[curp+1].hh.b0;rhyf:=mem[curp+1].hh.b1;
if trie[hyphstart+curlang].b1<>curlang+0 then hyphindex:=0 else
hyphindex:=trie[hyphstart+curlang].rh;end{:1362};
10:begin{868:}if autobreaking then begin if(prevp>=himemmin)then
trybreak(0,0)else if(mem[prevp].hh.b0<9)then trybreak(0,0)else if(mem[
prevp].hh.b0=11)and(mem[prevp].hh.b1<>1)then trybreak(0,0);end;
if(mem[mem[curp+1].hh.lh].hh.b1<>0)and(mem[mem[curp+1].hh.lh+3].int<>0)
then begin mem[curp+1].hh.lh:=finiteshrink(mem[curp+1].hh.lh);end;
q:=mem[curp+1].hh.lh;activewidth[1]:=activewidth[1]+mem[q+1].int;
activewidth[2+mem[q].hh.b0]:=activewidth[2+mem[q].hh.b0]+mem[q+2].int;
activewidth[6]:=activewidth[6]+mem[q+3].int{:868};
if secondpass and autobreaking then{894:}begin prevs:=curp;
s:=mem[prevs].hh.rh;
if s<>0 then begin{896:}while true do begin if(s>=himemmin)then begin c
:=mem[s].hh.b1-0;hf:=mem[s].hh.b0;
end else if mem[s].hh.b0=6 then if mem[s+1].hh.rh=0 then goto 22 else
begin q:=mem[s+1].hh.rh;c:=mem[q].hh.b1-0;hf:=mem[q].hh.b0;
end else if(mem[s].hh.b0=11)and(mem[s].hh.b1=0)then goto 22 else if mem[
s].hh.b0=8 then begin{1363:}if mem[s].hh.b1=4 then begin curlang:=mem[s
+1].hh.rh;lhyf:=mem[s+1].hh.b0;rhyf:=mem[s+1].hh.b1;
if trie[hyphstart+curlang].b1<>curlang+0 then hyphindex:=0 else
hyphindex:=trie[hyphstart+curlang].rh;end{:1363};goto 22;
end else goto 31;
if hyphindex=0 then hc[0]:=eqtb[4244+c].hh.rh else if trie[hyphindex+c].
b1<>c+0 then hc[0]:=0 else hc[0]:=trie[hyphindex+c].b0-0;
if hc[0]<>0 then if(hc[0]=c)or(eqtb[5306].int>0)then goto 32 else goto
31;22:prevs:=s;s:=mem[prevs].hh.rh;end;32:hyfchar:=hyphenchar[hf];
if hyfchar<0 then goto 31;if hyfchar>255 then goto 31;ha:=prevs{:896};
if lhyf+rhyf>63 then goto 31;{897:}hn:=0;
while true do begin if(s>=himemmin)then begin if mem[s].hh.b0<>hf then
goto 33;hyfbchar:=mem[s].hh.b1;c:=hyfbchar-0;
if hyphindex=0 then hc[0]:=eqtb[4244+c].hh.rh else if trie[hyphindex+c].
b1<>c+0 then hc[0]:=0 else hc[0]:=trie[hyphindex+c].b0-0;
if hc[0]=0 then goto 33;if hn=63 then goto 33;hb:=s;hn:=hn+1;hu[hn]:=c;
hc[hn]:=hc[0];hyfbchar:=256;
end else if mem[s].hh.b0=6 then{898:}begin if mem[s+1].hh.b0<>hf then
goto 33;j:=hn;q:=mem[s+1].hh.rh;if q>0 then hyfbchar:=mem[q].hh.b1;
while q>0 do begin c:=mem[q].hh.b1-0;
if hyphindex=0 then hc[0]:=eqtb[4244+c].hh.rh else if trie[hyphindex+c].
b1<>c+0 then hc[0]:=0 else hc[0]:=trie[hyphindex+c].b0-0;
if hc[0]=0 then goto 33;if j=63 then goto 33;j:=j+1;hu[j]:=c;
hc[j]:=hc[0];q:=mem[q].hh.rh;end;hb:=s;hn:=j;
if odd(mem[s].hh.b1)then hyfbchar:=fontbchar[hf]else hyfbchar:=256;
end{:898}else if(mem[s].hh.b0=11)and(mem[s].hh.b1=0)then begin hb:=s;
hyfbchar:=fontbchar[hf];end else goto 33;s:=mem[s].hh.rh;end;33:{:897};
{899:}if hn<lhyf+rhyf then goto 31;
while true do begin if not((s>=himemmin))then case mem[s].hh.b0 of 6:;
11:if mem[s].hh.b1<>0 then goto 34;8,10,12,3,5,4:goto 34;
others:goto 31 end;s:=mem[s].hh.rh;end;34:{:899};hyphenate;end;
31:end{:894};end;
11:if mem[curp].hh.b1=1 then begin if not(mem[curp].hh.rh>=himemmin)and
autobreaking then if mem[mem[curp].hh.rh].hh.b0=10 then trybreak(0,0);
activewidth[1]:=activewidth[1]+mem[curp+1].int;
end else activewidth[1]:=activewidth[1]+mem[curp+1].int;
6:begin f:=mem[curp+1].hh.b0;
activewidth[1]:=activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
]+mem[curp+1].hh.b1].qqqq.b0].int;end;
7:{869:}begin s:=mem[curp+1].hh.lh;discwidth:=0;
if s=0 then trybreak(eqtb[5272].int,1)else begin repeat{870:}if(s>=
himemmin)then begin f:=mem[s].hh.b0;
discwidth:=discwidth+fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[s].
hh.b1].qqqq.b0].int;
end else case mem[s].hh.b0 of 6:begin f:=mem[s+1].hh.b0;
discwidth:=discwidth+fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[s+1]
.hh.b1].qqqq.b0].int;end;0,1,2,11:discwidth:=discwidth+mem[s+1].int;
others:confusion(948)end{:870};s:=mem[s].hh.rh;until s=0;
activewidth[1]:=activewidth[1]+discwidth;trybreak(eqtb[5271].int,1);
activewidth[1]:=activewidth[1]-discwidth;end;r:=mem[curp].hh.b1;
s:=mem[curp].hh.rh;
while r>0 do begin{871:}if(s>=himemmin)then begin f:=mem[s].hh.b0;
activewidth[1]:=activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
]+mem[s].hh.b1].qqqq.b0].int;
end else case mem[s].hh.b0 of 6:begin f:=mem[s+1].hh.b0;
activewidth[1]:=activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
]+mem[s+1].hh.b1].qqqq.b0].int;end;
0,1,2,11:activewidth[1]:=activewidth[1]+mem[s+1].int;
others:confusion(949)end{:871};r:=r-1;s:=mem[s].hh.rh;end;prevp:=curp;
curp:=s;goto 35;end{:869};
9:begin if mem[curp].hh.b1<4 then autobreaking:=odd(mem[curp].hh.b1);
begin if not(mem[curp].hh.rh>=himemmin)and autobreaking then if mem[mem[
curp].hh.rh].hh.b0=10 then trybreak(0,0);
activewidth[1]:=activewidth[1]+mem[curp+1].int;end;end;
12:trybreak(mem[curp+1].int,0);4,3,5:;others:confusion(947)end;
prevp:=curp;curp:=mem[curp].hh.rh;35:end{:866};
if curp=0 then{873:}begin trybreak(-10000,1);
if mem[29993].hh.rh<>29993 then begin{874:}r:=mem[29993].hh.rh;
fewestdemerits:=1073741823;
repeat if mem[r].hh.b0<>2 then if mem[r+2].int<fewestdemerits then begin
fewestdemerits:=mem[r+2].int;bestbet:=r;end;r:=mem[r].hh.rh;
until r=29993;bestline:=mem[bestbet+1].hh.lh{:874};
if eqtb[5287].int=0 then goto 30;{875:}begin r:=mem[29993].hh.rh;
actuallooseness:=0;
repeat if mem[r].hh.b0<>2 then begin linediff:=mem[r+1].hh.lh-bestline;
if((linediff<actuallooseness)and(eqtb[5287].int<=linediff))or((linediff>
actuallooseness)and(eqtb[5287].int>=linediff))then begin bestbet:=r;
actuallooseness:=linediff;fewestdemerits:=mem[r+2].int;
end else if(linediff=actuallooseness)and(mem[r+2].int<fewestdemerits)
then begin bestbet:=r;fewestdemerits:=mem[r+2].int;end;end;
r:=mem[r].hh.rh;until r=29993;bestline:=mem[bestbet+1].hh.lh;end{:875};
if(actuallooseness=eqtb[5287].int)or finalpass then goto 30;end;
end{:873};{865:}q:=mem[29993].hh.rh;
while q<>29993 do begin curp:=mem[q].hh.rh;
if mem[q].hh.b0=2 then freenode(q,7)else freenode(q,activenodesize);
q:=curp;end;q:=passive;while q<>0 do begin curp:=mem[q].hh.rh;
freenode(q,2);q:=curp;end{:865};
if not secondpass then begin{if eqtb[5300].int>0 then printnl(945);}
threshold:=eqtb[5269].int;secondpass:=true;
finalpass:=(eqtb[5865].int<=0);
end else begin{if eqtb[5300].int>0 then printnl(946);}
background[2]:=background[2]+eqtb[5865].int;finalpass:=true;end;end;
30:{if eqtb[5300].int>0 then begin enddiagnostic(true);
normalizeselector;end;}
if dolastlinefit then{1586:}if mem[bestbet+3].int=0 then dolastlinefit:=
false else begin q:=newspec(mem[lastlinefill+1].hh.lh);
deleteglueref(mem[lastlinefill+1].hh.lh);
mem[q+1].int:=mem[q+1].int+mem[bestbet+3].int-mem[bestbet+4].int;
mem[q+2].int:=0;mem[lastlinefill+1].hh.lh:=q;end{:1586};{:863};
{876:}postlinebreak(d){:876};{865:}q:=mem[29993].hh.rh;
while q<>29993 do begin curp:=mem[q].hh.rh;
if mem[q].hh.b0=2 then freenode(q,7)else freenode(q,activenodesize);
q:=curp;end;q:=passive;while q<>0 do begin curp:=mem[q].hh.rh;
freenode(q,2);q:=curp;end{:865};packbeginline:=0;end;
{1387:}function eTeXenabled(b:boolean;j:quarterword;k:halfword):boolean;
begin if not b then begin begin if interaction=3 then;printnl(263);
print(689);end;printcmdchr(j,k);begin helpptr:=1;helpline[0]:=1316;end;
error;end;eTeXenabled:=b;end;{:1387}{1410:}procedure showsavegroups;
label 41,42,40,30;var p:0..nestsize;m:-203..203;v:savepointer;
l:quarterword;c:groupcode;a:-1..1;i:integer;j:quarterword;s:strnumber;
begin p:=nestptr;nest[p]:=curlist;v:=saveptr;l:=curlevel;c:=curgroup;
saveptr:=curboundary;curlevel:=curlevel-1;a:=1;printnl(339);println;
while true do begin printnl(366);printgroup(true);
if curgroup=0 then goto 30;repeat m:=nest[p].modefield;
if p>0 then p:=p-1 else m:=1;until m<>102;print(287);
case curgroup of 1:begin p:=p+1;goto 42;end;2,3:s:=1071;4:s:=978;
5:s:=1070;6:if a=0 then begin if m=-1 then s:=523 else s:=542;a:=1;
goto 41;end else begin if a=1 then print(1353)else printesc(910);
if p>=a then p:=p-a;a:=0;goto 40;end;7:begin p:=p+1;a:=-1;printesc(530);
goto 42;end;8:begin printesc(401);goto 40;end;9:goto 42;
10,13:begin if curgroup=10 then printesc(352)else printesc(528);
for i:=1 to 3 do if i<=savestack[saveptr-2].int then print(870);goto 42;
end;
11:begin if savestack[saveptr-2].int=255 then printesc(355)else begin
printesc(331);printint(savestack[saveptr-2].int);end;goto 42;end;
12:begin s:=543;goto 41;end;14:begin p:=p+1;printesc(515);goto 40;end;
15:begin if m=203 then printchar(36)else if nest[p].modefield=203 then
begin printcmdchr(48,savestack[saveptr-2].int);goto 40;end;
printchar(36);goto 40;end;
16:begin if mem[nest[p+1].eTeXauxfield].hh.b0=30 then printesc(886)else
printesc(888);goto 40;end;end;{1412:}i:=savestack[saveptr-4].int;
if i<>0 then if i<1073741824 then begin if abs(nest[p].modefield)=1 then
j:=21 else j:=22;if i>0 then printcmdchr(j,0)else printcmdchr(j,1);
printscaled(abs(i));print(400);
end else if i<1073807360 then begin if i>=1073774592 then begin printesc
(1185);i:=i-(32768);end;printesc(540);printint(i-1073741824);
printchar(61);end else printcmdchr(31,i-(1073807261)){:1412};
41:printesc(s);
{1411:}if savestack[saveptr-2].int<>0 then begin printchar(32);
if savestack[saveptr-3].int=0 then print(852)else print(853);
printscaled(savestack[saveptr-2].int);print(400);end{:1411};
42:printchar(123);40:printchar(41);curlevel:=curlevel-1;
curgroup:=savestack[saveptr].hh.b1;
saveptr:=savestack[saveptr].hh.rh end;30:saveptr:=v;curlevel:=l;
curgroup:=c;end;{:1410}{1426:}procedure newinteraction;forward;
{:1426}{:815}{934:}procedure newhyphexceptions;label 21,10,40,45,46;
var n:0..64;j:0..64;h:hyphpointer;k:strnumber;p:halfword;q:halfword;
s,t:strnumber;u,v:poolpointer;begin scanleftbrace;
if eqtb[5318].int<=0 then curlang:=0 else if eqtb[5318].int>255 then
curlang:=0 else curlang:=eqtb[5318].int;
if trienotready then begin hyphindex:=0;goto 46;end;
if trie[hyphstart+curlang].b1<>curlang+0 then hyphindex:=0 else
hyphindex:=trie[hyphstart+curlang].rh;46:{935:}n:=0;p:=0;
while true do begin getxtoken;
21:case curcmd of 11,12,68:{937:}if curchr=45 then{938:}begin if n<63
then begin q:=getavail;mem[q].hh.rh:=p;mem[q].hh.lh:=n;p:=q;end;
end{:938}else begin if hyphindex=0 then hc[0]:=eqtb[4244+curchr].hh.rh
else if trie[hyphindex+curchr].b1<>curchr+0 then hc[0]:=0 else hc[0]:=
trie[hyphindex+curchr].b0-0;
if hc[0]=0 then begin begin if interaction=3 then;printnl(263);
print(956);end;begin helpptr:=2;helpline[1]:=957;helpline[0]:=958;end;
error;end else if n<63 then begin n:=n+1;hc[n]:=hc[0];end;end{:937};
16:begin scancharnum;curchr:=curval;curcmd:=68;goto 21;end;
10,2:begin if n>1 then{939:}begin n:=n+1;hc[n]:=curlang;
begin if poolptr+n>poolsize then overflow(258,poolsize-initpoolptr);end;
h:=0;for j:=1 to n do begin h:=(h+h+hc[j])mod 307;
begin strpool[poolptr]:=hc[j];poolptr:=poolptr+1;end;end;s:=makestring;
{940:}if hyphcount=307 then overflow(959,307);hyphcount:=hyphcount+1;
while hyphword[h]<>0 do begin{941:}k:=hyphword[h];
if(strstart[k+1]-strstart[k])<(strstart[s+1]-strstart[s])then goto 40;
if(strstart[k+1]-strstart[k])>(strstart[s+1]-strstart[s])then goto 45;
u:=strstart[k];v:=strstart[s];
repeat if strpool[u]<strpool[v]then goto 40;
if strpool[u]>strpool[v]then goto 45;u:=u+1;v:=v+1;
until u=strstart[k+1];40:q:=hyphlist[h];hyphlist[h]:=p;p:=q;
t:=hyphword[h];hyphword[h]:=s;s:=t;45:{:941};
if h>0 then h:=h-1 else h:=307;end;hyphword[h]:=s;hyphlist[h]:=p{:940};
end{:939};if curcmd=2 then goto 10;n:=0;p:=0;end;
others:{936:}begin begin if interaction=3 then;printnl(263);print(689);
end;printesc(952);print(953);begin helpptr:=2;helpline[1]:=954;
helpline[0]:=955;end;error;end{:936}end;end{:935};10:end;
{:934}{968:}function prunepagetop(p:halfword;s:boolean):halfword;
var prevp:halfword;q,r:halfword;begin prevp:=29997;mem[29997].hh.rh:=p;
while p<>0 do case mem[p].hh.b0 of 0,1,2:{969:}begin q:=newskipparam(10)
;mem[prevp].hh.rh:=q;mem[q].hh.rh:=p;
if mem[tempptr+1].int>mem[p+3].int then mem[tempptr+1].int:=mem[tempptr
+1].int-mem[p+3].int else mem[tempptr+1].int:=0;p:=0;end{:969};
8,4,3:begin prevp:=p;p:=mem[prevp].hh.rh;end;10,11,12:begin q:=p;
p:=mem[q].hh.rh;mem[q].hh.rh:=0;mem[prevp].hh.rh:=p;
if s then begin if discptr[3]=0 then discptr[3]:=q else mem[r].hh.rh:=q;
r:=q;end else flushnodelist(q);end;others:confusion(970)end;
prunepagetop:=mem[29997].hh.rh;end;
{:968}{970:}function vertbreak(p:halfword;h,d:scaled):halfword;
label 30,45,90;var prevp:halfword;q,r:halfword;pi:integer;b:integer;
leastcost:integer;bestplace:halfword;prevdp:scaled;t:smallnumber;
begin prevp:=p;leastcost:=1073741823;activewidth[1]:=0;
activewidth[2]:=0;activewidth[3]:=0;activewidth[4]:=0;activewidth[5]:=0;
activewidth[6]:=0;prevdp:=0;
while true do begin{972:}if p=0 then pi:=-10000 else{973:}case mem[p].hh
.b0 of 0,1,2:begin activewidth[1]:=activewidth[1]+prevdp+mem[p+3].int;
prevdp:=mem[p+2].int;goto 45;end;8:{1365:}goto 45{:1365};
10:if(mem[prevp].hh.b0<9)then pi:=0 else goto 90;
11:begin if mem[p].hh.rh=0 then t:=12 else t:=mem[mem[p].hh.rh].hh.b0;
if t=10 then pi:=0 else goto 90;end;12:pi:=mem[p+1].int;4,3:goto 45;
others:confusion(971)end{:973};
{974:}if pi<10000 then begin{975:}if activewidth[1]<h then if(
activewidth[3]<>0)or(activewidth[4]<>0)or(activewidth[5]<>0)then b:=0
else b:=badness(h-activewidth[1],activewidth[2])else if activewidth[1]-h
>activewidth[6]then b:=1073741823 else b:=badness(activewidth[1]-h,
activewidth[6]){:975};
if b<1073741823 then if pi<=-10000 then b:=pi else if b<10000 then b:=b+
pi else b:=100000;if b<=leastcost then begin bestplace:=p;leastcost:=b;
bestheightplusdepth:=activewidth[1]+prevdp;end;
if(b=1073741823)or(pi<=-10000)then goto 30;end{:974};
if(mem[p].hh.b0<10)or(mem[p].hh.b0>11)then goto 45;
90:{976:}if mem[p].hh.b0=11 then q:=p else begin q:=mem[p+1].hh.lh;
activewidth[2+mem[q].hh.b0]:=activewidth[2+mem[q].hh.b0]+mem[q+2].int;
activewidth[6]:=activewidth[6]+mem[q+3].int;
if(mem[q].hh.b1<>0)and(mem[q+3].int<>0)then begin begin if interaction=3
then;printnl(263);print(972);end;begin helpptr:=4;helpline[3]:=973;
helpline[2]:=974;helpline[1]:=975;helpline[0]:=933;end;error;
r:=newspec(q);mem[r].hh.b1:=0;deleteglueref(q);mem[p+1].hh.lh:=r;q:=r;
end;end;activewidth[1]:=activewidth[1]+prevdp+mem[q+1].int;
prevdp:=0{:976};
45:if prevdp>d then begin activewidth[1]:=activewidth[1]+prevdp-d;
prevdp:=d;end;{:972};prevp:=p;p:=mem[prevp].hh.rh;end;
30:vertbreak:=bestplace;end;
{:970}{977:}{1558:}function domarks(a,l:smallnumber;q:halfword):boolean;
var i:smallnumber;
begin if l<4 then begin for i:=0 to 15 do begin if odd(i)then curptr:=
mem[q+(i div 2)+1].hh.rh else curptr:=mem[q+(i div 2)+1].hh.lh;
if curptr<>0 then if domarks(a,l+1,curptr)then begin if odd(i)then mem[q
+(i div 2)+1].hh.rh:=0 else mem[q+(i div 2)+1].hh.lh:=0;
mem[q].hh.b1:=mem[q].hh.b1-1;end;end;
if mem[q].hh.b1=0 then begin freenode(q,9);q:=0;end;
end else begin case a of{1559:}0:if mem[q+2].hh.rh<>0 then begin
deletetokenref(mem[q+2].hh.rh);mem[q+2].hh.rh:=0;
deletetokenref(mem[q+3].hh.lh);mem[q+3].hh.lh:=0;end;
{:1559}{1561:}1:if mem[q+2].hh.lh<>0 then begin if mem[q+1].hh.lh<>0
then deletetokenref(mem[q+1].hh.lh);deletetokenref(mem[q+1].hh.rh);
mem[q+1].hh.rh:=0;
if mem[mem[q+2].hh.lh].hh.rh=0 then begin deletetokenref(mem[q+2].hh.lh)
;mem[q+2].hh.lh:=0;
end else mem[mem[q+2].hh.lh].hh.lh:=mem[mem[q+2].hh.lh].hh.lh+1;
mem[q+1].hh.lh:=mem[q+2].hh.lh;end;
{:1561}{1562:}2:if(mem[q+1].hh.lh<>0)and(mem[q+1].hh.rh=0)then begin mem
[q+1].hh.rh:=mem[q+1].hh.lh;
mem[mem[q+1].hh.lh].hh.lh:=mem[mem[q+1].hh.lh].hh.lh+1;end;
{:1562}{1564:}3:for i:=0 to 4 do begin if odd(i)then curptr:=mem[q+(i
div 2)+1].hh.rh else curptr:=mem[q+(i div 2)+1].hh.lh;
if curptr<>0 then begin deletetokenref(curptr);
if odd(i)then mem[q+(i div 2)+1].hh.rh:=0 else mem[q+(i div 2)+1].hh.lh
:=0;end;end;{:1564}end;
if mem[q+2].hh.lh=0 then if mem[q+3].hh.lh=0 then begin freenode(q,4);
q:=0;end;end;domarks:=(q=0);end;{:1558}function vsplit(n:halfword;
h:scaled):halfword;label 10,30;var v:halfword;p:halfword;q:halfword;
begin curval:=n;
if curval<256 then v:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then v:=0 else v:=mem[curptr+1].hh.rh;end;
flushnodelist(discptr[3]);discptr[3]:=0;
if saroot[6]<>0 then if domarks(0,0,saroot[6])then saroot[6]:=0;
if curmark[3]<>0 then begin deletetokenref(curmark[3]);curmark[3]:=0;
deletetokenref(curmark[4]);curmark[4]:=0;end;
{978:}if v=0 then begin vsplit:=0;goto 10;end;
if mem[v].hh.b0<>1 then begin begin if interaction=3 then;printnl(263);
print(339);end;printesc(976);print(977);printesc(978);begin helpptr:=2;
helpline[1]:=979;helpline[0]:=980;end;error;vsplit:=0;goto 10;end{:978};
q:=vertbreak(mem[v+5].hh.rh,h,eqtb[5851].int);{979:}p:=mem[v+5].hh.rh;
if p=q then mem[v+5].hh.rh:=0 else while true do begin if mem[p].hh.b0=4
then if mem[p+1].hh.lh<>0 then{1560:}begin findsaelement(6,mem[p+1].hh.
lh,true);
if mem[curptr+2].hh.rh=0 then begin mem[curptr+2].hh.rh:=mem[p+1].hh.rh;
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;
end else deletetokenref(mem[curptr+3].hh.lh);
mem[curptr+3].hh.lh:=mem[p+1].hh.rh;
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;
end{:1560}else if curmark[3]=0 then begin curmark[3]:=mem[p+1].hh.rh;
curmark[4]:=curmark[3];mem[curmark[3]].hh.lh:=mem[curmark[3]].hh.lh+2;
end else begin deletetokenref(curmark[4]);curmark[4]:=mem[p+1].hh.rh;
mem[curmark[4]].hh.lh:=mem[curmark[4]].hh.lh+1;end;
if mem[p].hh.rh=q then begin mem[p].hh.rh:=0;goto 30;end;
p:=mem[p].hh.rh;end;30:{:979};q:=prunepagetop(q,eqtb[5330].int>0);
p:=mem[v+5].hh.rh;freenode(v,7);
if q<>0 then q:=vpackage(q,0,1,1073741823);
if curval<256 then eqtb[3683+curval].hh.rh:=q else begin findsaelement(4
,curval,false);if curptr<>0 then begin mem[curptr+1].hh.rh:=q;
mem[curptr+1].hh.lh:=mem[curptr+1].hh.lh+1;deletesaref(curptr);end;end;
vsplit:=vpackage(p,h,0,eqtb[5851].int);10:end;
{:977}{985:}procedure printtotals;begin printscaled(pagesofar[1]);
if pagesofar[2]<>0 then begin print(313);printscaled(pagesofar[2]);
print(339);end;if pagesofar[3]<>0 then begin print(313);
printscaled(pagesofar[3]);print(312);end;
if pagesofar[4]<>0 then begin print(313);printscaled(pagesofar[4]);
print(989);end;if pagesofar[5]<>0 then begin print(313);
printscaled(pagesofar[5]);print(990);end;
if pagesofar[6]<>0 then begin print(314);printscaled(pagesofar[6]);end;
end;{:985}{987:}procedure freezepagespecs(s:smallnumber);
begin pagecontents:=s;pagesofar[0]:=eqtb[5849].int;
pagemaxdepth:=eqtb[5850].int;pagesofar[7]:=0;pagesofar[1]:=0;
pagesofar[2]:=0;pagesofar[3]:=0;pagesofar[4]:=0;pagesofar[5]:=0;
pagesofar[6]:=0;leastpagecost:=1073741823;
{if eqtb[5301].int>0 then begin begindiagnostic;printnl(998);
printscaled(pagesofar[0]);print(999);printscaled(pagemaxdepth);
enddiagnostic(false);end;}end;
{:987}{992:}procedure boxerror(n:eightbits);begin error;begindiagnostic;
printnl(846);showbox(eqtb[3683+n].hh.rh);enddiagnostic(true);
flushnodelist(eqtb[3683+n].hh.rh);eqtb[3683+n].hh.rh:=0;end;
{:992}{993:}procedure ensurevbox(n:eightbits);var p:halfword;
begin p:=eqtb[3683+n].hh.rh;
if p<>0 then if mem[p].hh.b0=0 then begin begin if interaction=3 then;
printnl(263);print(1000);end;begin helpptr:=3;helpline[2]:=1001;
helpline[1]:=1002;helpline[0]:=1003;end;boxerror(n);end;end;
{:993}{994:}{1012:}procedure fireup(c:halfword);label 10;
var p,q,r,s:halfword;prevp:halfword;n:0..255;wait:boolean;
savevbadness:integer;savevfuzz:scaled;savesplittopskip:halfword;
begin{1013:}if mem[bestpagebreak].hh.b0=12 then begin geqworddefine(5307
,mem[bestpagebreak+1].int);mem[bestpagebreak+1].int:=10000;
end else geqworddefine(5307,10000){:1013};
if saroot[6]<>0 then if domarks(1,0,saroot[6])then saroot[6]:=0;
if curmark[2]<>0 then begin if curmark[0]<>0 then deletetokenref(curmark
[0]);curmark[0]:=curmark[2];
mem[curmark[0]].hh.lh:=mem[curmark[0]].hh.lh+1;
deletetokenref(curmark[1]);curmark[1]:=0;end;
{1014:}if c=bestpagebreak then bestpagebreak:=0;
{1015:}if eqtb[3938].hh.rh<>0 then begin begin if interaction=3 then;
printnl(263);print(339);end;printesc(412);print(1014);begin helpptr:=2;
helpline[1]:=1015;helpline[0]:=1003;end;boxerror(255);end{:1015};
insertpenalties:=0;savesplittopskip:=eqtb[2892].hh.rh;
if eqtb[5321].int<=0 then{1018:}begin r:=mem[30000].hh.rh;
while r<>30000 do begin if mem[r+2].hh.lh<>0 then begin n:=mem[r].hh.b1
-0;ensurevbox(n);
if eqtb[3683+n].hh.rh=0 then eqtb[3683+n].hh.rh:=newnullbox;
p:=eqtb[3683+n].hh.rh+5;while mem[p].hh.rh<>0 do p:=mem[p].hh.rh;
mem[r+2].hh.rh:=p;end;r:=mem[r].hh.rh;end;end{:1018};q:=29996;
mem[q].hh.rh:=0;prevp:=29998;p:=mem[prevp].hh.rh;
while p<>bestpagebreak do begin if mem[p].hh.b0=3 then begin if eqtb[
5321].int<=0 then{1020:}begin r:=mem[30000].hh.rh;
while mem[r].hh.b1<>mem[p].hh.b1 do r:=mem[r].hh.rh;
if mem[r+2].hh.lh=0 then wait:=true else begin wait:=false;
s:=mem[r+2].hh.rh;mem[s].hh.rh:=mem[p+4].hh.lh;
if mem[r+2].hh.lh=p then{1021:}begin if mem[r].hh.b0=1 then if(mem[r+1].
hh.lh=p)and(mem[r+1].hh.rh<>0)then begin while mem[s].hh.rh<>mem[r+1].hh
.rh do s:=mem[s].hh.rh;mem[s].hh.rh:=0;eqtb[2892].hh.rh:=mem[p+4].hh.rh;
mem[p+4].hh.lh:=prunepagetop(mem[r+1].hh.rh,false);
if mem[p+4].hh.lh<>0 then begin tempptr:=vpackage(mem[p+4].hh.lh,0,1,
1073741823);mem[p+3].int:=mem[tempptr+3].int+mem[tempptr+2].int;
freenode(tempptr,7);wait:=true;end;end;mem[r+2].hh.lh:=0;
n:=mem[r].hh.b1-0;tempptr:=mem[eqtb[3683+n].hh.rh+5].hh.rh;
freenode(eqtb[3683+n].hh.rh,7);
eqtb[3683+n].hh.rh:=vpackage(tempptr,0,1,1073741823);
end{:1021}else begin while mem[s].hh.rh<>0 do s:=mem[s].hh.rh;
mem[r+2].hh.rh:=s;end;end;{1022:}mem[prevp].hh.rh:=mem[p].hh.rh;
mem[p].hh.rh:=0;if wait then begin mem[q].hh.rh:=p;q:=p;
insertpenalties:=insertpenalties+1;
end else begin deleteglueref(mem[p+4].hh.rh);freenode(p,5);end;
p:=prevp{:1022};end{:1020};
end else if mem[p].hh.b0=4 then if mem[p+1].hh.lh<>0 then{1563:}begin
findsaelement(6,mem[p+1].hh.lh,true);
if mem[curptr+1].hh.rh=0 then begin mem[curptr+1].hh.rh:=mem[p+1].hh.rh;
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;end;
if mem[curptr+2].hh.lh<>0 then deletetokenref(mem[curptr+2].hh.lh);
mem[curptr+2].hh.lh:=mem[p+1].hh.rh;
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;
end{:1563}else{1016:}begin if curmark[1]=0 then begin curmark[1]:=mem[p
+1].hh.rh;mem[curmark[1]].hh.lh:=mem[curmark[1]].hh.lh+1;end;
if curmark[2]<>0 then deletetokenref(curmark[2]);
curmark[2]:=mem[p+1].hh.rh;
mem[curmark[2]].hh.lh:=mem[curmark[2]].hh.lh+1;end{:1016};prevp:=p;
p:=mem[prevp].hh.rh;end;eqtb[2892].hh.rh:=savesplittopskip;
{1017:}if p<>0 then begin if mem[29999].hh.rh=0 then if nestptr=0 then
curlist.tailfield:=pagetail else nest[0].tailfield:=pagetail;
mem[pagetail].hh.rh:=mem[29999].hh.rh;mem[29999].hh.rh:=p;
mem[prevp].hh.rh:=0;end;savevbadness:=eqtb[5295].int;
eqtb[5295].int:=10000;savevfuzz:=eqtb[5854].int;
eqtb[5854].int:=1073741823;
eqtb[3938].hh.rh:=vpackage(mem[29998].hh.rh,bestsize,0,pagemaxdepth);
eqtb[5295].int:=savevbadness;eqtb[5854].int:=savevfuzz;
if lastglue<>65535 then deleteglueref(lastglue);{991:}pagecontents:=0;
pagetail:=29998;mem[29998].hh.rh:=0;lastglue:=65535;lastpenalty:=0;
lastkern:=0;lastnodetype:=-1;pagesofar[7]:=0;pagemaxdepth:=0{:991};
if q<>29996 then begin mem[29998].hh.rh:=mem[29996].hh.rh;pagetail:=q;
end{:1017};{1019:}r:=mem[30000].hh.rh;
while r<>30000 do begin q:=mem[r].hh.rh;freenode(r,4);r:=q;end;
mem[30000].hh.rh:=30000{:1019}{:1014};
if saroot[6]<>0 then if domarks(2,0,saroot[6])then saroot[6]:=0;
if(curmark[0]<>0)and(curmark[1]=0)then begin curmark[1]:=curmark[0];
mem[curmark[0]].hh.lh:=mem[curmark[0]].hh.lh+1;end;
if eqtb[3413].hh.rh<>0 then if deadcycles>=eqtb[5308].int then{1024:}
begin begin if interaction=3 then;printnl(263);print(1016);end;
printint(deadcycles);print(1017);begin helpptr:=3;helpline[2]:=1018;
helpline[1]:=1019;helpline[0]:=1020;end;error;
end{:1024}else{1025:}begin outputactive:=true;deadcycles:=deadcycles+1;
pushnest;curlist.modefield:=-1;curlist.auxfield.int:=-65536000;
curlist.mlfield:=-line;begintokenlist(eqtb[3413].hh.rh,6);
newsavelevel(8);normalparagraph;scanleftbrace;goto 10;end{:1025};
{1023:}begin if mem[29998].hh.rh<>0 then begin if mem[29999].hh.rh=0
then if nestptr=0 then curlist.tailfield:=pagetail else nest[0].
tailfield:=pagetail else mem[pagetail].hh.rh:=mem[29999].hh.rh;
mem[29999].hh.rh:=mem[29998].hh.rh;mem[29998].hh.rh:=0;pagetail:=29998;
end;flushnodelist(discptr[2]);discptr[2]:=0;shipout(eqtb[3938].hh.rh);
eqtb[3938].hh.rh:=0;end{:1023};10:end;{:1012}procedure buildpage;
label 10,30,31,22,80,90;var p:halfword;q,r:halfword;b,c:integer;
pi:integer;n:0..255;delta,h,w:scaled;
begin if(mem[29999].hh.rh=0)or outputactive then goto 10;
repeat 22:p:=mem[29999].hh.rh;
{996:}if lastglue<>65535 then deleteglueref(lastglue);lastpenalty:=0;
lastkern:=0;lastnodetype:=mem[p].hh.b0+1;
if mem[p].hh.b0=10 then begin lastglue:=mem[p+1].hh.lh;
mem[lastglue].hh.rh:=mem[lastglue].hh.rh+1;
end else begin lastglue:=65535;
if mem[p].hh.b0=12 then lastpenalty:=mem[p+1].int else if mem[p].hh.b0=
11 then lastkern:=mem[p+1].int;end{:996};
{997:}{1000:}case mem[p].hh.b0 of 0,1,2:if pagecontents<2 then{1001:}
begin if pagecontents=0 then freezepagespecs(2)else pagecontents:=2;
q:=newskipparam(9);
if mem[tempptr+1].int>mem[p+3].int then mem[tempptr+1].int:=mem[tempptr
+1].int-mem[p+3].int else mem[tempptr+1].int:=0;mem[q].hh.rh:=p;
mem[29999].hh.rh:=q;goto 22;
end{:1001}else{1002:}begin pagesofar[1]:=pagesofar[1]+pagesofar[7]+mem[p
+3].int;pagesofar[7]:=mem[p+2].int;goto 80;end{:1002};
8:{1364:}goto 80{:1364};
10:if pagecontents<2 then goto 31 else if(mem[pagetail].hh.b0<9)then pi
:=0 else goto 90;
11:if pagecontents<2 then goto 31 else if mem[p].hh.rh=0 then goto 10
else if mem[mem[p].hh.rh].hh.b0=10 then pi:=0 else goto 90;
12:if pagecontents<2 then goto 31 else pi:=mem[p+1].int;4:goto 80;
3:{1008:}begin if pagecontents=0 then freezepagespecs(1);
n:=mem[p].hh.b1;r:=30000;
while n>=mem[mem[r].hh.rh].hh.b1 do r:=mem[r].hh.rh;n:=n-0;
if mem[r].hh.b1<>n+0 then{1009:}begin q:=getnode(4);
mem[q].hh.rh:=mem[r].hh.rh;mem[r].hh.rh:=q;r:=q;mem[r].hh.b1:=n+0;
mem[r].hh.b0:=0;ensurevbox(n);
if eqtb[3683+n].hh.rh=0 then mem[r+3].int:=0 else mem[r+3].int:=mem[eqtb
[3683+n].hh.rh+3].int+mem[eqtb[3683+n].hh.rh+2].int;mem[r+2].hh.lh:=0;
q:=eqtb[2900+n].hh.rh;
if eqtb[5333+n].int=1000 then h:=mem[r+3].int else h:=xovern(mem[r+3].
int,1000)*eqtb[5333+n].int;pagesofar[0]:=pagesofar[0]-h-mem[q+1].int;
pagesofar[2+mem[q].hh.b0]:=pagesofar[2+mem[q].hh.b0]+mem[q+2].int;
pagesofar[6]:=pagesofar[6]+mem[q+3].int;
if(mem[q].hh.b1<>0)and(mem[q+3].int<>0)then begin begin if interaction=3
then;printnl(263);print(1009);end;printesc(398);printint(n);
begin helpptr:=3;helpline[2]:=1010;helpline[1]:=1011;helpline[0]:=933;
end;error;end;end{:1009};
if mem[r].hh.b0=1 then insertpenalties:=insertpenalties+mem[p+1].int
else begin mem[r+2].hh.rh:=p;
delta:=pagesofar[0]-pagesofar[1]-pagesofar[7]+pagesofar[6];
if eqtb[5333+n].int=1000 then h:=mem[p+3].int else h:=xovern(mem[p+3].
int,1000)*eqtb[5333+n].int;
if((h<=0)or(h<=delta))and(mem[p+3].int+mem[r+3].int<=eqtb[5866+n].int)
then begin pagesofar[0]:=pagesofar[0]-h;
mem[r+3].int:=mem[r+3].int+mem[p+3].int;
end else{1010:}begin if eqtb[5333+n].int<=0 then w:=1073741823 else
begin w:=pagesofar[0]-pagesofar[1]-pagesofar[7];
if eqtb[5333+n].int<>1000 then w:=xovern(w,eqtb[5333+n].int)*1000;end;
if w>eqtb[5866+n].int-mem[r+3].int then w:=eqtb[5866+n].int-mem[r+3].int
;q:=vertbreak(mem[p+4].hh.lh,w,mem[p+2].int);
mem[r+3].int:=mem[r+3].int+bestheightplusdepth;
{if eqtb[5301].int>0 then[1011:]begin begindiagnostic;printnl(1012);
printint(n);print(1013);printscaled(w);printchar(44);
printscaled(bestheightplusdepth);print(942);
if q=0 then printint(-10000)else if mem[q].hh.b0=12 then printint(mem[q
+1].int)else printchar(48);enddiagnostic(false);end[:1011];}
if eqtb[5333+n].int<>1000 then bestheightplusdepth:=xovern(
bestheightplusdepth,1000)*eqtb[5333+n].int;
pagesofar[0]:=pagesofar[0]-bestheightplusdepth;mem[r].hh.b0:=1;
mem[r+1].hh.rh:=q;mem[r+1].hh.lh:=p;
if q=0 then insertpenalties:=insertpenalties-10000 else if mem[q].hh.b0=
12 then insertpenalties:=insertpenalties+mem[q+1].int;end{:1010};end;
goto 80;end{:1008};others:confusion(1004)end{:1000};
{1005:}if pi<10000 then begin{1007:}if pagesofar[1]<pagesofar[0]then if(
pagesofar[3]<>0)or(pagesofar[4]<>0)or(pagesofar[5]<>0)then b:=0 else b:=
badness(pagesofar[0]-pagesofar[1],pagesofar[2])else if pagesofar[1]-
pagesofar[0]>pagesofar[6]then b:=1073741823 else b:=badness(pagesofar[1]
-pagesofar[0],pagesofar[6]){:1007};
if b<1073741823 then if pi<=-10000 then c:=pi else if b<10000 then c:=b+
pi+insertpenalties else c:=100000 else c:=b;
if insertpenalties>=10000 then c:=1073741823;
{if eqtb[5301].int>0 then[1006:]begin begindiagnostic;printnl(37);
print(938);printtotals;print(1007);printscaled(pagesofar[0]);print(941);
if b=1073741823 then printchar(42)else printint(b);print(942);
printint(pi);print(1008);
if c=1073741823 then printchar(42)else printint(c);
if c<=leastpagecost then printchar(35);enddiagnostic(false);end[:1006];}
if c<=leastpagecost then begin bestpagebreak:=p;bestsize:=pagesofar[0];
leastpagecost:=c;r:=mem[30000].hh.rh;
while r<>30000 do begin mem[r+2].hh.lh:=mem[r+2].hh.rh;r:=mem[r].hh.rh;
end;end;if(c=1073741823)or(pi<=-10000)then begin fireup(p);
if outputactive then goto 10;goto 30;end;end{:1005};
if(mem[p].hh.b0<10)or(mem[p].hh.b0>11)then goto 80;
90:{1004:}if mem[p].hh.b0=11 then q:=p else begin q:=mem[p+1].hh.lh;
pagesofar[2+mem[q].hh.b0]:=pagesofar[2+mem[q].hh.b0]+mem[q+2].int;
pagesofar[6]:=pagesofar[6]+mem[q+3].int;
if(mem[q].hh.b1<>0)and(mem[q+3].int<>0)then begin begin if interaction=3
then;printnl(263);print(1005);end;begin helpptr:=4;helpline[3]:=1006;
helpline[2]:=974;helpline[1]:=975;helpline[0]:=933;end;error;
r:=newspec(q);mem[r].hh.b1:=0;deleteglueref(q);mem[p+1].hh.lh:=r;q:=r;
end;end;pagesofar[1]:=pagesofar[1]+pagesofar[7]+mem[q+1].int;
pagesofar[7]:=0{:1004};
80:{1003:}if pagesofar[7]>pagemaxdepth then begin pagesofar[1]:=
pagesofar[1]+pagesofar[7]-pagemaxdepth;pagesofar[7]:=pagemaxdepth;end;
{:1003};{998:}mem[pagetail].hh.rh:=p;pagetail:=p;
mem[29999].hh.rh:=mem[p].hh.rh;mem[p].hh.rh:=0;goto 30{:998};
31:{999:}mem[29999].hh.rh:=mem[p].hh.rh;mem[p].hh.rh:=0;
if eqtb[5330].int>0 then begin if discptr[2]=0 then discptr[2]:=p else
mem[discptr[1]].hh.rh:=p;discptr[1]:=p;end else flushnodelist(p){:999};
30:{:997};until mem[29999].hh.rh=0;
{995:}if nestptr=0 then curlist.tailfield:=29999 else nest[0].tailfield
:=29999{:995};10:end;{:994}{1030:}{1043:}procedure appspace;
var q:halfword;
begin if(curlist.auxfield.hh.lh>=2000)and(eqtb[2895].hh.rh<>0)then q:=
newparamglue(13)else begin if eqtb[2894].hh.rh<>0 then mainp:=eqtb[2894]
.hh.rh else{1042:}begin mainp:=fontglue[eqtb[3939].hh.rh];
if mainp=0 then begin mainp:=newspec(0);
maink:=parambase[eqtb[3939].hh.rh]+2;
mem[mainp+1].int:=fontinfo[maink].int;
mem[mainp+2].int:=fontinfo[maink+1].int;
mem[mainp+3].int:=fontinfo[maink+2].int;
fontglue[eqtb[3939].hh.rh]:=mainp;end;end{:1042};mainp:=newspec(mainp);
{1044:}if curlist.auxfield.hh.lh>=2000 then mem[mainp+1].int:=mem[mainp
+1].int+fontinfo[7+parambase[eqtb[3939].hh.rh]].int;
mem[mainp+2].int:=xnoverd(mem[mainp+2].int,curlist.auxfield.hh.lh,1000);
mem[mainp+3].int:=xnoverd(mem[mainp+3].int,1000,curlist.auxfield.hh.lh)
{:1044};q:=newglue(mainp);mem[mainp].hh.rh:=0;end;
mem[curlist.tailfield].hh.rh:=q;curlist.tailfield:=q;end;
{:1043}{1047:}procedure insertdollarsign;begin backinput;curtok:=804;
begin if interaction=3 then;printnl(263);print(1028);end;
begin helpptr:=2;helpline[1]:=1029;helpline[0]:=1030;end;inserror;end;
{:1047}{1049:}procedure youcant;begin begin if interaction=3 then;
printnl(263);print(694);end;printcmdchr(curcmd,curchr);print(1031);
printmode(curlist.modefield);end;
{:1049}{1050:}procedure reportillegalcase;begin youcant;
begin helpptr:=4;helpline[3]:=1032;helpline[2]:=1033;helpline[1]:=1034;
helpline[0]:=1035;end;error;end;
{:1050}{1051:}function privileged:boolean;
begin if curlist.modefield>0 then privileged:=true else begin
reportillegalcase;privileged:=false;end;end;
{:1051}{1054:}function itsallover:boolean;label 10;
begin if privileged then begin if(29998=pagetail)and(curlist.headfield=
curlist.tailfield)and(deadcycles=0)then begin itsallover:=true;goto 10;
end;backinput;begin mem[curlist.tailfield].hh.rh:=newnullbox;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield+1].int:=eqtb[5848].int;
begin mem[curlist.tailfield].hh.rh:=newglue(8);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
begin mem[curlist.tailfield].hh.rh:=newpenalty(-1073741824);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;buildpage;end;
itsallover:=false;10:end;{:1054}{1060:}procedure appendglue;
var s:smallnumber;begin s:=curchr;case s of 0:curval:=4;1:curval:=8;
2:curval:=12;3:curval:=16;4:scanglue(2);5:scanglue(3);end;
begin mem[curlist.tailfield].hh.rh:=newglue(curval);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
if s>=4 then begin mem[curval].hh.rh:=mem[curval].hh.rh-1;
if s>4 then mem[curlist.tailfield].hh.b1:=99;end;end;
{:1060}{1061:}procedure appendkern;var s:quarterword;begin s:=curchr;
scandimen(s=99,false,false);
begin mem[curlist.tailfield].hh.rh:=newkern(curval);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b1:=s;end;{:1061}{1064:}procedure offsave;
var p:halfword;
begin if curgroup=0 then{1066:}begin begin if interaction=3 then;
printnl(263);print(787);end;printcmdchr(curcmd,curchr);begin helpptr:=1;
helpline[0]:=1053;end;error;end{:1066}else begin backinput;p:=getavail;
mem[29997].hh.rh:=p;begin if interaction=3 then;printnl(263);print(634);
end;{1065:}case curgroup of 14:begin mem[p].hh.lh:=6711;printesc(519);
end;15:begin mem[p].hh.lh:=804;printchar(36);end;
16:begin mem[p].hh.lh:=6712;mem[p].hh.rh:=getavail;p:=mem[p].hh.rh;
mem[p].hh.lh:=3118;printesc(1052);end;others:begin mem[p].hh.lh:=637;
printchar(125);end end{:1065};print(635);
begintokenlist(mem[29997].hh.rh,4);begin helpptr:=5;helpline[4]:=1047;
helpline[3]:=1048;helpline[2]:=1049;helpline[1]:=1050;helpline[0]:=1051;
end;error;end;end;{:1064}{1069:}procedure extrarightbrace;
begin begin if interaction=3 then;printnl(263);print(1058);end;
case curgroup of 14:printesc(519);15:printchar(36);16:printesc(887);end;
begin helpptr:=5;helpline[4]:=1059;helpline[3]:=1060;helpline[2]:=1061;
helpline[1]:=1062;helpline[0]:=1063;end;error;alignstate:=alignstate+1;
end;{:1069}{1070:}procedure normalparagraph;
begin if eqtb[5287].int<>0 then eqworddefine(5287,0);
if eqtb[5862].int<>0 then eqworddefine(5862,0);
if eqtb[5309].int<>1 then eqworddefine(5309,1);
if eqtb[3412].hh.rh<>0 then eqdefine(3412,118,0);
if eqtb[3679].hh.rh<>0 then eqdefine(3679,118,0);end;
{:1070}{1075:}procedure boxend(boxcontext:integer);var p:halfword;
a:smallnumber;
begin if boxcontext<1073741824 then{1076:}begin if curbox<>0 then begin
mem[curbox+4].int:=boxcontext;
if abs(curlist.modefield)=1 then begin appendtovlist(curbox);
if adjusttail<>0 then begin if 29995<>adjusttail then begin mem[curlist.
tailfield].hh.rh:=mem[29995].hh.rh;curlist.tailfield:=adjusttail;end;
adjusttail:=0;end;if curlist.modefield>0 then buildpage;
end else begin if abs(curlist.modefield)=102 then curlist.auxfield.hh.lh
:=1000 else begin p:=newnoad;mem[p+1].hh.rh:=2;mem[p+1].hh.lh:=curbox;
curbox:=p;end;mem[curlist.tailfield].hh.rh:=curbox;
curlist.tailfield:=curbox;end;end;
end{:1076}else if boxcontext<1073807360 then{1077:}begin if boxcontext<
1073774592 then begin curval:=boxcontext-1073741824;a:=0;
end else begin curval:=boxcontext-1073774592;a:=4;end;
if curval<256 then if(a>=4)then geqdefine(3683+curval,119,curbox)else
eqdefine(3683+curval,119,curbox)else begin findsaelement(4,curval,true);
if(a>=4)then gsadef(curptr,curbox)else sadef(curptr,curbox);end;
end{:1077}else if curbox<>0 then if boxcontext>1073807360 then{1078:}
begin{404:}repeat getxtoken;until(curcmd<>10)and(curcmd<>0){:404};
if((curcmd=26)and(abs(curlist.modefield)<>1))or((curcmd=27)and(abs(
curlist.modefield)=1))then begin appendglue;
mem[curlist.tailfield].hh.b1:=boxcontext-(1073807261);
mem[curlist.tailfield+1].hh.rh:=curbox;
end else begin begin if interaction=3 then;printnl(263);print(1076);end;
begin helpptr:=3;helpline[2]:=1077;helpline[1]:=1078;helpline[0]:=1079;
end;backerror;flushnodelist(curbox);end;end{:1078}else shipout(curbox);
end;{:1075}{1079:}procedure beginbox(boxcontext:integer);label 10,30;
var p,q:halfword;r:halfword;fm:boolean;tx:halfword;m:quarterword;
k:halfword;n:halfword;begin case curchr of 0:begin scanregisternum;
if curval<256 then curbox:=eqtb[3683+curval].hh.rh else begin
findsaelement(4,curval,false);
if curptr=0 then curbox:=0 else curbox:=mem[curptr+1].hh.rh;end;
if curval<256 then eqtb[3683+curval].hh.rh:=0 else begin findsaelement(4
,curval,false);if curptr<>0 then begin mem[curptr+1].hh.rh:=0;
mem[curptr+1].hh.lh:=mem[curptr+1].hh.lh+1;deletesaref(curptr);end;end;
end;1:begin scanregisternum;
if curval<256 then q:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then q:=0 else q:=mem[curptr+1].hh.rh;end;
curbox:=copynodelist(q);end;2:{1080:}begin curbox:=0;
if abs(curlist.modefield)=203 then begin youcant;begin helpptr:=1;
helpline[0]:=1081;end;error;
end else if(curlist.modefield=1)and(curlist.headfield=curlist.tailfield)
then begin youcant;begin helpptr:=2;helpline[1]:=1082;helpline[0]:=1083;
end;error;end else begin tx:=curlist.tailfield;
if not(tx>=himemmin)then if(mem[tx].hh.b0=9)and(mem[tx].hh.b1=3)then
begin r:=curlist.headfield;repeat q:=r;r:=mem[q].hh.rh;until r=tx;tx:=q;
end;if not(tx>=himemmin)then if(mem[tx].hh.b0=0)or(mem[tx].hh.b0=1)then
{1081:}begin q:=curlist.headfield;p:=0;repeat r:=p;p:=q;fm:=false;
if not(q>=himemmin)then if mem[q].hh.b0=7 then begin for m:=1 to mem[q].
hh.b1 do p:=mem[p].hh.rh;if p=tx then goto 30;
end else if(mem[q].hh.b0=9)and(mem[q].hh.b1=2)then fm:=true;
q:=mem[p].hh.rh;until q=tx;q:=mem[tx].hh.rh;mem[p].hh.rh:=q;
mem[tx].hh.rh:=0;
if q=0 then if fm then confusion(1080)else curlist.tailfield:=p else if
fm then begin curlist.tailfield:=r;mem[r].hh.rh:=0;flushnodelist(p);end;
curbox:=tx;mem[curbox+4].int:=0;end{:1081};30:end;end{:1080};
3:{1082:}begin scanregisternum;n:=curval;
if not scankeyword(852)then begin begin if interaction=3 then;
printnl(263);print(1084);end;begin helpptr:=2;helpline[1]:=1085;
helpline[0]:=1086;end;error;end;scandimen(false,false,false);
curbox:=vsplit(n,curval);end{:1082};others:{1083:}begin k:=curchr-4;
savestack[saveptr+0].int:=boxcontext;
if k=102 then if(boxcontext<1073741824)and(abs(curlist.modefield)=1)then
scanspec(3,true)else scanspec(2,true)else begin if k=1 then scanspec(4,
true)else begin scanspec(5,true);k:=1;end;normalparagraph;end;pushnest;
curlist.modefield:=-k;if k=1 then begin curlist.auxfield.int:=-65536000;
if eqtb[3418].hh.rh<>0 then begintokenlist(eqtb[3418].hh.rh,11);
end else begin curlist.auxfield.hh.lh:=1000;
if eqtb[3417].hh.rh<>0 then begintokenlist(eqtb[3417].hh.rh,10);end;
goto 10;end{:1083}end;boxend(boxcontext);10:end;
{:1079}{1084:}procedure scanbox(boxcontext:integer);
begin{404:}repeat getxtoken;until(curcmd<>10)and(curcmd<>0){:404};
if curcmd=20 then beginbox(boxcontext)else if(boxcontext>=1073807361)and
((curcmd=36)or(curcmd=35))then begin curbox:=scanrulespec;
boxend(boxcontext);end else begin begin if interaction=3 then;
printnl(263);print(1087);end;begin helpptr:=3;helpline[2]:=1088;
helpline[1]:=1089;helpline[0]:=1090;end;backerror;end;end;
{:1084}{1086:}procedure package(c:smallnumber);var h:scaled;p:halfword;
d:scaled;begin d:=eqtb[5852].int;unsave;saveptr:=saveptr-3;
if curlist.modefield=-102 then curbox:=hpack(mem[curlist.headfield].hh.
rh,savestack[saveptr+2].int,savestack[saveptr+1].int)else begin curbox:=
vpackage(mem[curlist.headfield].hh.rh,savestack[saveptr+2].int,savestack
[saveptr+1].int,d);if c=4 then{1087:}begin h:=0;p:=mem[curbox+5].hh.rh;
if p<>0 then if mem[p].hh.b0<=2 then h:=mem[p+3].int;
mem[curbox+2].int:=mem[curbox+2].int-h+mem[curbox+3].int;
mem[curbox+3].int:=h;end{:1087};end;popnest;
boxend(savestack[saveptr+0].int);end;
{:1086}{1091:}function normmin(h:integer):smallnumber;
begin if h<=0 then normmin:=1 else if h>=63 then normmin:=63 else
normmin:=h;end;procedure newgraf(indented:boolean);
begin curlist.pgfield:=0;
if(curlist.modefield=1)or(curlist.headfield<>curlist.tailfield)then
begin mem[curlist.tailfield].hh.rh:=newparamglue(2);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;pushnest;
curlist.modefield:=102;curlist.auxfield.hh.lh:=1000;
if eqtb[5318].int<=0 then curlang:=0 else if eqtb[5318].int>255 then
curlang:=0 else curlang:=eqtb[5318].int;curlist.auxfield.hh.rh:=curlang;
curlist.pgfield:=(normmin(eqtb[5319].int)*64+normmin(eqtb[5320].int))
*65536+curlang;if indented then begin curlist.tailfield:=newnullbox;
mem[curlist.headfield].hh.rh:=curlist.tailfield;
mem[curlist.tailfield+1].int:=eqtb[5845].int;end;
if eqtb[3414].hh.rh<>0 then begintokenlist(eqtb[3414].hh.rh,7);
if nestptr=1 then buildpage;end;{:1091}{1093:}procedure indentinhmode;
var p,q:halfword;begin if curchr>0 then begin p:=newnullbox;
mem[p+1].int:=eqtb[5845].int;
if abs(curlist.modefield)=102 then curlist.auxfield.hh.lh:=1000 else
begin q:=newnoad;mem[q+1].hh.rh:=2;mem[q+1].hh.lh:=p;p:=q;end;
begin mem[curlist.tailfield].hh.rh:=p;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;end;end;
{:1093}{1095:}procedure headforvmode;
begin if curlist.modefield<0 then if curcmd<>36 then offsave else begin
begin if interaction=3 then;printnl(263);print(694);end;printesc(524);
print(1093);begin helpptr:=2;helpline[1]:=1094;helpline[0]:=1095;end;
error;end else begin backinput;curtok:=partoken;backinput;
curinput.indexfield:=4;end;end;{:1095}{1096:}procedure endgraf;
begin if curlist.modefield=102 then begin if curlist.headfield=curlist.
tailfield then popnest else linebreak(false);
if curlist.eTeXauxfield<>0 then begin flushlist(curlist.eTeXauxfield);
curlist.eTeXauxfield:=0;end;normalparagraph;errorcount:=0;end;end;
{:1096}{1099:}procedure begininsertoradjust;
begin if curcmd=38 then curval:=255 else begin scaneightbitint;
if curval=255 then begin begin if interaction=3 then;printnl(263);
print(1096);end;printesc(331);printint(255);begin helpptr:=1;
helpline[0]:=1097;end;error;curval:=0;end;end;
savestack[saveptr+0].int:=curval;saveptr:=saveptr+1;newsavelevel(11);
scanleftbrace;normalparagraph;pushnest;curlist.modefield:=-1;
curlist.auxfield.int:=-65536000;end;{:1099}{1101:}procedure makemark;
var p:halfword;c:halfword;
begin if curchr=0 then c:=0 else begin scanregisternum;c:=curval;end;
p:=scantoks(false,true);p:=getnode(2);mem[p+1].hh.lh:=c;mem[p].hh.b0:=4;
mem[p].hh.b1:=0;mem[p+1].hh.rh:=defref;mem[curlist.tailfield].hh.rh:=p;
curlist.tailfield:=p;end;{:1101}{1103:}procedure appendpenalty;
begin scanint;begin mem[curlist.tailfield].hh.rh:=newpenalty(curval);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
if curlist.modefield=1 then buildpage;end;
{:1103}{1105:}procedure deletelast;label 10;var p,q:halfword;r:halfword;
fm:boolean;tx:halfword;m:quarterword;
begin if(curlist.modefield=1)and(curlist.tailfield=curlist.headfield)
then{1106:}begin if(curchr<>10)or(lastglue<>65535)then begin youcant;
begin helpptr:=2;helpline[1]:=1082;helpline[0]:=1098;end;
if curchr=11 then helpline[0]:=(1099)else if curchr<>10 then helpline[0]
:=(1100);error;end;end{:1106}else begin tx:=curlist.tailfield;
if not(tx>=himemmin)then if(mem[tx].hh.b0=9)and(mem[tx].hh.b1=3)then
begin r:=curlist.headfield;repeat q:=r;r:=mem[q].hh.rh;until r=tx;tx:=q;
end;
if not(tx>=himemmin)then if mem[tx].hh.b0=curchr then begin q:=curlist.
headfield;p:=0;repeat r:=p;p:=q;fm:=false;
if not(q>=himemmin)then if mem[q].hh.b0=7 then begin for m:=1 to mem[q].
hh.b1 do p:=mem[p].hh.rh;if p=tx then goto 10;
end else if(mem[q].hh.b0=9)and(mem[q].hh.b1=2)then fm:=true;
q:=mem[p].hh.rh;until q=tx;q:=mem[tx].hh.rh;mem[p].hh.rh:=q;
mem[tx].hh.rh:=0;
if q=0 then if fm then confusion(1080)else curlist.tailfield:=p else if
fm then begin curlist.tailfield:=r;mem[r].hh.rh:=0;flushnodelist(p);end;
flushnodelist(tx);end;end;10:end;{:1105}{1110:}procedure unpackage;
label 30,10;var p:halfword;c:0..1;
begin if curchr>1 then{1596:}begin mem[curlist.tailfield].hh.rh:=discptr
[curchr];discptr[curchr]:=0;goto 30;end{:1596};c:=curchr;
scanregisternum;
if curval<256 then p:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then p:=0 else p:=mem[curptr+1].hh.rh;end;
if p=0 then goto 10;
if(abs(curlist.modefield)=203)or((abs(curlist.modefield)=1)and(mem[p].hh
.b0<>1))or((abs(curlist.modefield)=102)and(mem[p].hh.b0<>0))then begin
begin if interaction=3 then;printnl(263);print(1108);end;
begin helpptr:=3;helpline[2]:=1109;helpline[1]:=1110;helpline[0]:=1111;
end;error;goto 10;end;
if c=1 then mem[curlist.tailfield].hh.rh:=copynodelist(mem[p+5].hh.rh)
else begin mem[curlist.tailfield].hh.rh:=mem[p+5].hh.rh;
if curval<256 then eqtb[3683+curval].hh.rh:=0 else begin findsaelement(4
,curval,false);if curptr<>0 then begin mem[curptr+1].hh.rh:=0;
mem[curptr+1].hh.lh:=mem[curptr+1].hh.lh+1;deletesaref(curptr);end;end;
freenode(p,7);end;
30:while mem[curlist.tailfield].hh.rh<>0 do curlist.tailfield:=mem[
curlist.tailfield].hh.rh;10:end;
{:1110}{1113:}procedure appenditaliccorrection;label 10;var p:halfword;
f:internalfontnumber;
begin if curlist.tailfield<>curlist.headfield then begin if(curlist.
tailfield>=himemmin)then p:=curlist.tailfield else if mem[curlist.
tailfield].hh.b0=6 then p:=curlist.tailfield+1 else goto 10;
f:=mem[p].hh.b0;
begin mem[curlist.tailfield].hh.rh:=newkern(fontinfo[italicbase[f]+(
fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b2-0)div 4].int);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b1:=1;end;10:end;
{:1113}{1117:}procedure appenddiscretionary;var c:integer;
begin begin mem[curlist.tailfield].hh.rh:=newdisc;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
if curchr=1 then begin c:=hyphenchar[eqtb[3939].hh.rh];
if c>=0 then if c<256 then mem[curlist.tailfield+1].hh.lh:=newcharacter(
eqtb[3939].hh.rh,c);end else begin saveptr:=saveptr+1;
savestack[saveptr-1].int:=0;newsavelevel(10);scanleftbrace;pushnest;
curlist.modefield:=-102;curlist.auxfield.hh.lh:=1000;end;end;
{:1117}{1119:}procedure builddiscretionary;label 30,10;var p,q:halfword;
n:integer;begin unsave;{1121:}q:=curlist.headfield;p:=mem[q].hh.rh;n:=0;
while p<>0 do begin if not(p>=himemmin)then if mem[p].hh.b0>2 then if
mem[p].hh.b0<>11 then if mem[p].hh.b0<>6 then begin begin if interaction
=3 then;printnl(263);print(1118);end;begin helpptr:=1;helpline[0]:=1119;
end;error;begindiagnostic;printnl(1120);showbox(p);enddiagnostic(true);
flushnodelist(p);mem[q].hh.rh:=0;goto 30;end;q:=p;p:=mem[q].hh.rh;
n:=n+1;end;30:{:1121};p:=mem[curlist.headfield].hh.rh;popnest;
case savestack[saveptr-1].int of 0:mem[curlist.tailfield+1].hh.lh:=p;
1:mem[curlist.tailfield+1].hh.rh:=p;
2:{1120:}begin if(n>0)and(abs(curlist.modefield)=203)then begin begin if
interaction=3 then;printnl(263);print(1112);end;printesc(352);
begin helpptr:=2;helpline[1]:=1113;helpline[0]:=1114;end;
flushnodelist(p);n:=0;error;end else mem[curlist.tailfield].hh.rh:=p;
if n<=255 then mem[curlist.tailfield].hh.b1:=n else begin begin if
interaction=3 then;printnl(263);print(1115);end;begin helpptr:=2;
helpline[1]:=1116;helpline[0]:=1117;end;error;end;
if n>0 then curlist.tailfield:=q;saveptr:=saveptr-1;goto 10;end{:1120};
end;savestack[saveptr-1].int:=savestack[saveptr-1].int+1;
newsavelevel(10);scanleftbrace;pushnest;curlist.modefield:=-102;
curlist.auxfield.hh.lh:=1000;10:end;{:1119}{1123:}procedure makeaccent;
var s,t:real;p,q,r:halfword;f:internalfontnumber;a,h,x,w,delta:scaled;
i:fourquarters;begin scancharnum;f:=eqtb[3939].hh.rh;
p:=newcharacter(f,curval);
if p<>0 then begin x:=fontinfo[5+parambase[f]].int;
s:=fontinfo[1+parambase[f]].int/65536.0;
a:=fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b0].int
;doassignments;{1124:}q:=0;f:=eqtb[3939].hh.rh;
if(curcmd=11)or(curcmd=12)or(curcmd=68)then q:=newcharacter(f,curchr)
else if curcmd=16 then begin scancharnum;q:=newcharacter(f,curval);
end else backinput{:1124};
if q<>0 then{1125:}begin t:=fontinfo[1+parambase[f]].int/65536.0;
i:=fontinfo[charbase[f]+mem[q].hh.b1].qqqq;
w:=fontinfo[widthbase[f]+i.b0].int;
h:=fontinfo[heightbase[f]+(i.b1-0)div 16].int;
if h<>x then begin p:=hpack(p,0,1);mem[p+4].int:=x-h;end;
delta:=round((w-a)/2.0+h*t-x*s);r:=newkern(delta);mem[r].hh.b1:=2;
mem[curlist.tailfield].hh.rh:=r;mem[r].hh.rh:=p;
curlist.tailfield:=newkern(-a-delta);mem[curlist.tailfield].hh.b1:=2;
mem[p].hh.rh:=curlist.tailfield;p:=q;end{:1125};
mem[curlist.tailfield].hh.rh:=p;curlist.tailfield:=p;
curlist.auxfield.hh.lh:=1000;end;end;{:1123}{1127:}procedure alignerror;
begin if abs(alignstate)>2 then{1128:}begin begin if interaction=3 then;
printnl(263);print(1125);end;printcmdchr(curcmd,curchr);
if curtok=1062 then begin begin helpptr:=6;helpline[5]:=1126;
helpline[4]:=1127;helpline[3]:=1128;helpline[2]:=1129;helpline[1]:=1130;
helpline[0]:=1131;end;end else begin begin helpptr:=5;helpline[4]:=1126;
helpline[3]:=1132;helpline[2]:=1129;helpline[1]:=1130;helpline[0]:=1131;
end;end;error;end{:1128}else begin backinput;
if alignstate<0 then begin begin if interaction=3 then;printnl(263);
print(666);end;alignstate:=alignstate+1;curtok:=379;
end else begin begin if interaction=3 then;printnl(263);print(1121);end;
alignstate:=alignstate-1;curtok:=637;end;begin helpptr:=3;
helpline[2]:=1122;helpline[1]:=1123;helpline[0]:=1124;end;inserror;end;
end;{:1127}{1129:}procedure noalignerror;
begin begin if interaction=3 then;printnl(263);print(1125);end;
printesc(530);begin helpptr:=2;helpline[1]:=1133;helpline[0]:=1134;end;
error;end;procedure omiterror;begin begin if interaction=3 then;
printnl(263);print(1125);end;printesc(533);begin helpptr:=2;
helpline[1]:=1135;helpline[0]:=1134;end;error;end;
{:1129}{1131:}procedure doendv;begin baseptr:=inputptr;
inputstack[baseptr]:=curinput;
while(inputstack[baseptr].indexfield<>2)and(inputstack[baseptr].locfield
=0)and(inputstack[baseptr].statefield=0)do baseptr:=baseptr-1;
if(inputstack[baseptr].indexfield<>2)or(inputstack[baseptr].locfield<>0)
or(inputstack[baseptr].statefield<>0)then fatalerror(604);
if curgroup=6 then begin endgraf;if fincol then finrow;end else offsave;
end;{:1131}{1135:}procedure cserror;begin begin if interaction=3 then;
printnl(263);print(787);end;printesc(508);begin helpptr:=1;
helpline[0]:=1137;end;error;end;
{:1135}{1136:}procedure pushmath(c:groupcode);begin pushnest;
curlist.modefield:=-203;curlist.auxfield.int:=0;newsavelevel(c);end;
{:1136}{1138:}{1466:}procedure justcopy(p,h,t:halfword);label 40,45;
var r:halfword;words:0..5;begin while p<>0 do begin words:=1;
if(p>=himemmin)then r:=getavail else case mem[p].hh.b0 of 0,1:begin r:=
getnode(7);mem[r+6]:=mem[p+6];mem[r+5]:=mem[p+5];words:=5;
mem[r+5].hh.rh:=0;end;2:begin r:=getnode(4);words:=4;end;
6:begin r:=getavail;mem[r]:=mem[p+1];goto 40;end;
11,9:begin r:=getnode(2);words:=2;end;10:begin r:=getnode(2);
mem[mem[p+1].hh.lh].hh.rh:=mem[mem[p+1].hh.lh].hh.rh+1;
mem[r+1].hh.lh:=mem[p+1].hh.lh;mem[r+1].hh.rh:=0;end;
8:{1357:}case mem[p].hh.b1 of 0:begin r:=getnode(3);words:=3;end;
1,3:begin r:=getnode(2);
mem[mem[p+1].hh.rh].hh.lh:=mem[mem[p+1].hh.rh].hh.lh+1;words:=2;end;
2,4:begin r:=getnode(2);words:=2;end;others:confusion(1307)end{:1357};
others:goto 45 end;while words>0 do begin words:=words-1;
mem[r+words]:=mem[p+words];end;40:mem[h].hh.rh:=r;h:=r;
45:p:=mem[p].hh.rh;end;mem[h].hh.rh:=t;end;
{:1466}{1471:}procedure justreverse(p:halfword);label 40,30;
var l:halfword;t:halfword;q:halfword;m,n:halfword;begin m:=0;n:=0;
if mem[29997].hh.rh=0 then begin justcopy(mem[p].hh.rh,29997,0);
q:=mem[29997].hh.rh;end else begin q:=mem[p].hh.rh;mem[p].hh.rh:=0;
flushnodelist(mem[29997].hh.rh);end;t:=newedge(curdir,0);l:=t;
curdir:=1-curdir;while q<>0 do if(q>=himemmin)then repeat p:=q;
q:=mem[p].hh.rh;mem[p].hh.rh:=l;l:=p;
until not(q>=himemmin)else begin p:=q;q:=mem[p].hh.rh;
if mem[p].hh.b0=9 then{1472:}if odd(mem[p].hh.b1)then if mem[LRptr].hh.
lh<>(4*(mem[p].hh.b1 div 4)+3)then begin mem[p].hh.b0:=11;
LRproblems:=LRproblems+1;end else begin begin tempptr:=LRptr;
LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;end;if n>0 then begin n:=n-1;
mem[p].hh.b1:=mem[p].hh.b1-1;
end else begin if m>0 then m:=m-1 else goto 40;mem[p].hh.b0:=11;end;
end else begin begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[p].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end;
if(n>0)or((mem[p].hh.b1 div 8)<>curdir)then begin n:=n+1;
mem[p].hh.b1:=mem[p].hh.b1+1;end else begin mem[p].hh.b0:=11;m:=m+1;end;
end{:1472};mem[p].hh.rh:=l;l:=p;end;goto 30;
40:mem[t+1].int:=mem[p+1].int;mem[t].hh.rh:=q;freenode(p,2);
30:mem[29997].hh.rh:=l;end;{:1471}procedure initmath;label 21,40,45,30;
var w:scaled;j:halfword;x:integer;l:scaled;s:scaled;p:halfword;
q:halfword;f:internalfontnumber;n:integer;v:scaled;d:scaled;
begin gettoken;
if(curcmd=3)and(curlist.modefield>0)then{1145:}begin j:=0;
w:=-1073741823;
if curlist.headfield=curlist.tailfield then{1465:}begin popnest;
{1464:}if curlist.eTeXauxfield=0 then x:=0 else if mem[curlist.
eTeXauxfield].hh.lh>=8 then x:=-1 else x:=1{:1464};
end{:1465}else begin linebreak(true);
{1146:}{1467:}if(eTeXmode=1)then{1473:}begin if eqtb[2890].hh.rh=0 then
j:=newkern(0)else j:=newparamglue(8);
if eqtb[2889].hh.rh=0 then p:=newkern(0)else p:=newparamglue(7);
mem[p].hh.rh:=j;j:=newnullbox;mem[j+1].int:=mem[justbox+1].int;
mem[j+4].int:=mem[justbox+4].int;mem[j+5].hh.rh:=p;
mem[j+5].hh.b1:=mem[justbox+5].hh.b1;
mem[j+5].hh.b0:=mem[justbox+5].hh.b0;mem[j+6].gr:=mem[justbox+6].gr;
end{:1473};v:=mem[justbox+4].int;
{1464:}if curlist.eTeXauxfield=0 then x:=0 else if mem[curlist.
eTeXauxfield].hh.lh>=8 then x:=-1 else x:=1{:1464};
if x>=0 then begin p:=mem[justbox+5].hh.rh;mem[29997].hh.rh:=0;
end else begin v:=-v-mem[justbox+1].int;p:=newmath(0,6);
mem[29997].hh.rh:=p;justcopy(mem[justbox+5].hh.rh,p,newmath(0,7));
curdir:=1;end;v:=v+2*fontinfo[6+parambase[eqtb[3939].hh.rh]].int;
if(eqtb[5332].int>0)then{1443:}begin tempptr:=getavail;
mem[tempptr].hh.lh:=0;mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;
end{:1443}{:1467};
while p<>0 do begin{1147:}21:if(p>=himemmin)then begin f:=mem[p].hh.b0;
d:=fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b0].int
;goto 40;end;case mem[p].hh.b0 of 0,1,2:begin d:=mem[p+1].int;goto 40;
end;6:{652:}begin mem[29988]:=mem[p+1];mem[29988].hh.rh:=mem[p].hh.rh;
p:=29988;goto 21;end{:652};11:d:=mem[p+1].int;
{1469:}9:begin d:=mem[p+1].int;
if(eqtb[5332].int>0)then{1470:}if odd(mem[p].hh.b1)then begin if mem[
LRptr].hh.lh=(4*(mem[p].hh.b1 div 4)+3)then begin tempptr:=LRptr;
LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;
end else if mem[p].hh.b1>4 then begin w:=1073741823;goto 30;
end end else begin begin tempptr:=getavail;
mem[tempptr].hh.lh:=(4*(mem[p].hh.b1 div 4)+3);
mem[tempptr].hh.rh:=LRptr;LRptr:=tempptr;end;
if(mem[p].hh.b1 div 8)<>curdir then begin justreverse(p);p:=29997;end;
end{:1470}else if mem[p].hh.b1>=4 then begin w:=1073741823;goto 30;end;
end;14:begin d:=mem[p+1].int;curdir:=mem[p].hh.b1;end;
{:1469}10:{1148:}begin q:=mem[p+1].hh.lh;d:=mem[q+1].int;
if mem[justbox+5].hh.b0=1 then begin if(mem[justbox+5].hh.b1=mem[q].hh.
b0)and(mem[q+2].int<>0)then v:=1073741823;
end else if mem[justbox+5].hh.b0=2 then begin if(mem[justbox+5].hh.b1=
mem[q].hh.b1)and(mem[q+3].int<>0)then v:=1073741823;end;
if mem[p].hh.b1>=100 then goto 40;end{:1148};8:{1361:}d:=0{:1361};
others:d:=0 end{:1147};if v<1073741823 then v:=v+d;goto 45;
40:if v<1073741823 then begin v:=v+d;w:=v;end else begin w:=1073741823;
goto 30;end;45:p:=mem[p].hh.rh;end;
30:{1468:}if(eqtb[5332].int>0)then begin while LRptr<>0 do begin tempptr
:=LRptr;LRptr:=mem[tempptr].hh.rh;begin mem[tempptr].hh.rh:=avail;
avail:=tempptr;{dynused:=dynused-1;}end;end;
if LRproblems<>0 then begin w:=1073741823;LRproblems:=0;end;end;
curdir:=0;flushnodelist(mem[29997].hh.rh){:1468}{:1146};end;
{1149:}if eqtb[3412].hh.rh=0 then if(eqtb[5862].int<>0)and(((eqtb[5309].
int>=0)and(curlist.pgfield+2>eqtb[5309].int))or(curlist.pgfield+1<-eqtb[
5309].int))then begin l:=eqtb[5848].int-abs(eqtb[5862].int);
if eqtb[5862].int>0 then s:=eqtb[5862].int else s:=0;
end else begin l:=eqtb[5848].int;s:=0;
end else begin n:=mem[eqtb[3412].hh.rh].hh.lh;
if curlist.pgfield+2>=n then p:=eqtb[3412].hh.rh+2*n else p:=eqtb[3412].
hh.rh+2*(curlist.pgfield+2);s:=mem[p-1].int;l:=mem[p].int;end{:1149};
pushmath(15);curlist.modefield:=203;eqworddefine(5312,-1);
eqworddefine(5858,w);curlist.eTeXauxfield:=j;
if(eTeXmode=1)then eqworddefine(5328,x);eqworddefine(5859,l);
eqworddefine(5860,s);
if eqtb[3416].hh.rh<>0 then begintokenlist(eqtb[3416].hh.rh,9);
if nestptr=1 then buildpage;end{:1145}else begin backinput;
{1139:}begin pushmath(15);eqworddefine(5312,-1);
if eqtb[3415].hh.rh<>0 then begintokenlist(eqtb[3415].hh.rh,8);
end{:1139};end;end;{:1138}{1142:}procedure starteqno;
begin savestack[saveptr+0].int:=curchr;saveptr:=saveptr+1;
{1139:}begin pushmath(15);eqworddefine(5312,-1);
if eqtb[3415].hh.rh<>0 then begintokenlist(eqtb[3415].hh.rh,8);
end{:1139};end;{:1142}{1151:}procedure scanmath(p:halfword);
label 20,21,10;var c:integer;begin 20:{404:}repeat getxtoken;
until(curcmd<>10)and(curcmd<>0){:404};
21:case curcmd of 11,12,68:begin c:=eqtb[5012+curchr].hh.rh-0;
if c=32768 then begin{1152:}begin curcs:=curchr+1;
curcmd:=eqtb[curcs].hh.b0;curchr:=eqtb[curcs].hh.rh;xtoken;backinput;
end{:1152};goto 20;end;end;16:begin scancharnum;curchr:=curval;
curcmd:=68;goto 21;end;17:begin scanfifteenbitint;c:=curval;end;
69:c:=curchr;15:begin scantwentysevenbitint;c:=curval div 4096;end;
others:{1153:}begin backinput;scanleftbrace;savestack[saveptr+0].int:=p;
saveptr:=saveptr+1;pushmath(9);goto 10;end{:1153}end;mem[p].hh.rh:=1;
mem[p].hh.b1:=c mod 256+0;
if(c>=28672)and((eqtb[5312].int>=0)and(eqtb[5312].int<16))then mem[p].hh
.b0:=eqtb[5312].int else mem[p].hh.b0:=(c div 256)mod 16;10:end;
{:1151}{1155:}procedure setmathchar(c:integer);var p:halfword;
begin if c>=32768 then{1152:}begin curcs:=curchr+1;
curcmd:=eqtb[curcs].hh.b0;curchr:=eqtb[curcs].hh.rh;xtoken;backinput;
end{:1152}else begin p:=newnoad;mem[p+1].hh.rh:=1;
mem[p+1].hh.b1:=c mod 256+0;mem[p+1].hh.b0:=(c div 256)mod 16;
if c>=28672 then begin if((eqtb[5312].int>=0)and(eqtb[5312].int<16))then
mem[p+1].hh.b0:=eqtb[5312].int;mem[p].hh.b0:=16;
end else mem[p].hh.b0:=16+(c div 4096);mem[curlist.tailfield].hh.rh:=p;
curlist.tailfield:=p;end;end;{:1155}{1159:}procedure mathlimitswitch;
label 10;
begin if curlist.headfield<>curlist.tailfield then if mem[curlist.
tailfield].hh.b0=17 then begin mem[curlist.tailfield].hh.b1:=curchr;
goto 10;end;begin if interaction=3 then;printnl(263);print(1141);end;
begin helpptr:=1;helpline[0]:=1142;end;error;10:end;
{:1159}{1160:}procedure scandelimiter(p:halfword;r:boolean);
begin if r then scantwentysevenbitint else begin{404:}repeat getxtoken;
until(curcmd<>10)and(curcmd<>0){:404};
case curcmd of 11,12:curval:=eqtb[5589+curchr].int;
15:scantwentysevenbitint;others:curval:=-1 end;end;
if curval<0 then{1161:}begin begin if interaction=3 then;printnl(263);
print(1143);end;begin helpptr:=6;helpline[5]:=1144;helpline[4]:=1145;
helpline[3]:=1146;helpline[2]:=1147;helpline[1]:=1148;helpline[0]:=1149;
end;backerror;curval:=0;end{:1161};
mem[p].qqqq.b0:=(curval div 1048576)mod 16;
mem[p].qqqq.b1:=(curval div 4096)mod 256+0;
mem[p].qqqq.b2:=(curval div 256)mod 16;mem[p].qqqq.b3:=curval mod 256+0;
end;{:1160}{1163:}procedure mathradical;
begin begin mem[curlist.tailfield].hh.rh:=getnode(5);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=24;mem[curlist.tailfield].hh.b1:=0;
mem[curlist.tailfield+1].hh:=emptyfield;
mem[curlist.tailfield+3].hh:=emptyfield;
mem[curlist.tailfield+2].hh:=emptyfield;
scandelimiter(curlist.tailfield+4,true);scanmath(curlist.tailfield+1);
end;{:1163}{1165:}procedure mathac;
begin if curcmd=45 then{1166:}begin begin if interaction=3 then;
printnl(263);print(1150);end;printesc(526);print(1151);begin helpptr:=2;
helpline[1]:=1152;helpline[0]:=1153;end;error;end{:1166};
begin mem[curlist.tailfield].hh.rh:=getnode(5);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=28;mem[curlist.tailfield].hh.b1:=0;
mem[curlist.tailfield+1].hh:=emptyfield;
mem[curlist.tailfield+3].hh:=emptyfield;
mem[curlist.tailfield+2].hh:=emptyfield;
mem[curlist.tailfield+4].hh.rh:=1;scanfifteenbitint;
mem[curlist.tailfield+4].hh.b1:=curval mod 256+0;
if(curval>=28672)and((eqtb[5312].int>=0)and(eqtb[5312].int<16))then mem[
curlist.tailfield+4].hh.b0:=eqtb[5312].int else mem[curlist.tailfield+4]
.hh.b0:=(curval div 256)mod 16;scanmath(curlist.tailfield+1);end;
{:1165}{1172:}procedure appendchoices;
begin begin mem[curlist.tailfield].hh.rh:=newchoice;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;saveptr:=saveptr+1;
savestack[saveptr-1].int:=0;pushmath(13);scanleftbrace;end;
{:1172}{1174:}{1184:}function finmlist(p:halfword):halfword;
var q:halfword;
begin if curlist.auxfield.int<>0 then{1185:}begin mem[curlist.auxfield.
int+3].hh.rh:=3;
mem[curlist.auxfield.int+3].hh.lh:=mem[curlist.headfield].hh.rh;
if p=0 then q:=curlist.auxfield.int else begin q:=mem[curlist.auxfield.
int+2].hh.lh;
if(mem[q].hh.b0<>30)or(curlist.eTeXauxfield=0)then confusion(887);
mem[curlist.auxfield.int+2].hh.lh:=mem[curlist.eTeXauxfield].hh.rh;
mem[curlist.eTeXauxfield].hh.rh:=curlist.auxfield.int;
mem[curlist.auxfield.int].hh.rh:=p;end;
end{:1185}else begin mem[curlist.tailfield].hh.rh:=p;
q:=mem[curlist.headfield].hh.rh;end;popnest;finmlist:=q;end;
{:1184}procedure buildchoices;label 10;var p:halfword;begin unsave;
p:=finmlist(0);
case savestack[saveptr-1].int of 0:mem[curlist.tailfield+1].hh.lh:=p;
1:mem[curlist.tailfield+1].hh.rh:=p;2:mem[curlist.tailfield+2].hh.lh:=p;
3:begin mem[curlist.tailfield+2].hh.rh:=p;saveptr:=saveptr-1;goto 10;
end;end;savestack[saveptr-1].int:=savestack[saveptr-1].int+1;
pushmath(13);scanleftbrace;10:end;{:1174}{1176:}procedure subsup;
var t:smallnumber;p:halfword;begin t:=0;p:=0;
if curlist.tailfield<>curlist.headfield then if(mem[curlist.tailfield].
hh.b0>=16)and(mem[curlist.tailfield].hh.b0<30)then begin p:=curlist.
tailfield+2+curcmd-7;t:=mem[p].hh.rh;end;
if(p=0)or(t<>0)then{1177:}begin begin mem[curlist.tailfield].hh.rh:=
newnoad;curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
p:=curlist.tailfield+2+curcmd-7;
if t<>0 then begin if curcmd=7 then begin begin if interaction=3 then;
printnl(263);print(1154);end;begin helpptr:=1;helpline[0]:=1155;end;
end else begin begin if interaction=3 then;printnl(263);print(1156);end;
begin helpptr:=1;helpline[0]:=1157;end;end;error;end;end{:1177};
scanmath(p);end;{:1176}{1181:}procedure mathfraction;var c:smallnumber;
begin c:=curchr;
if curlist.auxfield.int<>0 then{1183:}begin if c>=3 then begin
scandelimiter(29988,false);scandelimiter(29988,false);end;
if c mod 3=0 then scandimen(false,false,false);
begin if interaction=3 then;printnl(263);print(1164);end;
begin helpptr:=3;helpline[2]:=1165;helpline[1]:=1166;helpline[0]:=1167;
end;error;end{:1183}else begin curlist.auxfield.int:=getnode(6);
mem[curlist.auxfield.int].hh.b0:=25;mem[curlist.auxfield.int].hh.b1:=0;
mem[curlist.auxfield.int+2].hh.rh:=3;
mem[curlist.auxfield.int+2].hh.lh:=mem[curlist.headfield].hh.rh;
mem[curlist.auxfield.int+3].hh:=emptyfield;
mem[curlist.auxfield.int+4].qqqq:=nulldelimiter;
mem[curlist.auxfield.int+5].qqqq:=nulldelimiter;
mem[curlist.headfield].hh.rh:=0;curlist.tailfield:=curlist.headfield;
{1182:}if c>=3 then begin scandelimiter(curlist.auxfield.int+4,false);
scandelimiter(curlist.auxfield.int+5,false);end;
case c mod 3 of 0:begin scandimen(false,false,false);
mem[curlist.auxfield.int+1].int:=curval;end;
1:mem[curlist.auxfield.int+1].int:=1073741824;
2:mem[curlist.auxfield.int+1].int:=0;end{:1182};end;end;
{:1181}{1191:}procedure mathleftright;var t:smallnumber;p:halfword;
q:halfword;begin t:=curchr;
if(t<>30)and(curgroup<>16)then{1192:}begin if curgroup=15 then begin
scandelimiter(29988,false);begin if interaction=3 then;printnl(263);
print(787);end;if t=1 then begin printesc(888);begin helpptr:=1;
helpline[0]:=1168;end;end else begin printesc(887);begin helpptr:=1;
helpline[0]:=1169;end;end;error;end else offsave;
end{:1192}else begin p:=newnoad;mem[p].hh.b0:=t;
scandelimiter(p+1,false);if t=1 then begin mem[p].hh.b0:=31;
mem[p].hh.b1:=1;end;if t=30 then q:=p else begin q:=finmlist(p);unsave;
end;if t<>31 then begin pushmath(16);mem[curlist.headfield].hh.rh:=q;
curlist.tailfield:=p;curlist.eTeXauxfield:=p;
end else begin begin mem[curlist.tailfield].hh.rh:=newnoad;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=23;mem[curlist.tailfield+1].hh.rh:=3;
mem[curlist.tailfield+1].hh.lh:=q;end;end;end;
{:1191}{1194:}{1477:}procedure appdisplay(j,b:halfword;d:scaled);
var z:scaled;s:scaled;e:scaled;x:integer;p,q,r,t,u:halfword;
begin s:=eqtb[5860].int;x:=eqtb[5328].int;
if x=0 then mem[b+4].int:=s+d else begin z:=eqtb[5859].int;p:=b;
{1478:}if x>0 then e:=z-d-mem[p+1].int else begin e:=d;
d:=z-e-mem[p+1].int;end;if j<>0 then begin b:=copynodelist(j);
mem[b+3].int:=mem[p+3].int;mem[b+2].int:=mem[p+2].int;s:=s-mem[b+4].int;
d:=d+s;e:=e+mem[b+1].int-z-s;end;
if(mem[p].hh.b1-0)=2 then q:=p else begin r:=mem[p+5].hh.rh;
freenode(p,7);if r=0 then confusion(1377);if x>0 then begin p:=r;
repeat q:=r;r:=mem[r].hh.rh;until r=0;end else begin p:=0;q:=r;
repeat t:=mem[r].hh.rh;mem[r].hh.rh:=p;p:=r;r:=t;until r=0;end;
end{:1478};{1479:}if j=0 then begin r:=newkern(0);t:=newkern(0);
end else begin r:=mem[b+5].hh.rh;t:=mem[r].hh.rh;end;u:=newmath(0,3);
if mem[t].hh.b0=10 then begin j:=newskipparam(8);mem[q].hh.rh:=j;
mem[j].hh.rh:=u;j:=mem[t+1].hh.lh;mem[tempptr].hh.b0:=mem[j].hh.b0;
mem[tempptr].hh.b1:=mem[j].hh.b1;mem[tempptr+1].int:=e-mem[j+1].int;
mem[tempptr+2].int:=-mem[j+2].int;mem[tempptr+3].int:=-mem[j+3].int;
mem[u].hh.rh:=t;end else begin mem[t+1].int:=e;mem[t].hh.rh:=u;
mem[q].hh.rh:=t;end;u:=newmath(0,2);
if mem[r].hh.b0=10 then begin j:=newskipparam(7);mem[u].hh.rh:=j;
mem[j].hh.rh:=p;j:=mem[r+1].hh.lh;mem[tempptr].hh.b0:=mem[j].hh.b0;
mem[tempptr].hh.b1:=mem[j].hh.b1;mem[tempptr+1].int:=d-mem[j+1].int;
mem[tempptr+2].int:=-mem[j+2].int;mem[tempptr+3].int:=-mem[j+3].int;
mem[r].hh.rh:=u;end else begin mem[r+1].int:=d;mem[r].hh.rh:=p;
mem[u].hh.rh:=r;if j=0 then begin b:=hpack(u,0,1);mem[b+4].int:=s;
end else mem[b+5].hh.rh:=u;end{:1479};end;appendtovlist(b);end;
{:1477}procedure aftermath;var l:boolean;danger:boolean;m:integer;
p:halfword;a:halfword;{1198:}b:halfword;w:scaled;z:scaled;e:scaled;
q:scaled;d:scaled;s:scaled;g1,g2:smallnumber;r:halfword;t:halfword;
{:1198}{1474:}j:halfword;{:1474}begin danger:=false;
{1475:}if curlist.modefield=203 then j:=curlist.eTeXauxfield{:1475};
{1195:}if(fontparams[eqtb[3942].hh.rh]<22)or(fontparams[eqtb[3958].hh.rh
]<22)or(fontparams[eqtb[3974].hh.rh]<22)then begin begin if interaction=
3 then;printnl(263);print(1170);end;begin helpptr:=3;helpline[2]:=1171;
helpline[1]:=1172;helpline[0]:=1173;end;error;flushmath;danger:=true;
end else if(fontparams[eqtb[3943].hh.rh]<13)or(fontparams[eqtb[3959].hh.
rh]<13)or(fontparams[eqtb[3975].hh.rh]<13)then begin begin if
interaction=3 then;printnl(263);print(1174);end;begin helpptr:=3;
helpline[2]:=1175;helpline[1]:=1176;helpline[0]:=1177;end;error;
flushmath;danger:=true;end{:1195};m:=curlist.modefield;l:=false;
p:=finmlist(0);if curlist.modefield=-m then begin{1197:}begin getxtoken;
if curcmd<>3 then begin begin if interaction=3 then;printnl(263);
print(1178);end;begin helpptr:=2;helpline[1]:=1179;helpline[0]:=1180;
end;backerror;end;end{:1197};curmlist:=p;curstyle:=2;
mlistpenalties:=false;mlisttohlist;a:=hpack(mem[29997].hh.rh,0,1);
mem[a].hh.b1:=2;unsave;saveptr:=saveptr-1;
if savestack[saveptr+0].int=1 then l:=true;danger:=false;
{1475:}if curlist.modefield=203 then j:=curlist.eTeXauxfield{:1475};
{1195:}if(fontparams[eqtb[3942].hh.rh]<22)or(fontparams[eqtb[3958].hh.rh
]<22)or(fontparams[eqtb[3974].hh.rh]<22)then begin begin if interaction=
3 then;printnl(263);print(1170);end;begin helpptr:=3;helpline[2]:=1171;
helpline[1]:=1172;helpline[0]:=1173;end;error;flushmath;danger:=true;
end else if(fontparams[eqtb[3943].hh.rh]<13)or(fontparams[eqtb[3959].hh.
rh]<13)or(fontparams[eqtb[3975].hh.rh]<13)then begin begin if
interaction=3 then;printnl(263);print(1174);end;begin helpptr:=3;
helpline[2]:=1175;helpline[1]:=1176;helpline[0]:=1177;end;error;
flushmath;danger:=true;end{:1195};m:=curlist.modefield;p:=finmlist(0);
end else a:=0;
if m<0 then{1196:}begin begin mem[curlist.tailfield].hh.rh:=newmath(eqtb
[5846].int,0);curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
curmlist:=p;curstyle:=2;mlistpenalties:=(curlist.modefield>0);
mlisttohlist;mem[curlist.tailfield].hh.rh:=mem[29997].hh.rh;
while mem[curlist.tailfield].hh.rh<>0 do curlist.tailfield:=mem[curlist.
tailfield].hh.rh;
begin mem[curlist.tailfield].hh.rh:=newmath(eqtb[5846].int,1);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
curlist.auxfield.hh.lh:=1000;unsave;
end{:1196}else begin if a=0 then{1197:}begin getxtoken;
if curcmd<>3 then begin begin if interaction=3 then;printnl(263);
print(1178);end;begin helpptr:=2;helpline[1]:=1179;helpline[0]:=1180;
end;backerror;end;end{:1197};{1199:}curmlist:=p;curstyle:=0;
mlistpenalties:=false;mlisttohlist;p:=mem[29997].hh.rh;
adjusttail:=29995;b:=hpack(p,0,1);p:=mem[b+5].hh.rh;t:=adjusttail;
adjusttail:=0;w:=mem[b+1].int;z:=eqtb[5859].int;s:=eqtb[5860].int;
if eqtb[5328].int<0 then s:=-s-z;if(a=0)or danger then begin e:=0;q:=0;
end else begin e:=mem[a+1].int;
q:=e+fontinfo[6+parambase[eqtb[3942].hh.rh]].int;end;
if w+q>z then{1201:}begin if(e<>0)and((w-totalshrink[0]+q<=z)or(
totalshrink[1]<>0)or(totalshrink[2]<>0)or(totalshrink[3]<>0))then begin
freenode(b,7);b:=hpack(p,z-q,0);end else begin e:=0;
if w>z then begin freenode(b,7);b:=hpack(p,z,0);end;end;w:=mem[b+1].int;
end{:1201};{1202:}mem[b].hh.b1:=2;d:=half(z-w);
if(e>0)and(d<2*e)then begin d:=half(z-w-e);
if p<>0 then if not(p>=himemmin)then if mem[p].hh.b0=10 then d:=0;
end{:1202};
{1203:}begin mem[curlist.tailfield].hh.rh:=newpenalty(eqtb[5279].int);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
if(d+s<=eqtb[5858].int)or l then begin g1:=3;g2:=4;end else begin g1:=5;
g2:=6;end;if l and(e=0)then begin appdisplay(j,a,0);
begin mem[curlist.tailfield].hh.rh:=newpenalty(10000);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
end else begin mem[curlist.tailfield].hh.rh:=newparamglue(g1);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end{:1203};
{1204:}if e<>0 then begin r:=newkern(z-w-e-d);
if l then begin mem[a].hh.rh:=r;mem[r].hh.rh:=b;b:=a;d:=0;
end else begin mem[b].hh.rh:=r;mem[r].hh.rh:=a;end;b:=hpack(b,0,1);end;
appdisplay(j,b,d){:1204};
{1205:}if(a<>0)and(e=0)and not l then begin begin mem[curlist.tailfield]
.hh.rh:=newpenalty(10000);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
appdisplay(j,a,z-mem[a+1].int);g2:=0;end;
if t<>29995 then begin mem[curlist.tailfield].hh.rh:=mem[29995].hh.rh;
curlist.tailfield:=t;end;
begin mem[curlist.tailfield].hh.rh:=newpenalty(eqtb[5280].int);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
if g2>0 then begin mem[curlist.tailfield].hh.rh:=newparamglue(g2);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end{:1205};
{1476:}flushnodelist(j){:1476};resumeafterdisplay{:1199};end;end;
{:1194}{1200:}procedure resumeafterdisplay;
begin if curgroup<>15 then confusion(1181);unsave;
curlist.pgfield:=curlist.pgfield+3;pushnest;curlist.modefield:=102;
curlist.auxfield.hh.lh:=1000;
if eqtb[5318].int<=0 then curlang:=0 else if eqtb[5318].int>255 then
curlang:=0 else curlang:=eqtb[5318].int;curlist.auxfield.hh.rh:=curlang;
curlist.pgfield:=(normmin(eqtb[5319].int)*64+normmin(eqtb[5320].int))
*65536+curlang;{443:}begin getxtoken;if curcmd<>10 then backinput;
end{:443};if nestptr=1 then buildpage;end;
{:1200}{1211:}{1215:}procedure getrtoken;label 20;
begin 20:repeat gettoken;until curtok<>2592;
if(curcs=0)or(curcs>2614)then begin begin if interaction=3 then;
printnl(263);print(1199);end;begin helpptr:=5;helpline[4]:=1200;
helpline[3]:=1201;helpline[2]:=1202;helpline[1]:=1203;helpline[0]:=1204;
end;if curcs=0 then backinput;curtok:=6709;inserror;goto 20;end;end;
{:1215}{1229:}procedure trapzeroglue;
begin if(mem[curval+1].int=0)and(mem[curval+2].int=0)and(mem[curval+3].
int=0)then begin mem[0].hh.rh:=mem[0].hh.rh+1;deleteglueref(curval);
curval:=0;end;end;
{:1229}{1236:}procedure doregistercommand(a:smallnumber);label 40,10;
var l,q,r,s:halfword;p:0..3;e:boolean;w:integer;begin q:=curcmd;
e:=false;{1237:}begin if q<>89 then begin getxtoken;
if(curcmd>=73)and(curcmd<=76)then begin l:=curchr;p:=curcmd-73;goto 40;
end;if curcmd<>89 then begin begin if interaction=3 then;printnl(263);
print(694);end;printcmdchr(curcmd,curchr);print(695);printcmdchr(q,0);
begin helpptr:=1;helpline[0]:=1225;end;error;goto 10;end;end;
if(curchr<0)or(curchr>19)then begin l:=curchr;p:=(mem[l].hh.b0 div 16);
e:=true;end else begin p:=curchr-0;scanregisternum;
if curval>255 then begin findsaelement(p,curval,true);l:=curptr;e:=true;
end else case p of 0:l:=curval+5333;1:l:=curval+5866;2:l:=curval+2900;
3:l:=curval+3156;end;end;end;
40:if p<2 then if e then w:=mem[l+2].int else w:=eqtb[l].int else if e
then s:=mem[l+1].hh.rh else s:=eqtb[l].hh.rh{:1237};
if q=89 then scanoptionalequals else if scankeyword(1221)then;
aritherror:=false;
if q<91 then{1238:}if p<2 then begin if p=0 then scanint else scandimen(
false,false,false);if q=90 then curval:=curval+w;
end else begin scanglue(p);if q=90 then{1239:}begin q:=newspec(curval);
r:=s;deleteglueref(curval);mem[q+1].int:=mem[q+1].int+mem[r+1].int;
if mem[q+2].int=0 then mem[q].hh.b0:=0;
if mem[q].hh.b0=mem[r].hh.b0 then mem[q+2].int:=mem[q+2].int+mem[r+2].
int else if(mem[q].hh.b0<mem[r].hh.b0)and(mem[r+2].int<>0)then begin mem
[q+2].int:=mem[r+2].int;mem[q].hh.b0:=mem[r].hh.b0;end;
if mem[q+3].int=0 then mem[q].hh.b1:=0;
if mem[q].hh.b1=mem[r].hh.b1 then mem[q+3].int:=mem[q+3].int+mem[r+3].
int else if(mem[q].hh.b1<mem[r].hh.b1)and(mem[r+3].int<>0)then begin mem
[q+3].int:=mem[r+3].int;mem[q].hh.b1:=mem[r].hh.b1;end;curval:=q;
end{:1239};end{:1238}else{1240:}begin scanint;
if p<2 then if q=91 then if p=0 then curval:=multandadd(w,curval,0,
2147483647)else curval:=multandadd(w,curval,0,1073741823)else curval:=
xovern(w,curval)else begin r:=newspec(s);
if q=91 then begin mem[r+1].int:=multandadd(mem[s+1].int,curval,0,
1073741823);mem[r+2].int:=multandadd(mem[s+2].int,curval,0,1073741823);
mem[r+3].int:=multandadd(mem[s+3].int,curval,0,1073741823);
end else begin mem[r+1].int:=xovern(mem[s+1].int,curval);
mem[r+2].int:=xovern(mem[s+2].int,curval);
mem[r+3].int:=xovern(mem[s+3].int,curval);end;curval:=r;end;end{:1240};
if aritherror then begin begin if interaction=3 then;printnl(263);
print(1222);end;begin helpptr:=2;helpline[1]:=1223;helpline[0]:=1224;
end;if p>=2 then deleteglueref(curval);error;goto 10;end;
if p<2 then if e then if(a>=4)then gsawdef(l,curval)else sawdef(l,curval
)else if(a>=4)then geqworddefine(l,curval)else eqworddefine(l,curval)
else begin trapzeroglue;
if e then if(a>=4)then gsadef(l,curval)else sadef(l,curval)else if(a>=4)
then geqdefine(l,117,curval)else eqdefine(l,117,curval);end;10:end;
{:1236}{1243:}procedure alteraux;var c:halfword;
begin if curchr<>abs(curlist.modefield)then reportillegalcase else begin
c:=curchr;scanoptionalequals;
if c=1 then begin scandimen(false,false,false);
curlist.auxfield.int:=curval;end else begin scanint;
if(curval<=0)or(curval>32767)then begin begin if interaction=3 then;
printnl(263);print(1228);end;begin helpptr:=1;helpline[0]:=1229;end;
interror(curval);end else curlist.auxfield.hh.lh:=curval;end;end;end;
{:1243}{1244:}procedure alterprevgraf;var p:0..nestsize;
begin nest[nestptr]:=curlist;p:=nestptr;
while abs(nest[p].modefield)<>1 do p:=p-1;scanoptionalequals;scanint;
if curval<0 then begin begin if interaction=3 then;printnl(263);
print(966);end;printesc(536);begin helpptr:=1;helpline[0]:=1230;end;
interror(curval);end else begin nest[p].pgfield:=curval;
curlist:=nest[nestptr];end;end;{:1244}{1245:}procedure alterpagesofar;
var c:0..7;begin c:=curchr;scanoptionalequals;
scandimen(false,false,false);pagesofar[c]:=curval;end;
{:1245}{1246:}procedure alterinteger;var c:smallnumber;begin c:=curchr;
scanoptionalequals;scanint;
if c=0 then deadcycles:=curval{1427:}else if c=2 then begin if(curval<0)
or(curval>3)then begin begin if interaction=3 then;printnl(263);
print(1362);end;begin helpptr:=2;helpline[1]:=1363;helpline[0]:=1364;
end;interror(curval);end else begin curchr:=curval;newinteraction;end;
end{:1427}else insertpenalties:=curval;end;
{:1246}{1247:}procedure alterboxdimen;var c:smallnumber;b:halfword;
begin c:=curchr;scanregisternum;
if curval<256 then b:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then b:=0 else b:=mem[curptr+1].hh.rh;end;
scanoptionalequals;scandimen(false,false,false);
if b<>0 then mem[b+c].int:=curval;end;
{:1247}{1257:}procedure newfont(a:smallnumber);label 50;var u:halfword;
s:scaled;f:internalfontnumber;t:strnumber;oldsetting:0..21;
flushablestring:strnumber;begin if jobname=0 then openlogfile;getrtoken;
u:=curcs;
if u>=514 then t:=hash[u].rh else if u>=257 then if u=513 then t:=1234
else t:=u-257 else begin oldsetting:=selector;selector:=21;print(1234);
print(u-1);selector:=oldsetting;
begin if poolptr+1>poolsize then overflow(258,poolsize-initpoolptr);end;
t:=makestring;end;if(a>=4)then geqdefine(u,87,0)else eqdefine(u,87,0);
scanoptionalequals;scanfilename;{1258:}nameinprogress:=true;
if scankeyword(1235)then{1259:}begin scandimen(false,false,false);
s:=curval;
if(s<=0)or(s>=134217728)then begin begin if interaction=3 then;
printnl(263);print(1237);end;printscaled(s);print(1238);
begin helpptr:=2;helpline[1]:=1239;helpline[0]:=1240;end;error;
s:=10*65536;end;end{:1259}else if scankeyword(1236)then begin scanint;
s:=-curval;
if(curval<=0)or(curval>32768)then begin begin if interaction=3 then;
printnl(263);print(560);end;begin helpptr:=1;helpline[0]:=561;end;
interror(curval);s:=-1000;end;end else s:=-1000;
nameinprogress:=false{:1258};{1260:}flushablestring:=strptr-1;
for f:=1 to fontptr do if streqstr(fontname[f],curname)and streqstr(
fontarea[f],curarea)then begin if curname=flushablestring then begin
begin strptr:=strptr-1;poolptr:=strstart[strptr];end;
curname:=fontname[f];end;if s>0 then begin if s=fontsize[f]then goto 50;
end else if fontsize[f]=xnoverd(fontdsize[f],-s,1000)then goto 50;
end{:1260};f:=readfontinfo(u,curname,curarea,s);50:eqtb[u].hh.rh:=f;
eqtb[2624+f]:=eqtb[u];hash[2624+f].rh:=t;end;
{:1257}{1265:}procedure newinteraction;begin println;
interaction:=curchr;
{75:}if interaction=0 then selector:=16 else selector:=17{:75};
if logopened then selector:=selector+2;end;
{:1265}procedure prefixedcommand;label 30,10;var a:smallnumber;
f:internalfontnumber;j:halfword;k:fontindex;p,q:halfword;n:integer;
e:boolean;begin a:=0;
while curcmd=93 do begin if not odd(a div curchr)then a:=a+curchr;
{404:}repeat getxtoken;until(curcmd<>10)and(curcmd<>0){:404};
if curcmd<=70 then{1212:}begin begin if interaction=3 then;printnl(263);
print(1191);end;printcmdchr(curcmd,curchr);printchar(39);
begin helpptr:=1;helpline[0]:=1192;end;
if(eTeXmode=1)then helpline[0]:=1193;backerror;goto 10;end{:1212};
if eqtb[5304].int>2 then if(eTeXmode=1)then showcurcmdchr;end;
{1213:}if a>=8 then begin j:=3585;a:=a-8;end else j:=0;
if(curcmd<>97)and((a mod 4<>0)or(j<>0))then begin begin if interaction=3
then;printnl(263);print(694);end;printesc(1183);print(1194);
printesc(1184);begin helpptr:=1;helpline[0]:=1195;end;
if(eTeXmode=1)then begin helpline[0]:=1196;print(1194);printesc(1197);
end;print(1198);printcmdchr(curcmd,curchr);printchar(39);error;
end{:1213};
{1214:}if eqtb[5311].int<>0 then if eqtb[5311].int<0 then begin if(a>=4)
then a:=a-4;end else begin if not(a>=4)then a:=a+4;end{:1214};
case curcmd of{1217:}87:if(a>=4)then geqdefine(3939,120,curchr)else
eqdefine(3939,120,curchr);
{:1217}{1218:}97:begin if odd(curchr)and not(a>=4)and(eqtb[5311].int>=0)
then a:=a+4;e:=(curchr>=2);getrtoken;p:=curcs;q:=scantoks(true,e);
if j<>0 then begin q:=getavail;mem[q].hh.lh:=j;
mem[q].hh.rh:=mem[defref].hh.rh;mem[defref].hh.rh:=q;end;
if(a>=4)then geqdefine(p,111+(a mod 4),defref)else eqdefine(p,111+(a mod
4),defref);end;{:1218}{1221:}94:begin n:=curchr;getrtoken;p:=curcs;
if n=0 then begin repeat gettoken;until curcmd<>10;
if curtok=3133 then begin gettoken;if curcmd=10 then gettoken;end;
end else begin gettoken;q:=curtok;gettoken;backinput;curtok:=q;
backinput;end;
if curcmd>=111 then mem[curchr].hh.lh:=mem[curchr].hh.lh+1 else if(
curcmd=89)or(curcmd=71)then if(curchr<0)or(curchr>19)then mem[curchr+1].
hh.lh:=mem[curchr+1].hh.lh+1;
if(a>=4)then geqdefine(p,curcmd,curchr)else eqdefine(p,curcmd,curchr);
end;{:1221}{1224:}95:begin n:=curchr;getrtoken;p:=curcs;
if(a>=4)then geqdefine(p,0,256)else eqdefine(p,0,256);
scanoptionalequals;case n of 0:begin scancharnum;
if(a>=4)then geqdefine(p,68,curval)else eqdefine(p,68,curval);end;
1:begin scanfifteenbitint;
if(a>=4)then geqdefine(p,69,curval)else eqdefine(p,69,curval);end;
others:begin scanregisternum;if curval>255 then begin j:=n-2;
if j>3 then j:=5;findsaelement(j,curval,true);
mem[curptr+1].hh.lh:=mem[curptr+1].hh.lh+1;if j=5 then j:=71 else j:=89;
if(a>=4)then geqdefine(p,j,curptr)else eqdefine(p,j,curptr);
end else case n of 2:if(a>=4)then geqdefine(p,73,5333+curval)else
eqdefine(p,73,5333+curval);
3:if(a>=4)then geqdefine(p,74,5866+curval)else eqdefine(p,74,5866+curval
);
4:if(a>=4)then geqdefine(p,75,2900+curval)else eqdefine(p,75,2900+curval
);
5:if(a>=4)then geqdefine(p,76,3156+curval)else eqdefine(p,76,3156+curval
);
6:if(a>=4)then geqdefine(p,72,3423+curval)else eqdefine(p,72,3423+curval
);end;end end;end;{:1224}{1225:}96:begin j:=curchr;scanint;n:=curval;
if not scankeyword(852)then begin begin if interaction=3 then;
printnl(263);print(1084);end;begin helpptr:=2;helpline[1]:=1215;
helpline[0]:=1216;end;error;end;getrtoken;p:=curcs;readtoks(n,p,j);
if(a>=4)then geqdefine(p,111,curval)else eqdefine(p,111,curval);end;
{:1225}{1226:}71,72:begin q:=curcs;e:=false;
if curcmd=71 then if curchr=0 then begin scanregisternum;
if curval>255 then begin findsaelement(5,curval,true);curchr:=curptr;
e:=true;end else curchr:=3423+curval;end else e:=true;p:=curchr;
scanoptionalequals;{404:}repeat getxtoken;
until(curcmd<>10)and(curcmd<>0){:404};
if curcmd<>1 then{1227:}if(curcmd=71)or(curcmd=72)then begin if curcmd=
71 then if curchr=0 then begin scanregisternum;
if curval<256 then q:=eqtb[3423+curval].hh.rh else begin findsaelement(5
,curval,false);if curptr=0 then q:=0 else q:=mem[curptr+1].hh.rh;end;
end else q:=mem[curchr+1].hh.rh else q:=eqtb[curchr].hh.rh;
if q=0 then if e then if(a>=4)then gsadef(p,0)else sadef(p,0)else if(a>=
4)then geqdefine(p,101,0)else eqdefine(p,101,0)else begin mem[q].hh.lh:=
mem[q].hh.lh+1;
if e then if(a>=4)then gsadef(p,q)else sadef(p,q)else if(a>=4)then
geqdefine(p,111,q)else eqdefine(p,111,q);end;goto 30;end{:1227};
backinput;curcs:=q;q:=scantoks(false,false);
if mem[defref].hh.rh=0 then begin if e then if(a>=4)then gsadef(p,0)else
sadef(p,0)else if(a>=4)then geqdefine(p,101,0)else eqdefine(p,101,0);
begin mem[defref].hh.rh:=avail;avail:=defref;{dynused:=dynused-1;}end;
end else begin if(p=3413)and not e then begin mem[q].hh.rh:=getavail;
q:=mem[q].hh.rh;mem[q].hh.lh:=637;q:=getavail;mem[q].hh.lh:=379;
mem[q].hh.rh:=mem[defref].hh.rh;mem[defref].hh.rh:=q;end;
if e then if(a>=4)then gsadef(p,defref)else sadef(p,defref)else if(a>=4)
then geqdefine(p,111,defref)else eqdefine(p,111,defref);end;end;
{:1226}{1228:}73:begin p:=curchr;scanoptionalequals;scanint;
if(a>=4)then geqworddefine(p,curval)else eqworddefine(p,curval);end;
74:begin p:=curchr;scanoptionalequals;scandimen(false,false,false);
if(a>=4)then geqworddefine(p,curval)else eqworddefine(p,curval);end;
75,76:begin p:=curchr;n:=curcmd;scanoptionalequals;
if n=76 then scanglue(3)else scanglue(2);trapzeroglue;
if(a>=4)then geqdefine(p,117,curval)else eqdefine(p,117,curval);end;
{:1228}{1232:}85:begin{1233:}if curchr=3988 then n:=15 else if curchr=
5012 then n:=32768 else if curchr=4756 then n:=32767 else if curchr=5589
then n:=16777215 else n:=255{:1233};p:=curchr;scancharnum;p:=p+curval;
scanoptionalequals;scanint;
if((curval<0)and(p<5589))or(curval>n)then begin begin if interaction=3
then;printnl(263);print(1217);end;printint(curval);
if p<5589 then print(1218)else print(1219);printint(n);begin helpptr:=1;
helpline[0]:=1220;end;error;curval:=0;end;
if p<5012 then if(a>=4)then geqdefine(p,120,curval)else eqdefine(p,120,
curval)else if p<5589 then if(a>=4)then geqdefine(p,120,curval+0)else
eqdefine(p,120,curval+0)else if(a>=4)then geqworddefine(p,curval)else
eqworddefine(p,curval);end;{:1232}{1234:}86:begin p:=curchr;
scanfourbitint;p:=p+curval;scanoptionalequals;scanfontident;
if(a>=4)then geqdefine(p,120,curval)else eqdefine(p,120,curval);end;
{:1234}{1235:}89,90,91,92:doregistercommand(a);
{:1235}{1241:}98:begin scanregisternum;
if(a>=4)then n:=1073774592+curval else n:=1073741824+curval;
scanoptionalequals;
if setboxallowed then scanbox(n)else begin begin if interaction=3 then;
printnl(263);print(689);end;printesc(540);begin helpptr:=2;
helpline[1]:=1226;helpline[0]:=1227;end;error;end;end;
{:1241}{1242:}79:alteraux;80:alterprevgraf;81:alterpagesofar;
82:alterinteger;83:alterboxdimen;{:1242}{1248:}84:begin q:=curchr;
scanoptionalequals;scanint;n:=curval;
if n<=0 then p:=0 else if q>3412 then begin n:=(curval div 2)+1;
p:=getnode(2*n+1);mem[p].hh.lh:=n;n:=curval;mem[p+1].int:=n;
for j:=p+2 to p+n+1 do begin scanint;mem[j].int:=curval;end;
if not odd(n)then mem[p+n+2].int:=0;end else begin p:=getnode(2*n+1);
mem[p].hh.lh:=n;for j:=1 to n do begin scandimen(false,false,false);
mem[p+2*j-1].int:=curval;scandimen(false,false,false);
mem[p+2*j].int:=curval;end;end;
if(a>=4)then geqdefine(q,118,p)else eqdefine(q,118,p);end;
{:1248}{1252:}99:if curchr=1 then begin newpatterns;goto 30;
begin if interaction=3 then;printnl(263);print(1231);end;helpptr:=0;
error;repeat gettoken;until curcmd=2;goto 10;
end else begin newhyphexceptions;goto 30;end;
{:1252}{1253:}77:begin findfontdimen(true);k:=curval;scanoptionalequals;
scandimen(false,false,false);fontinfo[k].int:=curval;end;
78:begin n:=curchr;scanfontident;f:=curval;scanoptionalequals;scanint;
if n=0 then hyphenchar[f]:=curval else skewchar[f]:=curval;end;
{:1253}{1256:}88:newfont(a);{:1256}{1264:}100:newinteraction;
{:1264}others:confusion(1190)end;
30:{1269:}if aftertoken<>0 then begin curtok:=aftertoken;backinput;
aftertoken:=0;end{:1269};10:end;{:1211}{1270:}procedure doassignments;
label 10;begin while true do begin{404:}repeat getxtoken;
until(curcmd<>10)and(curcmd<>0){:404};if curcmd<=70 then goto 10;
setboxallowed:=false;prefixedcommand;setboxallowed:=true;end;10:end;
{:1270}{1275:}procedure openorclosein;var c:0..1;n:0..15;
begin c:=curchr;scanfourbitint;n:=curval;
if readopen[n]<>2 then begin aclose(readfile[n]);readopen[n]:=2;end;
if c<>0 then begin scanoptionalequals;scanfilename;
if curext=339 then curext:=801;packfilename(curname,curarea,curext);
if aopenin(readfile[n])then readopen[n]:=1;end;end;
{:1275}{1279:}procedure issuemessage;var oldsetting:0..21;c:0..1;
s:strnumber;begin c:=curchr;mem[29988].hh.rh:=scantoks(false,true);
oldsetting:=selector;selector:=21;tokenshow(defref);
selector:=oldsetting;flushlist(defref);
begin if poolptr+1>poolsize then overflow(258,poolsize-initpoolptr);end;
s:=makestring;
if c=0 then{1280:}begin if termoffset+(strstart[s+1]-strstart[s])>
maxprintline-2 then println else if(termoffset>0)or(fileoffset>0)then
printchar(32);slowprint(s);break(termout);
end{:1280}else{1283:}begin begin if interaction=3 then;printnl(263);
print(339);end;slowprint(s);
if eqtb[3421].hh.rh<>0 then useerrhelp:=true else if longhelpseen then
begin helpptr:=1;helpline[0]:=1247;
end else begin if interaction<3 then longhelpseen:=true;
begin helpptr:=4;helpline[3]:=1248;helpline[2]:=1249;helpline[1]:=1250;
helpline[0]:=1251;end;end;error;useerrhelp:=false;end{:1283};
begin strptr:=strptr-1;poolptr:=strstart[strptr];end;end;
{:1279}{1288:}procedure shiftcase;var b:halfword;p:halfword;t:halfword;
c:eightbits;begin b:=curchr;p:=scantoks(false,false);
p:=mem[defref].hh.rh;while p<>0 do begin{1289:}t:=mem[p].hh.lh;
if t<4352 then begin c:=t mod 256;
if eqtb[b+c].hh.rh<>0 then mem[p].hh.lh:=t-c+eqtb[b+c].hh.rh;end{:1289};
p:=mem[p].hh.rh;end;begintokenlist(mem[defref].hh.rh,3);
begin mem[defref].hh.rh:=avail;avail:=defref;{dynused:=dynused-1;}end;
end;{:1288}{1293:}procedure showwhatever;label 50;var p:halfword;
t:smallnumber;m:0..4;l:integer;n:integer;
begin case curchr of 3:begin begindiagnostic;showactivities;end;
1:{1296:}begin scanregisternum;
if curval<256 then p:=eqtb[3683+curval].hh.rh else begin findsaelement(4
,curval,false);if curptr=0 then p:=0 else p:=mem[curptr+1].hh.rh;end;
begindiagnostic;printnl(1267);printint(curval);printchar(61);
if p=0 then print(413)else showbox(p);end{:1296};
0:{1294:}begin gettoken;if interaction=3 then;printnl(1263);
if curcs<>0 then begin sprintcs(curcs);printchar(61);end;printmeaning;
goto 50;end{:1294};{1408:}4:begin begindiagnostic;showsavegroups;end;
{:1408}{1422:}6:begin begindiagnostic;printnl(339);println;
if condptr=0 then begin printnl(366);print(1359);
end else begin p:=condptr;n:=0;repeat n:=n+1;p:=mem[p].hh.rh;until p=0;
p:=condptr;t:=curif;l:=ifline;m:=iflimit;repeat printnl(1360);
printint(n);print(575);printcmdchr(105,t);if m=2 then printesc(786);
if l<>0 then begin print(1358);printint(l);end;n:=n-1;t:=mem[p].hh.b1;
l:=mem[p+1].int;m:=mem[p].hh.b0;p:=mem[p].hh.rh;until p=0;end;end;
{:1422}others:{1297:}begin p:=thetoks;if interaction=3 then;
printnl(1263);tokenshow(29997);flushlist(mem[29997].hh.rh);goto 50;
end{:1297}end;{1298:}enddiagnostic(true);begin if interaction=3 then;
printnl(263);print(1268);end;
if selector=19 then if eqtb[5297].int<=0 then begin selector:=17;
print(1269);selector:=19;end{:1298};
50:if interaction<3 then begin helpptr:=0;errorcount:=errorcount-1;
end else if eqtb[5297].int>0 then begin begin helpptr:=3;
helpline[2]:=1258;helpline[1]:=1259;helpline[0]:=1260;end;
end else begin begin helpptr:=5;helpline[4]:=1258;helpline[3]:=1259;
helpline[2]:=1260;helpline[1]:=1261;helpline[0]:=1262;end;end;error;end;
{:1293}{1302:}procedure storefmtfile;label 41,42,31,32;
var j,k,l:integer;p,q:halfword;x:integer;w:fourquarters;
begin{1304:}if saveptr<>0 then begin begin if interaction=3 then;
printnl(263);print(1271);end;begin helpptr:=1;helpline[0]:=1272;end;
begin if interaction=3 then interaction:=2;if logopened then error;
{if interaction>0 then debughelp;}history:=3;jumpout;end;end{:1304};
{1328:}selector:=21;print(1285);print(jobname);printchar(32);
printint(eqtb[5291].int);printchar(46);printint(eqtb[5290].int);
printchar(46);printint(eqtb[5289].int);printchar(41);
if interaction=0 then selector:=18 else selector:=19;
begin if poolptr+1>poolsize then overflow(258,poolsize-initpoolptr);end;
formatident:=makestring;packjobname(796);
while not wopenout(fmtfile)do promptfilename(1286,796);printnl(1287);
slowprint(wmakenamestring(fmtfile));begin strptr:=strptr-1;
poolptr:=strstart[strptr];end;printnl(339);
slowprint(formatident){:1328};{1307:}begin fmtfile^.int:=274155489;
put(fmtfile);end;{1385:}begin fmtfile^.int:=eTeXmode;put(fmtfile);end;
for j:=0 to-0 do eqtb[5332+j].int:=0;
{:1385}{1491:}while pseudofiles<>0 do pseudoclose;
{:1491}begin fmtfile^.int:=0;put(fmtfile);end;begin fmtfile^.int:=30000;
put(fmtfile);end;begin fmtfile^.int:=6121;put(fmtfile);end;
begin fmtfile^.int:=1777;put(fmtfile);end;begin fmtfile^.int:=307;
put(fmtfile);end{:1307};{1309:}begin fmtfile^.int:=poolptr;put(fmtfile);
end;begin fmtfile^.int:=strptr;put(fmtfile);end;
for k:=0 to strptr do begin fmtfile^.int:=strstart[k];put(fmtfile);end;
k:=0;while k+4<poolptr do begin w.b0:=strpool[k]+0;w.b1:=strpool[k+1]+0;
w.b2:=strpool[k+2]+0;w.b3:=strpool[k+3]+0;begin fmtfile^.qqqq:=w;
put(fmtfile);end;k:=k+4;end;k:=poolptr-4;w.b0:=strpool[k]+0;
w.b1:=strpool[k+1]+0;w.b2:=strpool[k+2]+0;w.b3:=strpool[k+3]+0;
begin fmtfile^.qqqq:=w;put(fmtfile);end;println;printint(strptr);
print(1273);printint(poolptr){:1309};{1311:}sortavail;varused:=0;
begin fmtfile^.int:=lomemmax;put(fmtfile);end;begin fmtfile^.int:=rover;
put(fmtfile);end;
if(eTeXmode=1)then for k:=0 to 5 do begin fmtfile^.int:=saroot[k];
put(fmtfile);end;p:=0;q:=rover;x:=0;
repeat for k:=p to q+1 do begin fmtfile^:=mem[k];put(fmtfile);end;
x:=x+q+2-p;varused:=varused+q-p;p:=q+mem[q].hh.lh;q:=mem[q+1].hh.rh;
until q=rover;varused:=varused+lomemmax-p;dynused:=memend+1-himemmin;
for k:=p to lomemmax do begin fmtfile^:=mem[k];put(fmtfile);end;
x:=x+lomemmax+1-p;begin fmtfile^.int:=himemmin;put(fmtfile);end;
begin fmtfile^.int:=avail;put(fmtfile);end;
for k:=himemmin to memend do begin fmtfile^:=mem[k];put(fmtfile);end;
x:=x+memend+1-himemmin;p:=avail;while p<>0 do begin dynused:=dynused-1;
p:=mem[p].hh.rh;end;begin fmtfile^.int:=varused;put(fmtfile);end;
begin fmtfile^.int:=dynused;put(fmtfile);end;println;printint(x);
print(1274);printint(varused);printchar(38);printint(dynused){:1311};
{1313:}{1315:}k:=1;repeat j:=k;
while j<5267 do begin if(eqtb[j].hh.rh=eqtb[j+1].hh.rh)and(eqtb[j].hh.b0
=eqtb[j+1].hh.b0)and(eqtb[j].hh.b1=eqtb[j+1].hh.b1)then goto 41;j:=j+1;
end;l:=5268;goto 31;41:j:=j+1;l:=j;
while j<5267 do begin if(eqtb[j].hh.rh<>eqtb[j+1].hh.rh)or(eqtb[j].hh.b0
<>eqtb[j+1].hh.b0)or(eqtb[j].hh.b1<>eqtb[j+1].hh.b1)then goto 31;j:=j+1;
end;31:begin fmtfile^.int:=l-k;put(fmtfile);end;
while k<l do begin begin fmtfile^:=eqtb[k];put(fmtfile);end;k:=k+1;end;
k:=j+1;begin fmtfile^.int:=k-l;put(fmtfile);end;until k=5268{:1315};
{1316:}repeat j:=k;
while j<6121 do begin if eqtb[j].int=eqtb[j+1].int then goto 42;j:=j+1;
end;l:=6122;goto 32;42:j:=j+1;l:=j;
while j<6121 do begin if eqtb[j].int<>eqtb[j+1].int then goto 32;j:=j+1;
end;32:begin fmtfile^.int:=l-k;put(fmtfile);end;
while k<l do begin begin fmtfile^:=eqtb[k];put(fmtfile);end;k:=k+1;end;
k:=j+1;begin fmtfile^.int:=k-l;put(fmtfile);end;until k>6121{:1316};
begin fmtfile^.int:=parloc;put(fmtfile);end;
begin fmtfile^.int:=writeloc;put(fmtfile);end;
{1318:}begin fmtfile^.int:=hashused;put(fmtfile);end;
cscount:=2613-hashused;
for p:=514 to hashused do if hash[p].rh<>0 then begin begin fmtfile^.int
:=p;put(fmtfile);end;begin fmtfile^.hh:=hash[p];put(fmtfile);end;
cscount:=cscount+1;end;
for p:=hashused+1 to 2880 do begin fmtfile^.hh:=hash[p];put(fmtfile);
end;begin fmtfile^.int:=cscount;put(fmtfile);end;println;
printint(cscount);print(1275){:1318}{:1313};
{1320:}begin fmtfile^.int:=fmemptr;put(fmtfile);end;
for k:=0 to fmemptr-1 do begin fmtfile^:=fontinfo[k];put(fmtfile);end;
begin fmtfile^.int:=fontptr;put(fmtfile);end;
for k:=0 to fontptr do{1322:}begin begin fmtfile^.qqqq:=fontcheck[k];
put(fmtfile);end;begin fmtfile^.int:=fontsize[k];put(fmtfile);end;
begin fmtfile^.int:=fontdsize[k];put(fmtfile);end;
begin fmtfile^.int:=fontparams[k];put(fmtfile);end;
begin fmtfile^.int:=hyphenchar[k];put(fmtfile);end;
begin fmtfile^.int:=skewchar[k];put(fmtfile);end;
begin fmtfile^.int:=fontname[k];put(fmtfile);end;
begin fmtfile^.int:=fontarea[k];put(fmtfile);end;
begin fmtfile^.int:=fontbc[k];put(fmtfile);end;
begin fmtfile^.int:=fontec[k];put(fmtfile);end;
begin fmtfile^.int:=charbase[k];put(fmtfile);end;
begin fmtfile^.int:=widthbase[k];put(fmtfile);end;
begin fmtfile^.int:=heightbase[k];put(fmtfile);end;
begin fmtfile^.int:=depthbase[k];put(fmtfile);end;
begin fmtfile^.int:=italicbase[k];put(fmtfile);end;
begin fmtfile^.int:=ligkernbase[k];put(fmtfile);end;
begin fmtfile^.int:=kernbase[k];put(fmtfile);end;
begin fmtfile^.int:=extenbase[k];put(fmtfile);end;
begin fmtfile^.int:=parambase[k];put(fmtfile);end;
begin fmtfile^.int:=fontglue[k];put(fmtfile);end;
begin fmtfile^.int:=bcharlabel[k];put(fmtfile);end;
begin fmtfile^.int:=fontbchar[k];put(fmtfile);end;
begin fmtfile^.int:=fontfalsebchar[k];put(fmtfile);end;printnl(1278);
printesc(hash[2624+k].rh);printchar(61);
printfilename(fontname[k],fontarea[k],339);
if fontsize[k]<>fontdsize[k]then begin print(751);
printscaled(fontsize[k]);print(400);end;end{:1322};println;
printint(fmemptr-7);print(1276);printint(fontptr-0);print(1277);
if fontptr<>1 then printchar(115){:1320};
{1324:}begin fmtfile^.int:=hyphcount;put(fmtfile);end;
for k:=0 to 307 do if hyphword[k]<>0 then begin begin fmtfile^.int:=k;
put(fmtfile);end;begin fmtfile^.int:=hyphword[k];put(fmtfile);end;
begin fmtfile^.int:=hyphlist[k];put(fmtfile);end;end;println;
printint(hyphcount);print(1279);if hyphcount<>1 then printchar(115);
if trienotready then inittrie;begin fmtfile^.int:=triemax;put(fmtfile);
end;begin fmtfile^.int:=hyphstart;put(fmtfile);end;
for k:=0 to triemax do begin fmtfile^.hh:=trie[k];put(fmtfile);end;
begin fmtfile^.int:=trieopptr;put(fmtfile);end;
for k:=1 to trieopptr do begin begin fmtfile^.int:=hyfdistance[k];
put(fmtfile);end;begin fmtfile^.int:=hyfnum[k];put(fmtfile);end;
begin fmtfile^.int:=hyfnext[k];put(fmtfile);end;end;printnl(1280);
printint(triemax);print(1281);printint(trieopptr);print(1282);
if trieopptr<>1 then printchar(115);print(1283);printint(trieopsize);
for k:=255 downto 0 do if trieused[k]>0 then begin printnl(810);
printint(trieused[k]-0);print(1284);printint(k);begin fmtfile^.int:=k;
put(fmtfile);end;begin fmtfile^.int:=trieused[k]-0;put(fmtfile);end;
end{:1324};{1326:}begin fmtfile^.int:=interaction;put(fmtfile);end;
begin fmtfile^.int:=formatident;put(fmtfile);end;
begin fmtfile^.int:=69069;put(fmtfile);end;eqtb[5299].int:=0{:1326};
{1329:}wclose(fmtfile){:1329};end;
{:1302}{1348:}{1349:}procedure newwhatsit(s:smallnumber;w:smallnumber);
var p:halfword;begin p:=getnode(w);mem[p].hh.b0:=8;mem[p].hh.b1:=s;
mem[curlist.tailfield].hh.rh:=p;curlist.tailfield:=p;end;
{:1349}{1350:}procedure newwritewhatsit(w:smallnumber);
begin newwhatsit(curchr,w);
if w<>2 then scanfourbitint else begin scanint;
if curval<0 then curval:=17 else if curval>15 then curval:=16;end;
mem[curlist.tailfield+1].hh.lh:=curval;end;{:1350}procedure doextension;
var i,j,k:integer;p,q,r:halfword;
begin case curchr of 0:{1351:}begin newwritewhatsit(3);
scanoptionalequals;scanfilename;mem[curlist.tailfield+1].hh.rh:=curname;
mem[curlist.tailfield+2].hh.lh:=curarea;
mem[curlist.tailfield+2].hh.rh:=curext;end{:1351};
1:{1352:}begin k:=curcs;newwritewhatsit(2);curcs:=k;
p:=scantoks(false,false);mem[curlist.tailfield+1].hh.rh:=defref;
end{:1352};2:{1353:}begin newwritewhatsit(2);
mem[curlist.tailfield+1].hh.rh:=0;end{:1353};
3:{1354:}begin newwhatsit(3,2);mem[curlist.tailfield+1].hh.lh:=0;
p:=scantoks(false,true);mem[curlist.tailfield+1].hh.rh:=defref;
end{:1354};4:{1375:}begin getxtoken;
if(curcmd=59)and(curchr<=2)then begin p:=curlist.tailfield;doextension;
outwhat(curlist.tailfield);flushnodelist(curlist.tailfield);
curlist.tailfield:=p;mem[p].hh.rh:=0;end else backinput;end{:1375};
5:{1377:}if abs(curlist.modefield)<>102 then reportillegalcase else
begin newwhatsit(4,2);scanint;
if curval<=0 then curlist.auxfield.hh.rh:=0 else if curval>255 then
curlist.auxfield.hh.rh:=0 else curlist.auxfield.hh.rh:=curval;
mem[curlist.tailfield+1].hh.rh:=curlist.auxfield.hh.rh;
mem[curlist.tailfield+1].hh.b0:=normmin(eqtb[5319].int);
mem[curlist.tailfield+1].hh.b1:=normmin(eqtb[5320].int);end{:1377};
others:confusion(1304)end;end;{:1348}{1376:}procedure fixlanguage;
var l:ASCIIcode;
begin if eqtb[5318].int<=0 then l:=0 else if eqtb[5318].int>255 then l:=
0 else l:=eqtb[5318].int;
if l<>curlist.auxfield.hh.rh then begin newwhatsit(4,2);
mem[curlist.tailfield+1].hh.rh:=l;curlist.auxfield.hh.rh:=l;
mem[curlist.tailfield+1].hh.b0:=normmin(eqtb[5319].int);
mem[curlist.tailfield+1].hh.b1:=normmin(eqtb[5320].int);end;end;
{:1376}{1068:}procedure handlerightbrace;var p,q:halfword;d:scaled;
f:integer;begin case curgroup of 1:unsave;
0:begin begin if interaction=3 then;printnl(263);print(1054);end;
begin helpptr:=2;helpline[1]:=1055;helpline[0]:=1056;end;error;end;
14,15,16:extrarightbrace;{1085:}2:package(0);3:begin adjusttail:=29995;
package(0);end;4:begin endgraf;package(0);end;5:begin endgraf;
package(4);end;{:1085}{1100:}11:begin endgraf;q:=eqtb[2892].hh.rh;
mem[q].hh.rh:=mem[q].hh.rh+1;d:=eqtb[5851].int;f:=eqtb[5310].int;unsave;
saveptr:=saveptr-1;
p:=vpackage(mem[curlist.headfield].hh.rh,0,1,1073741823);popnest;
if savestack[saveptr+0].int<255 then begin begin mem[curlist.tailfield].
hh.rh:=getnode(5);curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=3;
mem[curlist.tailfield].hh.b1:=savestack[saveptr+0].int+0;
mem[curlist.tailfield+3].int:=mem[p+3].int+mem[p+2].int;
mem[curlist.tailfield+4].hh.lh:=mem[p+5].hh.rh;
mem[curlist.tailfield+4].hh.rh:=q;mem[curlist.tailfield+2].int:=d;
mem[curlist.tailfield+1].int:=f;
end else begin begin mem[curlist.tailfield].hh.rh:=getnode(2);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=5;mem[curlist.tailfield].hh.b1:=0;
mem[curlist.tailfield+1].int:=mem[p+5].hh.rh;deleteglueref(q);end;
freenode(p,7);if nestptr=0 then buildpage;end;
8:{1026:}begin if(curinput.locfield<>0)or((curinput.indexfield<>6)and(
curinput.indexfield<>3))then{1027:}begin begin if interaction=3 then;
printnl(263);print(1021);end;begin helpptr:=2;helpline[1]:=1022;
helpline[0]:=1023;end;error;repeat gettoken;until curinput.locfield=0;
end{:1027};endtokenlist;endgraf;unsave;outputactive:=false;
insertpenalties:=0;
{1028:}if eqtb[3938].hh.rh<>0 then begin begin if interaction=3 then;
printnl(263);print(1024);end;printesc(412);printint(255);
begin helpptr:=3;helpline[2]:=1025;helpline[1]:=1026;helpline[0]:=1027;
end;boxerror(255);end{:1028};
if curlist.tailfield<>curlist.headfield then begin mem[pagetail].hh.rh:=
mem[curlist.headfield].hh.rh;pagetail:=curlist.tailfield;end;
if mem[29998].hh.rh<>0 then begin if mem[29999].hh.rh=0 then nest[0].
tailfield:=pagetail;mem[pagetail].hh.rh:=mem[29999].hh.rh;
mem[29999].hh.rh:=mem[29998].hh.rh;mem[29998].hh.rh:=0;pagetail:=29998;
end;flushnodelist(discptr[2]);discptr[2]:=0;popnest;buildpage;
end{:1026};{:1100}{1118:}10:builddiscretionary;
{:1118}{1132:}6:begin backinput;curtok:=6710;
begin if interaction=3 then;printnl(263);print(634);end;printesc(910);
print(635);begin helpptr:=1;helpline[0]:=1136;end;inserror;end;
{:1132}{1133:}7:begin endgraf;unsave;alignpeek;end;
{:1133}{1168:}12:begin endgraf;unsave;saveptr:=saveptr-2;
p:=vpackage(mem[curlist.headfield].hh.rh,savestack[saveptr+1].int,
savestack[saveptr+0].int,1073741823);popnest;
begin mem[curlist.tailfield].hh.rh:=newnoad;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=29;mem[curlist.tailfield+1].hh.rh:=2;
mem[curlist.tailfield+1].hh.lh:=p;end;{:1168}{1173:}13:buildchoices;
{:1173}{1186:}9:begin unsave;saveptr:=saveptr-1;
mem[savestack[saveptr+0].int].hh.rh:=3;p:=finmlist(0);
mem[savestack[saveptr+0].int].hh.lh:=p;
if p<>0 then if mem[p].hh.rh=0 then if mem[p].hh.b0=16 then begin if mem
[p+3].hh.rh=0 then if mem[p+2].hh.rh=0 then begin mem[savestack[saveptr
+0].int].hh:=mem[p+1].hh;freenode(p,4);end;
end else if mem[p].hh.b0=28 then if savestack[saveptr+0].int=curlist.
tailfield+1 then if mem[curlist.tailfield].hh.b0=16 then{1187:}begin q:=
curlist.headfield;
while mem[q].hh.rh<>curlist.tailfield do q:=mem[q].hh.rh;
mem[q].hh.rh:=p;freenode(curlist.tailfield,4);curlist.tailfield:=p;
end{:1187};end;{:1186}others:confusion(1057)end;end;
{:1068}procedure maincontrol;
label 60,21,70,80,90,91,92,95,100,101,110,111,112,120,10;var t:integer;
begin if eqtb[3419].hh.rh<>0 then begintokenlist(eqtb[3419].hh.rh,12);
60:getxtoken;
21:{1031:}if interrupt<>0 then if OKtointerrupt then begin backinput;
begin if interrupt<>0 then pauseforinstructions;end;goto 60;end;
{if panicking then checkmem(false);}
if eqtb[5304].int>0 then showcurcmdchr{:1031};
case abs(curlist.modefield)+curcmd of 113,114,170:goto 70;
118:begin scancharnum;curchr:=curval;goto 70;end;167:begin getxtoken;
if(curcmd=11)or(curcmd=12)or(curcmd=68)or(curcmd=16)then cancelboundary
:=true;goto 21;end;
112:if curlist.auxfield.hh.lh=1000 then goto 120 else appspace;
166,267:goto 120;{1045:}1,102,203,11,213,268:;
40,141,242:begin{406:}repeat getxtoken;until curcmd<>10{:406};goto 21;
end;15:if itsallover then goto 10;
{1048:}23,123,224,71,172,273,{:1048}{1098:}39,{:1098}{1111:}45,{:1111}
{1144:}49,150,{:1144}7,108,209:reportillegalcase;
{1046:}8,109,9,110,18,119,70,171,51,152,16,117,50,151,53,154,67,168,54,
155,55,156,57,158,56,157,31,132,52,153,29,130,47,148,212,216,217,230,227
,236,239{:1046}:insertdollarsign;
{1056:}37,137,238:begin begin mem[curlist.tailfield].hh.rh:=scanrulespec
;curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
if abs(curlist.modefield)=1 then curlist.auxfield.int:=-65536000 else if
abs(curlist.modefield)=102 then curlist.auxfield.hh.lh:=1000;end;
{:1056}{1057:}28,128,229,231:appendglue;30,131,232,233:appendkern;
{:1057}{1063:}2,103:newsavelevel(1);62,163,264:newsavelevel(14);
63,164,265:if curgroup=14 then unsave else offsave;
{:1063}{1067:}3,104,205:handlerightbrace;
{:1067}{1073:}22,124,225:begin t:=curchr;scandimen(false,false,false);
if t=0 then scanbox(curval)else scanbox(-curval);end;
32,133,234:scanbox(1073807261+curchr);21,122,223:beginbox(0);
{:1073}{1090:}44:newgraf(curchr>0);
12,13,17,69,4,24,36,46,48,27,34,65,66:begin backinput;newgraf(true);end;
{:1090}{1092:}145,246:indentinhmode;
{:1092}{1094:}14:begin normalparagraph;
if curlist.modefield>0 then buildpage;end;
115:begin if alignstate<0 then offsave;endgraf;
if curlist.modefield=1 then buildpage;end;
116,129,138,126,134:headforvmode;
{:1094}{1097:}38,139,240,140,241:begininsertoradjust;
19,120,221:makemark;{:1097}{1102:}43,144,245:appendpenalty;
{:1102}{1104:}26,127,228:deletelast;{:1104}{1109:}25,125,226:unpackage;
{:1109}{1112:}146:appenditaliccorrection;
247:begin mem[curlist.tailfield].hh.rh:=newkern(0);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
{:1112}{1116:}149,250:appenddiscretionary;{:1116}{1122:}147:makeaccent;
{:1122}{1126:}6,107,208,5,106,207:alignerror;35,136,237:noalignerror;
64,165,266:omiterror;{:1126}{1130:}33:initalign;
135:{1434:}if curchr>0 then begin if eTeXenabled((eqtb[5332].int>0),
curcmd,curchr)then begin mem[curlist.tailfield].hh.rh:=newmath(0,curchr)
;curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
end else{:1434}initalign;
235:if privileged then if curgroup=15 then initalign else offsave;
10,111:doendv;{:1130}{1134:}68,169,270:cserror;
{:1134}{1137:}105:initmath;
{:1137}{1140:}251:if privileged then if curgroup=15 then starteqno else
offsave;
{:1140}{1150:}204:begin begin mem[curlist.tailfield].hh.rh:=newnoad;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;backinput;
scanmath(curlist.tailfield+1);end;
{:1150}{1154:}214,215,271:setmathchar(eqtb[5012+curchr].hh.rh-0);
219:begin scancharnum;curchr:=curval;
setmathchar(eqtb[5012+curchr].hh.rh-0);end;220:begin scanfifteenbitint;
setmathchar(curval);end;272:setmathchar(curchr);
218:begin scantwentysevenbitint;setmathchar(curval div 4096);end;
{:1154}{1158:}253:begin begin mem[curlist.tailfield].hh.rh:=newnoad;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b0:=curchr;scanmath(curlist.tailfield+1);end;
254:mathlimitswitch;{:1158}{1162:}269:mathradical;
{:1162}{1164:}248,249:mathac;{:1164}{1167:}259:begin scanspec(12,false);
normalparagraph;pushnest;curlist.modefield:=-1;
curlist.auxfield.int:=-65536000;
if eqtb[3418].hh.rh<>0 then begintokenlist(eqtb[3418].hh.rh,11);end;
{:1167}{1171:}256:begin mem[curlist.tailfield].hh.rh:=newstyle(curchr);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
258:begin begin mem[curlist.tailfield].hh.rh:=newglue(0);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;
mem[curlist.tailfield].hh.b1:=98;end;257:appendchoices;
{:1171}{1175:}211,210:subsup;{:1175}{1180:}255:mathfraction;
{:1180}{1190:}252:mathleftright;
{:1190}{1193:}206:if curgroup=15 then aftermath else offsave;
{:1193}{1210:}72,173,274,73,174,275,74,175,276,75,176,277,76,177,278,77,
178,279,78,179,280,79,180,281,80,181,282,81,182,283,82,183,284,83,184,
285,84,185,286,85,186,287,86,187,288,87,188,289,88,189,290,89,190,291,90
,191,292,91,192,293,92,193,294,93,194,295,94,195,296,95,196,297,96,197,
298,97,198,299,98,199,300,99,200,301,100,201,302,101,202,303:
prefixedcommand;{:1210}{1268:}41,142,243:begin gettoken;
aftertoken:=curtok;end;{:1268}{1271:}42,143,244:begin gettoken;
saveforafter(curtok);end;{:1271}{1274:}61,162,263:openorclosein;
{:1274}{1276:}59,160,261:issuemessage;
{:1276}{1285:}58,159,260:shiftcase;
{:1285}{1290:}20,121,222:showwhatever;
{:1290}{1347:}60,161,262:doextension;{:1347}{:1045}end;goto 60;
70:{1034:}mains:=eqtb[4756+curchr].hh.rh;
if mains=1000 then curlist.auxfield.hh.lh:=1000 else if mains<1000 then
begin if mains>0 then curlist.auxfield.hh.lh:=mains;
end else if curlist.auxfield.hh.lh<1000 then curlist.auxfield.hh.lh:=
1000 else curlist.auxfield.hh.lh:=mains;mainf:=eqtb[3939].hh.rh;
bchar:=fontbchar[mainf];falsebchar:=fontfalsebchar[mainf];
if curlist.modefield>0 then if eqtb[5318].int<>curlist.auxfield.hh.rh
then fixlanguage;begin ligstack:=avail;
if ligstack=0 then ligstack:=getavail else begin avail:=mem[ligstack].hh
.rh;mem[ligstack].hh.rh:=0;{dynused:=dynused+1;}end;end;
mem[ligstack].hh.b0:=mainf;curl:=curchr+0;mem[ligstack].hh.b1:=curl;
curq:=curlist.tailfield;
if cancelboundary then begin cancelboundary:=false;maink:=0;
end else maink:=bcharlabel[mainf];if maink=0 then goto 92;curr:=curl;
curl:=256;goto 111;
80:{1035:}if curl<256 then begin if mem[curq].hh.rh>0 then if mem[
curlist.tailfield].hh.b1=hyphenchar[mainf]+0 then insdisc:=true;
if ligaturepresent then begin mainp:=newligature(mainf,curl,mem[curq].hh
.rh);if lfthit then begin mem[mainp].hh.b1:=2;lfthit:=false;end;
if rthit then if ligstack=0 then begin mem[mainp].hh.b1:=mem[mainp].hh.
b1+1;rthit:=false;end;mem[curq].hh.rh:=mainp;curlist.tailfield:=mainp;
ligaturepresent:=false;end;if insdisc then begin insdisc:=false;
if curlist.modefield>0 then begin mem[curlist.tailfield].hh.rh:=newdisc;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;end;end{:1035};
90:{1036:}if ligstack=0 then goto 21;curq:=curlist.tailfield;
curl:=mem[ligstack].hh.b1;91:if not(ligstack>=himemmin)then goto 95;
92:if(curchr<fontbc[mainf])or(curchr>fontec[mainf])then begin
charwarning(mainf,curchr);begin mem[ligstack].hh.rh:=avail;
avail:=ligstack;{dynused:=dynused-1;}end;goto 60;end;
maini:=fontinfo[charbase[mainf]+curl].qqqq;
if not(maini.b0>0)then begin charwarning(mainf,curchr);
begin mem[ligstack].hh.rh:=avail;avail:=ligstack;{dynused:=dynused-1;}
end;goto 60;end;mem[curlist.tailfield].hh.rh:=ligstack;
curlist.tailfield:=ligstack{:1036};100:{1038:}getnext;
if curcmd=11 then goto 101;if curcmd=12 then goto 101;
if curcmd=68 then goto 101;xtoken;if curcmd=11 then goto 101;
if curcmd=12 then goto 101;if curcmd=68 then goto 101;
if curcmd=16 then begin scancharnum;curchr:=curval;goto 101;end;
if curcmd=65 then bchar:=256;curr:=bchar;ligstack:=0;goto 110;
101:mains:=eqtb[4756+curchr].hh.rh;
if mains=1000 then curlist.auxfield.hh.lh:=1000 else if mains<1000 then
begin if mains>0 then curlist.auxfield.hh.lh:=mains;
end else if curlist.auxfield.hh.lh<1000 then curlist.auxfield.hh.lh:=
1000 else curlist.auxfield.hh.lh:=mains;begin ligstack:=avail;
if ligstack=0 then ligstack:=getavail else begin avail:=mem[ligstack].hh
.rh;mem[ligstack].hh.rh:=0;{dynused:=dynused+1;}end;end;
mem[ligstack].hh.b0:=mainf;curr:=curchr+0;mem[ligstack].hh.b1:=curr;
if curr=falsebchar then curr:=256{:1038};
110:{1039:}if((maini.b2-0)mod 4)<>1 then goto 80;
if curr=256 then goto 80;maink:=ligkernbase[mainf]+maini.b3;
mainj:=fontinfo[maink].qqqq;if mainj.b0<=128 then goto 112;
maink:=ligkernbase[mainf]+256*mainj.b2+mainj.b3+32768-256*(128);
111:mainj:=fontinfo[maink].qqqq;
112:if mainj.b1=curr then if mainj.b0<=128 then{1040:}begin if mainj.b2
>=128 then begin if curl<256 then begin if mem[curq].hh.rh>0 then if mem
[curlist.tailfield].hh.b1=hyphenchar[mainf]+0 then insdisc:=true;
if ligaturepresent then begin mainp:=newligature(mainf,curl,mem[curq].hh
.rh);if lfthit then begin mem[mainp].hh.b1:=2;lfthit:=false;end;
if rthit then if ligstack=0 then begin mem[mainp].hh.b1:=mem[mainp].hh.
b1+1;rthit:=false;end;mem[curq].hh.rh:=mainp;curlist.tailfield:=mainp;
ligaturepresent:=false;end;if insdisc then begin insdisc:=false;
if curlist.modefield>0 then begin mem[curlist.tailfield].hh.rh:=newdisc;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;end;end;
begin mem[curlist.tailfield].hh.rh:=newkern(fontinfo[kernbase[mainf]+256
*mainj.b2+mainj.b3].int);
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;goto 90;end;
if curl=256 then lfthit:=true else if ligstack=0 then rthit:=true;
begin if interrupt<>0 then pauseforinstructions;end;
case mainj.b2 of 1,5:begin curl:=mainj.b3;
maini:=fontinfo[charbase[mainf]+curl].qqqq;ligaturepresent:=true;end;
2,6:begin curr:=mainj.b3;
if ligstack=0 then begin ligstack:=newligitem(curr);bchar:=256;
end else if(ligstack>=himemmin)then begin mainp:=ligstack;
ligstack:=newligitem(curr);mem[ligstack+1].hh.rh:=mainp;
end else mem[ligstack].hh.b1:=curr;end;3:begin curr:=mainj.b3;
mainp:=ligstack;ligstack:=newligitem(curr);mem[ligstack].hh.rh:=mainp;
end;7,11:begin if curl<256 then begin if mem[curq].hh.rh>0 then if mem[
curlist.tailfield].hh.b1=hyphenchar[mainf]+0 then insdisc:=true;
if ligaturepresent then begin mainp:=newligature(mainf,curl,mem[curq].hh
.rh);if lfthit then begin mem[mainp].hh.b1:=2;lfthit:=false;end;
if false then if ligstack=0 then begin mem[mainp].hh.b1:=mem[mainp].hh.
b1+1;rthit:=false;end;mem[curq].hh.rh:=mainp;curlist.tailfield:=mainp;
ligaturepresent:=false;end;if insdisc then begin insdisc:=false;
if curlist.modefield>0 then begin mem[curlist.tailfield].hh.rh:=newdisc;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;end;end;
curq:=curlist.tailfield;curl:=mainj.b3;
maini:=fontinfo[charbase[mainf]+curl].qqqq;ligaturepresent:=true;end;
others:begin curl:=mainj.b3;ligaturepresent:=true;
if ligstack=0 then goto 80 else goto 91;end end;
if mainj.b2>4 then if mainj.b2<>7 then goto 80;
if curl<256 then goto 110;maink:=bcharlabel[mainf];goto 111;end{:1040};
if mainj.b0=0 then maink:=maink+1 else begin if mainj.b0>=128 then goto
80;maink:=maink+mainj.b0+1;end;goto 111{:1039};
95:{1037:}mainp:=mem[ligstack+1].hh.rh;
if mainp>0 then begin mem[curlist.tailfield].hh.rh:=mainp;
curlist.tailfield:=mem[curlist.tailfield].hh.rh;end;tempptr:=ligstack;
ligstack:=mem[tempptr].hh.rh;freenode(tempptr,2);
maini:=fontinfo[charbase[mainf]+curl].qqqq;ligaturepresent:=true;
if ligstack=0 then if mainp>0 then goto 100 else curr:=bchar else curr:=
mem[ligstack].hh.b1;goto 110{:1037}{:1034};
120:{1041:}if eqtb[2894].hh.rh=0 then begin{1042:}begin mainp:=fontglue[
eqtb[3939].hh.rh];if mainp=0 then begin mainp:=newspec(0);
maink:=parambase[eqtb[3939].hh.rh]+2;
mem[mainp+1].int:=fontinfo[maink].int;
mem[mainp+2].int:=fontinfo[maink+1].int;
mem[mainp+3].int:=fontinfo[maink+2].int;
fontglue[eqtb[3939].hh.rh]:=mainp;end;end{:1042};
tempptr:=newglue(mainp);end else tempptr:=newparamglue(12);
mem[curlist.tailfield].hh.rh:=tempptr;curlist.tailfield:=tempptr;
goto 60{:1041};10:end;{:1030}{1284:}procedure giveerrhelp;
begin tokenshow(eqtb[3421].hh.rh);end;
{:1284}{1303:}{524:}function openfmtfile:boolean;label 40,10;
var j:0..bufsize;begin j:=curinput.locfield;
if buffer[curinput.locfield]=38 then begin curinput.locfield:=curinput.
locfield+1;j:=curinput.locfield;buffer[last]:=32;
while buffer[j]<>32 do j:=j+1;packbufferedname(0,curinput.locfield,j-1);
if wopenin(fmtfile)then goto 40;
packbufferedname(11,curinput.locfield,j-1);
if wopenin(fmtfile)then goto 40;;
writeln(termout,'Sorry, I can''t find that format;',' will try PLAIN.');
break(termout);end;packbufferedname(16,1,0);
if not wopenin(fmtfile)then begin;
writeln(termout,'I can''t find the PLAIN format file!');
openfmtfile:=false;goto 10;end;40:curinput.locfield:=j;
openfmtfile:=true;10:end;{:524}function loadfmtfile:boolean;
label 6666,10;var j,k:integer;p,q:halfword;x:integer;w:fourquarters;
begin{1308:}x:=fmtfile^.int;if x<>274155489 then goto 6666;
{1386:}begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>1)then goto 6666 else eTeXmode:=x;end;
if(eTeXmode=1)then begin{1546:}maxregnum:=32767;maxreghelpline:=1408;
{:1546}end else begin{1545:}maxregnum:=255;maxreghelpline:=697;
{:1545}end;{:1386}begin get(fmtfile);x:=fmtfile^.int;end;
if x<>0 then goto 6666;begin get(fmtfile);x:=fmtfile^.int;end;
if x<>30000 then goto 6666;begin get(fmtfile);x:=fmtfile^.int;end;
if x<>6121 then goto 6666;begin get(fmtfile);x:=fmtfile^.int;end;
if x<>1777 then goto 6666;begin get(fmtfile);x:=fmtfile^.int;end;
if x<>307 then goto 6666{:1308};{1310:}begin begin get(fmtfile);
x:=fmtfile^.int;end;if x<0 then goto 6666;if x>poolsize then begin;
writeln(termout,'---! Must increase the ','string pool size');goto 6666;
end else poolptr:=x;end;begin begin get(fmtfile);x:=fmtfile^.int;end;
if x<0 then goto 6666;if x>maxstrings then begin;
writeln(termout,'---! Must increase the ','max strings');goto 6666;
end else strptr:=x;end;for k:=0 to strptr do begin begin get(fmtfile);
x:=fmtfile^.int;end;
if(x<0)or(x>poolptr)then goto 6666 else strstart[k]:=x;end;k:=0;
while k+4<poolptr do begin begin get(fmtfile);w:=fmtfile^.qqqq;end;
strpool[k]:=w.b0-0;strpool[k+1]:=w.b1-0;strpool[k+2]:=w.b2-0;
strpool[k+3]:=w.b3-0;k:=k+4;end;k:=poolptr-4;begin get(fmtfile);
w:=fmtfile^.qqqq;end;strpool[k]:=w.b0-0;strpool[k+1]:=w.b1-0;
strpool[k+2]:=w.b2-0;strpool[k+3]:=w.b3-0;initstrptr:=strptr;
initpoolptr:=poolptr{:1310};{1312:}begin begin get(fmtfile);
x:=fmtfile^.int;end;
if(x<1019)or(x>29986)then goto 6666 else lomemmax:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<20)or(x>lomemmax)then goto 6666 else rover:=x;end;
if(eTeXmode=1)then for k:=0 to 5 do begin begin get(fmtfile);
x:=fmtfile^.int;end;
if(x<0)or(x>lomemmax)then goto 6666 else saroot[k]:=x;end;p:=0;q:=rover;
repeat for k:=p to q+1 do begin get(fmtfile);mem[k]:=fmtfile^;end;
p:=q+mem[q].hh.lh;
if(p>lomemmax)or((q>=mem[q+1].hh.rh)and(mem[q+1].hh.rh<>rover))then goto
6666;q:=mem[q+1].hh.rh;until q=rover;
for k:=p to lomemmax do begin get(fmtfile);mem[k]:=fmtfile^;end;
if memmin<-2 then begin p:=mem[rover+1].hh.lh;q:=memmin+1;
mem[memmin].hh.rh:=0;mem[memmin].hh.lh:=0;mem[p+1].hh.rh:=q;
mem[rover+1].hh.lh:=q;mem[q+1].hh.rh:=rover;mem[q+1].hh.lh:=p;
mem[q].hh.rh:=65535;mem[q].hh.lh:=-0-q;end;begin begin get(fmtfile);
x:=fmtfile^.int;end;
if(x<lomemmax+1)or(x>29987)then goto 6666 else himemmin:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>30000)then goto 6666 else avail:=x;end;memend:=30000;
for k:=himemmin to memend do begin get(fmtfile);mem[k]:=fmtfile^;end;
begin get(fmtfile);varused:=fmtfile^.int;end;begin get(fmtfile);
dynused:=fmtfile^.int;end{:1312};{1314:}{1317:}k:=1;
repeat begin get(fmtfile);x:=fmtfile^.int;end;
if(x<1)or(k+x>6122)then goto 6666;
for j:=k to k+x-1 do begin get(fmtfile);eqtb[j]:=fmtfile^;end;k:=k+x;
begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(k+x>6122)then goto 6666;
for j:=k to k+x-1 do eqtb[j]:=eqtb[k-1];k:=k+x;until k>6121{:1317};
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<514)or(x>2614)then goto 6666 else parloc:=x;end;
partoken:=4095+parloc;begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<514)or(x>2614)then goto 6666 else writeloc:=x;end;
{1319:}begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<514)or(x>2614)then goto 6666 else hashused:=x;end;p:=513;
repeat begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<p+1)or(x>hashused)then goto 6666 else p:=x;end;begin get(fmtfile);
hash[p]:=fmtfile^.hh;end;until p=hashused;
for p:=hashused+1 to 2880 do begin get(fmtfile);hash[p]:=fmtfile^.hh;
end;begin get(fmtfile);cscount:=fmtfile^.int;end{:1319}{:1314};
{1321:}begin begin get(fmtfile);x:=fmtfile^.int;end;
if x<7 then goto 6666;if x>fontmemsize then begin;
writeln(termout,'---! Must increase the ','font mem size');goto 6666;
end else fmemptr:=x;end;for k:=0 to fmemptr-1 do begin get(fmtfile);
fontinfo[k]:=fmtfile^;end;begin begin get(fmtfile);x:=fmtfile^.int;end;
if x<0 then goto 6666;if x>fontmax then begin;
writeln(termout,'---! Must increase the ','font max');goto 6666;
end else fontptr:=x;end;
for k:=0 to fontptr do{1323:}begin begin get(fmtfile);
fontcheck[k]:=fmtfile^.qqqq;end;begin get(fmtfile);
fontsize[k]:=fmtfile^.int;end;begin get(fmtfile);
fontdsize[k]:=fmtfile^.int;end;begin begin get(fmtfile);x:=fmtfile^.int;
end;if(x<0)or(x>65535)then goto 6666 else fontparams[k]:=x;end;
begin get(fmtfile);hyphenchar[k]:=fmtfile^.int;end;begin get(fmtfile);
skewchar[k]:=fmtfile^.int;end;begin begin get(fmtfile);x:=fmtfile^.int;
end;if(x<0)or(x>strptr)then goto 6666 else fontname[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>strptr)then goto 6666 else fontarea[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>255)then goto 6666 else fontbc[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>255)then goto 6666 else fontec[k]:=x;end;begin get(fmtfile);
charbase[k]:=fmtfile^.int;end;begin get(fmtfile);
widthbase[k]:=fmtfile^.int;end;begin get(fmtfile);
heightbase[k]:=fmtfile^.int;end;begin get(fmtfile);
depthbase[k]:=fmtfile^.int;end;begin get(fmtfile);
italicbase[k]:=fmtfile^.int;end;begin get(fmtfile);
ligkernbase[k]:=fmtfile^.int;end;begin get(fmtfile);
kernbase[k]:=fmtfile^.int;end;begin get(fmtfile);
extenbase[k]:=fmtfile^.int;end;begin get(fmtfile);
parambase[k]:=fmtfile^.int;end;begin begin get(fmtfile);x:=fmtfile^.int;
end;if(x<0)or(x>lomemmax)then goto 6666 else fontglue[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>fmemptr-1)then goto 6666 else bcharlabel[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>256)then goto 6666 else fontbchar[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>256)then goto 6666 else fontfalsebchar[k]:=x;end;
end{:1323}{:1321};{1325:}begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>307)then goto 6666 else hyphcount:=x;end;
for k:=1 to hyphcount do begin begin begin get(fmtfile);x:=fmtfile^.int;
end;if(x<0)or(x>307)then goto 6666 else j:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>strptr)then goto 6666 else hyphword[j]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>65535)then goto 6666 else hyphlist[j]:=x;end;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;if x<0 then goto 6666;
if x>triesize then begin;
writeln(termout,'---! Must increase the ','trie size');goto 6666;
end else j:=x;end;triemax:=j;begin begin get(fmtfile);x:=fmtfile^.int;
end;if(x<0)or(x>j)then goto 6666 else hyphstart:=x;end;
for k:=0 to j do begin get(fmtfile);trie[k]:=fmtfile^.hh;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;if x<0 then goto 6666;
if x>trieopsize then begin;
writeln(termout,'---! Must increase the ','trie op size');goto 6666;
end else j:=x;end;trieopptr:=j;
for k:=1 to j do begin begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>63)then goto 6666 else hyfdistance[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>63)then goto 6666 else hyfnum[k]:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>255)then goto 6666 else hyfnext[k]:=x;end;end;
for k:=0 to 255 do trieused[k]:=0;k:=256;
while j>0 do begin begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>k-1)then goto 6666 else k:=x;end;begin begin get(fmtfile);
x:=fmtfile^.int;end;if(x<1)or(x>j)then goto 6666 else x:=x;end;
trieused[k]:=x+0;j:=j-x;opstart[k]:=j-0;end;trienotready:=false{:1325};
{1327:}begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>3)then goto 6666 else interaction:=x;end;
begin begin get(fmtfile);x:=fmtfile^.int;end;
if(x<0)or(x>strptr)then goto 6666 else formatident:=x;end;
begin get(fmtfile);x:=fmtfile^.int;end;
if(x<>69069)or eof(fmtfile)then goto 6666{:1327};loadfmtfile:=true;
goto 10;6666:;
writeln(termout,'(Fatal format file error; I''m stymied)');
loadfmtfile:=false;10:end;
{:1303}{1330:}{1333:}procedure closefilesandterminate;var k:integer;
begin{1378:}for k:=0 to 15 do if writeopen[k]then aclose(writefile[k])
{:1378};
{if eqtb[5299].int>0 then[1334:]if logopened then begin writeln(logfile,
' ');writeln(logfile,'Here is how much of TeX''s memory',' you used:');
write(logfile,' ',strptr-initstrptr:1,' string');
if strptr<>initstrptr+1 then write(logfile,'s');
writeln(logfile,' out of ',maxstrings-initstrptr:1);
writeln(logfile,' ',poolptr-initpoolptr:1,' string characters out of ',
poolsize-initpoolptr:1);
writeln(logfile,' ',lomemmax-memmin+memend-himemmin+2:1,
' words of memory out of ',memend+1-memmin:1);
writeln(logfile,' ',cscount:1,' multiletter control sequences out of ',
2100:1);
write(logfile,' ',fmemptr:1,' words of font info for ',fontptr-0:1,
' font');if fontptr<>1 then write(logfile,'s');
writeln(logfile,', out of ',fontmemsize:1,' for ',fontmax-0:1);
write(logfile,' ',hyphcount:1,' hyphenation exception');
if hyphcount<>1 then write(logfile,'s');
writeln(logfile,' out of ',307:1);
writeln(logfile,' ',maxinstack:1,'i,',maxneststack:1,'n,',maxparamstack:
1,'p,',maxbufstack+1:1,'b,',maxsavestack+6:1,'s stack positions out of '
,stacksize:1,'i,',nestsize:1,'n,',paramsize:1,'p,',bufsize:1,'b,',
savesize:1,'s');end[:1334];};
{642:}while curs>-1 do begin if curs>0 then begin dvibuf[dviptr]:=142;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;
end else begin begin dvibuf[dviptr]:=140;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;totalpages:=totalpages+1;end;
curs:=curs-1;end;
if totalpages=0 then printnl(847)else begin begin dvibuf[dviptr]:=248;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;dvifour(lastbop);
lastbop:=dvioffset+dviptr-5;dvifour(25400000);dvifour(473628672);
preparemag;dvifour(eqtb[5285].int);dvifour(maxv);dvifour(maxh);
begin dvibuf[dviptr]:=maxpush div 256;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=maxpush mod 256;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=(totalpages div 256)mod 256;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
begin dvibuf[dviptr]:=totalpages mod 256;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;
{643:}while fontptr>0 do begin if fontused[fontptr]then dvifontdef(
fontptr);fontptr:=fontptr-1;end{:643};begin dvibuf[dviptr]:=249;
dviptr:=dviptr+1;if dviptr=dvilimit then dviswap;end;dvifour(lastbop);
begin dvibuf[dviptr]:=2;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;k:=4+((dvibufsize-dviptr)mod 4);
while k>0 do begin begin dvibuf[dviptr]:=223;dviptr:=dviptr+1;
if dviptr=dvilimit then dviswap;end;k:=k-1;end;
{599:}if dvilimit=halfbuf then writedvi(halfbuf,dvibufsize-1);
if dviptr>0 then writedvi(0,dviptr-1){:599};printnl(848);
slowprint(outputfilename);print(287);printint(totalpages);print(849);
if totalpages<>1 then printchar(115);print(850);
printint(dvioffset+dviptr);print(851);bclose(dvifile);end{:642};
if logopened then begin writeln(logfile);aclose(logfile);
selector:=selector-2;if selector=17 then begin printnl(1288);
slowprint(logname);printchar(46);end;end;end;
{:1333}{1335:}procedure finalcleanup;label 10;var c:smallnumber;
begin c:=curchr;if jobname=0 then openlogfile;
while inputptr>0 do if curinput.statefield=0 then endtokenlist else
endfilereading;while openparens>0 do begin print(1289);
openparens:=openparens-1;end;if curlevel>1 then begin printnl(40);
printesc(1290);print(1291);printint(curlevel-1);printchar(41);
if(eTeXmode=1)then showsavegroups;end;
while condptr<>0 do begin printnl(40);printesc(1290);print(1292);
printcmdchr(105,curif);if ifline<>0 then begin print(1293);
printint(ifline);end;print(1294);ifline:=mem[condptr+1].int;
curif:=mem[condptr].hh.b1;tempptr:=condptr;condptr:=mem[condptr].hh.rh;
freenode(tempptr,2);end;
if history<>0 then if((history=1)or(interaction<3))then if selector=19
then begin selector:=17;printnl(1295);selector:=19;end;
if c=1 then begin for c:=0 to 4 do if curmark[c]<>0 then deletetokenref(
curmark[c]);
if saroot[6]<>0 then if domarks(3,0,saroot[6])then saroot[6]:=0;
for c:=2 to 3 do flushnodelist(discptr[c]);
if lastglue<>65535 then deleteglueref(lastglue);storefmtfile;goto 10;
printnl(1296);goto 10;end;10:end;{:1335}{1336:}procedure initprim;
begin nonewcontrolsequence:=false;first:=0;{226:}primitive(379,75,2882);
primitive(380,75,2883);primitive(381,75,2884);primitive(382,75,2885);
primitive(383,75,2886);primitive(384,75,2887);primitive(385,75,2888);
primitive(386,75,2889);primitive(387,75,2890);primitive(388,75,2891);
primitive(389,75,2892);primitive(390,75,2893);primitive(391,75,2894);
primitive(392,75,2895);primitive(393,75,2896);primitive(394,76,2897);
primitive(395,76,2898);primitive(396,76,2899);
{:226}{230:}primitive(401,72,3413);primitive(402,72,3414);
primitive(403,72,3415);primitive(404,72,3416);primitive(405,72,3417);
primitive(406,72,3418);primitive(407,72,3419);primitive(408,72,3420);
primitive(409,72,3421);{:230}{238:}primitive(423,73,5268);
primitive(424,73,5269);primitive(425,73,5270);primitive(426,73,5271);
primitive(427,73,5272);primitive(428,73,5273);primitive(429,73,5274);
primitive(430,73,5275);primitive(431,73,5276);primitive(432,73,5277);
primitive(433,73,5278);primitive(434,73,5279);primitive(435,73,5280);
primitive(436,73,5281);primitive(437,73,5282);primitive(438,73,5283);
primitive(439,73,5284);primitive(440,73,5285);primitive(441,73,5286);
primitive(442,73,5287);primitive(443,73,5288);primitive(444,73,5289);
primitive(445,73,5290);primitive(446,73,5291);primitive(447,73,5292);
primitive(448,73,5293);primitive(449,73,5294);primitive(450,73,5295);
primitive(451,73,5296);primitive(452,73,5297);primitive(453,73,5298);
primitive(454,73,5299);primitive(455,73,5300);primitive(456,73,5301);
primitive(457,73,5302);primitive(458,73,5303);primitive(459,73,5304);
primitive(460,73,5305);primitive(461,73,5306);primitive(462,73,5307);
primitive(463,73,5308);primitive(464,73,5309);primitive(465,73,5310);
primitive(466,73,5311);primitive(467,73,5312);primitive(468,73,5313);
primitive(469,73,5314);primitive(470,73,5315);primitive(471,73,5316);
primitive(472,73,5317);primitive(473,73,5318);primitive(474,73,5319);
primitive(475,73,5320);primitive(476,73,5321);primitive(477,73,5322);
{:238}{248:}primitive(481,74,5845);primitive(482,74,5846);
primitive(483,74,5847);primitive(484,74,5848);primitive(485,74,5849);
primitive(486,74,5850);primitive(487,74,5851);primitive(488,74,5852);
primitive(489,74,5853);primitive(490,74,5854);primitive(491,74,5855);
primitive(492,74,5856);primitive(493,74,5857);primitive(494,74,5858);
primitive(495,74,5859);primitive(496,74,5860);primitive(497,74,5861);
primitive(498,74,5862);primitive(499,74,5863);primitive(500,74,5864);
primitive(501,74,5865);{:248}{265:}primitive(32,64,0);
primitive(47,44,0);primitive(511,45,0);primitive(512,90,0);
primitive(513,40,0);primitive(514,41,0);primitive(515,61,0);
primitive(516,16,0);primitive(507,107,0);primitive(517,15,0);
primitive(518,92,0);primitive(508,67,0);primitive(519,62,0);
hash[2616].rh:=519;eqtb[2616]:=eqtb[curval];primitive(520,102,0);
primitive(521,88,0);primitive(522,77,0);primitive(523,32,0);
primitive(524,36,0);primitive(525,39,0);primitive(331,37,0);
primitive(354,18,0);primitive(526,46,0);primitive(527,17,0);
primitive(528,54,0);primitive(529,91,0);primitive(530,34,0);
primitive(531,65,0);primitive(532,103,0);primitive(336,55,0);
primitive(533,63,0);primitive(534,84,3412);primitive(535,42,0);
primitive(536,80,0);primitive(537,66,0);primitive(538,96,0);
primitive(539,0,256);hash[2621].rh:=539;eqtb[2621]:=eqtb[curval];
primitive(540,98,0);primitive(541,109,0);primitive(410,71,0);
primitive(355,38,0);primitive(542,33,0);primitive(543,56,0);
primitive(544,35,0);{:265}{334:}primitive(606,13,256);parloc:=curval;
partoken:=4095+parloc;{:334}{376:}primitive(638,104,0);
primitive(639,104,1);{:376}{384:}primitive(640,110,0);
primitive(641,110,1);primitive(642,110,2);primitive(643,110,3);
primitive(644,110,4);{:384}{411:}primitive(479,89,0);
primitive(503,89,1);primitive(398,89,2);primitive(399,89,3);
{:411}{416:}primitive(677,79,102);primitive(678,79,1);
primitive(679,82,0);primitive(680,82,1);primitive(681,83,1);
primitive(682,83,3);primitive(683,83,2);primitive(684,70,0);
primitive(685,70,1);primitive(686,70,2);primitive(687,70,4);
primitive(688,70,5);{:416}{468:}primitive(744,108,0);
primitive(745,108,1);primitive(746,108,2);primitive(747,108,3);
primitive(748,108,4);primitive(749,108,6);
{:468}{487:}primitive(766,105,0);primitive(767,105,1);
primitive(768,105,2);primitive(769,105,3);primitive(770,105,4);
primitive(771,105,5);primitive(772,105,6);primitive(773,105,7);
primitive(774,105,8);primitive(775,105,9);primitive(776,105,10);
primitive(777,105,11);primitive(778,105,12);primitive(779,105,13);
primitive(780,105,14);primitive(781,105,15);primitive(782,105,16);
{:487}{491:}primitive(784,106,2);hash[2618].rh:=784;
eqtb[2618]:=eqtb[curval];primitive(785,106,4);primitive(786,106,3);
{:491}{553:}primitive(811,87,0);hash[2624].rh:=811;
eqtb[2624]:=eqtb[curval];{:553}{780:}primitive(909,4,256);
primitive(910,5,257);hash[2615].rh:=910;eqtb[2615]:=eqtb[curval];
primitive(911,5,258);hash[2619].rh:=912;hash[2620].rh:=912;
eqtb[2620].hh.b0:=9;eqtb[2620].hh.rh:=29989;eqtb[2620].hh.b1:=1;
eqtb[2619]:=eqtb[2620];eqtb[2619].hh.b0:=115;
{:780}{983:}primitive(981,81,0);primitive(982,81,1);primitive(983,81,2);
primitive(984,81,3);primitive(985,81,4);primitive(986,81,5);
primitive(987,81,6);primitive(988,81,7);
{:983}{1052:}primitive(344,14,0);primitive(1036,14,1);
{:1052}{1058:}primitive(1037,26,4);primitive(1038,26,0);
primitive(1039,26,1);primitive(1040,26,2);primitive(1041,26,3);
primitive(1042,27,4);primitive(1043,27,0);primitive(1044,27,1);
primitive(1045,27,2);primitive(1046,27,3);primitive(337,28,5);
primitive(341,29,1);primitive(343,30,99);
{:1058}{1071:}primitive(1064,21,1);primitive(1065,21,0);
primitive(1066,22,1);primitive(1067,22,0);primitive(412,20,0);
primitive(1068,20,1);primitive(1069,20,2);primitive(976,20,3);
primitive(1070,20,4);primitive(978,20,5);primitive(1071,20,106);
primitive(1072,31,99);primitive(1073,31,100);primitive(1074,31,101);
primitive(1075,31,102);{:1071}{1088:}primitive(1091,43,1);
primitive(1092,43,0);{:1088}{1107:}primitive(1101,25,12);
primitive(1102,25,11);primitive(1103,25,10);primitive(1104,23,0);
primitive(1105,23,1);primitive(1106,24,0);primitive(1107,24,1);
{:1107}{1114:}primitive(45,47,1);primitive(352,47,0);
{:1114}{1141:}primitive(1138,48,0);primitive(1139,48,1);
{:1141}{1156:}primitive(876,50,16);primitive(877,50,17);
primitive(878,50,18);primitive(879,50,19);primitive(880,50,20);
primitive(881,50,21);primitive(882,50,22);primitive(883,50,23);
primitive(885,50,26);primitive(884,50,27);primitive(1140,51,0);
primitive(889,51,1);primitive(890,51,2);
{:1156}{1169:}primitive(871,53,0);primitive(872,53,2);
primitive(873,53,4);primitive(874,53,6);
{:1169}{1178:}primitive(1158,52,0);primitive(1159,52,1);
primitive(1160,52,2);primitive(1161,52,3);primitive(1162,52,4);
primitive(1163,52,5);{:1178}{1188:}primitive(886,49,30);
primitive(887,49,31);hash[2617].rh:=887;eqtb[2617]:=eqtb[curval];
{:1188}{1208:}primitive(1183,93,1);primitive(1184,93,2);
primitive(1185,93,4);primitive(1186,97,0);primitive(1187,97,1);
primitive(1188,97,2);primitive(1189,97,3);
{:1208}{1219:}primitive(1206,94,0);primitive(1207,94,1);
{:1219}{1222:}primitive(1208,95,0);primitive(1209,95,1);
primitive(1210,95,2);primitive(1211,95,3);primitive(1212,95,4);
primitive(1213,95,5);primitive(1214,95,6);
{:1222}{1230:}primitive(418,85,3988);primitive(422,85,5012);
primitive(419,85,4244);primitive(420,85,4500);primitive(421,85,4756);
primitive(480,85,5589);primitive(415,86,3940);primitive(416,86,3956);
primitive(417,86,3972);{:1230}{1250:}primitive(952,99,0);
primitive(964,99,1);{:1250}{1254:}primitive(1232,78,0);
primitive(1233,78,1);{:1254}{1262:}primitive(275,100,0);
primitive(276,100,1);primitive(277,100,2);primitive(1242,100,3);
{:1262}{1272:}primitive(1243,60,1);primitive(1244,60,0);
{:1272}{1277:}primitive(1245,58,0);primitive(1246,58,1);
{:1277}{1286:}primitive(1252,57,4244);primitive(1253,57,4500);
{:1286}{1291:}primitive(1254,19,0);primitive(1255,19,1);
primitive(1256,19,2);primitive(1257,19,3);
{:1291}{1344:}primitive(1298,59,0);primitive(603,59,1);writeloc:=curval;
primitive(1299,59,2);primitive(1300,59,3);primitive(1301,59,4);
primitive(1302,59,5);{:1344};nonewcontrolsequence:=true;end;
{:1336}{1338:}{procedure debughelp;label 888,10;var k,l,m,n:integer;
begin while true do begin;printnl(1297);break(termout);read(termin,m);
if m<0 then goto 10 else if m=0 then begin goto 888;
888:m:=0;
['BREAKPOINT']
end else begin read(termin,n);case m of[1339:]1:printword(mem[n]);
2:printint(mem[n].hh.lh);3:printint(mem[n].hh.rh);4:printword(eqtb[n]);
5:printword(fontinfo[n]);6:printword(savestack[n]);7:showbox(n);
8:begin breadthmax:=10000;depththreshold:=poolsize-poolptr-10;
shownodelist(n);end;9:showtokenlist(n,0,1000);10:slowprint(n);
11:checkmem(n>0);12:searchmem(n);13:begin read(termin,l);
printcmdchr(n,l);end;14:for k:=0 to n do print(buffer[k]);
15:begin fontinshortdisplay:=0;shortdisplay(n);end;
16:panicking:=not panicking;[:1339]others:print(63)end;end;end;10:end;}
{:1338}{:1330}{1332:}begin history:=3;rewrite(termout,'TTY:','/O');
if readyalready=314159 then goto 1;{14:}bad:=0;
if(halferrorline<30)or(halferrorline>errorline-15)then bad:=1;
if maxprintline<60 then bad:=2;if dvibufsize mod 8<>0 then bad:=3;
if 1100>30000 then bad:=4;if 1777>2100 then bad:=5;
if maxinopen>=128 then bad:=6;if 30000<267 then bad:=7;
{:14}{111:}if(memmin<>0)or(memmax<>30000)then bad:=10;
if(memmin>0)or(memmax<30000)then bad:=10;if(0>0)or(255<127)then bad:=11;
if(0>0)or(65535<32767)then bad:=12;if(0<0)or(255>65535)then bad:=13;
if(memmin<0)or(memmax>=65535)or(-0-memmin>65536)then bad:=14;
if(0<0)or(fontmax>255)then bad:=15;if fontmax>256 then bad:=16;
if(savesize>65535)or(maxstrings>65535)then bad:=17;
if bufsize>65535 then bad:=18;if 255<255 then bad:=19;
{:111}{290:}if 6976>65535 then bad:=21;
{:290}{522:}if 20>filenamesize then bad:=31;
{:522}{1249:}if 2*65535<30000-memmin then bad:=41;
{:1249}if bad>0 then begin writeln(termout,
'Ouch---my internal constants have been clobbered!','---case ',bad:1);
goto 9999;end;initialize;if not getstringsstarted then goto 9999;
initprim;initstrptr:=strptr;initpoolptr:=poolptr;fixdateandtime;
readyalready:=314159;1:{55:}selector:=17;tally:=0;termoffset:=0;
fileoffset:=0;
{:55}{61:}write(termout,'This is e-TeX, Version 3.1415926','-2.2');
if formatident=0 then writeln(termout,' (no format preloaded)')else
begin slowprint(formatident);println;end;break(termout);
{:61}{528:}jobname:=0;nameinprogress:=false;logopened:=false;
{:528}{533:}outputfilename:=0;{:533};
{1337:}begin{331:}begin inputptr:=0;maxinstack:=0;inopen:=0;
openparens:=0;maxbufstack:=0;grpstack[0]:=0;ifstack[0]:=0;paramptr:=0;
maxparamstack:=0;first:=bufsize;repeat buffer[first]:=0;first:=first-1;
until first=0;scannerstatus:=0;warningindex:=0;first:=1;
curinput.statefield:=33;curinput.startfield:=1;curinput.indexfield:=0;
line:=0;curinput.namefield:=0;forceeof:=false;alignstate:=1000000;
if not initterminal then goto 9999;curinput.limitfield:=last;
first:=last+1;end{:331};
{1379:}if(buffer[curinput.locfield]=42)and(formatident=1270)then begin
nonewcontrolsequence:=false;{1380:}primitive(1314,70,3);
primitive(1315,70,6);primitive(750,108,5);
{:1380}{1388:}primitive(1317,72,3422);primitive(1318,73,5323);
primitive(1319,73,5324);primitive(1320,73,5325);primitive(1321,73,5326);
primitive(1322,73,5327);primitive(1323,73,5328);primitive(1324,73,5329);
primitive(1325,73,5330);primitive(1326,73,5331);
{:1388}{1394:}primitive(1340,70,7);primitive(1341,70,8);
{:1394}{1397:}primitive(1342,70,9);primitive(1343,70,10);
primitive(1344,70,11);{:1397}{1400:}primitive(1345,70,14);
primitive(1346,70,15);primitive(1347,70,16);primitive(1348,70,17);
{:1400}{1403:}primitive(1349,70,18);primitive(1350,70,19);
primitive(1351,70,20);{:1403}{1406:}primitive(1352,19,4);
{:1406}{1415:}primitive(1354,19,5);{:1415}{1417:}primitive(1355,109,1);
primitive(1356,109,5);{:1417}{1420:}primitive(1357,19,6);
{:1420}{1423:}primitive(1361,82,2);{:1423}{1428:}primitive(888,49,1);
{:1428}{1432:}primitive(1365,73,5332);primitive(1366,33,6);
primitive(1367,33,7);primitive(1368,33,10);primitive(1369,33,11);
{:1432}{1480:}primitive(1378,104,2);{:1480}{1492:}primitive(1380,96,1);
{:1492}{1495:}primitive(783,102,1);primitive(1381,105,17);
primitive(1382,105,18);primitive(1383,105,19);
{:1495}{1503:}primitive(1197,93,8);{:1503}{1511:}primitive(1389,70,25);
primitive(1390,70,26);primitive(1391,70,27);primitive(1392,70,28);
{:1511}{1534:}primitive(1396,70,12);primitive(1397,70,13);
primitive(1398,70,21);primitive(1399,70,22);
{:1534}{1538:}primitive(1400,70,23);primitive(1401,70,24);
{:1538}{1542:}primitive(1402,18,5);primitive(1403,110,5);
primitive(1404,110,6);primitive(1405,110,7);primitive(1406,110,8);
primitive(1407,110,9);{:1542}{1594:}primitive(1411,24,2);
primitive(1412,24,3);{:1594}{1597:}primitive(1413,84,3679);
primitive(1414,84,3680);primitive(1415,84,3681);primitive(1416,84,3682);
{:1597}curinput.locfield:=curinput.locfield+1;eTeXmode:=1;
{1546:}maxregnum:=32767;maxreghelpline:=1408;{:1546}end;
if not nonewcontrolsequence then nonewcontrolsequence:=true else{:1379}
if(formatident=0)or(buffer[curinput.locfield]=38)then begin if
formatident<>0 then initialize;if not openfmtfile then goto 9999;
if not loadfmtfile then begin wclose(fmtfile);goto 9999;end;
wclose(fmtfile);
while(curinput.locfield<curinput.limitfield)and(buffer[curinput.locfield
]=32)do curinput.locfield:=curinput.locfield+1;end;
if(eTeXmode=1)then writeln(termout,'entering extended mode');
if(eqtb[5316].int<0)or(eqtb[5316].int>255)then curinput.limitfield:=
curinput.limitfield-1 else buffer[curinput.limitfield]:=eqtb[5316].int;
fixdateandtime;{765:}magicoffset:=strstart[903]-9*16{:765};
{75:}if interaction=0 then selector:=16 else selector:=17{:75};
if(curinput.locfield<curinput.limitfield)and(eqtb[3988+buffer[curinput.
locfield]].hh.rh<>0)then startinput;end{:1337};history:=0;maincontrol;
finalcleanup;9998:closefilesandterminate;9999:readyalready:=0;
end.{:1332}
