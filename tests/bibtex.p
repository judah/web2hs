{10:}{11:}{$C-,A+,D-}{[$C+,D+]}{:11}program BibTEX;
label 9998,9999{109:},31{:109}{146:},32,9932{:146};
const{14:}bufsize=1000;minprintline=3;maxprintline=79;auxstacksize=20;
maxbibfiles=20;poolsize=65000;maxstrings=4000;maxcites=750;
mincrossrefs=2;wizfnspace=3000;singlefnspace=100;maxentints=3000;
maxentstrs=3000;entstrsize=100;globstrsize=1000;maxfields=17250;
litstksize=100;{:14}{333:}numbltinfns=37;
{:333}type{22:}ASCIIcode=0..127;{:22}{31:}lextype=0..5;idtype=0..1;
{:31}{36:}alphafile=packed file of char;{:36}{42:}bufpointer=0..bufsize;
buftype=array[bufpointer]of ASCIIcode;{:42}{49:}poolpointer=0..poolsize;
strnumber=0..maxstrings;{:49}{64:}hashloc=1..5000;hashpointer=0..5000;
strilk=0..14;{:64}{73:}pdsloc=1..12;pdslen=0..12;
pdstype=packed array[pdsloc]of char;
{:73}{105:}auxnumber=0..auxstacksize;
{:105}{118:}bibnumber=0..maxbibfiles;{:118}{130:}citenumber=0..maxcites;
{:130}{160:}fnclass=0..8;wizfnloc=0..wizfnspace;intentloc=0..maxentints;
strentloc=0..maxentstrs;strglobloc=0..9;fieldloc=0..maxfields;
hashptr2=0..5001;{:160}{291:}litstkloc=0..litstksize;stktype=0..4;
{:291}{332:}bltinrange=0..numbltinfns;{:332}var{16:}bad:integer;
{:16}{19:}history:0..3;errcount:integer;
{:19}{24:}xord:array[char]of ASCIIcode;xchr:array[ASCIIcode]of char;
{:24}{30:}lexclass:array[ASCIIcode]of lextype;
idclass:array[ASCIIcode]of idtype;
{:30}{34:}charwidth:array[ASCIIcode]of integer;stringwidth:integer;
{:34}{37:}nameoffile:packed array[1..40]of char;namelength:0..40;
nameptr:0..41;{:37}{41:}buffer:buftype;last:bufpointer;
{:41}{43:}svbuffer:buftype;svptr1:bufpointer;svptr2:bufpointer;
tmpptr,tmpendptr:integer;
{:43}{48:}strpool:packed array[poolpointer]of ASCIIcode;
strstart:packed array[strnumber]of poolpointer;poolptr:poolpointer;
strptr:strnumber;strnum:strnumber;pptr1,pptr2:poolpointer;
{:48}{65:}hashnext:packed array[hashloc]of hashpointer;
hashtext:packed array[hashloc]of strnumber;
hashilk:packed array[hashloc]of strilk;
ilkinfo:packed array[hashloc]of integer;hashused:1..5001;
hashfound:boolean;dummyloc:hashloc;{:65}{74:}sauxextension:strnumber;
slogextension:strnumber;sbblextension:strnumber;sbstextension:strnumber;
sbibextension:strnumber;sbstarea:strnumber;sbibarea:strnumber;
{:74}{76:}predefloc:hashloc;{:76}{78:}commandnum:integer;
{:78}{80:}bufptr1:bufpointer;bufptr2:bufpointer;
{:80}{89:}scanresult:0..3;{:89}{91:}tokenvalue:integer;
{:91}{97:}auxnamelength:0..41;
{:97}{104:}auxfile:array[auxnumber]of alphafile;
auxlist:array[auxnumber]of strnumber;auxptr:auxnumber;
auxlnstack:array[auxnumber]of integer;toplevstr:strnumber;
logfile:alphafile;bblfile:alphafile;
{:104}{117:}biblist:array[bibnumber]of strnumber;bibptr:bibnumber;
numbibfiles:bibnumber;bibseen:boolean;
bibfile:array[bibnumber]of alphafile;{:117}{124:}bstseen:boolean;
bststr:strnumber;bstfile:alphafile;
{:124}{129:}citelist:packed array[citenumber]of strnumber;
citeptr:citenumber;entryciteptr:citenumber;numcites:citenumber;
oldnumcites:citenumber;citationseen:boolean;citeloc:hashloc;
lcciteloc:hashloc;lcxciteloc:hashloc;citefound:boolean;
allentries:boolean;allmarker:citenumber;{:129}{147:}bbllinenum:integer;
bstlinenum:integer;{:147}{161:}fnloc:hashloc;wizloc:hashloc;
literalloc:hashloc;macronameloc:hashloc;macrodefloc:hashloc;
fntype:packed array[hashloc]of fnclass;wizdefptr:wizfnloc;
wizfnptr:wizfnloc;wizfunctions:packed array[wizfnloc]of hashptr2;
intentptr:intentloc;entryints:array[intentloc]of integer;
numentints:intentloc;strentptr:strentloc;
entrystrs:array[strentloc]of packed array[0..entstrsize]of ASCIIcode;
numentstrs:strentloc;strglbptr:0..10;
glbstrptr:array[strglobloc]of strnumber;
globalstrs:array[strglobloc]of array[0..globstrsize]of ASCIIcode;
glbstrend:array[strglobloc]of 0..globstrsize;numglbstrs:0..10;
fieldptr:fieldloc;fieldparentptr,fieldendptr:fieldloc;
citeparentptr,citexptr:citenumber;
fieldinfo:packed array[fieldloc]of strnumber;numfields:fieldloc;
numpredefinedfields:fieldloc;crossrefnum:fieldloc;nofields:boolean;
{:161}{163:}entryseen:boolean;readseen:boolean;readperformed:boolean;
readingcompleted:boolean;readcompleted:boolean;
{:163}{195:}implfnnum:integer;{:195}{219:}biblinenum:integer;
entrytypeloc:hashloc;typelist:packed array[citenumber]of hashptr2;
typeexists:boolean;entryexists:packed array[citenumber]of boolean;
storeentry:boolean;fieldnameloc:hashloc;fieldvalloc:hashloc;
storefield:boolean;storetoken:boolean;rightouterdelim:ASCIIcode;
rightstrdelim:ASCIIcode;atbibcommand:boolean;curmacroloc:hashloc;
citeinfo:packed array[citenumber]of strnumber;citehashfound:boolean;
preambleptr:bibnumber;numpreamblestrings:bibnumber;
{:219}{247:}bibbracelevel:integer;
{:247}{290:}litstack:array[litstkloc]of integer;
litstktype:array[litstkloc]of stktype;litstkptr:litstkloc;
cmdstrptr:strnumber;entchrptr:0..entstrsize;globchrptr:0..globstrsize;
exbuf:buftype;exbufptr:bufpointer;exbuflength:bufpointer;outbuf:buftype;
outbufptr:bufpointer;outbuflength:bufpointer;messwithentries:boolean;
sortciteptr:citenumber;sortkeynum:strentloc;bracelevel:integer;
{:290}{331:}bequals:hashloc;bgreaterthan:hashloc;blessthan:hashloc;
bplus:hashloc;bminus:hashloc;bconcatenate:hashloc;bgets:hashloc;
baddperiod:hashloc;bcalltype:hashloc;bchangecase:hashloc;
bchrtoint:hashloc;bcite:hashloc;bduplicate:hashloc;bempty:hashloc;
bformatname:hashloc;bif:hashloc;binttochr:hashloc;binttostr:hashloc;
bmissing:hashloc;bnewline:hashloc;bnumnames:hashloc;bpop:hashloc;
bpreamble:hashloc;bpurify:hashloc;bquote:hashloc;bskip:hashloc;
bstack:hashloc;bsubstring:hashloc;bswap:hashloc;btextlength:hashloc;
btextprefix:hashloc;btopstack:hashloc;btype:hashloc;bwarning:hashloc;
bwhile:hashloc;bwidth:hashloc;bwrite:hashloc;bdefault:hashloc;
{bltinloc:array[bltinrange]of hashloc;
executioncount:array[bltinrange]of integer;totalexcount:integer;
bltinptr:bltinrange;}{:331}{337:}snull:strnumber;sdefault:strnumber;
st:strnumber;sl:strnumber;su:strnumber;
spreamble:array[bibnumber]of strnumber;
{:337}{344:}poplit1,poplit2,poplit3:integer;
poptyp1,poptyp2,poptyp3:stktype;spptr:poolpointer;
spxptr1,spxptr2:poolpointer;spend:poolpointer;
splength,sp2length:poolpointer;spbracelevel:integer;
exbufxptr,exbufyptr:bufpointer;controlseqloc:hashloc;
precedingwhite:boolean;andfound:boolean;numnames:integer;
namebfptr:bufpointer;namebfxptr,namebfyptr:bufpointer;
nmbracelevel:integer;nametok:packed array[bufpointer]of bufpointer;
namesepchar:packed array[bufpointer]of ASCIIcode;numtokens:bufpointer;
tokenstarting:boolean;alphafound:boolean;
doubleletter,endofgroup,tobewritten:boolean;firststart:bufpointer;
firstend:bufpointer;lastend:bufpointer;vonstart:bufpointer;
vonend:bufpointer;jrend:bufpointer;curtoken,lasttoken:bufpointer;
usedefault:boolean;numcommas:bufpointer;comma1,comma2:bufpointer;
numtextchars:bufpointer;{:344}{365:}conversiontype:0..3;
prevcolon:boolean;{:365}{12:}{3:}procedure printanewline;
begin writeln(logfile);writeln(tty);end;{:3}{18:}procedure markwarning;
begin if(history=1)then errcount:=errcount+1 else if(history=0)then
begin history:=1;errcount:=1;end;end;procedure markerror;
begin if(history<2)then begin history:=2;errcount:=1;
end else errcount:=errcount+1;end;procedure markfatal;begin history:=3;
end;{:18}{44:}procedure printoverflow;
begin begin write(logfile,'Sorry---you''ve exceeded BibTeX''s ');
write(tty,'Sorry---you''ve exceeded BibTeX''s ');end;markfatal;end;
{:44}{45:}procedure printconfusion;
begin begin writeln(logfile,'---this can''t happen');
writeln(tty,'---this can''t happen');end;
begin writeln(logfile,'*Please notify the BibTeX maintainer*');
writeln(tty,'*Please notify the BibTeX maintainer*');end;markfatal;end;
{:45}{46:}procedure bufferoverflow;begin begin printoverflow;
begin writeln(logfile,'buffer size ',bufsize:0);
writeln(tty,'buffer size ',bufsize:0);end;goto 9998;end;end;
{:46}{47:}function inputln(var f:alphafile):boolean;label 15;
begin last:=0;
if(eof(f))then inputln:=false else begin while(not eoln(f))do begin if(
last>=bufsize)then bufferoverflow;buffer[last]:=xord[f^];get(f);
last:=last+1;end;get(f);
while(last>0)do if(lexclass[buffer[last-1]]=1)then last:=last-1 else
goto 15;15:inputln:=true;end;end;
{:47}{51:}procedure outpoolstr(var f:alphafile;s:strnumber);
var i:poolpointer;
begin if((s<0)or(s>=strptr+3)or(s>=maxstrings))then begin begin write(
logfile,'Illegal string number:',s:0);
write(tty,'Illegal string number:',s:0);end;printconfusion;goto 9998;
end;for i:=strstart[s]to strstart[s+1]-1 do write(f,xchr[strpool[i]]);
end;procedure printapoolstr(s:strnumber);begin outpoolstr(tty,s);
outpoolstr(logfile,s);end;{:51}{53:}procedure pooloverflow;
begin begin printoverflow;
begin writeln(logfile,'pool size ',poolsize:0);
writeln(tty,'pool size ',poolsize:0);end;goto 9998;end;end;
{:53}{59:}procedure filenmsizeoverflow;begin begin printoverflow;
begin writeln(logfile,'file name size ',40:0);
writeln(tty,'file name size ',40:0);end;goto 9998;end;end;
{:59}{82:}procedure outtoken(var f:alphafile);var i:bufpointer;
begin i:=bufptr1;while(i<bufptr2)do begin write(f,xchr[buffer[i]]);
i:=i+1;end;end;procedure printatoken;begin outtoken(tty);
outtoken(logfile);end;{:82}{95:}procedure printbadinputline;
var bfptr:bufpointer;begin begin write(logfile,' : ');write(tty,' : ');
end;bfptr:=0;
while(bfptr<bufptr2)do begin if(lexclass[buffer[bfptr]]=1)then begin
write(logfile,xchr[32]);write(tty,xchr[32]);
end else begin write(logfile,xchr[buffer[bfptr]]);
write(tty,xchr[buffer[bfptr]]);end;bfptr:=bfptr+1;end;printanewline;
begin write(logfile,' : ');write(tty,' : ');end;bfptr:=0;
while(bfptr<bufptr2)do begin begin write(logfile,xchr[32]);
write(tty,xchr[32]);end;bfptr:=bfptr+1;end;bfptr:=bufptr2;
while(bfptr<last)do begin if(lexclass[buffer[bfptr]]=1)then begin write(
logfile,xchr[32]);write(tty,xchr[32]);
end else begin write(logfile,xchr[buffer[bfptr]]);
write(tty,xchr[buffer[bfptr]]);end;bfptr:=bfptr+1;end;printanewline;
bfptr:=0;
while((bfptr<bufptr2)and(lexclass[buffer[bfptr]]=1))do bfptr:=bfptr+1;
if(bfptr=bufptr2)then begin writeln(logfile,
'(Error may have been on previous line)');
writeln(tty,'(Error may have been on previous line)');end;markerror;end;
{:95}{96:}procedure printskippingwhateverremains;
begin begin write(logfile,'I''m skipping whatever remains of this ');
write(tty,'I''m skipping whatever remains of this ');end;end;
{:96}{98:}procedure samtoolongfilenameprint;
begin write(tty,'File name `');nameptr:=1;
while(nameptr<=auxnamelength)do begin write(tty,nameoffile[nameptr]);
nameptr:=nameptr+1;end;writeln(tty,''' is too long');end;
{:98}{99:}procedure samwrongfilenameprint;
begin write(tty,'I couldn''t open file name `');nameptr:=1;
while(nameptr<=namelength)do begin write(tty,nameoffile[nameptr]);
nameptr:=nameptr+1;end;writeln(tty,'''');end;
{:99}{108:}procedure printauxname;begin printapoolstr(auxlist[auxptr]);
printanewline;end;{:108}{111:}procedure auxerrprint;
begin begin write(logfile,'---line ',auxlnstack[auxptr]:0,' of file ');
write(tty,'---line ',auxlnstack[auxptr]:0,' of file ');end;printauxname;
printbadinputline;printskippingwhateverremains;
begin writeln(logfile,'command');writeln(tty,'command');end end;
{:111}{112:}procedure auxerrillegalanotherprint(cmdnum:integer);
begin begin write(logfile,'Illegal, another \bib');
write(tty,'Illegal, another \bib');end;
case(cmdnum)of 0:begin write(logfile,'data');write(tty,'data');end;
1:begin write(logfile,'style');write(tty,'style');end;
others:begin begin write(logfile,'Illegal auxiliary-file command');
write(tty,'Illegal auxiliary-file command');end;printconfusion;
goto 9998;end end;begin write(logfile,' command');write(tty,' command');
end;end;{:112}{113:}procedure auxerrnorightbraceprint;
begin begin write(logfile,'No "',xchr[125],'"');
write(tty,'No "',xchr[125],'"');end;end;
{:113}{114:}procedure auxerrstuffafterrightbraceprint;
begin begin write(logfile,'Stuff after "',xchr[125],'"');
write(tty,'Stuff after "',xchr[125],'"');end;end;
{:114}{115:}procedure auxerrwhitespaceinargumentprint;
begin begin write(logfile,'White space in argument');
write(tty,'White space in argument');end;end;
{:115}{121:}procedure printbibname;begin printapoolstr(biblist[bibptr]);
printapoolstr(sbibextension);printanewline;end;
{:121}{128:}procedure printbstname;begin printapoolstr(bststr);
printapoolstr(sbstextension);printanewline;end;
{:128}{137:}procedure hashciteconfusion;
begin begin begin write(logfile,'Cite hash error');
write(tty,'Cite hash error');end;printconfusion;goto 9998;end;end;
{:137}{138:}procedure checkciteoverflow(lastcite:citenumber);
begin if(lastcite=maxcites)then begin printapoolstr(hashtext[citeloc]);
begin writeln(logfile,' is the key:');writeln(tty,' is the key:');end;
begin printoverflow;
begin writeln(logfile,'number of cite keys ',maxcites:0);
writeln(tty,'number of cite keys ',maxcites:0);end;goto 9998;end;end;
end;{:138}{144:}procedure auxend1errprint;
begin begin write(logfile,'I found no ');write(tty,'I found no ');end;
end;procedure auxend2errprint;
begin begin write(logfile,'---while reading file ');
write(tty,'---while reading file ');end;printauxname;markerror;end;
{:144}{148:}procedure bstlnnumprint;
begin begin write(logfile,'--line ',bstlinenum:0,' of file ');
write(tty,'--line ',bstlinenum:0,' of file ');end;printbstname;end;
{:148}{149:}procedure bsterrprintandlookforblankline;
begin begin write(logfile,'-');write(tty,'-');end;bstlnnumprint;
printbadinputline;
while(last<>0)do if(not inputln(bstfile))then goto 32 else bstlinenum:=
bstlinenum+1;bufptr2:=last;end;{:149}{150:}procedure bstwarnprint;
begin bstlnnumprint;markwarning;end;{:150}{153:}procedure eatbstprint;
begin begin write(logfile,'Illegal end of style file in command: ');
write(tty,'Illegal end of style file in command: ');end;end;
{:153}{157:}procedure unknwnfunctionclassconfusion;
begin begin begin write(logfile,'Unknown function class');
write(tty,'Unknown function class');end;printconfusion;goto 9998;end;
end;{:157}{158:}procedure printfnclass(fnloc:hashloc);
begin case(fntype[fnloc])of 0:begin write(logfile,'built-in');
write(tty,'built-in');end;1:begin write(logfile,'wizard-defined');
write(tty,'wizard-defined');end;
2:begin write(logfile,'integer-literal');write(tty,'integer-literal');
end;3:begin write(logfile,'string-literal');write(tty,'string-literal');
end;4:begin write(logfile,'field');write(tty,'field');end;
5:begin write(logfile,'integer-entry-variable');
write(tty,'integer-entry-variable');end;
6:begin write(logfile,'string-entry-variable');
write(tty,'string-entry-variable');end;
7:begin write(logfile,'integer-global-variable');
write(tty,'integer-global-variable');end;
8:begin write(logfile,'string-global-variable');
write(tty,'string-global-variable');end;
others:unknwnfunctionclassconfusion end;end;
{:158}{159:}{procedure traceprfnclass(fnloc:hashloc);
begin case(fntype[fnloc])of 0:begin write(logfile,'built-in');end;
1:begin write(logfile,'wizard-defined');end;
2:begin write(logfile,'integer-literal');end;
3:begin write(logfile,'string-literal');end;
4:begin write(logfile,'field');end;
5:begin write(logfile,'integer-entry-variable');end;
6:begin write(logfile,'string-entry-variable');end;
7:begin write(logfile,'integer-global-variable');end;
8:begin write(logfile,'string-global-variable');end;
others:unknwnfunctionclassconfusion end;end;}
{:159}{165:}procedure idscanningconfusion;
begin begin begin write(logfile,'Identifier scanning error');
write(tty,'Identifier scanning error');end;printconfusion;goto 9998;end;
end;{:165}{166:}procedure bstidprint;
begin if(scanresult=0)then begin write(logfile,'"',xchr[buffer[bufptr2]]
,'" begins identifier, command: ');
write(tty,'"',xchr[buffer[bufptr2]],'" begins identifier, command: ');
end else if(scanresult=2)then begin write(logfile,'"',xchr[buffer[
bufptr2]],'" immediately follows identifier, command: ');
write(tty,'"',xchr[buffer[bufptr2]],
'" immediately follows identifier, command: ');
end else idscanningconfusion;end;
{:166}{167:}procedure bstleftbraceprint;
begin begin write(logfile,'"',xchr[123],'" is missing in command: ');
write(tty,'"',xchr[123],'" is missing in command: ');end;end;
{:167}{168:}procedure bstrightbraceprint;
begin begin write(logfile,'"',xchr[125],'" is missing in command: ');
write(tty,'"',xchr[125],'" is missing in command: ');end;end;
{:168}{169:}procedure alreadyseenfunctionprint(seenfnloc:hashloc);
label 10;begin printapoolstr(hashtext[seenfnloc]);
begin write(logfile,' is already a type "');
write(tty,' is already a type "');end;printfnclass(seenfnloc);
begin writeln(logfile,'" function name');writeln(tty,'" function name');
end;begin bsterrprintandlookforblankline;goto 10;end;10:end;
{:169}{188:}procedure singlfnoverflow;begin begin printoverflow;
begin writeln(logfile,'single function space ',singlefnspace:0);
writeln(tty,'single function space ',singlefnspace:0);end;goto 9998;end;
end;{:188}{220:}procedure biblnnumprint;
begin begin write(logfile,'--line ',biblinenum:0,' of file ');
write(tty,'--line ',biblinenum:0,' of file ');end;printbibname;end;
{:220}{221:}procedure biberrprint;begin begin write(logfile,'-');
write(tty,'-');end;biblnnumprint;printbadinputline;
printskippingwhateverremains;
if(atbibcommand)then begin writeln(logfile,'command');
writeln(tty,'command');end else begin writeln(logfile,'entry');
writeln(tty,'entry');end;end;{:221}{222:}procedure bibwarnprint;
begin biblnnumprint;markwarning;end;
{:222}{226:}procedure checkfieldoverflow(totalfields:integer);
begin if(totalfields>maxfields)then begin begin writeln(logfile,
totalfields:0,' fields:');writeln(tty,totalfields:0,' fields:');end;
begin printoverflow;
begin writeln(logfile,'total number of fields ',maxfields:0);
writeln(tty,'total number of fields ',maxfields:0);end;goto 9998;end;
end;end;{:226}{229:}procedure eatbibprint;label 10;
begin begin begin write(logfile,'Illegal end of database file');
write(tty,'Illegal end of database file');end;biberrprint;goto 10;end;
10:end;{:229}{230:}procedure biboneoftwoprint(char1,char2:ASCIIcode);
label 10;
begin begin begin write(logfile,'I was expecting a `',xchr[char1],
''' or a `',xchr[char2],'''');
write(tty,'I was expecting a `',xchr[char1],''' or a `',xchr[char2],''''
);end;biberrprint;goto 10;end;10:end;
{:230}{231:}procedure bibequalssignprint;label 10;
begin begin begin write(logfile,'I was expecting an "',xchr[61],'"');
write(tty,'I was expecting an "',xchr[61],'"');end;biberrprint;goto 10;
end;10:end;{:231}{232:}procedure bibunbalancedbracesprint;label 10;
begin begin begin write(logfile,'Unbalanced braces');
write(tty,'Unbalanced braces');end;biberrprint;goto 10;end;10:end;
{:232}{233:}procedure bibfieldtoolongprint;label 10;
begin begin begin write(logfile,'Your field is more than ',bufsize:0,
' characters');
write(tty,'Your field is more than ',bufsize:0,' characters');end;
biberrprint;goto 10;end;10:end;{:233}{234:}procedure macrowarnprint;
begin begin write(logfile,'Warning--string name "');
write(tty,'Warning--string name "');end;printatoken;
begin write(logfile,'" is ');write(tty,'" is ');end;end;
{:234}{235:}procedure bibidprint;
begin if(scanresult=0)then begin write(logfile,'You''re missing ');
write(tty,'You''re missing ');
end else if(scanresult=2)then begin write(logfile,'"',xchr[buffer[
bufptr2]],'" immediately follows ');
write(tty,'"',xchr[buffer[bufptr2]],'" immediately follows ');
end else idscanningconfusion;end;{:235}{240:}procedure bibcmdconfusion;
begin begin begin write(logfile,'Unknown database-file command');
write(tty,'Unknown database-file command');end;printconfusion;goto 9998;
end;end;{:240}{271:}procedure citekeydisappearedconfusion;
begin begin begin write(logfile,'A cite key disappeared');
write(tty,'A cite key disappeared');end;printconfusion;goto 9998;end;
end;{:271}{280:}procedure badcrossreferenceprint(s:strnumber);
begin begin write(logfile,'--entry "');write(tty,'--entry "');end;
printapoolstr(citelist[citeptr]);begin writeln(logfile,'"');
writeln(tty,'"');end;begin write(logfile,'refers to entry "');
write(tty,'refers to entry "');end;printapoolstr(s);end;
{:280}{281:}procedure nonexistentcrossreferenceerror;
begin begin write(logfile,'A bad cross reference-');
write(tty,'A bad cross reference-');end;
badcrossreferenceprint(fieldinfo[fieldptr]);
begin writeln(logfile,'", which doesn''t exist');
writeln(tty,'", which doesn''t exist');end;markerror;end;
{:281}{284:}procedure printmissingentry(s:strnumber);
begin begin write(logfile,
'Warning--I didn''t find a database entry for "');
write(tty,'Warning--I didn''t find a database entry for "');end;
printapoolstr(s);begin writeln(logfile,'"');writeln(tty,'"');end;
markwarning;end;{:284}{293:}procedure bstexwarnprint;
begin if(messwithentries)then begin begin write(logfile,' for entry ');
write(tty,' for entry ');end;printapoolstr(citelist[citeptr]);end;
printanewline;begin write(logfile,'while executing-');
write(tty,'while executing-');end;bstlnnumprint;markerror;end;
{:293}{294:}procedure bstmildexwarnprint;
begin if(messwithentries)then begin begin write(logfile,' for entry ');
write(tty,' for entry ');end;printapoolstr(citelist[citeptr]);end;
printanewline;begin begin write(logfile,'while executing');
write(tty,'while executing');end;bstwarnprint;end;end;
{:294}{295:}procedure bstcantmesswithentriesprint;
begin begin begin write(logfile,'You can''t mess with entries here');
write(tty,'You can''t mess with entries here');end;bstexwarnprint;end;
end;{:295}{310:}procedure illeglliteralconfusion;
begin begin begin write(logfile,'Illegal literal type');
write(tty,'Illegal literal type');end;printconfusion;goto 9998;end;end;
procedure unknwnliteralconfusion;
begin begin begin write(logfile,'Unknown literal type');
write(tty,'Unknown literal type');end;printconfusion;goto 9998;end;end;
{:310}{311:}procedure printstklit(stklt:integer;stktp:stktype);
begin case(stktp)of 0:begin write(logfile,stklt:0,
' is an integer literal');write(tty,stklt:0,' is an integer literal');
end;1:begin begin write(logfile,'"');write(tty,'"');end;
printapoolstr(stklt);begin write(logfile,'" is a string literal');
write(tty,'" is a string literal');end;end;
2:begin begin write(logfile,'`');write(tty,'`');end;
printapoolstr(hashtext[stklt]);
begin write(logfile,''' is a function literal');
write(tty,''' is a function literal');end;end;
3:begin begin write(logfile,'`');write(tty,'`');end;
printapoolstr(stklt);begin write(logfile,''' is a missing field');
write(tty,''' is a missing field');end;end;4:illeglliteralconfusion;
others:unknwnliteralconfusion end;end;
{:311}{313:}procedure printlit(stklt:integer;stktp:stktype);
begin case(stktp)of 0:begin writeln(logfile,stklt:0);
writeln(tty,stklt:0);end;1:begin printapoolstr(stklt);printanewline;end;
2:begin printapoolstr(hashtext[stklt]);printanewline;end;
3:begin printapoolstr(stklt);printanewline;end;4:illeglliteralconfusion;
others:unknwnliteralconfusion end;end;
{:313}{321:}procedure outputbblline;label 15,10;
begin if(outbuflength<>0)then begin while(outbuflength>0)do if(lexclass[
outbuf[outbuflength-1]]=1)then outbuflength:=outbuflength-1 else goto 15
;15:if(outbuflength=0)then goto 10;outbufptr:=0;
while(outbufptr<outbuflength)do begin write(bblfile,xchr[outbuf[
outbufptr]]);outbufptr:=outbufptr+1;end;end;writeln(bblfile);
bbllinenum:=bbllinenum+1;outbuflength:=0;10:end;
{:321}{356:}procedure bst1printstringsizeexceeded;
begin begin write(logfile,'Warning--you''ve exceeded ');
write(tty,'Warning--you''ve exceeded ');end;end;
procedure bst2printstringsizeexceeded;
begin begin write(logfile,'-string-size,');write(tty,'-string-size,');
end;bstmildexwarnprint;
begin writeln(logfile,'*Please notify the bibstyle designer*');
writeln(tty,'*Please notify the bibstyle designer*');end;end;
{:356}{368:}procedure bracesunbalancedcomplaint(poplitvar:strnumber);
begin begin write(logfile,'Warning--"');write(tty,'Warning--"');end;
printapoolstr(poplitvar);
begin begin write(logfile,'" isn''t a brace-balanced string');
write(tty,'" isn''t a brace-balanced string');end;bstmildexwarnprint;
end;end;{:368}{373:}procedure caseconversionconfusion;
begin begin begin write(logfile,'Unknown type of case conversion');
write(tty,'Unknown type of case conversion');end;printconfusion;
goto 9998;end;end;{:373}{456:}procedure traceandstatprinting;
begin{[457:]begin if(numbibfiles=1)then begin writeln(logfile,
'The 1 database file is');
end else begin writeln(logfile,'The ',numbibfiles:0,
' database files are');end;
if(numbibfiles=0)then begin writeln(logfile,'   undefined');
end else begin bibptr:=0;
while(bibptr<numbibfiles)do begin begin write(logfile,'   ');end;
begin outpoolstr(logfile,biblist[bibptr]);end;
begin outpoolstr(logfile,sbibextension);end;begin writeln(logfile);end;
bibptr:=bibptr+1;end;end;begin write(logfile,'The style file is ');end;
if(bststr=0)then begin writeln(logfile,'undefined');
end else begin begin outpoolstr(logfile,bststr);end;
begin outpoolstr(logfile,sbstextension);end;begin writeln(logfile);end;
end;end[:457];
[458:]begin if(allentries)then begin write(logfile,'all_marker=',
allmarker:0,', ');end;
if(readperformed)then begin writeln(logfile,'old_num_cites=',oldnumcites
:0);end else begin writeln(logfile);end;
begin write(logfile,'The ',numcites:0);end;
if(numcites=1)then begin writeln(logfile,' entry:');
end else begin writeln(logfile,' entries:');end;
if(numcites=0)then begin writeln(logfile,'   undefined');
end else begin sortciteptr:=0;
while(sortciteptr<numcites)do begin if(not readcompleted)then citeptr:=
sortciteptr else citeptr:=citeinfo[sortciteptr];
begin outpoolstr(logfile,citelist[citeptr]);end;
if(readperformed)then[459:]begin begin write(logfile,', entry-type ');
end;if(typelist[citeptr]=5001)then 5001:begin write(logfile,'unknown');
end else if(typelist[citeptr]=0)then begin write(logfile,
'--- no type found');
end else begin outpoolstr(logfile,hashtext[typelist[citeptr]]);end;
begin writeln(logfile,', has entry strings');end;
[460:]begin if(numentstrs=0)then begin writeln(logfile,'    undefined');
end else if(not readcompleted)then begin writeln(logfile,
'    uninitialized');end else begin strentptr:=citeptr*numentstrs;
while(strentptr<(citeptr+1)*numentstrs)do begin entchrptr:=0;
begin write(logfile,'    "');end;
while(entrystrs[strentptr][entchrptr]<>127)do begin begin write(logfile,
xchr[entrystrs[strentptr][entchrptr]]);end;entchrptr:=entchrptr+1;end;
begin writeln(logfile,'"');end;strentptr:=strentptr+1;end;end;end[:460];
begin write(logfile,'  has entry integers');end;
[461:]begin if(numentints=0)then begin write(logfile,' undefined');
end else if(not readcompleted)then begin write(logfile,' uninitialized')
;end else begin intentptr:=citeptr*numentints;
while(intentptr<(citeptr+1)*numentints)do begin begin write(logfile,' ',
entryints[intentptr]:0);end;intentptr:=intentptr+1;end;end;
begin writeln(logfile);end;end[:461];
begin writeln(logfile,'  and has fields');end;
[462:]begin if(not readperformed)then begin writeln(logfile,
'    uninitialized');end else begin fieldptr:=citeptr*numfields;
fieldendptr:=fieldptr+numfields;nofields:=true;
while(fieldptr<fieldendptr)do begin if(fieldinfo[fieldptr]<>0)then begin
begin write(logfile,'    "');end;
begin outpoolstr(logfile,fieldinfo[fieldptr]);end;
begin writeln(logfile,'"');end;nofields:=false;end;fieldptr:=fieldptr+1;
end;if(nofields)then begin writeln(logfile,'    missing');end;end;
end[:462];end[:459]else begin writeln(logfile);end;
sortciteptr:=sortciteptr+1;end;end;end[:458];
[463:]begin begin writeln(logfile,'The wiz-defined functions are');end;
if(wizdefptr=0)then begin writeln(logfile,'   nonexistent');
end else begin wizfnptr:=0;
while(wizfnptr<wizdefptr)do begin if(wizfunctions[wizfnptr]=5001)then
begin writeln(logfile,wizfnptr:0,'--end-of-def--');
end else if(wizfunctions[wizfnptr]=0)then begin write(logfile,wizfnptr:0
,'  quote_next_function    ');
end else begin begin write(logfile,wizfnptr:0,'  `');end;
begin outpoolstr(logfile,hashtext[wizfunctions[wizfnptr]]);end;
begin writeln(logfile,'''');end;end;wizfnptr:=wizfnptr+1;end;end;
end[:463];[464:]begin begin writeln(logfile,'The string pool is');end;
strnum:=1;
while(strnum<strptr)do begin begin write(logfile,strnum:4,strstart[
strnum]:6,' "');end;begin outpoolstr(logfile,strnum);end;
begin writeln(logfile,'"');end;strnum:=strnum+1;end;end[:464];}
{[465:]begin begin write(logfile,'You''ve used ',numcites:0);end;
if(numcites=1)then begin writeln(logfile,' entry,');
end else begin writeln(logfile,' entries,');end;
begin writeln(logfile,'            ',wizdefptr:0,
' wiz_defined-function locations,');end;
begin writeln(logfile,'            ',strptr:0,' strings with ',strstart[
strptr]:0,' characters,');end;bltinptr:=0;totalexcount:=0;
while(bltinptr<numbltinfns)do begin totalexcount:=totalexcount+
executioncount[bltinptr];bltinptr:=bltinptr+1;end;
begin writeln(logfile,'and the built_in function-call counts, ',
totalexcount:0,' in all, are:');end;bltinptr:=0;
while(bltinptr<numbltinfns)do begin begin outpoolstr(logfile,hashtext[
bltinloc[bltinptr]]);end;
begin writeln(logfile,' -- ',executioncount[bltinptr]:0);end;
bltinptr:=bltinptr+1;end;end[:465];}end;
{JSJ NOTE: The erstat function is an anomaly; for now, I've just modified it to
be standard Pascal.}
{:456}{38:}function erstat(var f:alphafile):integer;forward;
function aopenin(var f:alphafile):boolean;
begin reset(f,nameoffile,'/O');aopenin:=erstat(f)=0;end;
function aopenout(var f:alphafile):boolean;
begin rewrite(f,nameoffile,'/O');aopenout:=erstat(f)=0;end;
{:38}{39:}procedure aclose(var f:alphafile);begin close(f);end;
{:39}{58:}procedure startname(filename:strnumber);var pptr:poolpointer;
begin if((strstart[filename+1]-strstart[filename])>40)then begin begin
write(logfile,'File=');write(tty,'File=');end;printapoolstr(filename);
begin writeln(logfile,',');writeln(tty,',');end;filenmsizeoverflow;end;
nameptr:=1;pptr:=strstart[filename];
while(pptr<strstart[filename+1])do begin nameoffile[nameptr]:=chr(
strpool[pptr]);nameptr:=nameptr+1;pptr:=pptr+1;end;
namelength:=(strstart[filename+1]-strstart[filename]);end;
{:58}{60:}procedure addextension(ext:strnumber);var pptr:poolpointer;
begin if(namelength+(strstart[ext+1]-strstart[ext])>40)then begin begin
write(logfile,'File=',nameoffile,', extension=');
write(tty,'File=',nameoffile,', extension=');end;printapoolstr(ext);
begin writeln(logfile,',');writeln(tty,',');end;filenmsizeoverflow;end;
nameptr:=namelength+1;pptr:=strstart[ext];
while(pptr<strstart[ext+1])do begin nameoffile[nameptr]:=chr(strpool[
pptr]);nameptr:=nameptr+1;pptr:=pptr+1;end;
namelength:=namelength+(strstart[ext+1]-strstart[ext]);
nameptr:=namelength+1;
while(nameptr<=40)do begin nameoffile[nameptr]:=' ';nameptr:=nameptr+1;
end;end;{:60}{61:}procedure addarea(area:strnumber);
var pptr:poolpointer;
begin if(namelength+(strstart[area+1]-strstart[area])>40)then begin
begin write(logfile,'File=');write(tty,'File=');end;printapoolstr(area);
begin write(logfile,nameoffile,',');write(tty,nameoffile,',');end;
filenmsizeoverflow;end;nameptr:=namelength;
while(nameptr>0)do begin nameoffile[nameptr+(strstart[area+1]-strstart[
area])]:=nameoffile[nameptr];nameptr:=nameptr-1;end;nameptr:=1;
pptr:=strstart[area];
while(pptr<strstart[area+1])do begin nameoffile[nameptr]:=chr(strpool[
pptr]);nameptr:=nameptr+1;pptr:=pptr+1;end;
namelength:=namelength+(strstart[area+1]-strstart[area]);end;
{:61}{54:}function makestring:strnumber;
begin if(strptr=maxstrings)then begin printoverflow;
begin writeln(logfile,'number of strings ',maxstrings:0);
writeln(tty,'number of strings ',maxstrings:0);end;goto 9998;end;
strptr:=strptr+1;strstart[strptr]:=poolptr;makestring:=strptr-1;end;
{:54}{56:}function streqbuf(s:strnumber;var buf:buftype;
bfptr,len:bufpointer):boolean;label 10;var i:bufpointer;j:poolpointer;
begin if((strstart[s+1]-strstart[s])<>len)then begin streqbuf:=false;
goto 10;end;i:=bfptr;j:=strstart[s];
while(j<strstart[s+1])do begin if(strpool[j]<>buf[i])then begin streqbuf
:=false;goto 10;end;i:=i+1;j:=j+1;end;streqbuf:=true;10:end;
{:56}{57:}function streqstr(s1,s2:strnumber):boolean;label 10;
begin if((strstart[s1+1]-strstart[s1])<>(strstart[s2+1]-strstart[s2]))
then begin streqstr:=false;goto 10;end;pptr1:=strstart[s1];
pptr2:=strstart[s2];
while(pptr1<strstart[s1+1])do begin if(strpool[pptr1]<>strpool[pptr2])
then begin streqstr:=false;goto 10;end;pptr1:=pptr1+1;pptr2:=pptr2+1;
end;streqstr:=true;10:end;{:57}{62:}procedure lowercase(var buf:buftype;
bfptr,len:bufpointer);var i:bufpointer;
begin if(len>0)then for i:=bfptr to bfptr+len-1 do if((buf[i]>=65)and(
buf[i]<=90))then buf[i]:=buf[i]+32;end;
{:62}{63:}procedure uppercase(var buf:buftype;bfptr,len:bufpointer);
var i:bufpointer;
begin if(len>0)then for i:=bfptr to bfptr+len-1 do if((buf[i]>=97)and(
buf[i]<=122))then buf[i]:=buf[i]-32;end;
{:63}{68:}function strlookup(var buf:buftype;j,l:bufpointer;ilk:strilk;
insertit:boolean):hashloc;label 40,45;var h:0..8631;p:hashloc;
k:bufpointer;oldstring:boolean;strnum:strnumber;begin{69:}begin h:=0;
k:=j;while(k<j+l)do begin h:=h+h+buf[k];while(h>=4253)do h:=h-4253;
k:=k+1;end;end{:69};p:=h+1;hashfound:=false;oldstring:=false;
while true do begin{70:}begin if(hashtext[p]>0)then if(streqbuf(hashtext
[p],buf,j,l))then if(hashilk[p]=ilk)then begin hashfound:=true;goto 40;
end else begin oldstring:=true;strnum:=hashtext[p];end;end{:70};
if(hashnext[p]=0)then begin if(not insertit)then goto 45;
{71:}begin if(hashtext[p]>0)then begin repeat if((hashused=1))then begin
printoverflow;begin writeln(logfile,'hash size ',5000:0);
writeln(tty,'hash size ',5000:0);end;goto 9998;end;hashused:=hashused-1;
until(hashtext[hashused]=0);hashnext[p]:=hashused;p:=hashused;end;
if(oldstring)then hashtext[p]:=strnum else begin begin if(poolptr+l>
poolsize)then pooloverflow;end;k:=j;
while(k<j+l)do begin begin strpool[poolptr]:=buf[k];poolptr:=poolptr+1;
end;k:=k+1;end;hashtext[p]:=makestring;end;hashilk[p]:=ilk;end{:71};
goto 40;end;p:=hashnext[p];end;45:;40:strlookup:=p;end;
{:68}{77:}procedure predefine(pds:pdstype;len:pdslen;ilk:strilk);
var i:pdslen;begin for i:=1 to len do buffer[i]:=xord[pds[i]];
predefloc:=strlookup(buffer,1,len,ilk,true);end;
{:77}{198:}procedure inttoASCII(int:integer;var intbuf:buftype;
intbegin:bufpointer;var intend:bufpointer);
var intptr,intxptr:bufpointer;inttmpval:ASCIIcode;
begin intptr:=intbegin;
if(int<0)then begin begin if(intptr=bufsize)then bufferoverflow;
intbuf[intptr]:=45;intptr:=intptr+1;end;int:=-int;end;intxptr:=intptr;
repeat begin if(intptr=bufsize)then bufferoverflow;
intbuf[intptr]:=48+(int mod 10);intptr:=intptr+1;end;int:=int div 10;
until(int=0);intend:=intptr;intptr:=intptr-1;
while(intxptr<intptr)do begin inttmpval:=intbuf[intxptr];
intbuf[intxptr]:=intbuf[intptr];intbuf[intptr]:=inttmpval;
intptr:=intptr-1;intxptr:=intxptr+1;end end;
{:198}{265:}procedure adddatabasecite(var newcite:citenumber);
begin checkciteoverflow(newcite);checkfieldoverflow(numfields*newcite);
citelist[newcite]:=hashtext[citeloc];ilkinfo[citeloc]:=newcite;
ilkinfo[lcciteloc]:=citeloc;newcite:=newcite+1;end;
{:265}{278:}function findcitelocsforthiscitekey(citestr:strnumber):
boolean;begin exbufptr:=0;tmpptr:=strstart[citestr];
tmpendptr:=strstart[citestr+1];
while(tmpptr<tmpendptr)do begin exbuf[exbufptr]:=strpool[tmpptr];
exbufptr:=exbufptr+1;tmpptr:=tmpptr+1;end;
citeloc:=strlookup(exbuf,0,(strstart[citestr+1]-strstart[citestr]),9,
false);citehashfound:=hashfound;
lowercase(exbuf,0,(strstart[citestr+1]-strstart[citestr]));
lcciteloc:=strlookup(exbuf,0,(strstart[citestr+1]-strstart[citestr]),10,
false);if(hashfound)then findcitelocsforthiscitekey:=true else
findcitelocsforthiscitekey:=false;end;
{:278}{300:}procedure swap(swap1,swap2:citenumber);
var innocentbystander:citenumber;
begin innocentbystander:=citeinfo[swap2];
citeinfo[swap2]:=citeinfo[swap1];citeinfo[swap1]:=innocentbystander;end;
{:300}{301:}function lessthan(arg1,arg2:citenumber):boolean;label 10;
var charptr:0..entstrsize;ptr1,ptr2:strentloc;char1,char2:ASCIIcode;
begin ptr1:=arg1*numentstrs+sortkeynum;ptr2:=arg2*numentstrs+sortkeynum;
charptr:=0;while true do begin char1:=entrystrs[ptr1][charptr];
char2:=entrystrs[ptr2][charptr];
if(char1=127)then if(char2=127)then if(arg1<arg2)then begin lessthan:=
true;goto 10;end else if(arg1>arg2)then begin lessthan:=false;goto 10;
end else begin begin write(logfile,'Duplicate sort key');
write(tty,'Duplicate sort key');end;printconfusion;goto 9998;
end else begin lessthan:=true;goto 10;
end else if(char2=127)then begin lessthan:=false;goto 10;
end else if(char1<char2)then begin lessthan:=true;goto 10;
end else if(char1>char2)then begin lessthan:=false;goto 10;end;
charptr:=charptr+1;end;10:end;
{:301}{303:}procedure quicksort(leftend,rightend:citenumber);label 24;
var left,right:citenumber;insertptr:citenumber;middle:citenumber;
partition:citenumber;
begin{begin writeln(logfile,'Sorting ',leftend:0,' through ',rightend:0)
;end;}if(rightend-leftend<10)then{304:}begin for insertptr:=leftend+1 to
rightend do begin for right:=insertptr downto leftend+1 do begin if(
lessthan(citeinfo[right-1],citeinfo[right]))then goto 24;
swap(right-1,right);end;24:end;
end{:304}else begin{305:}begin left:=leftend+4;
middle:=(leftend+rightend)div 2;right:=rightend-4;
if(lessthan(citeinfo[left],citeinfo[middle]))then if(lessthan(citeinfo[
middle],citeinfo[right]))then swap(leftend,middle)else if(lessthan(
citeinfo[left],citeinfo[right]))then swap(leftend,right)else swap(
leftend,left)else if(lessthan(citeinfo[right],citeinfo[middle]))then
swap(leftend,middle)else if(lessthan(citeinfo[right],citeinfo[left]))
then swap(leftend,right)else swap(leftend,left);end{:305};
{306:}begin partition:=citeinfo[leftend];left:=leftend+1;
right:=rightend;
repeat while(lessthan(citeinfo[left],partition))do left:=left+1;
while(lessthan(partition,citeinfo[right]))do right:=right-1;
if(left<right)then begin swap(left,right);left:=left+1;right:=right-1;
end;until(left=right+1);swap(leftend,right);quicksort(leftend,right-1);
quicksort(left,rightend);end{:306};end;end;
{:303}{335:}procedure buildin(pds:pdstype;len:pdslen;
var fnhashloc:hashloc;bltinnum:bltinrange);begin predefine(pds,len,11);
fnhashloc:=predefloc;fntype[fnhashloc]:=0;ilkinfo[fnhashloc]:=bltinnum;
{bltinloc[bltinnum]:=fnhashloc;executioncount[bltinnum]:=0;}end;
{:335}{336:}procedure predefcertainstrings;
begin{75:}predefine('.aux        ',4,7);
sauxextension:=hashtext[predefloc];predefine('.bbl        ',4,7);
sbblextension:=hashtext[predefloc];predefine('.blg        ',4,7);
slogextension:=hashtext[predefloc];predefine('.bst        ',4,7);
sbstextension:=hashtext[predefloc];predefine('.bib        ',4,7);
sbibextension:=hashtext[predefloc];predefine('texinputs:  ',10,8);
sbstarea:=hashtext[predefloc];predefine('texbib:     ',7,8);
sbibarea:=hashtext[predefloc];{:75}{79:}predefine('\citation   ',9,2);
ilkinfo[predefloc]:=2;predefine('\bibdata    ',8,2);
ilkinfo[predefloc]:=0;predefine('\bibstyle   ',9,2);
ilkinfo[predefloc]:=1;predefine('\@input     ',7,2);
ilkinfo[predefloc]:=3;predefine('entry       ',5,4);
ilkinfo[predefloc]:=0;predefine('execute     ',7,4);
ilkinfo[predefloc]:=1;predefine('function    ',8,4);
ilkinfo[predefloc]:=2;predefine('integers    ',8,4);
ilkinfo[predefloc]:=3;predefine('iterate     ',7,4);
ilkinfo[predefloc]:=4;predefine('macro       ',5,4);
ilkinfo[predefloc]:=5;predefine('read        ',4,4);
ilkinfo[predefloc]:=6;predefine('reverse     ',7,4);
ilkinfo[predefloc]:=7;predefine('sort        ',4,4);
ilkinfo[predefloc]:=8;predefine('strings     ',7,4);
ilkinfo[predefloc]:=9;predefine('comment     ',7,12);
ilkinfo[predefloc]:=0;predefine('preamble    ',8,12);
ilkinfo[predefloc]:=1;predefine('string      ',6,12);
ilkinfo[predefloc]:=2;{:79}{334:}buildin('=           ',1,bequals,0);
buildin('>           ',1,bgreaterthan,1);
buildin('<           ',1,blessthan,2);buildin('+           ',1,bplus,3);
buildin('-           ',1,bminus,4);
buildin('*           ',1,bconcatenate,5);
buildin(':=          ',2,bgets,6);
buildin('add.period$ ',11,baddperiod,7);
buildin('call.type$  ',10,bcalltype,8);
buildin('change.case$',12,bchangecase,9);
buildin('chr.to.int$ ',11,bchrtoint,10);
buildin('cite$       ',5,bcite,11);
buildin('duplicate$  ',10,bduplicate,12);
buildin('empty$      ',6,bempty,13);
buildin('format.name$',12,bformatname,14);
buildin('if$         ',3,bif,15);
buildin('int.to.chr$ ',11,binttochr,16);
buildin('int.to.str$ ',11,binttostr,17);
buildin('missing$    ',8,bmissing,18);
buildin('newline$    ',8,bnewline,19);
buildin('num.names$  ',10,bnumnames,20);
buildin('pop$        ',4,bpop,21);
buildin('preamble$   ',9,bpreamble,22);
buildin('purify$     ',7,bpurify,23);
buildin('quote$      ',6,bquote,24);buildin('skip$       ',5,bskip,25);
buildin('stack$      ',6,bstack,26);
buildin('substring$  ',10,bsubstring,27);
buildin('swap$       ',5,bswap,28);
buildin('text.length$',12,btextlength,29);
buildin('text.prefix$',12,btextprefix,30);
buildin('top$        ',4,btopstack,31);
buildin('type$       ',5,btype,32);
buildin('warning$    ',8,bwarning,33);
buildin('width$      ',6,bwidth,35);buildin('while$      ',6,bwhile,34);
buildin('width$      ',6,bwidth,35);buildin('write$      ',6,bwrite,36);
{:334}{339:}predefine('            ',0,0);snull:=hashtext[predefloc];
fntype[predefloc]:=3;predefine('default.type',12,0);
sdefault:=hashtext[predefloc];fntype[predefloc]:=3;bdefault:=bskip;
preambleptr:=0;predefine('i           ',1,14);ilkinfo[predefloc]:=0;
predefine('j           ',1,14);ilkinfo[predefloc]:=1;
predefine('oe          ',2,14);ilkinfo[predefloc]:=2;
predefine('OE          ',2,14);ilkinfo[predefloc]:=3;
predefine('ae          ',2,14);ilkinfo[predefloc]:=4;
predefine('AE          ',2,14);ilkinfo[predefloc]:=5;
predefine('aa          ',2,14);ilkinfo[predefloc]:=6;
predefine('AA          ',2,14);ilkinfo[predefloc]:=7;
predefine('o           ',1,14);ilkinfo[predefloc]:=8;
predefine('O           ',1,14);ilkinfo[predefloc]:=9;
predefine('l           ',1,14);ilkinfo[predefloc]:=10;
predefine('L           ',1,14);ilkinfo[predefloc]:=11;
predefine('ss          ',2,14);ilkinfo[predefloc]:=12;
{:339}{340:}predefine('crossref    ',8,11);fntype[predefloc]:=4;
ilkinfo[predefloc]:=numfields;crossrefnum:=numfields;
numfields:=numfields+1;numpredefinedfields:=numfields;
predefine('sort.key$   ',9,11);fntype[predefloc]:=6;
ilkinfo[predefloc]:=numentstrs;sortkeynum:=numentstrs;
numentstrs:=numentstrs+1;predefine('entry.max$  ',10,11);
fntype[predefloc]:=7;ilkinfo[predefloc]:=entstrsize;
predefine('global.max$ ',11,11);fntype[predefloc]:=7;
ilkinfo[predefloc]:=globstrsize;{:340}end;
{:336}{83:}function scan1(char1:ASCIIcode):boolean;
begin bufptr1:=bufptr2;
while((buffer[bufptr2]<>char1)and(bufptr2<last))do bufptr2:=bufptr2+1;
if(bufptr2<last)then scan1:=true else scan1:=false;end;
{:83}{84:}function scan1white(char1:ASCIIcode):boolean;
begin bufptr1:=bufptr2;
while((lexclass[buffer[bufptr2]]<>1)and(buffer[bufptr2]<>char1)and(
bufptr2<last))do bufptr2:=bufptr2+1;
if(bufptr2<last)then scan1white:=true else scan1white:=false;end;
{:84}{85:}function scan2(char1,char2:ASCIIcode):boolean;
begin bufptr1:=bufptr2;
while((buffer[bufptr2]<>char1)and(buffer[bufptr2]<>char2)and(bufptr2<
last))do bufptr2:=bufptr2+1;
if(bufptr2<last)then scan2:=true else scan2:=false;end;
{:85}{86:}function scan2white(char1,char2:ASCIIcode):boolean;
begin bufptr1:=bufptr2;
while((buffer[bufptr2]<>char1)and(buffer[bufptr2]<>char2)and(lexclass[
buffer[bufptr2]]<>1)and(bufptr2<last))do bufptr2:=bufptr2+1;
if(bufptr2<last)then scan2white:=true else scan2white:=false;end;
{:86}{87:}function scan3(char1,char2,char3:ASCIIcode):boolean;
begin bufptr1:=bufptr2;
while((buffer[bufptr2]<>char1)and(buffer[bufptr2]<>char2)and(buffer[
bufptr2]<>char3)and(bufptr2<last))do bufptr2:=bufptr2+1;
if(bufptr2<last)then scan3:=true else scan3:=false;end;
{:87}{88:}function scanalpha:boolean;begin bufptr1:=bufptr2;
while((lexclass[buffer[bufptr2]]=2)and(bufptr2<last))do bufptr2:=bufptr2
+1;if((bufptr2-bufptr1)=0)then scanalpha:=false else scanalpha:=true;
end;{:88}{90:}procedure scanidentifier(char1,char2,char3:ASCIIcode);
begin bufptr1:=bufptr2;
if(lexclass[buffer[bufptr2]]<>3)then while((idclass[buffer[bufptr2]]=1)
and(bufptr2<last))do bufptr2:=bufptr2+1;
if((bufptr2-bufptr1)=0)then scanresult:=0 else if((lexclass[buffer[
bufptr2]]=1)or(bufptr2=last))then scanresult:=3 else if((buffer[bufptr2]
=char1)or(buffer[bufptr2]=char2)or(buffer[bufptr2]=char3))then
scanresult:=1 else scanresult:=2;end;
{:90}{92:}function scannonneginteger:boolean;begin bufptr1:=bufptr2;
tokenvalue:=0;
while((lexclass[buffer[bufptr2]]=3)and(bufptr2<last))do begin tokenvalue
:=tokenvalue*10+(buffer[bufptr2]-48);bufptr2:=bufptr2+1;end;
if((bufptr2-bufptr1)=0)then scannonneginteger:=false else
scannonneginteger:=true;end;{:92}{93:}function scaninteger:boolean;
var signlength:0..1;begin bufptr1:=bufptr2;
if(buffer[bufptr2]=45)then begin signlength:=1;bufptr2:=bufptr2+1;
end else signlength:=0;tokenvalue:=0;
while((lexclass[buffer[bufptr2]]=3)and(bufptr2<last))do begin tokenvalue
:=tokenvalue*10+(buffer[bufptr2]-48);bufptr2:=bufptr2+1;end;
if((signlength=1))then tokenvalue:=-tokenvalue;
if((bufptr2-bufptr1)=signlength)then scaninteger:=false else scaninteger
:=true;end;{:93}{94:}function scanwhitespace:boolean;
begin while((lexclass[buffer[bufptr2]]=1)and(bufptr2<last))do bufptr2:=
bufptr2+1;
if(bufptr2<last)then scanwhitespace:=true else scanwhitespace:=false;
end;{:94}{152:}function eatbstwhitespace:boolean;label 10;
begin while true do begin if(scanwhitespace)then if(buffer[bufptr2]<>37)
then begin eatbstwhitespace:=true;goto 10;end;
if(not inputln(bstfile))then begin eatbstwhitespace:=false;goto 10;end;
bstlinenum:=bstlinenum+1;bufptr2:=0;end;10:end;
{:152}{183:}procedure skiptokenprint;begin begin write(logfile,'-');
write(tty,'-');end;bstlnnumprint;markerror;if(scan2white(125,37))then;
end;{:183}{184:}procedure printrecursionillegal;
begin{begin writeln(logfile);end;}
begin writeln(logfile,'Curse you, wizard, before you recurse me:');
writeln(tty,'Curse you, wizard, before you recurse me:');end;
begin write(logfile,'function ');write(tty,'function ');end;printatoken;
begin writeln(logfile,' is illegal in its own definition');
writeln(tty,' is illegal in its own definition');end;
{printrecursionillegal;}skiptokenprint;end;
{:184}{185:}procedure skptokenunknownfunctionprint;begin printatoken;
begin write(logfile,' is an unknown function');
write(tty,' is an unknown function');end;skiptokenprint;end;
{:185}{186:}procedure skipillegalstuffaftertokenprint;
begin begin write(logfile,'"',xchr[buffer[bufptr2]],
'" can''t follow a literal');
write(tty,'"',xchr[buffer[bufptr2]],'" can''t follow a literal');end;
skiptokenprint;end;{:186}{187:}procedure scanfndef(fnhashloc:hashloc);
label 25,10;type fndefloc=0..singlefnspace;
var singlfunction:packed array[fndefloc]of hashptr2;singleptr:fndefloc;
copyptr:fndefloc;endofnum:bufpointer;implfnloc:hashloc;
begin begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
singleptr:=0;
while(buffer[bufptr2]<>125)do begin{189:}case(buffer[bufptr2])of 35:
{190:}begin bufptr2:=bufptr2+1;
if(not scaninteger)then begin begin write(logfile,
'Illegal integer in integer literal');
write(tty,'Illegal integer in integer literal');end;skiptokenprint;
goto 25;end;{begin write(logfile,'#');end;begin outtoken(logfile);end;
begin writeln(logfile,' is an integer literal with value ',tokenvalue:0)
;end;}literalloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),1,true);
if(not hashfound)then begin fntype[literalloc]:=2;
ilkinfo[literalloc]:=tokenvalue;end;
if((lexclass[buffer[bufptr2]]<>1)and(bufptr2<last)and(buffer[bufptr2]<>
125)and(buffer[bufptr2]<>37))then begin skipillegalstuffaftertokenprint;
goto 25;end;begin singlfunction[singleptr]:=literalloc;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;end{:190};34:{191:}begin bufptr2:=bufptr2+1;
if(not scan1(34))then begin begin write(logfile,'No `',xchr[34],
''' to end string literal');
write(tty,'No `',xchr[34],''' to end string literal');end;
skiptokenprint;goto 25;end;{begin write(logfile,'"');end;
begin outtoken(logfile);end;begin write(logfile,'"');end;
begin writeln(logfile,' is a string literal');end;}
literalloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),0,true);
fntype[literalloc]:=3;bufptr2:=bufptr2+1;
if((lexclass[buffer[bufptr2]]<>1)and(bufptr2<last)and(buffer[bufptr2]<>
125)and(buffer[bufptr2]<>37))then begin skipillegalstuffaftertokenprint;
goto 25;end;begin singlfunction[singleptr]:=literalloc;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;end{:191};39:{192:}begin bufptr2:=bufptr2+1;
if(scan2white(125,37))then;{begin write(logfile,'''');end;
begin outtoken(logfile);end;
begin write(logfile,' is a quoted function ');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,false);
if(not hashfound)then begin skptokenunknownfunctionprint;goto 25;
end else{193:}begin if(fnloc=wizloc)then begin printrecursionillegal;
goto 25;end else begin{begin write(logfile,'of type ');end;
traceprfnclass(fnloc);begin writeln(logfile);end;}
begin singlfunction[singleptr]:=0;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;begin singlfunction[singleptr]:=fnloc;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;end end{:193};end{:192};123:{194:}begin exbuf[0]:=39;
inttoASCII(implfnnum,exbuf,1,endofnum);
implfnloc:=strlookup(exbuf,0,endofnum,11,true);
if(hashfound)then begin begin write(logfile,
'Already encountered implicit function');
write(tty,'Already encountered implicit function');end;printconfusion;
goto 9998;end;{begin outpoolstr(logfile,hashtext[implfnloc]);end;
begin writeln(logfile,' is an implicit function');end;}
implfnnum:=implfnnum+1;fntype[implfnloc]:=1;
begin singlfunction[singleptr]:=0;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;begin singlfunction[singleptr]:=implfnloc;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;bufptr2:=bufptr2+1;scanfndef(implfnloc);end{:194};
others:{199:}begin if(scan2white(125,37))then;{begin outtoken(logfile);
end;begin write(logfile,' is a function ');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,false);
if(not hashfound)then begin skptokenunknownfunctionprint;goto 25;
end else if(fnloc=wizloc)then begin printrecursionillegal;goto 25;
end else begin{begin write(logfile,'of type ');end;
traceprfnclass(fnloc);begin writeln(logfile);end;}
begin singlfunction[singleptr]:=fnloc;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;end;end{:199}end{:189};
25:begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;end;
{200:}begin begin singlfunction[singleptr]:=5001;
if(singleptr=singlefnspace)then singlfnoverflow;singleptr:=singleptr+1;
end;if(singleptr+wizdefptr>wizfnspace)then begin begin write(logfile,
singleptr+wizdefptr:0,': ');write(tty,singleptr+wizdefptr:0,': ');end;
begin printoverflow;
begin writeln(logfile,'wizard-defined function space ',wizfnspace:0);
writeln(tty,'wizard-defined function space ',wizfnspace:0);end;
goto 9998;end;end;ilkinfo[fnhashloc]:=wizdefptr;copyptr:=0;
while(copyptr<singleptr)do begin wizfunctions[wizdefptr]:=singlfunction[
copyptr];copyptr:=copyptr+1;wizdefptr:=wizdefptr+1;end;end{:200};
bufptr2:=bufptr2+1;10:end;{:187}{228:}function eatbibwhitespace:boolean;
label 10;
begin while(not scanwhitespace)do begin if(not inputln(bibfile[bibptr]))
then begin eatbibwhitespace:=false;goto 10;end;biblinenum:=biblinenum+1;
bufptr2:=0;end;eatbibwhitespace:=true;10:end;
{:228}{248:}{252:}function compressbibwhite:boolean;label 10;
begin compressbibwhite:=false;
begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;goto 10;
end else begin exbuf[exbufptr]:=32;exbufptr:=exbufptr+1;end;end;
while(not scanwhitespace)do begin if(not inputln(bibfile[bibptr]))then
begin eatbibprint;goto 10;end;biblinenum:=biblinenum+1;bufptr2:=0;end;
compressbibwhite:=true;10:end;
{:252}{253:}function scanbalancedbraces:boolean;label 15,10;
begin scanbalancedbraces:=false;bufptr2:=bufptr2+1;
begin if((lexclass[buffer[bufptr2]]=1)or(bufptr2=last))then if(not
compressbibwhite)then goto 10;end;
if(exbufptr>1)then if(exbuf[exbufptr-1]=32)then if(exbuf[exbufptr-2]=32)
then exbufptr:=exbufptr-1;bibbracelevel:=0;
if(storefield)then{256:}begin while(buffer[bufptr2]<>rightstrdelim)do
case(buffer[bufptr2])of 123:begin bibbracelevel:=bibbracelevel+1;
begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;goto 10;
end else begin exbuf[exbufptr]:=123;exbufptr:=exbufptr+1;end;end;
bufptr2:=bufptr2+1;
begin if((lexclass[buffer[bufptr2]]=1)or(bufptr2=last))then if(not
compressbibwhite)then goto 10;end;
{257:}begin while true do case(buffer[bufptr2])of 125:begin
bibbracelevel:=bibbracelevel-1;
begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;goto 10;
end else begin exbuf[exbufptr]:=125;exbufptr:=exbufptr+1;end;end;
bufptr2:=bufptr2+1;
begin if((lexclass[buffer[bufptr2]]=1)or(bufptr2=last))then if(not
compressbibwhite)then goto 10;end;if(bibbracelevel=0)then goto 15;end;
123:begin bibbracelevel:=bibbracelevel+1;
begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;goto 10;
end else begin exbuf[exbufptr]:=123;exbufptr:=exbufptr+1;end;end;
bufptr2:=bufptr2+1;
begin if((lexclass[buffer[bufptr2]]=1)or(bufptr2=last))then if(not
compressbibwhite)then goto 10;end;end;
others:begin begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;
goto 10;end else begin exbuf[exbufptr]:=buffer[bufptr2];
exbufptr:=exbufptr+1;end;end;bufptr2:=bufptr2+1;
begin if((lexclass[buffer[bufptr2]]=1)or(bufptr2=last))then if(not
compressbibwhite)then goto 10;end;end end;15:end{:257};end;
125:begin bibunbalancedbracesprint;goto 10;end;
others:begin begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;
goto 10;end else begin exbuf[exbufptr]:=buffer[bufptr2];
exbufptr:=exbufptr+1;end;end;bufptr2:=bufptr2+1;
begin if((lexclass[buffer[bufptr2]]=1)or(bufptr2=last))then if(not
compressbibwhite)then goto 10;end;end end;
end{:256}else{254:}begin while(buffer[bufptr2]<>rightstrdelim)do if(
buffer[bufptr2]=123)then begin bibbracelevel:=bibbracelevel+1;
bufptr2:=bufptr2+1;begin if(not eatbibwhitespace)then begin eatbibprint;
goto 10;end;end;
while(bibbracelevel>0)do{255:}begin if(buffer[bufptr2]=125)then begin
bibbracelevel:=bibbracelevel-1;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
end else if(buffer[bufptr2]=123)then begin bibbracelevel:=bibbracelevel
+1;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
end else begin bufptr2:=bufptr2+1;
if(not scan2(125,123))then begin if(not eatbibwhitespace)then begin
eatbibprint;goto 10;end;end;end end{:255};
end else if(buffer[bufptr2]=125)then begin bibunbalancedbracesprint;
goto 10;end else begin bufptr2:=bufptr2+1;
if(not scan3(rightstrdelim,123,125))then begin if(not eatbibwhitespace)
then begin eatbibprint;goto 10;end;end;end end{:254};bufptr2:=bufptr2+1;
scanbalancedbraces:=true;10:end;
{:253}{250:}function scanafieldtokenandeatwhite:boolean;label 10;
begin scanafieldtokenandeatwhite:=false;
case(buffer[bufptr2])of 123:begin rightstrdelim:=125;
if(not scanbalancedbraces)then goto 10;end;34:begin rightstrdelim:=34;
if(not scanbalancedbraces)then goto 10;end;
48,49,50,51,52,53,54,55,56,57:{258:}begin if(not scannonneginteger)then
begin begin write(logfile,'A digit disappeared');
write(tty,'A digit disappeared');end;printconfusion;goto 9998;end;
if(storefield)then begin tmpptr:=bufptr1;
while(tmpptr<bufptr2)do begin begin if(exbufptr=bufsize)then begin
bibfieldtoolongprint;goto 10;
end else begin exbuf[exbufptr]:=buffer[tmpptr];exbufptr:=exbufptr+1;end;
end;tmpptr:=tmpptr+1;end;end;end{:258};
others:{259:}begin scanidentifier(44,rightouterdelim,35);
begin if((scanresult=3)or(scanresult=1))then else begin bibidprint;
begin begin write(logfile,'a field part');write(tty,'a field part');end;
biberrprint;goto 10;end;end;end;
if(storefield)then begin lowercase(buffer,bufptr1,(bufptr2-bufptr1));
macronameloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),13,false);
storetoken:=true;
if(atbibcommand)then if(commandnum=2)then if(macronameloc=curmacroloc)
then begin storetoken:=false;begin macrowarnprint;
begin begin writeln(logfile,'used in its own definition');
writeln(tty,'used in its own definition');end;bibwarnprint;end;end;end;
if(not hashfound)then begin storetoken:=false;begin macrowarnprint;
begin begin writeln(logfile,'undefined');writeln(tty,'undefined');end;
bibwarnprint;end;end;end;
if(storetoken)then{260:}begin tmpptr:=strstart[ilkinfo[macronameloc]];
tmpendptr:=strstart[ilkinfo[macronameloc]+1];
if(exbufptr=0)then if((lexclass[strpool[tmpptr]]=1)and(tmpptr<tmpendptr)
)then begin begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;
goto 10;end else begin exbuf[exbufptr]:=32;exbufptr:=exbufptr+1;end;end;
tmpptr:=tmpptr+1;
while((lexclass[strpool[tmpptr]]=1)and(tmpptr<tmpendptr))do tmpptr:=
tmpptr+1;end;
while(tmpptr<tmpendptr)do begin if(lexclass[strpool[tmpptr]]<>1)then
begin if(exbufptr=bufsize)then begin bibfieldtoolongprint;goto 10;
end else begin exbuf[exbufptr]:=strpool[tmpptr];exbufptr:=exbufptr+1;
end;
end else if(exbuf[exbufptr-1]<>32)then begin if(exbufptr=bufsize)then
begin bibfieldtoolongprint;goto 10;end else begin exbuf[exbufptr]:=32;
exbufptr:=exbufptr+1;end;end;tmpptr:=tmpptr+1;end;end{:260};end;
end{:259}end;begin if(not eatbibwhitespace)then begin eatbibprint;
goto 10;end;end;scanafieldtokenandeatwhite:=true;10:end;
{:250}{:248}{249:}function scanandstorethefieldvalueandeatwhite:boolean;
label 10;begin scanandstorethefieldvalueandeatwhite:=false;exbufptr:=0;
if(not scanafieldtokenandeatwhite)then goto 10;
while(buffer[bufptr2]=35)do begin bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
if(not scanafieldtokenandeatwhite)then goto 10;end;
if(storefield)then{261:}begin if(not atbibcommand)then if(exbufptr>0)
then if(exbuf[exbufptr-1]=32)then exbufptr:=exbufptr-1;
if((not atbibcommand)and(exbuf[0]=32)and(exbufptr>0))then exbufxptr:=1
else exbufxptr:=0;
fieldvalloc:=strlookup(exbuf,exbufxptr,exbufptr-exbufxptr,0,true);
fntype[fieldvalloc]:=3;{begin write(logfile,'"');end;
begin outpoolstr(logfile,hashtext[fieldvalloc]);end;
begin writeln(logfile,'" is a field value');end;}
if(atbibcommand)then{262:}begin case(commandnum)of 1:begin spreamble[
preambleptr]:=hashtext[fieldvalloc];preambleptr:=preambleptr+1;end;
2:ilkinfo[curmacroloc]:=hashtext[fieldvalloc];
others:bibcmdconfusion end;
end{:262}else{263:}begin fieldptr:=entryciteptr*numfields+ilkinfo[
fieldnameloc];
if(fieldinfo[fieldptr]<>0)then begin begin write(logfile,
'Warning--I''m ignoring ');write(tty,'Warning--I''m ignoring ');end;
printapoolstr(citelist[entryciteptr]);
begin write(logfile,'''s extra "');write(tty,'''s extra "');end;
printapoolstr(hashtext[fieldnameloc]);
begin begin writeln(logfile,'" field');writeln(tty,'" field');end;
bibwarnprint;end;
end else begin fieldinfo[fieldptr]:=hashtext[fieldvalloc];
if((ilkinfo[fieldnameloc]=crossrefnum)and(not allentries))then{264:}
begin tmpptr:=exbufxptr;
while(tmpptr<exbufptr)do begin outbuf[tmpptr]:=exbuf[tmpptr];
tmpptr:=tmpptr+1;end;lowercase(outbuf,exbufxptr,exbufptr-exbufxptr);
lcciteloc:=strlookup(outbuf,exbufxptr,exbufptr-exbufxptr,10,true);
if(hashfound)then begin citeloc:=ilkinfo[lcciteloc];
if(ilkinfo[citeloc]>=oldnumcites)then citeinfo[ilkinfo[citeloc]]:=
citeinfo[ilkinfo[citeloc]]+1;
end else begin citeloc:=strlookup(exbuf,exbufxptr,exbufptr-exbufxptr,9,
true);if(hashfound)then hashciteconfusion;adddatabasecite(citeptr);
citeinfo[ilkinfo[citeloc]]:=1;end;end{:264};end;end{:263};end{:261};
scanandstorethefieldvalueandeatwhite:=true;10:end;
{:249}{367:}procedure decrbracelevel(poplitvar:strnumber);
begin if(bracelevel=0)then bracesunbalancedcomplaint(poplitvar)else
bracelevel:=bracelevel-1;end;
{:367}{369:}procedure checkbracelevel(poplitvar:strnumber);
begin if(bracelevel>0)then bracesunbalancedcomplaint(poplitvar);end;
{:369}{384:}procedure namescanforand(poplitvar:strnumber);
begin bracelevel:=0;precedingwhite:=false;andfound:=false;
while((not andfound)and(exbufptr<exbuflength))do case(exbuf[exbufptr])of
97,65:begin exbufptr:=exbufptr+1;
if(precedingwhite)then{386:}begin if(exbufptr<=(exbuflength-3))then if((
exbuf[exbufptr]=110)or(exbuf[exbufptr]=78))then if((exbuf[exbufptr+1]=
100)or(exbuf[exbufptr+1]=68))then if(lexclass[exbuf[exbufptr+2]]=1)then
begin exbufptr:=exbufptr+2;andfound:=true;end;end{:386};
precedingwhite:=false;end;123:begin bracelevel:=bracelevel+1;
exbufptr:=exbufptr+1;
{385:}while((bracelevel>0)and(exbufptr<exbuflength))do begin if(exbuf[
exbufptr]=125)then bracelevel:=bracelevel-1 else if(exbuf[exbufptr]=123)
then bracelevel:=bracelevel+1;exbufptr:=exbufptr+1;end{:385};
precedingwhite:=false;end;125:begin decrbracelevel(poplitvar);
exbufptr:=exbufptr+1;precedingwhite:=false;end;
others:if(lexclass[exbuf[exbufptr]]=1)then begin exbufptr:=exbufptr+1;
precedingwhite:=true;end else begin exbufptr:=exbufptr+1;
precedingwhite:=false;end end;checkbracelevel(poplitvar);end;
{:384}{397:}function vontokenfound:boolean;label 10;
begin nmbracelevel:=0;vontokenfound:=false;
while(namebfptr<namebfxptr)do if((svbuffer[namebfptr]>=65)and(svbuffer[
namebfptr]<=90))then goto 10 else if((svbuffer[namebfptr]>=97)and(
svbuffer[namebfptr]<=122))then begin vontokenfound:=true;goto 10;
end else if(svbuffer[namebfptr]=123)then begin nmbracelevel:=
nmbracelevel+1;namebfptr:=namebfptr+1;
if((namebfptr+2<namebfxptr)and(svbuffer[namebfptr]=92))then{398:}begin
namebfptr:=namebfptr+1;namebfyptr:=namebfptr;
while((namebfptr<namebfxptr)and(lexclass[svbuffer[namebfptr]]=2))do
namebfptr:=namebfptr+1;
controlseqloc:=strlookup(svbuffer,namebfyptr,namebfptr-namebfyptr,14,
false);
if(hashfound)then{399:}begin case(ilkinfo[controlseqloc])of 3,5,7,9,11:
goto 10;0,1,2,4,6,8,10,12:begin vontokenfound:=true;goto 10;end;
others:begin begin write(logfile,'Control-sequence hash error');
write(tty,'Control-sequence hash error');end;printconfusion;goto 9998;
end end;end{:399};
while((namebfptr<namebfxptr)and(nmbracelevel>0))do begin if((svbuffer[
namebfptr]>=65)and(svbuffer[namebfptr]<=90))then goto 10 else if((
svbuffer[namebfptr]>=97)and(svbuffer[namebfptr]<=122))then begin
vontokenfound:=true;goto 10;
end else if(svbuffer[namebfptr]=125)then nmbracelevel:=nmbracelevel-1
else if(svbuffer[namebfptr]=123)then nmbracelevel:=nmbracelevel+1;
namebfptr:=namebfptr+1;end;goto 10;
end{:398}else{400:}while((nmbracelevel>0)and(namebfptr<namebfxptr))do
begin if(svbuffer[namebfptr]=125)then nmbracelevel:=nmbracelevel-1 else
if(svbuffer[namebfptr]=123)then nmbracelevel:=nmbracelevel+1;
namebfptr:=namebfptr+1;end{:400};end else namebfptr:=namebfptr+1;10:end;
{:397}{401:}procedure vonnameendsandlastnamestartsstuff;label 10;
begin vonend:=lastend-1;
while(vonend>vonstart)do begin namebfptr:=nametok[vonend-1];
namebfxptr:=nametok[vonend];if(vontokenfound)then goto 10;
vonend:=vonend-1;end;10:end;
{:401}{404:}procedure skipstuffatspbracelevelgreaterthanone;
begin while((spbracelevel>1)and(spptr<spend))do begin if(strpool[spptr]=
125)then spbracelevel:=spbracelevel-1 else if(strpool[spptr]=123)then
spbracelevel:=spbracelevel+1;spptr:=spptr+1;end;end;
{:404}{406:}procedure bracelvloneletterscomplaint;
begin begin write(logfile,'The format string "');
write(tty,'The format string "');end;printapoolstr(poplit1);
begin begin write(logfile,'" has an illegal brace-level-1 letter');
write(tty,'" has an illegal brace-level-1 letter');end;bstexwarnprint;
end;end;
{:406}{418:}function enoughtextchars(enoughchars:bufpointer):boolean;
begin numtextchars:=0;exbufyptr:=exbufxptr;
while((exbufyptr<exbufptr)and(numtextchars<enoughchars))do begin
exbufyptr:=exbufyptr+1;
if(exbuf[exbufyptr-1]=123)then begin bracelevel:=bracelevel+1;
if((bracelevel=1)and(exbufyptr<exbufptr))then if(exbuf[exbufyptr]=92)
then begin exbufyptr:=exbufyptr+1;
while((exbufyptr<exbufptr)and(bracelevel>0))do begin if(exbuf[exbufyptr]
=125)then bracelevel:=bracelevel-1 else if(exbuf[exbufyptr]=123)then
bracelevel:=bracelevel+1;exbufyptr:=exbufyptr+1;end;end;
end else if(exbuf[exbufyptr-1]=125)then bracelevel:=bracelevel-1;
numtextchars:=numtextchars+1;end;
if(numtextchars<enoughchars)then enoughtextchars:=false else
enoughtextchars:=true;end;
{:418}{420:}procedure figureouttheformattedname;label 15;
begin{402:}begin exbufptr:=0;spbracelevel:=0;spptr:=strstart[poplit1];
spend:=strstart[poplit1+1];
while(spptr<spend)do if(strpool[spptr]=123)then begin spbracelevel:=
spbracelevel+1;spptr:=spptr+1;{403:}begin spxptr1:=spptr;
alphafound:=false;doubleletter:=false;endofgroup:=false;
tobewritten:=true;
while((not endofgroup)and(spptr<spend))do if(lexclass[strpool[spptr]]=2)
then begin spptr:=spptr+1;
{405:}begin if(alphafound)then begin bracelvloneletterscomplaint;
tobewritten:=false;
end else begin case(strpool[spptr-1])of 102,70:{407:}begin curtoken:=
firststart;lasttoken:=firstend;
if(curtoken=lasttoken)then tobewritten:=false;
if((strpool[spptr]=102)or(strpool[spptr]=70))then doubleletter:=true;
end{:407};118,86:{408:}begin curtoken:=vonstart;lasttoken:=vonend;
if(curtoken=lasttoken)then tobewritten:=false;
if((strpool[spptr]=118)or(strpool[spptr]=86))then doubleletter:=true;
end{:408};108,76:{409:}begin curtoken:=vonend;lasttoken:=lastend;
if(curtoken=lasttoken)then tobewritten:=false;
if((strpool[spptr]=108)or(strpool[spptr]=76))then doubleletter:=true;
end{:409};106,74:{410:}begin curtoken:=lastend;lasttoken:=jrend;
if(curtoken=lasttoken)then tobewritten:=false;
if((strpool[spptr]=106)or(strpool[spptr]=74))then doubleletter:=true;
end{:410};others:begin bracelvloneletterscomplaint;tobewritten:=false;
end end;if(doubleletter)then spptr:=spptr+1;end;alphafound:=true;
end{:405};
end else if(strpool[spptr]=125)then begin spbracelevel:=spbracelevel-1;
spptr:=spptr+1;endofgroup:=true;
end else if(strpool[spptr]=123)then begin spbracelevel:=spbracelevel+1;
spptr:=spptr+1;skipstuffatspbracelevelgreaterthanone;
end else spptr:=spptr+1;
if((endofgroup)and(tobewritten))then{411:}begin exbufxptr:=exbufptr;
spptr:=spxptr1;spbracelevel:=1;
while(spbracelevel>0)do if((lexclass[strpool[spptr]]=2)and(spbracelevel=
1))then begin spptr:=spptr+1;
{412:}begin if(doubleletter)then spptr:=spptr+1;usedefault:=true;
spxptr2:=spptr;if(strpool[spptr]=123)then begin usedefault:=false;
spbracelevel:=spbracelevel+1;spptr:=spptr+1;spxptr1:=spptr;
skipstuffatspbracelevelgreaterthanone;spxptr2:=spptr-1;end;
{413:}while(curtoken<lasttoken)do begin if(doubleletter)then{414:}begin
namebfptr:=nametok[curtoken];namebfxptr:=nametok[curtoken+1];
if(exbuflength+(namebfxptr-namebfptr)>bufsize)then bufferoverflow;
while(namebfptr<namebfxptr)do begin begin exbuf[exbufptr]:=svbuffer[
namebfptr];exbufptr:=exbufptr+1;end;namebfptr:=namebfptr+1;end;
end{:414}else{415:}begin namebfptr:=nametok[curtoken];
namebfxptr:=nametok[curtoken+1];
while(namebfptr<namebfxptr)do begin if(lexclass[svbuffer[namebfptr]]=2)
then begin begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=svbuffer[namebfptr];exbufptr:=exbufptr+1;end;end;
goto 15;
end else if((svbuffer[namebfptr]=123)and(namebfptr+1<namebfxptr))then if
(svbuffer[namebfptr+1]=92)then{416:}begin if(exbufptr+2>bufsize)then
bufferoverflow;begin exbuf[exbufptr]:=123;exbufptr:=exbufptr+1;end;
begin exbuf[exbufptr]:=92;exbufptr:=exbufptr+1;end;
namebfptr:=namebfptr+2;nmbracelevel:=1;
while((namebfptr<namebfxptr)and(nmbracelevel>0))do begin if(svbuffer[
namebfptr]=125)then nmbracelevel:=nmbracelevel-1 else if(svbuffer[
namebfptr]=123)then nmbracelevel:=nmbracelevel+1;
begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=svbuffer[namebfptr];exbufptr:=exbufptr+1;end;end;
namebfptr:=namebfptr+1;end;goto 15;end{:416};namebfptr:=namebfptr+1;end;
15:end{:415};curtoken:=curtoken+1;
if(curtoken<lasttoken)then{417:}begin if(usedefault)then begin if(not
doubleletter)then begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=46;exbufptr:=exbufptr+1;end;end;
if(lexclass[namesepchar[curtoken]]=4)then begin if(exbufptr=bufsize)then
bufferoverflow;begin exbuf[exbufptr]:=namesepchar[curtoken];
exbufptr:=exbufptr+1;end;
end else if((curtoken=lasttoken-1)or(not enoughtextchars(3)))then begin
if(exbufptr=bufsize)then bufferoverflow;begin exbuf[exbufptr]:=126;
exbufptr:=exbufptr+1;end;
end else begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=32;exbufptr:=exbufptr+1;end;end;
end else begin if(exbuflength+(spxptr2-spxptr1)>bufsize)then
bufferoverflow;spptr:=spxptr1;
while(spptr<spxptr2)do begin begin exbuf[exbufptr]:=strpool[spptr];
exbufptr:=exbufptr+1;end;spptr:=spptr+1;end end;end{:417};end{:413};
if(not usedefault)then spptr:=spxptr2+1;end{:412};
end else if(strpool[spptr]=125)then begin spbracelevel:=spbracelevel-1;
spptr:=spptr+1;
if(spbracelevel>0)then begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=125;exbufptr:=exbufptr+1;end;end;
end else if(strpool[spptr]=123)then begin spbracelevel:=spbracelevel+1;
spptr:=spptr+1;begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=123;exbufptr:=exbufptr+1;end;end;
end else begin begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=strpool[spptr];exbufptr:=exbufptr+1;end;end;
spptr:=spptr+1;end;
if(exbufptr>0)then if(exbuf[exbufptr-1]=126)then{419:}begin exbufptr:=
exbufptr-1;
if(exbuf[exbufptr-1]=126)then else if(not enoughtextchars(3))then
exbufptr:=exbufptr+1 else begin exbuf[exbufptr]:=32;
exbufptr:=exbufptr+1;end;end{:419};end{:411};end{:403};
end else if(strpool[spptr]=125)then begin bracesunbalancedcomplaint(
poplit1);spptr:=spptr+1;
end else begin begin if(exbufptr=bufsize)then bufferoverflow;
begin exbuf[exbufptr]:=strpool[spptr];exbufptr:=exbufptr+1;end;end;
spptr:=spptr+1;end;
if(spbracelevel>0)then bracesunbalancedcomplaint(poplit1);
exbuflength:=exbufptr;end{:402};end;
{:420}{307:}procedure pushlitstk(pushlt:integer;pushtype:stktype);
{var dumptr:litstkloc;}begin litstack[litstkptr]:=pushlt;
litstktype[litstkptr]:=pushtype;
{for dumptr:=0 to litstkptr do begin write(logfile,'  ');end;
begin write(logfile,'Pushing ');end;
case(litstktype[litstkptr])of 0:begin writeln(logfile,litstack[litstkptr
]:0);end;1:begin begin write(logfile,'"');end;
begin outpoolstr(logfile,litstack[litstkptr]);end;
begin writeln(logfile,'"');end;end;2:begin begin write(logfile,'`');end;
begin outpoolstr(logfile,hashtext[litstack[litstkptr]]);end;
begin writeln(logfile,'''');end;end;
3:begin begin write(logfile,'missing field `');end;
begin outpoolstr(logfile,litstack[litstkptr]);end;
begin writeln(logfile,'''');end;end;
4:begin writeln(logfile,'a bad literal--popped from an empty stack');
end;others:unknwnliteralconfusion end;}
if(litstkptr=litstksize)then begin printoverflow;
begin writeln(logfile,'literal-stack size ',litstksize:0);
writeln(tty,'literal-stack size ',litstksize:0);end;goto 9998;end;
litstkptr:=litstkptr+1;end;
{:307}{309:}procedure poplitstk(var poplit:integer;var poptype:stktype);
begin if(litstkptr=0)then begin begin begin write(logfile,
'You can''t pop an empty literal stack');
write(tty,'You can''t pop an empty literal stack');end;bstexwarnprint;
end;poptype:=4;end else begin litstkptr:=litstkptr-1;
poplit:=litstack[litstkptr];poptype:=litstktype[litstkptr];
if(poptype=1)then if(poplit>=cmdstrptr)then begin if(poplit<>strptr-1)
then begin begin write(logfile,'Nontop top of string stack');
write(tty,'Nontop top of string stack');end;printconfusion;goto 9998;
end;begin strptr:=strptr-1;poolptr:=strstart[strptr];end;end;end;end;
{:309}{312:}procedure printwrongstklit(stklt:integer;
stktp1,stktp2:stktype);
begin if(stktp1<>4)then begin printstklit(stklt,stktp1);
case(stktp2)of 0:begin write(logfile,', not an integer,');
write(tty,', not an integer,');end;
1:begin write(logfile,', not a string,');write(tty,', not a string,');
end;2:begin write(logfile,', not a function,');
write(tty,', not a function,');end;3,4:illeglliteralconfusion;
others:unknwnliteralconfusion end;bstexwarnprint;end;end;
{:312}{314:}procedure poptopandprint;var stklt:integer;stktp:stktype;
begin poplitstk(stklt,stktp);
if(stktp=4)then begin writeln(logfile,'Empty literal');
writeln(tty,'Empty literal');end else printlit(stklt,stktp);end;
{:314}{315:}procedure popwholestack;
begin while(litstkptr>0)do poptopandprint;end;
{:315}{316:}procedure initcommandexecution;begin litstkptr:=0;
cmdstrptr:=strptr;end;{:316}{317:}procedure checkcommandexecution;
begin if(litstkptr<>0)then begin begin writeln(logfile,'ptr=',litstkptr:
0,', stack=');writeln(tty,'ptr=',litstkptr:0,', stack=');end;
popwholestack;
begin begin write(logfile,'---the literal stack isn''t empty');
write(tty,'---the literal stack isn''t empty');end;bstexwarnprint;end;
end;if(cmdstrptr<>strptr)then begin{begin writeln(logfile,'Pointer is ',
strptr:0,' but should be ',cmdstrptr:0);
writeln(tty,'Pointer is ',strptr:0,' but should be ',cmdstrptr:0);end;}
begin begin write(logfile,'Nonempty empty string stack');
write(tty,'Nonempty empty string stack');end;printconfusion;goto 9998;
end;end;end;{:317}{318:}procedure addpoolbufandpush;
begin begin if(poolptr+exbuflength>poolsize)then pooloverflow;end;
exbufptr:=0;
while(exbufptr<exbuflength)do begin begin strpool[poolptr]:=exbuf[
exbufptr];poolptr:=poolptr+1;end;exbufptr:=exbufptr+1;end;
pushlitstk(makestring,1);end;
{:318}{320:}procedure addbufpool(pstr:strnumber);
begin pptr1:=strstart[pstr];pptr2:=strstart[pstr+1];
if(exbuflength+(pptr2-pptr1)>bufsize)then bufferoverflow;
exbufptr:=exbuflength;
while(pptr1<pptr2)do begin begin exbuf[exbufptr]:=strpool[pptr1];
exbufptr:=exbufptr+1;end;pptr1:=pptr1+1;end;exbuflength:=exbufptr;end;
{:320}{322:}procedure addoutpool(pstr:strnumber);label 16,17;
var breakptr:bufpointer;endptr:bufpointer;breakptfound:boolean;
unbreakabletail:boolean;begin pptr1:=strstart[pstr];
pptr2:=strstart[pstr+1];
if(outbuflength+(pptr2-pptr1)>bufsize)then begin printoverflow;
begin writeln(logfile,'output buffer size ',bufsize:0);
writeln(tty,'output buffer size ',bufsize:0);end;goto 9998;end;
outbufptr:=outbuflength;
while(pptr1<pptr2)do begin outbuf[outbufptr]:=strpool[pptr1];
pptr1:=pptr1+1;outbufptr:=outbufptr+1;end;outbuflength:=outbufptr;
unbreakabletail:=false;
while((outbuflength>maxprintline)and(not unbreakabletail))do{323:}begin
endptr:=outbuflength;outbufptr:=maxprintline;breakptfound:=false;
while((lexclass[outbuf[outbufptr]]<>1)and(outbufptr>=minprintline))do
outbufptr:=outbufptr-1;
if(outbufptr=minprintline-1)then{324:}begin outbufptr:=maxprintline+1;
while(outbufptr<endptr)do if(lexclass[outbuf[outbufptr]]<>1)then
outbufptr:=outbufptr+1 else goto 16;
16:if(outbufptr=endptr)then unbreakabletail:=true else begin
breakptfound:=true;
while(outbufptr+1<endptr)do if(lexclass[outbuf[outbufptr+1]]=1)then
outbufptr:=outbufptr+1 else goto 17;17:end;
end{:324}else breakptfound:=true;
if(breakptfound)then begin outbuflength:=outbufptr;
breakptr:=outbuflength+1;outputbblline;outbuf[0]:=32;outbuf[1]:=32;
outbufptr:=2;tmpptr:=breakptr;
while(tmpptr<endptr)do begin outbuf[outbufptr]:=outbuf[tmpptr];
outbufptr:=outbufptr+1;tmpptr:=tmpptr+1;end;
outbuflength:=endptr-breakptr+2;end;end{:323};end;
{:322}{342:}{345:}procedure xequals;begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);
if(poptyp1<>poptyp2)then begin if((poptyp1<>4)and(poptyp2<>4))then begin
printstklit(poplit1,poptyp1);begin write(logfile,', ');write(tty,', ');
end;printstklit(poplit2,poptyp2);printanewline;
begin begin write(logfile,'---they aren''t the same literal types');
write(tty,'---they aren''t the same literal types');end;bstexwarnprint;
end;end;pushlitstk(0,0);
end else if((poptyp1<>0)and(poptyp1<>1))then begin if(poptyp1<>4)then
begin printstklit(poplit1,poptyp1);
begin begin write(logfile,', not an integer or a string,');
write(tty,', not an integer or a string,');end;bstexwarnprint;end;end;
pushlitstk(0,0);
end else if(poptyp1=0)then if(poplit2=poplit1)then pushlitstk(1,0)else
pushlitstk(0,0)else if(streqstr(poplit2,poplit1))then pushlitstk(1,0)
else pushlitstk(0,0);end;{:345}{346:}procedure xgreaterthan;
begin poplitstk(poplit1,poptyp1);poplitstk(poplit2,poptyp2);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(0,0);
end else if(poptyp2<>0)then begin printwrongstklit(poplit2,poptyp2,0);
pushlitstk(0,0);
end else if(poplit2>poplit1)then pushlitstk(1,0)else pushlitstk(0,0);
end;{:346}{347:}procedure xlessthan;begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(0,0);
end else if(poptyp2<>0)then begin printwrongstklit(poplit2,poptyp2,0);
pushlitstk(0,0);
end else if(poplit2<poplit1)then pushlitstk(1,0)else pushlitstk(0,0);
end;{:347}{348:}procedure xplus;begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(0,0);
end else if(poptyp2<>0)then begin printwrongstklit(poplit2,poptyp2,0);
pushlitstk(0,0);end else pushlitstk(poplit2+poplit1,0);end;
{:348}{349:}procedure xminus;begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(0,0);
end else if(poptyp2<>0)then begin printwrongstklit(poplit2,poptyp2,0);
pushlitstk(0,0);end else pushlitstk(poplit2-poplit1,0);end;
{:349}{350:}procedure xconcatenate;begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(snull,1);
end else if(poptyp2<>1)then begin printwrongstklit(poplit2,poptyp2,1);
pushlitstk(snull,1);
end else{351:}begin if(poplit2>=cmdstrptr)then if(poplit1>=cmdstrptr)
then begin strstart[poplit1]:=strstart[poplit1+1];
begin strptr:=strptr+1;poolptr:=strstart[strptr];end;
litstkptr:=litstkptr+1;
end else if((strstart[poplit2+1]-strstart[poplit2])=0)then pushlitstk(
poplit1,1)else begin poolptr:=strstart[poplit2+1];
begin if(poolptr+(strstart[poplit1+1]-strstart[poplit1])>poolsize)then
pooloverflow;end;spptr:=strstart[poplit1];spend:=strstart[poplit1+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;pushlitstk(makestring,1);
end else{352:}begin if(poplit1>=cmdstrptr)then if((strstart[poplit2+1]-
strstart[poplit2])=0)then begin begin strptr:=strptr+1;
poolptr:=strstart[strptr];end;litstack[litstkptr]:=poplit1;
litstkptr:=litstkptr+1;
end else if((strstart[poplit1+1]-strstart[poplit1])=0)then litstkptr:=
litstkptr+1 else begin splength:=(strstart[poplit1+1]-strstart[poplit1])
;sp2length:=(strstart[poplit2+1]-strstart[poplit2]);
begin if(poolptr+splength+sp2length>poolsize)then pooloverflow;end;
spptr:=strstart[poplit1+1];spend:=strstart[poplit1];
spxptr1:=spptr+sp2length;while(spptr>spend)do begin spptr:=spptr-1;
spxptr1:=spxptr1-1;strpool[spxptr1]:=strpool[spptr];end;
spptr:=strstart[poplit2];spend:=strstart[poplit2+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;poolptr:=poolptr+splength;
pushlitstk(makestring,1);
end else{353:}begin if((strstart[poplit1+1]-strstart[poplit1])=0)then
litstkptr:=litstkptr+1 else if((strstart[poplit2+1]-strstart[poplit2])=0
)then pushlitstk(poplit1,1)else begin begin if(poolptr+(strstart[poplit1
+1]-strstart[poplit1])+(strstart[poplit2+1]-strstart[poplit2])>poolsize)
then pooloverflow;end;spptr:=strstart[poplit2];
spend:=strstart[poplit2+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;spptr:=strstart[poplit1];
spend:=strstart[poplit1+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;pushlitstk(makestring,1);end;
end{:353};end{:352};end{:351};end;{:350}{354:}procedure xgets;
begin poplitstk(poplit1,poptyp1);poplitstk(poplit2,poptyp2);
if(poptyp1<>2)then printwrongstklit(poplit1,poptyp1,2)else if((not
messwithentries)and((fntype[poplit1]=6)or(fntype[poplit1]=5)))then
bstcantmesswithentriesprint else case(fntype[poplit1])of 5:{355:}if(
poptyp2<>0)then printwrongstklit(poplit2,poptyp2,0)else entryints[
citeptr*numentints+ilkinfo[poplit1]]:=poplit2{:355};
6:{357:}begin if(poptyp2<>1)then printwrongstklit(poplit2,poptyp2,1)else
begin strentptr:=citeptr*numentstrs+ilkinfo[poplit1];entchrptr:=0;
spptr:=strstart[poplit2];spxptr1:=strstart[poplit2+1];
if(spxptr1-spptr>entstrsize)then begin begin bst1printstringsizeexceeded
;begin write(logfile,entstrsize:0,', the entry');
write(tty,entstrsize:0,', the entry');end;bst2printstringsizeexceeded;
end;spxptr1:=spptr+entstrsize;end;
while(spptr<spxptr1)do begin entrystrs[strentptr][entchrptr]:=strpool[
spptr];entchrptr:=entchrptr+1;spptr:=spptr+1;end;
entrystrs[strentptr][entchrptr]:=127;end end{:357};
7:{358:}if(poptyp2<>0)then printwrongstklit(poplit2,poptyp2,0)else
ilkinfo[poplit1]:=poplit2{:358};
8:{359:}begin if(poptyp2<>1)then printwrongstklit(poplit2,poptyp2,1)else
begin strglbptr:=ilkinfo[poplit1];
if(poplit2<cmdstrptr)then glbstrptr[strglbptr]:=poplit2 else begin
glbstrptr[strglbptr]:=0;globchrptr:=0;spptr:=strstart[poplit2];
spend:=strstart[poplit2+1];
if(spend-spptr>globstrsize)then begin begin bst1printstringsizeexceeded;
begin write(logfile,globstrsize:0,', the global');
write(tty,globstrsize:0,', the global');end;bst2printstringsizeexceeded;
end;spend:=spptr+globstrsize;end;
while(spptr<spend)do begin globalstrs[strglbptr][globchrptr]:=strpool[
spptr];globchrptr:=globchrptr+1;spptr:=spptr+1;end;
glbstrend[strglbptr]:=globchrptr;end;end end{:359};
others:begin begin write(logfile,'You can''t assign to type ');
write(tty,'You can''t assign to type ');end;printfnclass(poplit1);
begin begin write(logfile,', a nonvariable function class');
write(tty,', a nonvariable function class');end;bstexwarnprint;end;
end end;end;{:354}{360:}procedure xaddperiod;label 15;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(snull,1);
end else if((strstart[poplit1+1]-strstart[poplit1])=0)then pushlitstk(
snull,1)else{361:}begin spptr:=strstart[poplit1+1];
spend:=strstart[poplit1];while(spptr>spend)do begin spptr:=spptr-1;
if(strpool[spptr]<>125)then goto 15;end;
15:case(strpool[spptr])of 46,63,33:begin if(litstack[litstkptr]>=
cmdstrptr)then begin strptr:=strptr+1;poolptr:=strstart[strptr];end;
litstkptr:=litstkptr+1;end;
others:{362:}begin if(poplit1<cmdstrptr)then begin begin if(poolptr+(
strstart[poplit1+1]-strstart[poplit1])+1>poolsize)then pooloverflow;end;
spptr:=strstart[poplit1];spend:=strstart[poplit1+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;
end else begin poolptr:=strstart[poplit1+1];
begin if(poolptr+1>poolsize)then pooloverflow;end;end;
begin strpool[poolptr]:=46;poolptr:=poolptr+1;end;
pushlitstk(makestring,1);end{:362}end;end{:361};end;
{:360}{364:}procedure xchangecase;label 21;
begin poplitstk(poplit1,poptyp1);poplitstk(poplit2,poptyp2);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(snull,1);
end else if(poptyp2<>1)then begin printwrongstklit(poplit2,poptyp2,1);
pushlitstk(snull,1);
end else begin{366:}begin case(strpool[strstart[poplit1]])of 116,84:
conversiontype:=0;108,76:conversiontype:=1;117,85:conversiontype:=2;
others:conversiontype:=3 end;
if(((strstart[poplit1+1]-strstart[poplit1])<>1)or(conversiontype=3))then
begin conversiontype:=3;printapoolstr(poplit1);
begin begin write(logfile,' is an illegal case-conversion string');
write(tty,' is an illegal case-conversion string');end;bstexwarnprint;
end;end;end{:366};exbuflength:=0;addbufpool(poplit2);
{370:}begin bracelevel:=0;exbufptr:=0;
while(exbufptr<exbuflength)do begin if(exbuf[exbufptr]=123)then begin
bracelevel:=bracelevel+1;if(bracelevel<>1)then goto 21;
if(exbufptr+4>exbuflength)then goto 21 else if(exbuf[exbufptr+1]<>92)
then goto 21;
if(conversiontype=0)then if(exbufptr=0)then goto 21 else if((prevcolon)
and(lexclass[exbuf[exbufptr-1]]=1))then goto 21;
{371:}begin exbufptr:=exbufptr+1;
while((exbufptr<exbuflength)and(bracelevel>0))do begin exbufptr:=
exbufptr+1;exbufxptr:=exbufptr;
while((exbufptr<exbuflength)and(lexclass[exbuf[exbufptr]]=2))do exbufptr
:=exbufptr+1;
controlseqloc:=strlookup(exbuf,exbufxptr,exbufptr-exbufxptr,14,false);
if(hashfound)then{372:}begin case(conversiontype)of 0,1:case(ilkinfo[
controlseqloc])of 11,9,3,5,7:lowercase(exbuf,exbufxptr,exbufptr-
exbufxptr);others:end;
2:case(ilkinfo[controlseqloc])of 10,8,2,4,6:uppercase(exbuf,exbufxptr,
exbufptr-exbufxptr);
0,1,12:{374:}begin uppercase(exbuf,exbufxptr,exbufptr-exbufxptr);
while(exbufxptr<exbufptr)do begin exbuf[exbufxptr-1]:=exbuf[exbufxptr];
exbufxptr:=exbufxptr+1;end;exbufxptr:=exbufxptr-1;
while((exbufptr<exbuflength)and(lexclass[exbuf[exbufptr]]=1))do exbufptr
:=exbufptr+1;tmpptr:=exbufptr;
while(tmpptr<exbuflength)do begin exbuf[tmpptr-(exbufptr-exbufxptr)]:=
exbuf[tmpptr];tmpptr:=tmpptr+1 end;
exbuflength:=tmpptr-(exbufptr-exbufxptr);exbufptr:=exbufxptr;end{:374};
others:end;3:;others:caseconversionconfusion end;end{:372};
exbufxptr:=exbufptr;
while((exbufptr<exbuflength)and(bracelevel>0)and(exbuf[exbufptr]<>92))do
begin if(exbuf[exbufptr]=125)then bracelevel:=bracelevel-1 else if(exbuf
[exbufptr]=123)then bracelevel:=bracelevel+1;exbufptr:=exbufptr+1;end;
{375:}begin case(conversiontype)of 0,1:lowercase(exbuf,exbufxptr,
exbufptr-exbufxptr);2:uppercase(exbuf,exbufxptr,exbufptr-exbufxptr);3:;
others:caseconversionconfusion end;end{:375};end;exbufptr:=exbufptr-1;
end{:371};21:prevcolon:=false;
end else if(exbuf[exbufptr]=125)then begin decrbracelevel(poplit2);
prevcolon:=false;
end else if(bracelevel=0)then{376:}begin case(conversiontype)of 0:begin
if(exbufptr=0)then else if((prevcolon)and(lexclass[exbuf[exbufptr-1]]=1)
)then else lowercase(exbuf,exbufptr,1);
if(exbuf[exbufptr]=58)then prevcolon:=true else if(lexclass[exbuf[
exbufptr]]<>1)then prevcolon:=false;end;1:lowercase(exbuf,exbufptr,1);
2:uppercase(exbuf,exbufptr,1);3:;others:caseconversionconfusion end;
end{:376};exbufptr:=exbufptr+1;end;checkbracelevel(poplit2);end{:370};
addpoolbufandpush;end;end;{:364}{377:}procedure xchrtoint;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(0,0);
end else if((strstart[poplit1+1]-strstart[poplit1])<>1)then begin begin
write(logfile,'"');write(tty,'"');end;printapoolstr(poplit1);
begin begin write(logfile,'" isn''t a single character');
write(tty,'" isn''t a single character');end;bstexwarnprint;end;
pushlitstk(0,0);end else pushlitstk(strpool[strstart[poplit1]],0);end;
{:377}{378:}procedure xcite;
begin if(not messwithentries)then bstcantmesswithentriesprint else
pushlitstk(citelist[citeptr],1);end;{:378}{379:}procedure xduplicate;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin pushlitstk(poplit1,poptyp1);
pushlitstk(poplit1,poptyp1);
end else begin begin if(litstack[litstkptr]>=cmdstrptr)then begin strptr
:=strptr+1;poolptr:=strstart[strptr];end;litstkptr:=litstkptr+1;end;
if(poplit1<cmdstrptr)then pushlitstk(poplit1,poptyp1)else begin begin if
(poolptr+(strstart[poplit1+1]-strstart[poplit1])>poolsize)then
pooloverflow;end;spptr:=strstart[poplit1];spend:=strstart[poplit1+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;pushlitstk(makestring,1);end;
end;end;{:379}{380:}procedure xempty;label 10;
begin poplitstk(poplit1,poptyp1);
case(poptyp1)of 1:{381:}begin spptr:=strstart[poplit1];
spend:=strstart[poplit1+1];
while(spptr<spend)do begin if(lexclass[strpool[spptr]]<>1)then begin
pushlitstk(0,0);goto 10;end;spptr:=spptr+1;end;pushlitstk(1,0);
end{:381};3:pushlitstk(1,0);4:pushlitstk(0,0);
others:begin printstklit(poplit1,poptyp1);
begin begin write(logfile,', not a string or missing field,');
write(tty,', not a string or missing field,');end;bstexwarnprint;end;
pushlitstk(0,0);end end;10:end;{:380}{382:}procedure xformatname;
label 16,17,52;begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);poplitstk(poplit3,poptyp3);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(snull,1);
end else if(poptyp2<>0)then begin printwrongstklit(poplit2,poptyp2,0);
pushlitstk(snull,1);
end else if(poptyp3<>1)then begin printwrongstklit(poplit3,poptyp3,1);
pushlitstk(snull,1);end else begin exbuflength:=0;addbufpool(poplit3);
{383:}begin exbufptr:=0;numnames:=0;
while((numnames<poplit2)and(exbufptr<exbuflength))do begin numnames:=
numnames+1;exbufxptr:=exbufptr;namescanforand(poplit3);end;
if(exbufptr<exbuflength)then exbufptr:=exbufptr-4;
if(numnames<poplit2)then begin if(poplit2=1)then begin write(logfile,
'There is no name in "');write(tty,'There is no name in "');
end else begin write(logfile,'There aren''t ',poplit2:0,' names in "');
write(tty,'There aren''t ',poplit2:0,' names in "');end;
printapoolstr(poplit3);begin begin write(logfile,'"');write(tty,'"');
end;bstexwarnprint;end;end end{:383};
{387:}begin{388:}begin while((exbufxptr<exbufptr)and(lexclass[exbuf[
exbufptr]]=1)and(lexclass[exbuf[exbufptr]]=4))do exbufxptr:=exbufxptr+1;
while(exbufptr>exbufxptr)do case(lexclass[exbuf[exbufptr-1]])of 1,4:
exbufptr:=exbufptr-1;
others:if(exbuf[exbufptr-1]=44)then begin begin write(logfile,'Name ',
poplit2:0,' in "');write(tty,'Name ',poplit2:0,' in "');end;
printapoolstr(poplit3);begin write(logfile,'" has a comma at the end');
write(tty,'" has a comma at the end');end;bstexwarnprint;
exbufptr:=exbufptr-1;end else goto 16 end;16:end{:388};namebfptr:=0;
numcommas:=0;numtokens:=0;tokenstarting:=true;
while(exbufxptr<exbufptr)do case(exbuf[exbufxptr])of 44:{389:}begin if(
numcommas=2)then begin begin write(logfile,'Too many commas in name ',
poplit2:0,' of "');
write(tty,'Too many commas in name ',poplit2:0,' of "');end;
printapoolstr(poplit3);begin write(logfile,'"');write(tty,'"');end;
bstexwarnprint;end else begin numcommas:=numcommas+1;
if(numcommas=1)then comma1:=numtokens else comma2:=numtokens;
namesepchar[numtokens]:=44;end;exbufxptr:=exbufxptr+1;
tokenstarting:=true;end{:389};123:{390:}begin bracelevel:=bracelevel+1;
if(tokenstarting)then begin nametok[numtokens]:=namebfptr;
numtokens:=numtokens+1;end;svbuffer[namebfptr]:=exbuf[exbufxptr];
namebfptr:=namebfptr+1;exbufxptr:=exbufxptr+1;
while((bracelevel>0)and(exbufxptr<exbufptr))do begin if(exbuf[exbufxptr]
=125)then bracelevel:=bracelevel-1 else if(exbuf[exbufxptr]=123)then
bracelevel:=bracelevel+1;svbuffer[namebfptr]:=exbuf[exbufxptr];
namebfptr:=namebfptr+1;exbufxptr:=exbufxptr+1;end;tokenstarting:=false;
end{:390};
125:{391:}begin if(tokenstarting)then begin nametok[numtokens]:=
namebfptr;numtokens:=numtokens+1;end;
begin write(logfile,'Name ',poplit2:0,' of "');
write(tty,'Name ',poplit2:0,' of "');end;printapoolstr(poplit3);
begin begin write(logfile,'" isn''t brace balanced');
write(tty,'" isn''t brace balanced');end;bstexwarnprint;end;
exbufxptr:=exbufxptr+1;tokenstarting:=false;end{:391};
others:case(lexclass[exbuf[exbufxptr]])of 1:{392:}begin if(not
tokenstarting)then namesepchar[numtokens]:=32;exbufxptr:=exbufxptr+1;
tokenstarting:=true;end{:392};
4:{393:}begin if(not tokenstarting)then namesepchar[numtokens]:=exbuf[
exbufxptr];exbufxptr:=exbufxptr+1;tokenstarting:=true;end{:393};
others:{394:}begin if(tokenstarting)then begin nametok[numtokens]:=
namebfptr;numtokens:=numtokens+1;end;
svbuffer[namebfptr]:=exbuf[exbufxptr];namebfptr:=namebfptr+1;
exbufxptr:=exbufxptr+1;tokenstarting:=false;end{:394}end end;
nametok[numtokens]:=namebfptr;end{:387};
{395:}begin if(numcommas=0)then begin firststart:=0;lastend:=numtokens;
jrend:=lastend;{396:}begin vonstart:=0;
while(vonstart<lastend-1)do begin namebfptr:=nametok[vonstart];
namebfxptr:=nametok[vonstart+1];
if(vontokenfound)then begin vonnameendsandlastnamestartsstuff;goto 52;
end;vonstart:=vonstart+1;end;
while(vonstart>0)do begin if((lexclass[namesepchar[vonstart]]<>4)or(
namesepchar[vonstart]=126))then goto 17;vonstart:=vonstart-1;end;
17:vonend:=vonstart;52:firstend:=vonstart;end{:396};
end else if(numcommas=1)then begin vonstart:=0;lastend:=comma1;
jrend:=lastend;firststart:=jrend;firstend:=numtokens;
vonnameendsandlastnamestartsstuff;
end else if(numcommas=2)then begin vonstart:=0;lastend:=comma1;
jrend:=comma2;firststart:=jrend;firstend:=numtokens;
vonnameendsandlastnamestartsstuff;
end else begin begin write(logfile,'Illegal number of comma,s');
write(tty,'Illegal number of comma,s');end;printconfusion;goto 9998;end;
end{:395};exbuflength:=0;addbufpool(poplit1);figureouttheformattedname;
addpoolbufandpush;end;end;{:382}{422:}procedure xinttochr;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(snull,1);
end else if((poplit1<0)or(poplit1>127))then begin begin begin write(
logfile,poplit1:0,' isn''t valid ASCII');
write(tty,poplit1:0,' isn''t valid ASCII');end;bstexwarnprint;end;
pushlitstk(snull,1);
end else begin begin if(poolptr+1>poolsize)then pooloverflow;end;
begin strpool[poolptr]:=poplit1;poolptr:=poolptr+1;end;
pushlitstk(makestring,1);end;end;{:422}{423:}procedure xinttostr;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(snull,1);
end else begin inttoASCII(poplit1,exbuf,0,exbuflength);
addpoolbufandpush;end;end;{:423}{424:}procedure xmissing;
begin poplitstk(poplit1,poptyp1);
if(not messwithentries)then bstcantmesswithentriesprint else if((poptyp1
<>1)and(poptyp1<>3))then begin if(poptyp1<>4)then begin printstklit(
poplit1,poptyp1);
begin begin write(logfile,', not a string or missing field,');
write(tty,', not a string or missing field,');end;bstexwarnprint;end;
end;pushlitstk(0,0);
end else if(poptyp1=3)then pushlitstk(1,0)else pushlitstk(0,0);end;
{:424}{426:}procedure xnumnames;begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(0,0);end else begin exbuflength:=0;addbufpool(poplit1);
{427:}begin exbufptr:=0;numnames:=0;
while(exbufptr<exbuflength)do begin namescanforand(poplit1);
numnames:=numnames+1;end;end{:427};pushlitstk(numnames,0);end;end;
{:426}{429:}procedure xpreamble;begin exbuflength:=0;preambleptr:=0;
while(preambleptr<numpreamblestrings)do begin addbufpool(spreamble[
preambleptr]);preambleptr:=preambleptr+1;end;addpoolbufandpush;end;
{:429}{430:}procedure xpurify;begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(snull,1);end else begin exbuflength:=0;addbufpool(poplit1);
{431:}begin bracelevel:=0;exbufxptr:=0;exbufptr:=0;
while(exbufptr<exbuflength)do begin case(lexclass[exbuf[exbufptr]])of 1,
4:begin exbuf[exbufxptr]:=32;exbufxptr:=exbufxptr+1;end;
2,3:begin exbuf[exbufxptr]:=exbuf[exbufptr];exbufxptr:=exbufxptr+1;end;
others:if(exbuf[exbufptr]=123)then begin bracelevel:=bracelevel+1;
if((bracelevel=1)and(exbufptr+1<exbuflength))then if(exbuf[exbufptr+1]=
92)then{432:}begin exbufptr:=exbufptr+1;
while((exbufptr<exbuflength)and(bracelevel>0))do begin exbufptr:=
exbufptr+1;exbufyptr:=exbufptr;
while((exbufptr<exbuflength)and(lexclass[exbuf[exbufptr]]=2))do exbufptr
:=exbufptr+1;
controlseqloc:=strlookup(exbuf,exbufyptr,exbufptr-exbufyptr,14,false);
if(hashfound)then{433:}begin exbuf[exbufxptr]:=exbuf[exbufyptr];
exbufxptr:=exbufxptr+1;
case(ilkinfo[controlseqloc])of 2,3,4,5,12:begin exbuf[exbufxptr]:=exbuf[
exbufyptr+1];exbufxptr:=exbufxptr+1;end;others:end;end{:433};
while((exbufptr<exbuflength)and(bracelevel>0)and(exbuf[exbufptr]<>92))do
begin case(lexclass[exbuf[exbufptr]])of 2,3:begin exbuf[exbufxptr]:=
exbuf[exbufptr];exbufxptr:=exbufxptr+1;end;
others:if(exbuf[exbufptr]=125)then bracelevel:=bracelevel-1 else if(
exbuf[exbufptr]=123)then bracelevel:=bracelevel+1 end;
exbufptr:=exbufptr+1;end;end;exbufptr:=exbufptr-1;end{:432};
end else if(exbuf[exbufptr]=125)then if(bracelevel>0)then bracelevel:=
bracelevel-1 end;exbufptr:=exbufptr+1;end;exbuflength:=exbufxptr;
end{:431};addpoolbufandpush;end;end;{:430}{434:}procedure xquote;
begin begin if(poolptr+1>poolsize)then pooloverflow;end;
begin strpool[poolptr]:=34;poolptr:=poolptr+1;end;
pushlitstk(makestring,1);end;{:434}{437:}procedure xsubstring;label 10;
begin poplitstk(poplit1,poptyp1);poplitstk(poplit2,poptyp2);
poplitstk(poplit3,poptyp3);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(snull,1);
end else if(poptyp2<>0)then begin printwrongstklit(poplit2,poptyp2,0);
pushlitstk(snull,1);
end else if(poptyp3<>1)then begin printwrongstklit(poplit3,poptyp3,1);
pushlitstk(snull,1);
end else begin splength:=(strstart[poplit3+1]-strstart[poplit3]);
if(poplit1>=splength)then if((poplit2=1)or(poplit2=-1))then begin begin
if(litstack[litstkptr]>=cmdstrptr)then begin strptr:=strptr+1;
poolptr:=strstart[strptr];end;litstkptr:=litstkptr+1;end;goto 10;end;
if((poplit1<=0)or(poplit2=0)or(poplit2>splength)or(poplit2<-splength))
then begin pushlitstk(snull,1);goto 10;
end else{438:}begin if(poplit2>0)then begin if(poplit1>splength-(poplit2
-1))then poplit1:=splength-(poplit2-1);
spptr:=strstart[poplit3]+(poplit2-1);spend:=spptr+poplit1;
if(poplit2=1)then if(poplit3>=cmdstrptr)then begin strstart[poplit3+1]:=
spend;begin strptr:=strptr+1;poolptr:=strstart[strptr];end;
litstkptr:=litstkptr+1;goto 10;end;end else begin poplit2:=-poplit2;
if(poplit1>splength-(poplit2-1))then poplit1:=splength-(poplit2-1);
spend:=strstart[poplit3+1]-(poplit2-1);spptr:=spend-poplit1;end;
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;pushlitstk(makestring,1);
end{:438};end;10:end;{:437}{439:}procedure xswap;
begin poplitstk(poplit1,poptyp1);poplitstk(poplit2,poptyp2);
if((poptyp1<>1)or(poplit1<cmdstrptr))then begin pushlitstk(poplit1,
poptyp1);
if((poptyp2=1)and(poplit2>=cmdstrptr))then begin strptr:=strptr+1;
poolptr:=strstart[strptr];end;pushlitstk(poplit2,poptyp2);
end else if((poptyp2<>1)or(poplit2<cmdstrptr))then begin begin strptr:=
strptr+1;poolptr:=strstart[strptr];end;pushlitstk(poplit1,1);
pushlitstk(poplit2,poptyp2);end else{440:}begin exbuflength:=0;
addbufpool(poplit2);spptr:=strstart[poplit1];spend:=strstart[poplit1+1];
while(spptr<spend)do begin begin strpool[poolptr]:=strpool[spptr];
poolptr:=poolptr+1;end;spptr:=spptr+1;end;pushlitstk(makestring,1);
addpoolbufandpush;end{:440};end;{:439}{441:}procedure xtextlength;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(snull,1);end else begin numtextchars:=0;
{442:}begin spptr:=strstart[poplit1];spend:=strstart[poplit1+1];
spbracelevel:=0;while(spptr<spend)do begin spptr:=spptr+1;
if(strpool[spptr-1]=123)then begin spbracelevel:=spbracelevel+1;
if((spbracelevel=1)and(spptr<spend))then if(strpool[spptr]=92)then begin
spptr:=spptr+1;
while((spptr<spend)and(spbracelevel>0))do begin if(strpool[spptr]=125)
then spbracelevel:=spbracelevel-1 else if(strpool[spptr]=123)then
spbracelevel:=spbracelevel+1;spptr:=spptr+1;end;
numtextchars:=numtextchars+1;end;
end else if(strpool[spptr-1]=125)then begin if(spbracelevel>0)then
spbracelevel:=spbracelevel-1;end else numtextchars:=numtextchars+1;end;
end{:442};pushlitstk(numtextchars,0);end;end;
{:441}{443:}procedure xtextprefix;label 10;
begin poplitstk(poplit1,poptyp1);poplitstk(poplit2,poptyp2);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);
pushlitstk(snull,1);
end else if(poptyp2<>1)then begin printwrongstklit(poplit2,poptyp2,1);
pushlitstk(snull,1);
end else if(poplit1<=0)then begin pushlitstk(snull,1);goto 10;
end else{444:}begin spptr:=strstart[poplit2];spend:=strstart[poplit2+1];
{445:}begin numtextchars:=0;spbracelevel:=0;spxptr1:=spptr;
while((spxptr1<spend)and(numtextchars<poplit1))do begin spxptr1:=spxptr1
+1;if(strpool[spxptr1-1]=123)then begin spbracelevel:=spbracelevel+1;
if((spbracelevel=1)and(spxptr1<spend))then if(strpool[spxptr1]=92)then
begin spxptr1:=spxptr1+1;
while((spxptr1<spend)and(spbracelevel>0))do begin if(strpool[spxptr1]=
125)then spbracelevel:=spbracelevel-1 else if(strpool[spxptr1]=123)then
spbracelevel:=spbracelevel+1;spxptr1:=spxptr1+1;end;
numtextchars:=numtextchars+1;end;
end else if(strpool[spxptr1-1]=125)then begin if(spbracelevel>0)then
spbracelevel:=spbracelevel-1;end else numtextchars:=numtextchars+1;end;
spend:=spxptr1;end{:445};
if(poplit2>=cmdstrptr)then poolptr:=spend else while(spptr<spend)do
begin begin strpool[poolptr]:=strpool[spptr];poolptr:=poolptr+1;end;
spptr:=spptr+1;end;
while(spbracelevel>0)do begin begin strpool[poolptr]:=125;
poolptr:=poolptr+1;end;spbracelevel:=spbracelevel-1;end;
pushlitstk(makestring,1);end{:444};10:end;{:443}{447:}procedure xtype;
begin if(not messwithentries)then bstcantmesswithentriesprint else if((
typelist[citeptr]=5001)or(typelist[citeptr]=0))then pushlitstk(snull,1)
else pushlitstk(hashtext[typelist[citeptr]],1);end;
{:447}{448:}procedure xwarning;begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then printwrongstklit(poplit1,poptyp1,1)else begin begin
write(logfile,'Warning--');write(tty,'Warning--');end;
printlit(poplit1,poptyp1);markwarning;end;end;
{:448}{450:}procedure xwidth;begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then begin printwrongstklit(poplit1,poptyp1,1);
pushlitstk(0,0);end else begin exbuflength:=0;addbufpool(poplit1);
stringwidth:=0;{451:}begin bracelevel:=0;exbufptr:=0;
while(exbufptr<exbuflength)do begin if(exbuf[exbufptr]=123)then begin
bracelevel:=bracelevel+1;
if((bracelevel=1)and(exbufptr+1<exbuflength))then if(exbuf[exbufptr+1]=
92)then{452:}begin exbufptr:=exbufptr+1;
while((exbufptr<exbuflength)and(bracelevel>0))do begin exbufptr:=
exbufptr+1;exbufxptr:=exbufptr;
while((exbufptr<exbuflength)and(lexclass[exbuf[exbufptr]]=2))do exbufptr
:=exbufptr+1;
if((exbufptr<exbuflength)and(exbufptr=exbufxptr))then exbufptr:=exbufptr
+1 else begin controlseqloc:=strlookup(exbuf,exbufxptr,exbufptr-
exbufxptr,14,false);
if(hashfound)then{453:}begin case(ilkinfo[controlseqloc])of 12:
stringwidth:=stringwidth+500;4:stringwidth:=stringwidth+722;
2:stringwidth:=stringwidth+778;5:stringwidth:=stringwidth+903;
3:stringwidth:=stringwidth+1014;
others:stringwidth:=stringwidth+charwidth[exbuf[exbufxptr]]end;
end{:453};end;
while((exbufptr<exbuflength)and(lexclass[exbuf[exbufptr]]=1))do exbufptr
:=exbufptr+1;
while((exbufptr<exbuflength)and(bracelevel>0)and(exbuf[exbufptr]<>92))do
begin if(exbuf[exbufptr]=125)then bracelevel:=bracelevel-1 else if(exbuf
[exbufptr]=123)then bracelevel:=bracelevel+1 else stringwidth:=
stringwidth+charwidth[exbuf[exbufptr]];exbufptr:=exbufptr+1;end;end;
exbufptr:=exbufptr-1;
end{:452}else stringwidth:=stringwidth+charwidth[123]else stringwidth:=
stringwidth+charwidth[123];
end else if(exbuf[exbufptr]=125)then begin decrbracelevel(poplit1);
stringwidth:=stringwidth+charwidth[125];
end else stringwidth:=stringwidth+charwidth[exbuf[exbufptr]];
exbufptr:=exbufptr+1;end;checkbracelevel(poplit1);end{:451};
pushlitstk(stringwidth,0);end end;{:450}{454:}procedure xwrite;
begin poplitstk(poplit1,poptyp1);
if(poptyp1<>1)then printwrongstklit(poplit1,poptyp1,1)else addoutpool(
poplit1);end;{:454}{325:}procedure executefn(exfnloc:hashloc);
{343:}label 51;var rpoplt1,rpoplt2:integer;rpoptp1,rpoptp2:stktype;
{:343}wizptr:wizfnloc;begin{begin write(logfile,'execute_fn `');end;
begin outpoolstr(logfile,hashtext[exfnloc]);end;
begin writeln(logfile,'''');end;}
case(fntype[exfnloc])of 0:{341:}begin{executioncount[ilkinfo[exfnloc]]:=
executioncount[ilkinfo[exfnloc]]+1;}case(ilkinfo[exfnloc])of 0:xequals;
1:xgreaterthan;2:xlessthan;3:xplus;4:xminus;5:xconcatenate;6:xgets;
7:xaddperiod;
8:{363:}begin if(not messwithentries)then bstcantmesswithentriesprint
else if(typelist[citeptr]=5001)then executefn(bdefault)else if(typelist[
citeptr]=0)then else executefn(typelist[citeptr]);end{:363};
9:xchangecase;10:xchrtoint;11:xcite;12:xduplicate;13:xempty;
14:xformatname;15:{421:}begin poplitstk(poplit1,poptyp1);
poplitstk(poplit2,poptyp2);poplitstk(poplit3,poptyp3);
if(poptyp1<>2)then printwrongstklit(poplit1,poptyp1,2)else if(poptyp2<>2
)then printwrongstklit(poplit2,poptyp2,2)else if(poptyp3<>0)then
printwrongstklit(poplit3,poptyp3,0)else if(poplit3>0)then executefn(
poplit2)else executefn(poplit1);end{:421};16:xinttochr;17:xinttostr;
18:xmissing;19:{425:}begin outputbblline;end{:425};20:xnumnames;
21:{428:}begin poplitstk(poplit1,poptyp1);end{:428};22:xpreamble;
23:xpurify;24:xquote;25:{435:}begin;end{:435};
26:{436:}begin popwholestack;end{:436};27:xsubstring;28:xswap;
29:xtextlength;30:xtextprefix;31:{446:}begin poptopandprint;end{:446};
32:xtype;33:xwarning;34:{449:}begin poplitstk(rpoplt1,rpoptp1);
poplitstk(rpoplt2,rpoptp2);
if(rpoptp1<>2)then printwrongstklit(rpoplt1,rpoptp1,2)else if(rpoptp2<>2
)then printwrongstklit(rpoplt2,rpoptp2,2)else while true do begin
executefn(rpoplt2);poplitstk(poplit1,poptyp1);
if(poptyp1<>0)then begin printwrongstklit(poplit1,poptyp1,0);goto 51;
end else if(poplit1>0)then executefn(rpoplt1)else goto 51;end;
51:end{:449};35:xwidth;36:xwrite;
others:begin begin write(logfile,'Unknown built-in function');
write(tty,'Unknown built-in function');end;printconfusion;goto 9998;
end end;end{:341};1:{326:}begin wizptr:=ilkinfo[exfnloc];
while(wizfunctions[wizptr]<>5001)do begin if(wizfunctions[wizptr]<>0)
then executefn(wizfunctions[wizptr])else begin wizptr:=wizptr+1;
pushlitstk(wizfunctions[wizptr],2);end;wizptr:=wizptr+1;end;end{:326};
2:pushlitstk(ilkinfo[exfnloc],0);3:pushlitstk(hashtext[exfnloc],1);
4:{327:}begin if(not messwithentries)then bstcantmesswithentriesprint
else begin fieldptr:=citeptr*numfields+ilkinfo[exfnloc];
if(fieldinfo[fieldptr]=0)then pushlitstk(hashtext[exfnloc],3)else
pushlitstk(fieldinfo[fieldptr],1);end end{:327};
5:{328:}begin if(not messwithentries)then bstcantmesswithentriesprint
else pushlitstk(entryints[citeptr*numentints+ilkinfo[exfnloc]],0);
end{:328};
6:{329:}begin if(not messwithentries)then bstcantmesswithentriesprint
else begin strentptr:=citeptr*numentstrs+ilkinfo[exfnloc];exbufptr:=0;
while(entrystrs[strentptr][exbufptr]<>127)do begin exbuf[exbufptr]:=
entrystrs[strentptr][exbufptr];exbufptr:=exbufptr+1;end;
exbuflength:=exbufptr;addpoolbufandpush;end;end{:329};
7:pushlitstk(ilkinfo[exfnloc],0);
8:{330:}begin strglbptr:=ilkinfo[exfnloc];
if(glbstrptr[strglbptr]>0)then pushlitstk(glbstrptr[strglbptr],1)else
begin begin if(poolptr+glbstrend[strglbptr]>poolsize)then pooloverflow;
end;globchrptr:=0;
while(globchrptr<glbstrend[strglbptr])do begin begin strpool[poolptr]:=
globalstrs[strglbptr][globchrptr];poolptr:=poolptr+1;end;
globchrptr:=globchrptr+1;end;pushlitstk(makestring,1);end;end{:330};
others:unknwnfunctionclassconfusion end;end;
{:325}{:342}{100:}procedure getthetoplevelauxfilename;label 41,46;
var{101:}checkcmndline:boolean;{:101}begin checkcmndline:=false;
while true do begin if(checkcmndline)then{102:}begin;
end{:102}else begin write(tty,
'Please type input file name (no extension)--');
if(eoln(tty))then readln(tty);auxnamelength:=0;
while(not eoln(tty))do begin if(auxnamelength=40)then begin while(not
eoln(tty))do get(tty);begin samtoolongfilenameprint;goto 46;end;end;
auxnamelength:=auxnamelength+1;nameoffile[auxnamelength]:=tty^;get(tty);
end;end;
{103:}begin if((auxnamelength+(strstart[sauxextension+1]-strstart[
sauxextension])>40)or(auxnamelength+(strstart[slogextension+1]-strstart[
slogextension])>40)or(auxnamelength+(strstart[sbblextension+1]-strstart[
sbblextension])>40))then begin samtoolongfilenameprint;goto 46;end;
{106:}begin namelength:=auxnamelength;addextension(sauxextension);
auxptr:=0;
if(not aopenin(auxfile[auxptr]))then begin samwrongfilenameprint;
goto 46;end;namelength:=auxnamelength;addextension(slogextension);
if(not aopenout(logfile))then begin samwrongfilenameprint;goto 46;end;
namelength:=auxnamelength;addextension(sbblextension);
if(not aopenout(bblfile))then begin samwrongfilenameprint;goto 46;end;
end{:106};{107:}begin namelength:=auxnamelength;
addextension(sauxextension);nameptr:=1;
while(nameptr<=namelength)do begin buffer[nameptr]:=xord[nameoffile[
nameptr]];nameptr:=nameptr+1;end;
toplevstr:=hashtext[strlookup(buffer,1,auxnamelength,0,true)];
auxlist[auxptr]:=hashtext[strlookup(buffer,1,namelength,3,true)];
if(hashfound)then begin{printauxname;}
begin begin write(logfile,'Already encountered auxiliary file');
write(tty,'Already encountered auxiliary file');end;printconfusion;
goto 9998;end;end;auxlnstack[auxptr]:=0;end{:107};goto 41;end{:103};
46:checkcmndline:=false;end;41:end;
{:100}{120:}procedure auxbibdatacommand;label 10;
begin if(bibseen)then begin auxerrillegalanotherprint(0);
begin auxerrprint;goto 10;end;end;bibseen:=true;
while(buffer[bufptr2]<>125)do begin bufptr2:=bufptr2+1;
if(not scan2white(125,44))then begin auxerrnorightbraceprint;
begin auxerrprint;goto 10;end;end;
if(lexclass[buffer[bufptr2]]=1)then begin
auxerrwhitespaceinargumentprint;begin auxerrprint;goto 10;end;end;
if((last>bufptr2+1)and(buffer[bufptr2]=125))then begin
auxerrstuffafterrightbraceprint;begin auxerrprint;goto 10;end;end;
{123:}begin if(bibptr=maxbibfiles)then begin printoverflow;
begin writeln(logfile,'number of database files ',maxbibfiles:0);
writeln(tty,'number of database files ',maxbibfiles:0);end;goto 9998;
end;
biblist[bibptr]:=hashtext[strlookup(buffer,bufptr1,(bufptr2-bufptr1),6,
true)];if(hashfound)then begin begin write(logfile,
'This database file appears more than once: ');
write(tty,'This database file appears more than once: ');end;
printbibname;begin auxerrprint;goto 10;end;end;
startname(biblist[bibptr]);addextension(sbibextension);
if(not aopenin(bibfile[bibptr]))then begin addarea(sbibarea);
if(not aopenin(bibfile[bibptr]))then begin begin write(logfile,
'I couldn''t open database file ');
write(tty,'I couldn''t open database file ');end;printbibname;
begin auxerrprint;goto 10;end;end;end;
{begin outpoolstr(logfile,biblist[bibptr]);end;
begin outpoolstr(logfile,sbibextension);end;
begin writeln(logfile,' is a bibdata file');end;}bibptr:=bibptr+1;
end{:123};end;10:end;{:120}{126:}procedure auxbibstylecommand;label 10;
begin if(bstseen)then begin auxerrillegalanotherprint(1);
begin auxerrprint;goto 10;end;end;bstseen:=true;bufptr2:=bufptr2+1;
if(not scan1white(125))then begin auxerrnorightbraceprint;
begin auxerrprint;goto 10;end;end;
if(lexclass[buffer[bufptr2]]=1)then begin
auxerrwhitespaceinargumentprint;begin auxerrprint;goto 10;end;end;
if(last>bufptr2+1)then begin auxerrstuffafterrightbraceprint;
begin auxerrprint;goto 10;end;end;
{127:}begin bststr:=hashtext[strlookup(buffer,bufptr1,(bufptr2-bufptr1),
5,true)];if(hashfound)then begin{printbstname;}
begin begin write(logfile,'Already encountered style file');
write(tty,'Already encountered style file');end;printconfusion;
goto 9998;end;end;startname(bststr);addextension(sbstextension);
if(not aopenin(bstfile))then begin addarea(sbstarea);
if(not aopenin(bstfile))then begin begin write(logfile,
'I couldn''t open style file ');
write(tty,'I couldn''t open style file ');end;printbstname;bststr:=0;
begin auxerrprint;goto 10;end;end;end;
begin write(logfile,'The style file: ');write(tty,'The style file: ');
end;printbstname;end{:127};10:end;
{:126}{132:}procedure auxcitationcommand;label 23,10;
begin citationseen:=true;
while(buffer[bufptr2]<>125)do begin bufptr2:=bufptr2+1;
if(not scan2white(125,44))then begin auxerrnorightbraceprint;
begin auxerrprint;goto 10;end;end;
if(lexclass[buffer[bufptr2]]=1)then begin
auxerrwhitespaceinargumentprint;begin auxerrprint;goto 10;end;end;
if((last>bufptr2+1)and(buffer[bufptr2]=125))then begin
auxerrstuffafterrightbraceprint;begin auxerrprint;goto 10;end;end;
{133:}begin{begin outtoken(logfile);end;
begin write(logfile,' cite key encountered');end;}
{134:}begin if((bufptr2-bufptr1)=1)then if(buffer[bufptr1]=42)then begin
{begin writeln(logfile,'---entire database to be included');end;}
if(allentries)then begin begin writeln(logfile,
'Multiple inclusions of entire database');
writeln(tty,'Multiple inclusions of entire database');end;
begin auxerrprint;goto 10;end;end else begin allentries:=true;
allmarker:=citeptr;goto 23;end;end;end{:134};tmpptr:=bufptr1;
while(tmpptr<bufptr2)do begin exbuf[tmpptr]:=buffer[tmpptr];
tmpptr:=tmpptr+1;end;lowercase(exbuf,bufptr1,(bufptr2-bufptr1));
lcciteloc:=strlookup(exbuf,bufptr1,(bufptr2-bufptr1),10,true);
if(hashfound)then{135:}begin{begin writeln(logfile,' previously');end;}
dummyloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),9,false);
if(not hashfound)then begin begin write(logfile,
'Case mismatch error between cite keys ');
write(tty,'Case mismatch error between cite keys ');end;printatoken;
begin write(logfile,' and ');write(tty,' and ');end;
printapoolstr(citelist[ilkinfo[ilkinfo[lcciteloc]]]);printanewline;
begin auxerrprint;goto 10;end;end;
end{:135}else{136:}begin{begin writeln(logfile);end;}
citeloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),9,true);
if(hashfound)then hashciteconfusion;checkciteoverflow(citeptr);
citelist[citeptr]:=hashtext[citeloc];ilkinfo[citeloc]:=citeptr;
ilkinfo[lcciteloc]:=citeloc;citeptr:=citeptr+1;end{:136};end{:133};
23:end;10:end;{:132}{139:}procedure auxinputcommand;label 10;
var auxextensionok:boolean;begin bufptr2:=bufptr2+1;
if(not scan1white(125))then begin auxerrnorightbraceprint;
begin auxerrprint;goto 10;end;end;
if(lexclass[buffer[bufptr2]]=1)then begin
auxerrwhitespaceinargumentprint;begin auxerrprint;goto 10;end;end;
if(last>bufptr2+1)then begin auxerrstuffafterrightbraceprint;
begin auxerrprint;goto 10;end;end;{140:}begin auxptr:=auxptr+1;
if(auxptr=auxstacksize)then begin printatoken;begin write(logfile,': ');
write(tty,': ');end;begin printoverflow;
begin writeln(logfile,'auxiliary file depth ',auxstacksize:0);
writeln(tty,'auxiliary file depth ',auxstacksize:0);end;goto 9998;end;
end;auxextensionok:=true;
if((bufptr2-bufptr1)<(strstart[sauxextension+1]-strstart[sauxextension])
)then auxextensionok:=false else if(not streqbuf(sauxextension,buffer,
bufptr2-(strstart[sauxextension+1]-strstart[sauxextension]),(strstart[
sauxextension+1]-strstart[sauxextension])))then auxextensionok:=false;
if(not auxextensionok)then begin printatoken;
begin write(logfile,' has a wrong extension');
write(tty,' has a wrong extension');end;auxptr:=auxptr-1;
begin auxerrprint;goto 10;end;end;
auxlist[auxptr]:=hashtext[strlookup(buffer,bufptr1,(bufptr2-bufptr1),3,
true)];
if(hashfound)then begin begin write(logfile,'Already encountered file ')
;write(tty,'Already encountered file ');end;printauxname;
auxptr:=auxptr-1;begin auxerrprint;goto 10;end;end;
{141:}begin startname(auxlist[auxptr]);nameptr:=namelength+1;
while(nameptr<=40)do begin nameoffile[nameptr]:=' ';nameptr:=nameptr+1;
end;if(not aopenin(auxfile[auxptr]))then begin begin write(logfile,
'I couldn''t open auxiliary file ');
write(tty,'I couldn''t open auxiliary file ');end;printauxname;
auxptr:=auxptr-1;begin auxerrprint;goto 10;end;end;
begin write(logfile,'A level-',auxptr:0,' auxiliary file: ');
write(tty,'A level-',auxptr:0,' auxiliary file: ');end;printauxname;
auxlnstack[auxptr]:=0;end{:141};end{:140};10:end;
{:139}{142:}procedure poptheauxstack;begin aclose(auxfile[auxptr]);
if(auxptr=0)then goto 31 else auxptr:=auxptr-1;end;
{:142}{143:}{116:}procedure getauxcommandandprocess;label 10;
begin bufptr2:=0;if(not scan1(123))then goto 10;
commandnum:=ilkinfo[strlookup(buffer,bufptr1,(bufptr2-bufptr1),2,false)]
;if(hashfound)then case(commandnum)of 0:auxbibdatacommand;
1:auxbibstylecommand;2:auxcitationcommand;3:auxinputcommand;
others:begin begin write(logfile,'Unknown auxiliary-file command');
write(tty,'Unknown auxiliary-file command');end;printconfusion;
goto 9998;end end;10:end;
{:116}{:143}{145:}procedure lastcheckforauxerrors;
begin numcites:=citeptr;numbibfiles:=bibptr;
if(not citationseen)then begin auxend1errprint;
begin write(logfile,'\citation commands');
write(tty,'\citation commands');end;auxend2errprint;
end else if((numcites=0)and(not allentries))then begin auxend1errprint;
begin write(logfile,'cite keys');write(tty,'cite keys');end;
auxend2errprint;end;if(not bibseen)then begin auxend1errprint;
begin write(logfile,'\bibdata command');write(tty,'\bibdata command');
end;auxend2errprint;
end else if(numbibfiles=0)then begin auxend1errprint;
begin write(logfile,'database files');write(tty,'database files');end;
auxend2errprint;end;if(not bstseen)then begin auxend1errprint;
begin write(logfile,'\bibstyle command');write(tty,'\bibstyle command');
end;auxend2errprint;end else if(bststr=0)then begin auxend1errprint;
begin write(logfile,'style file');write(tty,'style file');end;
auxend2errprint;end;end;{:145}{170:}procedure bstentrycommand;label 10;
begin if(entryseen)then begin begin write(logfile,
'Illegal, another entry command');
write(tty,'Illegal, another entry command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;entryseen:=true;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{171:}begin begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
while(buffer[bufptr2]<>125)do begin begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{172:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a field');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,true);
begin if(hashfound)then begin alreadyseenfunctionprint(fnloc);goto 10;
end;end;fntype[fnloc]:=4;ilkinfo[fnloc]:=numfields;
numfields:=numfields+1;end{:172};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;end;
bufptr2:=bufptr2+1;end{:171};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
if(numfields=numpredefinedfields)then begin begin write(logfile,
'Warning--I didn''t find any fields');
write(tty,'Warning--I didn''t find any fields');end;bstwarnprint;end;
{173:}begin begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
while(buffer[bufptr2]<>125)do begin begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{174:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is an integer entry-variable');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,true);
begin if(hashfound)then begin alreadyseenfunctionprint(fnloc);goto 10;
end;end;fntype[fnloc]:=5;ilkinfo[fnloc]:=numentints;
numentints:=numentints+1;end{:174};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;end;
bufptr2:=bufptr2+1;end{:173};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{175:}begin begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
while(buffer[bufptr2]<>125)do begin begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{176:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a string entry-variable');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,true);
begin if(hashfound)then begin alreadyseenfunctionprint(fnloc);goto 10;
end;end;fntype[fnloc]:=6;ilkinfo[fnloc]:=numentstrs;
numentstrs:=numentstrs+1;end{:176};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'entry');write(tty,'entry');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;end;
bufptr2:=bufptr2+1;end{:175};10:end;
{:170}{177:}function badargumenttoken:boolean;label 10;
begin badargumenttoken:=true;
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,false);
if(not hashfound)then begin printatoken;
begin begin write(logfile,' is an unknown function');
write(tty,' is an unknown function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
end else if((fntype[fnloc]<>0)and(fntype[fnloc]<>1))then begin
printatoken;begin write(logfile,' has bad function type ');
write(tty,' has bad function type ');end;printfnclass(fnloc);
begin bsterrprintandlookforblankline;goto 10;end;end;
badargumenttoken:=false;10:end;{:177}{178:}procedure bstexecutecommand;
label 10;begin if(not readseen)then begin begin write(logfile,
'Illegal, execute command before read command');
write(tty,'Illegal, execute command before read command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'execute');write(tty,'execute');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'execute');write(tty,'execute');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'execute');write(tty,'execute');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'execute');write(tty,'execute');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{179:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a to be executed function');end;}
if(badargumenttoken)then goto 10;end{:179};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'execute');write(tty,'execute');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>125)then begin bstrightbraceprint;
begin begin write(logfile,'execute');write(tty,'execute');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;{296:}begin initcommandexecution;
messwithentries:=false;executefn(fnloc);checkcommandexecution;end{:296};
10:end;{:178}{180:}procedure bstfunctioncommand;label 10;
begin begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{181:}begin begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{182:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a wizard-defined function');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
wizloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,true);
begin if(hashfound)then begin alreadyseenfunctionprint(wizloc);goto 10;
end;end;fntype[wizloc]:=1;
if(hashtext[wizloc]=sdefault)then bdefault:=wizloc;end{:182};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>125)then begin bstrightbraceprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;end{:181};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'function');write(tty,'function');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;scanfndef(wizloc);10:end;
{:180}{201:}procedure bstintegerscommand;label 10;
begin begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'integers');write(tty,'integers');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'integers');write(tty,'integers');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'integers');write(tty,'integers');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
while(buffer[bufptr2]<>125)do begin begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'integers');write(tty,'integers');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{202:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is an integer global-variable');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,true);
begin if(hashfound)then begin alreadyseenfunctionprint(fnloc);goto 10;
end;end;fntype[fnloc]:=7;ilkinfo[fnloc]:=0;end{:202};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'integers');write(tty,'integers');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;end;
bufptr2:=bufptr2+1;10:end;{:201}{203:}procedure bstiteratecommand;
label 10;begin if(not readseen)then begin begin write(logfile,
'Illegal, iterate command before read command');
write(tty,'Illegal, iterate command before read command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'iterate');write(tty,'iterate');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'iterate');write(tty,'iterate');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'iterate');write(tty,'iterate');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'iterate');write(tty,'iterate');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{204:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a to be iterated function');end;}
if(badargumenttoken)then goto 10;end{:204};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'iterate');write(tty,'iterate');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>125)then begin bstrightbraceprint;
begin begin write(logfile,'iterate');write(tty,'iterate');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;{297:}begin initcommandexecution;
messwithentries:=true;sortciteptr:=0;
while(sortciteptr<numcites)do begin citeptr:=citeinfo[sortciteptr];
{begin outpoolstr(logfile,hashtext[fnloc]);end;
begin write(logfile,' to be iterated on ');end;
begin outpoolstr(logfile,citelist[citeptr]);end;begin writeln(logfile);
end;}executefn(fnloc);checkcommandexecution;sortciteptr:=sortciteptr+1;
end;end{:297};10:end;{:203}{205:}procedure bstmacrocommand;label 10;
begin if(readseen)then begin begin write(logfile,
'Illegal, macro command after read command');
write(tty,'Illegal, macro command after read command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{206:}begin begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{207:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a macro');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
macronameloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),13,true);
if(hashfound)then begin printatoken;
begin begin write(logfile,' is already defined as a macro');
write(tty,' is already defined as a macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
ilkinfo[macronameloc]:=hashtext[macronameloc];end{:207};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>125)then begin bstrightbraceprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;end{:206};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{208:}begin begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
if(buffer[bufptr2]<>34)then begin begin write(logfile,
'A macro definition must be ',xchr[34],'-delimited');
write(tty,'A macro definition must be ',xchr[34],'-delimited');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
{209:}begin bufptr2:=bufptr2+1;
if(not scan1(34))then begin begin write(logfile,'There''s no `',xchr[34]
,''' to end macro definition');
write(tty,'There''s no `',xchr[34],''' to end macro definition');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
{begin write(logfile,'"');end;begin outtoken(logfile);end;
begin write(logfile,'"');end;
begin writeln(logfile,' is a macro string');end;}
macrodefloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),0,true);
fntype[macrodefloc]:=3;ilkinfo[macronameloc]:=hashtext[macrodefloc];
bufptr2:=bufptr2+1;end{:209};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>125)then begin bstrightbraceprint;
begin begin write(logfile,'macro');write(tty,'macro');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;end{:208};10:end;
{:205}{210:}{236:}procedure getbibcommandorentryandprocess;
label 22,26,15,10;begin atbibcommand:=false;
{237:}while(not scan1(64))do begin if(not inputln(bibfile[bibptr]))then
goto 10;biblinenum:=biblinenum+1;bufptr2:=0;end{:237};
{238:}begin if(buffer[bufptr2]<>64)then begin begin write(logfile,'An "'
,xchr[64],'" disappeared');write(tty,'An "',xchr[64],'" disappeared');
end;printconfusion;goto 9998;end;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
scanidentifier(123,40,40);
begin if((scanresult=3)or(scanresult=1))then else begin bibidprint;
begin begin write(logfile,'an entry type');write(tty,'an entry type');
end;biberrprint;goto 10;end;end;end;{begin outtoken(logfile);end;
begin writeln(logfile,' is an entry type or a database-file command');
end;}lowercase(buffer,bufptr1,(bufptr2-bufptr1));
commandnum:=ilkinfo[strlookup(buffer,bufptr1,(bufptr2-bufptr1),12,false)
];if(hashfound)then{239:}begin atbibcommand:=true;
case(commandnum)of 0:{241:}begin goto 10;end{:241};
1:{242:}begin if(preambleptr=maxbibfiles)then begin begin write(logfile,
'You''ve exceeded ',maxbibfiles:0,' preamble commands');
write(tty,'You''ve exceeded ',maxbibfiles:0,' preamble commands');end;
biberrprint;goto 10;end;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
if(buffer[bufptr2]=123)then rightouterdelim:=125 else if(buffer[bufptr2]
=40)then rightouterdelim:=41 else begin biboneoftwoprint(123,40);
goto 10;end;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
storefield:=true;
if(not scanandstorethefieldvalueandeatwhite)then goto 10;
if(buffer[bufptr2]<>rightouterdelim)then begin begin write(logfile,
'Missing "',xchr[rightouterdelim],'" in preamble command');
write(tty,'Missing "',xchr[rightouterdelim],'" in preamble command');
end;biberrprint;goto 10;end;bufptr2:=bufptr2+1;goto 10;end{:242};
2:{243:}begin begin if(not eatbibwhitespace)then begin eatbibprint;
goto 10;end;end;
{244:}begin if(buffer[bufptr2]=123)then rightouterdelim:=125 else if(
buffer[bufptr2]=40)then rightouterdelim:=41 else begin biboneoftwoprint(
123,40);goto 10;end;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
scanidentifier(61,61,61);
begin if((scanresult=3)or(scanresult=1))then else begin bibidprint;
begin begin write(logfile,'a string name');write(tty,'a string name');
end;biberrprint;goto 10;end;end;end;{245:}begin{begin outtoken(logfile);
end;begin writeln(logfile,' is a database-defined macro');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
curmacroloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),13,true);
ilkinfo[curmacroloc]:=hashtext[curmacroloc];
{if(hashfound)then begin macrowarnprint;
begin begin writeln(logfile,'having its definition overwritten');
writeln(tty,'having its definition overwritten');end;bibwarnprint;end;
end;}end{:245};end{:244};
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
{246:}begin if(buffer[bufptr2]<>61)then begin bibequalssignprint;
goto 10;end;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
storefield:=true;
if(not scanandstorethefieldvalueandeatwhite)then goto 10;
if(buffer[bufptr2]<>rightouterdelim)then begin begin write(logfile,
'Missing "',xchr[rightouterdelim],'" in string command');
write(tty,'Missing "',xchr[rightouterdelim],'" in string command');end;
biberrprint;goto 10;end;bufptr2:=bufptr2+1;end{:246};goto 10;end{:243};
others:bibcmdconfusion end;
end{:239}else begin entrytypeloc:=strlookup(buffer,bufptr1,(bufptr2-
bufptr1),11,false);
if((not hashfound)or(fntype[entrytypeloc]<>1))then typeexists:=false
else typeexists:=true;end;end{:238};
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
{266:}begin if(buffer[bufptr2]=123)then rightouterdelim:=125 else if(
buffer[bufptr2]=40)then rightouterdelim:=41 else begin biboneoftwoprint(
123,40);goto 10;end;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
if(rightouterdelim=41)then begin if(scan1white(44))then;
end else if(scan2white(44,125))then;{267:}begin{begin outtoken(logfile);
end;begin writeln(logfile,' is a database key');end;}tmpptr:=bufptr1;
while(tmpptr<bufptr2)do begin exbuf[tmpptr]:=buffer[tmpptr];
tmpptr:=tmpptr+1;end;lowercase(exbuf,bufptr1,(bufptr2-bufptr1));
if(allentries)then lcciteloc:=strlookup(exbuf,bufptr1,(bufptr2-bufptr1),
10,true)else lcciteloc:=strlookup(exbuf,bufptr1,(bufptr2-bufptr1),10,
false);
if(hashfound)then begin entryciteptr:=ilkinfo[ilkinfo[lcciteloc]];
{268:}begin if((not allentries)or(entryciteptr<allmarker)or(entryciteptr
>=oldnumcites))then begin if(typelist[entryciteptr]=0)then begin{269:}
begin if((not allentries)and(entryciteptr>=oldnumcites))then begin
citeloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),9,true);
if(not hashfound)then begin ilkinfo[lcciteloc]:=citeloc;
ilkinfo[citeloc]:=entryciteptr;
citelist[entryciteptr]:=hashtext[citeloc];hashfound:=true;end;end;
end{:269};goto 26;end;
end else if(not entryexists[entryciteptr])then begin{270:}begin exbufptr
:=0;tmpptr:=strstart[citeinfo[entryciteptr]];
tmpendptr:=strstart[citeinfo[entryciteptr]+1];
while(tmpptr<tmpendptr)do begin exbuf[exbufptr]:=strpool[tmpptr];
exbufptr:=exbufptr+1;tmpptr:=tmpptr+1;end;
lowercase(exbuf,0,(strstart[citeinfo[entryciteptr]+1]-strstart[citeinfo[
entryciteptr]]));
lcxciteloc:=strlookup(exbuf,0,(strstart[citeinfo[entryciteptr]+1]-
strstart[citeinfo[entryciteptr]]),10,false);
if(not hashfound)then citekeydisappearedconfusion;end{:270};
if(lcxciteloc=lcciteloc)then goto 26;end;
if(typelist[entryciteptr]=0)then begin begin write(logfile,
'The cite list is messed up');write(tty,'The cite list is messed up');
end;printconfusion;goto 9998;end;
begin begin write(logfile,'Repeated entry');write(tty,'Repeated entry');
end;biberrprint;goto 10;end;26:end{:268};end;storeentry:=true;
if(allentries)then{272:}begin if(hashfound)then begin if(entryciteptr<
allmarker)then goto 22 else begin entryexists[entryciteptr]:=true;
citeloc:=ilkinfo[lcciteloc];end;
end else begin citeloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),9,
true);if(hashfound)then hashciteconfusion;end;entryciteptr:=citeptr;
adddatabasecite(citeptr);
22:end{:272}else if(not hashfound)then storeentry:=false;
if(storeentry)then{273:}begin{dummyloc:=strlookup(buffer,bufptr1,(
bufptr2-bufptr1),9,false);
if(not hashfound)then begin begin write(logfile,
'Warning--case mismatch, database key "');
write(tty,'Warning--case mismatch, database key "');end;printatoken;
begin write(logfile,'", cite key "');write(tty,'", cite key "');end;
printapoolstr(citelist[entryciteptr]);begin begin writeln(logfile,'"');
writeln(tty,'"');end;bibwarnprint;end;end;}
if(typeexists)then typelist[entryciteptr]:=entrytypeloc else begin
typelist[entryciteptr]:=5001;
begin write(logfile,'Warning--entry type for "');
write(tty,'Warning--entry type for "');end;printatoken;
begin begin writeln(logfile,'" isn''t style-file defined');
writeln(tty,'" isn''t style-file defined');end;bibwarnprint;end;end;
end{:273};end{:267};end{:266};
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
{274:}begin while(buffer[bufptr2]<>rightouterdelim)do begin if(buffer[
bufptr2]<>44)then begin biboneoftwoprint(44,rightouterdelim);goto 10;
end;bufptr2:=bufptr2+1;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
if(buffer[bufptr2]=rightouterdelim)then goto 15;
{275:}begin scanidentifier(61,61,61);
begin if((scanresult=3)or(scanresult=1))then else begin bibidprint;
begin begin write(logfile,'a field name');write(tty,'a field name');end;
biberrprint;goto 10;end;end;end;{begin outtoken(logfile);end;
begin writeln(logfile,' is a field name');end;}storefield:=false;
if(storeentry)then begin lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fieldnameloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,false);
if(hashfound)then if(fntype[fieldnameloc]=4)then storefield:=true;end;
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
if(buffer[bufptr2]<>61)then begin bibequalssignprint;goto 10;end;
bufptr2:=bufptr2+1;end{:275};
begin if(not eatbibwhitespace)then begin eatbibprint;goto 10;end;end;
if(not scanandstorethefieldvalueandeatwhite)then goto 10;end;
15:bufptr2:=bufptr2+1;end{:274};10:end;
{:236}{:210}{211:}procedure bstreadcommand;label 10;
begin if(readseen)then begin begin write(logfile,
'Illegal, another read command');
write(tty,'Illegal, another read command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;readseen:=true;
if(not entryseen)then begin begin write(logfile,
'Illegal, read command before entry command');
write(tty,'Illegal, read command before entry command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;svptr1:=bufptr2;
svptr2:=last;tmpptr:=svptr1;
while(tmpptr<svptr2)do begin svbuffer[tmpptr]:=buffer[tmpptr];
tmpptr:=tmpptr+1;end;
{223:}begin{224:}begin{225:}begin checkfieldoverflow(numfields*numcites)
;fieldptr:=0;while(fieldptr<maxfields)do begin fieldinfo[fieldptr]:=0;
fieldptr:=fieldptr+1;end;end{:225};{227:}begin citeptr:=0;
while(citeptr<maxcites)do begin typelist[citeptr]:=0;
citeinfo[citeptr]:=0;citeptr:=citeptr+1;end;oldnumcites:=numcites;
if(allentries)then begin citeptr:=allmarker;
while(citeptr<oldnumcites)do begin citeinfo[citeptr]:=citelist[citeptr];
entryexists[citeptr]:=false;citeptr:=citeptr+1;end;citeptr:=allmarker;
end else begin citeptr:=numcites;allmarker:=0;end;end{:227};end{:224};
readperformed:=true;bibptr:=0;
while(bibptr<numbibfiles)do begin begin write(logfile,'Database file #',
bibptr+1:0,': ');write(tty,'Database file #',bibptr+1:0,': ');end;
printbibname;biblinenum:=0;bufptr2:=last;
while(not eof(bibfile[bibptr]))do getbibcommandorentryandprocess;
aclose(bibfile[bibptr]);bibptr:=bibptr+1;end;readingcompleted:=true;
{begin writeln(logfile,'Finished reading the database file(s)');end;}
{276:}begin numcites:=citeptr;numpreamblestrings:=preambleptr;
{277:}begin citeptr:=0;
while(citeptr<numcites)do begin fieldptr:=citeptr*numfields+crossrefnum;
if(fieldinfo[fieldptr]<>0)then if(findcitelocsforthiscitekey(fieldinfo[
fieldptr]))then begin citeloc:=ilkinfo[lcciteloc];
fieldinfo[fieldptr]:=hashtext[citeloc];citeparentptr:=ilkinfo[citeloc];
fieldptr:=citeptr*numfields+numpredefinedfields;
fieldendptr:=fieldptr-numpredefinedfields+numfields;
fieldparentptr:=citeparentptr*numfields+numpredefinedfields;
while(fieldptr<fieldendptr)do begin if(fieldinfo[fieldptr]=0)then
fieldinfo[fieldptr]:=fieldinfo[fieldparentptr];fieldptr:=fieldptr+1;
fieldparentptr:=fieldparentptr+1;end;end;citeptr:=citeptr+1;end;
end{:277};{279:}begin citeptr:=0;
while(citeptr<numcites)do begin fieldptr:=citeptr*numfields+crossrefnum;
if(fieldinfo[fieldptr]<>0)then if(not findcitelocsforthiscitekey(
fieldinfo[fieldptr]))then begin if(citehashfound)then hashciteconfusion;
nonexistentcrossreferenceerror;fieldinfo[fieldptr]:=0;
end else begin if(citeloc<>ilkinfo[lcciteloc])then hashciteconfusion;
citeparentptr:=ilkinfo[citeloc];
if(typelist[citeparentptr]=0)then begin nonexistentcrossreferenceerror;
fieldinfo[fieldptr]:=0;
end else begin fieldparentptr:=citeparentptr*numfields+crossrefnum;
if(fieldinfo[fieldparentptr]<>0)then{282:}begin begin write(logfile,
'Warning--you''ve nested cross references');
write(tty,'Warning--you''ve nested cross references');end;
badcrossreferenceprint(citelist[citeparentptr]);
begin writeln(logfile,'", which also refers to something');
writeln(tty,'", which also refers to something');end;markwarning;
end{:282};
if((not allentries)and(citeparentptr>=oldnumcites)and(citeinfo[
citeparentptr]<mincrossrefs))then fieldinfo[fieldptr]:=0;end;end;
citeptr:=citeptr+1;end;end{:279};{283:}begin citeptr:=0;
while(citeptr<numcites)do begin if(typelist[citeptr]=0)then
printmissingentry(citelist[citeptr])else if((allentries)or(citeptr<
oldnumcites)or(citeinfo[citeptr]>=mincrossrefs))then begin if(citeptr>
citexptr)then{285:}begin citelist[citexptr]:=citelist[citeptr];
typelist[citexptr]:=typelist[citeptr];
if(not findcitelocsforthiscitekey(citelist[citeptr]))then
citekeydisappearedconfusion;
if((not citehashfound)or(citeloc<>ilkinfo[lcciteloc]))then
hashciteconfusion;ilkinfo[citeloc]:=citexptr;
fieldptr:=citexptr*numfields;fieldendptr:=fieldptr+numfields;
tmpptr:=citeptr*numfields;
while(fieldptr<fieldendptr)do begin fieldinfo[fieldptr]:=fieldinfo[
tmpptr];fieldptr:=fieldptr+1;tmpptr:=tmpptr+1;end;end{:285};
citexptr:=citexptr+1;end;citeptr:=citeptr+1;end;numcites:=citexptr;
if(allentries)then{286:}begin citeptr:=allmarker;
while(citeptr<oldnumcites)do begin if(not entryexists[citeptr])then
printmissingentry(citeinfo[citeptr]);citeptr:=citeptr+1;end;end{:286};
end{:283};
{287:}begin if(numentints*numcites>maxentints)then begin begin write(
logfile,numentints*numcites,': ');write(tty,numentints*numcites,': ');
end;begin printoverflow;
begin writeln(logfile,'total number of integer entry-variables ',
maxentints:0);
writeln(tty,'total number of integer entry-variables ',maxentints:0);
end;goto 9998;end;end;intentptr:=0;
while(intentptr<numentints*numcites)do begin entryints[intentptr]:=0;
intentptr:=intentptr+1;end;end{:287};
{288:}begin if(numentstrs*numcites>maxentstrs)then begin begin write(
logfile,numentstrs*numcites,': ');write(tty,numentstrs*numcites,': ');
end;begin printoverflow;
begin writeln(logfile,'total number of string entry-variables ',
maxentstrs:0);
writeln(tty,'total number of string entry-variables ',maxentstrs:0);end;
goto 9998;end;end;strentptr:=0;
while(strentptr<numentstrs*numcites)do begin entrystrs[strentptr][0]:=
127;strentptr:=strentptr+1;end;end{:288};{289:}begin citeptr:=0;
while(citeptr<numcites)do begin citeinfo[citeptr]:=citeptr;
citeptr:=citeptr+1;end;end{:289};end{:276};readcompleted:=true;
end{:223};bufptr2:=svptr1;last:=svptr2;tmpptr:=bufptr2;
while(tmpptr<last)do begin buffer[tmpptr]:=svbuffer[tmpptr];
tmpptr:=tmpptr+1;end;10:end;{:211}{212:}procedure bstreversecommand;
label 10;begin if(not readseen)then begin begin write(logfile,
'Illegal, reverse command before read command');
write(tty,'Illegal, reverse command before read command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'reverse');write(tty,'reverse');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'reverse');write(tty,'reverse');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'reverse');write(tty,'reverse');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'reverse');write(tty,'reverse');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{213:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a to be iterated in reverse function');end;}
if(badargumenttoken)then goto 10;end{:213};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'reverse');write(tty,'reverse');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>125)then begin bstrightbraceprint;
begin begin write(logfile,'reverse');write(tty,'reverse');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;{298:}begin initcommandexecution;
messwithentries:=true;if(numcites>0)then begin sortciteptr:=numcites;
repeat sortciteptr:=sortciteptr-1;citeptr:=citeinfo[sortciteptr];
{begin outpoolstr(logfile,hashtext[fnloc]);end;
begin write(logfile,' to be iterated in reverse on ');end;
begin outpoolstr(logfile,citelist[citeptr]);end;begin writeln(logfile);
end;}executefn(fnloc);checkcommandexecution;until(sortciteptr=0);end;
end{:298};10:end;{:212}{214:}procedure bstsortcommand;label 10;
begin if(not readseen)then begin begin write(logfile,
'Illegal, sort command before read command');
write(tty,'Illegal, sort command before read command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
{299:}begin{begin writeln(logfile,'Sorting the entries');end;}
if(numcites>1)then quicksort(0,numcites-1);
{begin writeln(logfile,'Done sorting');end;}end{:299};10:end;
{:214}{215:}procedure bststringscommand;label 10;
begin begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'strings');write(tty,'strings');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
begin if(buffer[bufptr2]<>123)then begin bstleftbraceprint;
begin begin write(logfile,'strings');write(tty,'strings');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
bufptr2:=bufptr2+1;end;
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'strings');write(tty,'strings');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
while(buffer[bufptr2]<>125)do begin begin scanidentifier(125,37,37);
if((scanresult=3)or(scanresult=1))then else begin bstidprint;
begin begin write(logfile,'strings');write(tty,'strings');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;
{216:}begin{begin outtoken(logfile);end;
begin writeln(logfile,' is a string global-variable');end;}
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
fnloc:=strlookup(buffer,bufptr1,(bufptr2-bufptr1),11,true);
begin if(hashfound)then begin alreadyseenfunctionprint(fnloc);goto 10;
end;end;fntype[fnloc]:=8;ilkinfo[fnloc]:=numglbstrs;
if(numglbstrs=10)then begin printoverflow;
begin writeln(logfile,'number of string global-variables ',10:0);
writeln(tty,'number of string global-variables ',10:0);end;goto 9998;
end;numglbstrs:=numglbstrs+1;end{:216};
begin if(not eatbstwhitespace)then begin eatbstprint;
begin begin write(logfile,'strings');write(tty,'strings');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;end;end;
bufptr2:=bufptr2+1;10:end;
{:215}{217:}{154:}procedure getbstcommandandprocess;label 10;
begin if(not scanalpha)then begin begin write(logfile,'"',xchr[buffer[
bufptr2]],'" can''t start a style-file command');
write(tty,'"',xchr[buffer[bufptr2]],
'" can''t start a style-file command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;
lowercase(buffer,bufptr1,(bufptr2-bufptr1));
commandnum:=ilkinfo[strlookup(buffer,bufptr1,(bufptr2-bufptr1),4,false)]
;if(not hashfound)then begin printatoken;
begin begin write(logfile,' is an illegal style-file command');
write(tty,' is an illegal style-file command');end;
begin bsterrprintandlookforblankline;goto 10;end;end;end;
{155:}case(commandnum)of 0:bstentrycommand;1:bstexecutecommand;
2:bstfunctioncommand;3:bstintegerscommand;4:bstiteratecommand;
5:bstmacrocommand;6:bstreadcommand;7:bstreversecommand;8:bstsortcommand;
9:bststringscommand;
others:begin begin write(logfile,'Unknown style-file command');
write(tty,'Unknown style-file command');end;printconfusion;goto 9998;
end end{:155};10:end;{:154}{:217}{:12}{13:}procedure initialize;
var{23:}i:0..127;{:23}{66:}k:hashloc;{:66}begin{17:}bad:=0;
if(minprintline<3)then bad:=1;
if(maxprintline<=minprintline)then bad:=10*bad+2;
if(maxprintline>=bufsize)then bad:=10*bad+3;
if(4253<128)then bad:=10*bad+4;if(4253>5000)then bad:=10*bad+5;
if(4253>=(16320))then bad:=10*bad+6;
if(maxstrings>5000)then bad:=10*bad+7;
if(maxcites>maxstrings)then bad:=10*bad+8;
if(entstrsize>bufsize)then bad:=10*bad+9;
if(globstrsize>bufsize)then bad:=100*bad+11;
{:17}{302:}if(10<2*4+2)then bad:=100*bad+22;{:302};
if(bad>0)then begin writeln(tty,bad:0,' is a bad bad');goto 9999;end;
{20:}history:=0;{:20}{25:}xchr[32]:=' ';xchr[33]:='!';xchr[34]:='"';
xchr[35]:='#';xchr[36]:='$';xchr[37]:='%';xchr[38]:='&';xchr[39]:='''';
xchr[40]:='(';xchr[41]:=')';xchr[42]:='*';xchr[43]:='+';xchr[44]:=',';
xchr[45]:='-';xchr[46]:='.';xchr[47]:='/';xchr[48]:='0';xchr[49]:='1';
xchr[50]:='2';xchr[51]:='3';xchr[52]:='4';xchr[53]:='5';xchr[54]:='6';
xchr[55]:='7';xchr[56]:='8';xchr[57]:='9';xchr[58]:=':';xchr[59]:=';';
xchr[60]:='<';xchr[61]:='=';xchr[62]:='>';xchr[63]:='?';xchr[64]:='@';
xchr[65]:='A';xchr[66]:='B';xchr[67]:='C';xchr[68]:='D';xchr[69]:='E';
xchr[70]:='F';xchr[71]:='G';xchr[72]:='H';xchr[73]:='I';xchr[74]:='J';
xchr[75]:='K';xchr[76]:='L';xchr[77]:='M';xchr[78]:='N';xchr[79]:='O';
xchr[80]:='P';xchr[81]:='Q';xchr[82]:='R';xchr[83]:='S';xchr[84]:='T';
xchr[85]:='U';xchr[86]:='V';xchr[87]:='W';xchr[88]:='X';xchr[89]:='Y';
xchr[90]:='Z';xchr[91]:='[';xchr[92]:='\';xchr[93]:=']';xchr[94]:='^';
xchr[95]:='_';xchr[96]:='`';xchr[97]:='a';xchr[98]:='b';xchr[99]:='c';
xchr[100]:='d';xchr[101]:='e';xchr[102]:='f';xchr[103]:='g';
xchr[104]:='h';xchr[105]:='i';xchr[106]:='j';xchr[107]:='k';
xchr[108]:='l';xchr[109]:='m';xchr[110]:='n';xchr[111]:='o';
xchr[112]:='p';xchr[113]:='q';xchr[114]:='r';xchr[115]:='s';
xchr[116]:='t';xchr[117]:='u';xchr[118]:='v';xchr[119]:='w';
xchr[120]:='x';xchr[121]:='y';xchr[122]:='z';xchr[123]:='{';
xchr[124]:='|';xchr[125]:='}';xchr[126]:='~';xchr[0]:=' ';
xchr[127]:=' ';{:25}{27:}for i:=1 to 31 do xchr[i]:=' ';xchr[9]:=chr(9);
{:27}{28:}for i:=0 to 127 do xord[chr(i)]:=127;
for i:=1 to 126 do xord[xchr[i]]:=i;
{:28}{32:}for i:=0 to 127 do lexclass[i]:=5;
for i:=0 to 31 do lexclass[i]:=0;lexclass[127]:=0;lexclass[9]:=1;
lexclass[32]:=1;lexclass[126]:=4;lexclass[45]:=4;
for i:=48 to 57 do lexclass[i]:=3;for i:=65 to 90 do lexclass[i]:=2;
for i:=97 to 122 do lexclass[i]:=2;
{:32}{33:}for i:=0 to 127 do idclass[i]:=1;
for i:=0 to 31 do idclass[i]:=0;idclass[32]:=0;idclass[9]:=0;
idclass[34]:=0;idclass[35]:=0;idclass[37]:=0;idclass[39]:=0;
idclass[40]:=0;idclass[41]:=0;idclass[44]:=0;idclass[61]:=0;
idclass[123]:=0;idclass[125]:=0;
{:33}{35:}for i:=0 to 127 do charwidth[i]:=0;charwidth[32]:=278;
charwidth[33]:=278;charwidth[34]:=500;charwidth[35]:=833;
charwidth[36]:=500;charwidth[37]:=833;charwidth[38]:=778;
charwidth[39]:=278;charwidth[40]:=389;charwidth[41]:=389;
charwidth[42]:=500;charwidth[43]:=778;charwidth[44]:=278;
charwidth[45]:=333;charwidth[46]:=278;charwidth[47]:=500;
charwidth[48]:=500;charwidth[49]:=500;charwidth[50]:=500;
charwidth[51]:=500;charwidth[52]:=500;charwidth[53]:=500;
charwidth[54]:=500;charwidth[55]:=500;charwidth[56]:=500;
charwidth[57]:=500;charwidth[58]:=278;charwidth[59]:=278;
charwidth[60]:=278;charwidth[61]:=778;charwidth[62]:=472;
charwidth[63]:=472;charwidth[64]:=778;charwidth[65]:=750;
charwidth[66]:=708;charwidth[67]:=722;charwidth[68]:=764;
charwidth[69]:=681;charwidth[70]:=653;charwidth[71]:=785;
charwidth[72]:=750;charwidth[73]:=361;charwidth[74]:=514;
charwidth[75]:=778;charwidth[76]:=625;charwidth[77]:=917;
charwidth[78]:=750;charwidth[79]:=778;charwidth[80]:=681;
charwidth[81]:=778;charwidth[82]:=736;charwidth[83]:=556;
charwidth[84]:=722;charwidth[85]:=750;charwidth[86]:=750;
charwidth[87]:=1028;charwidth[88]:=750;charwidth[89]:=750;
charwidth[90]:=611;charwidth[91]:=278;charwidth[92]:=500;
charwidth[93]:=278;charwidth[94]:=500;charwidth[95]:=278;
charwidth[96]:=278;charwidth[97]:=500;charwidth[98]:=556;
charwidth[99]:=444;charwidth[100]:=556;charwidth[101]:=444;
charwidth[102]:=306;charwidth[103]:=500;charwidth[104]:=556;
charwidth[105]:=278;charwidth[106]:=306;charwidth[107]:=528;
charwidth[108]:=278;charwidth[109]:=833;charwidth[110]:=556;
charwidth[111]:=500;charwidth[112]:=556;charwidth[113]:=528;
charwidth[114]:=392;charwidth[115]:=394;charwidth[116]:=389;
charwidth[117]:=556;charwidth[118]:=528;charwidth[119]:=722;
charwidth[120]:=528;charwidth[121]:=528;charwidth[122]:=444;
charwidth[123]:=500;charwidth[124]:=1000;charwidth[125]:=500;
charwidth[126]:=500;{:35}{67:}for k:=1 to 5000 do begin hashnext[k]:=0;
hashtext[k]:=0;end;hashused:=5001;{:67}{72:}poolptr:=0;strptr:=1;
strstart[strptr]:=poolptr;{:72}{119:}bibptr:=0;bibseen:=false;
{:119}{125:}bststr:=0;bstseen:=false;{:125}{131:}citeptr:=0;
citationseen:=false;allentries:=false;{:131}{162:}wizdefptr:=0;
numentints:=0;numentstrs:=0;numfields:=0;strglbptr:=0;
while(strglbptr<10)do begin glbstrptr[strglbptr]:=0;
glbstrend[strglbptr]:=0;strglbptr:=strglbptr+1;end;numglbstrs:=0;
{:162}{164:}entryseen:=false;readseen:=false;readperformed:=false;
readingcompleted:=false;readcompleted:=false;{:164}{196:}implfnnum:=0;
{:196}{292:}outbuflength:=0;{:292};predefcertainstrings;
getthetoplevelauxfilename;end;{:13}begin initialize;
begin writeln(logfile,'This is BibTeX, Version 0.99d');
writeln(tty,'This is BibTeX, Version 0.99d');end;
{110:}begin write(logfile,'The top-level auxiliary file: ');
write(tty,'The top-level auxiliary file: ');end;printauxname;
while true do begin auxlnstack[auxptr]:=auxlnstack[auxptr]+1;
if(not inputln(auxfile[auxptr]))then poptheauxstack else
getauxcommandandprocess;end;
{begin writeln(logfile,'Finished reading the auxiliary file(s)');end;}
31:lastcheckforauxerrors;{:110};{151:}if(bststr=0)then goto 9932;
bstlinenum:=0;bbllinenum:=1;bufptr2:=last;
while true do begin if(not eatbstwhitespace)then goto 32;
getbstcommandandprocess;end;32:aclose(bstfile);9932:aclose(bblfile);
{:151};
9998:{455:}begin if((readperformed)and(not readingcompleted))then begin
begin write(logfile,'Aborted at line ',biblinenum:0,' of file ');
write(tty,'Aborted at line ',biblinenum:0,' of file ');end;printbibname;
end;traceandstatprinting;{466:}case(history)of 0:;
1:begin if(errcount=1)then begin writeln(logfile,'(There was 1 warning)'
);writeln(tty,'(There was 1 warning)');
end else begin writeln(logfile,'(There were ',errcount:0,' warnings)');
writeln(tty,'(There were ',errcount:0,' warnings)');end;end;
2:begin if(errcount=1)then begin writeln(logfile,
'(There was 1 error message)');
writeln(tty,'(There was 1 error message)');
end else begin writeln(logfile,'(There were ',errcount:0,
' error messages)');
writeln(tty,'(There were ',errcount:0,' error messages)');end;end;
3:begin writeln(logfile,'(That was a fatal error)');
writeln(tty,'(That was a fatal error)');end;
others:begin begin write(logfile,'History is bunk');
write(tty,'History is bunk');end;printconfusion;end end{:466};
aclose(logfile);end{:455};9999:end.{:10}
