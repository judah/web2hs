{2:}program POOLtype(poolfile,output);label 9999;
type{5:}ASCIIcode=0..255;{:5}var{7:}xord:array[char]of ASCIIcode;
xchr:array[ASCIIcode]of char;{:7}{12:}k,l:0..255;m,n:char;s:integer;
{:12}{13:}count:integer;{:13}{18:}poolfile:packed file of char;
xsum:boolean;{:18}

procedure initialize;var{6:}i:integer;
{:6}begin{8:}xchr[32]:=' ';xchr[33]:='!';xchr[34]:='"';xchr[35]:='#';
xchr[36]:='$';xchr[37]:='%';xchr[38]:='&';xchr[39]:='''';xchr[40]:='(';
xchr[41]:=')';xchr[42]:='*';xchr[43]:='+';xchr[44]:=',';xchr[45]:='-';
xchr[46]:='.';xchr[47]:='/';xchr[48]:='0';xchr[49]:='1';xchr[50]:='2';
xchr[51]:='3';xchr[52]:='4';xchr[53]:='5';xchr[54]:='6';xchr[55]:='7';
xchr[56]:='8';xchr[57]:='9';xchr[58]:=':';xchr[59]:=';';xchr[60]:='<';
xchr[61]:='=';xchr[62]:='>';xchr[63]:='?';xchr[64]:='@';xchr[65]:='A';
xchr[66]:='B';xchr[67]:='C';xchr[68]:='D';xchr[69]:='E';xchr[70]:='F';
xchr[71]:='G';xchr[72]:='H';xchr[73]:='I';xchr[74]:='J';xchr[75]:='K';
xchr[76]:='L';xchr[77]:='M';xchr[78]:='N';xchr[79]:='O';xchr[80]:='P';
xchr[81]:='Q';xchr[82]:='R';xchr[83]:='S';xchr[84]:='T';xchr[85]:='U';
xchr[86]:='V';xchr[87]:='W';xchr[88]:='X';xchr[89]:='Y';xchr[90]:='Z';
xchr[91]:='[';xchr[92]:='\';xchr[93]:=']';xchr[94]:='^';xchr[95]:='_';
xchr[96]:='`';xchr[97]:='a';xchr[98]:='b';xchr[99]:='c';xchr[100]:='d';
xchr[101]:='e';xchr[102]:='f';xchr[103]:='g';xchr[104]:='h';
xchr[105]:='i';xchr[106]:='j';xchr[107]:='k';xchr[108]:='l';
xchr[109]:='m';xchr[110]:='n';xchr[111]:='o';xchr[112]:='p';
xchr[113]:='q';xchr[114]:='r';xchr[115]:='s';xchr[116]:='t';
xchr[117]:='u';xchr[118]:='v';xchr[119]:='w';xchr[120]:='x';
end;
begin
x := 7;
end.
