{2:}program POOLtype(poolfile,output);label 9999;
type{5:}ASCIIcode=0..255;{:5}var{7:}xord:array[char]of ASCIIcode;
xchr:array[ASCIIcode]of char;{:7}{12:}k,l:0..255;m,n:char;s:integer;
{:12}{13:}count:integer;{:13}{18:}poolfile:packed file of char;
procedure initialize;
begin xchr[32]:=' ';xchr[33]:='!';xchr[34]:='"';xchr[35]:='#';
end;
begin
x := 7;
end.
