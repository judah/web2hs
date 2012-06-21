{3:}program DVI_type(dvi_file,output);label{4:}9999,30;
{:4}const{5:}max_fonts=100;max_widths=10000;line_length=79;
terminal_line_length=150;stack_size=100;name_size=1000;name_length=50;
{:5}type{8:}ASCII_code=32..126;{:8}{9:}text_file=packed file of char;
{:9}{21:}eight_bits=0..255;byte_file=packed file of eight_bits;
{:21}var{10:}xord:array[char]of ASCII_code;xchr:array[0..255]of char;
{:10}{22:}dvi_file:byte_file;tfm_file:byte_file;
{:22}{24:}cur_loc:integer;cur_name:packed array[1..name_length]of char;
{:24}{25:}b0,b1,b2,b3:eight_bits;
{:25}{30:}font_num:array[0..max_fonts]of integer;
font_name:array[0..max_fonts]of 1..name_size;
names:array[1..name_size]of ASCII_code;
font_check_sum:array[0..max_fonts]of integer;
font_scaled_size:array[0..max_fonts]of integer;
font_design_size:array[0..max_fonts]of integer;
font_space:array[0..max_fonts]of integer;
font_bc:array[0..max_fonts]of integer;
font_ec:array[0..max_fonts]of integer;
width_base:array[0..max_fonts]of integer;
width:array[0..max_widths]of integer;nf:0..max_fonts;
width_ptr:0..max_widths;{:30}{33:}in_width:array[0..255]of integer;
tfm_check_sum:integer;tfm_design_size:integer;tfm_conv:real;
{:33}{39:}pixel_width:array[0..max_widths]of integer;conv:real;
true_conv:real;numerator,denominator:integer;mag:integer;
{:39}{41:}out_mode:0..4;max_pages:integer;resolution:real;
new_mag:integer;{:41}{42:}start_count:array[0..9]of integer;
start_there:array[0..9]of boolean;start_vals:0..9;
count:array[0..9]of integer;
{:42}{45:}buffer:array[0..terminal_line_length]of ASCII_code;
term_in:text_file;term_out:text_file;
{:45}{48:}buf_ptr:0..terminal_line_length;
{:48}{57:}in_postamble:boolean;
{:57}{64:}default_directory:packed array[1..9]of char;
{:64}{67:}text_ptr:0..line_length;
text_buf:array[1..line_length]of ASCII_code;
{:67}{72:}h,v,w,x,y,z,hh,vv:integer;
hstack,vstack,wstack,xstack,ystack,zstack:array[0..stack_size]of integer
;hhstack,vvstack:array[0..stack_size]of integer;{:72}{73:}max_v:integer;
max_h:integer;max_s:integer;
max_v_so_far,max_h_so_far,max_s_so_far:integer;total_pages:integer;
page_count:integer;{:73}{78:}s:integer;ss:integer;cur_font:integer;
showing:boolean;{:78}{97:}old_backpointer:integer;
new_backpointer:integer;started:boolean;{:97}{101:}post_loc:integer;
first_backpointer:integer;start_loc:integer;after_pre:integer;
{:101}{108:}k,m,n,p,q:integer;{:108}procedure initialize;var i:integer;
begin write_ln('This is DVItype, Version 3.6');
{11:}for i:=0 to 31 do xchr[i]:='?';xchr[32]:=' ';xchr[33]:='!';
xchr[34]:='"';xchr[35]:='#';xchr[36]:='$';xchr[37]:='%';xchr[38]:='&';
xchr[39]:='''';xchr[40]:='(';xchr[41]:=')';xchr[42]:='*';xchr[43]:='+';
xchr[44]:=',';xchr[45]:='-';xchr[46]:='.';xchr[47]:='/';xchr[48]:='0';
xchr[49]:='1';xchr[50]:='2';xchr[51]:='3';xchr[52]:='4';xchr[53]:='5';
xchr[54]:='6';xchr[55]:='7';xchr[56]:='8';xchr[57]:='9';xchr[58]:=':';
xchr[59]:=';';xchr[60]:='<';xchr[61]:='=';xchr[62]:='>';xchr[63]:='?';
xchr[64]:='@';xchr[65]:='A';xchr[66]:='B';xchr[67]:='C';xchr[68]:='D';
xchr[69]:='E';xchr[70]:='F';xchr[71]:='G';xchr[72]:='H';xchr[73]:='I';
xchr[74]:='J';xchr[75]:='K';xchr[76]:='L';xchr[77]:='M';xchr[78]:='N';
xchr[79]:='O';xchr[80]:='P';xchr[81]:='Q';xchr[82]:='R';xchr[83]:='S';
xchr[84]:='T';xchr[85]:='U';xchr[86]:='V';xchr[87]:='W';xchr[88]:='X';
xchr[89]:='Y';xchr[90]:='Z';xchr[91]:='[';xchr[92]:='\';xchr[93]:=']';
xchr[94]:='^';xchr[95]:='_';xchr[96]:='`';xchr[97]:='a';xchr[98]:='b';
xchr[99]:='c';xchr[100]:='d';xchr[101]:='e';xchr[102]:='f';
xchr[103]:='g';xchr[104]:='h';xchr[105]:='i';xchr[106]:='j';
xchr[107]:='k';xchr[108]:='l';xchr[109]:='m';xchr[110]:='n';
xchr[111]:='o';xchr[112]:='p';xchr[113]:='q';xchr[114]:='r';
xchr[115]:='s';xchr[116]:='t';xchr[117]:='u';xchr[118]:='v';
xchr[119]:='w';xchr[120]:='x';xchr[121]:='y';xchr[122]:='z';
xchr[123]:='{';xchr[124]:='|';xchr[125]:='}';xchr[126]:='~';
for i:=127 to 255 do xchr[i]:='?';
{:11}{12:}for i:=0 to 127 do xord[chr(i)]:=32;
for i:=32 to 126 do xord[xchr[i]]:=i;{:12}{31:}nf:=0;width_ptr:=0;
font_name[0]:=1;font_space[max_fonts]:=0;font_bc[max_fonts]:=1;
font_ec[max_fonts]:=0;{:31}{43:}out_mode:=4;max_pages:=1000000;
start_vals:=0;start_there[0]:=false;{:43}{58:}in_postamble:=false;
{:58}{65:}default_directory:='TeXfonts:';{:65}{68:}text_ptr:=0;
{:68}{74:}max_v:=2147483548;max_h:=2147483548;max_s:=stack_size+1;
max_v_so_far:=0;max_h_so_far:=0;max_s_so_far:=0;page_count:=0;
{:74}{98:}old_backpointer:=-1;started:=false;{:98}end;
{:3}{7:}procedure jump_out;begin goto 9999;end;
{:7}{23:}procedure open_dvi_file;begin reset(dvi_file);cur_loc:=0;end;
procedure open_tfm_file;begin reset(tfm_file,cur_name);end;
{:23}{26:}procedure read_tfm_word;begin read(tfm_file,b0);
read(tfm_file,b1);read(tfm_file,b2);read(tfm_file,b3);end;
{:26}{27:}function get_byte:integer;var b:eight_bits;
begin if eof(dvi_file)then get_byte:=0 else begin read(dvi_file,b);
cur_loc:=cur_loc+1;get_byte:=b;end;end;function signed_byte:integer;
var b:eight_bits;begin read(dvi_file,b);cur_loc:=cur_loc+1;
if b<128 then signed_byte:=b else signed_byte:=b-256;end;
function get_two_bytes:integer;var a,b:eight_bits;
begin read(dvi_file,a);read(dvi_file,b);cur_loc:=cur_loc+2;
get_two_bytes:=a*256+b;end;function signed_pair:integer;
var a,b:eight_bits;begin read(dvi_file,a);read(dvi_file,b);
cur_loc:=cur_loc+2;
if a<128 then signed_pair:=a*256+b else signed_pair:=(a-256)*256+b;end;
function get_three_bytes:integer;var a,b,c:eight_bits;
begin read(dvi_file,a);read(dvi_file,b);read(dvi_file,c);
cur_loc:=cur_loc+3;get_three_bytes:=(a*256+b)*256+c;end;
function signed_trio:integer;var a,b,c:eight_bits;
begin read(dvi_file,a);read(dvi_file,b);read(dvi_file,c);
cur_loc:=cur_loc+3;
if a<128 then signed_trio:=(a*256+b)*256+c else signed_trio:=((a-256)
*256+b)*256+c;end;function signed_quad:integer;var a,b,c,d:eight_bits;
begin read(dvi_file,a);read(dvi_file,b);read(dvi_file,c);
read(dvi_file,d);cur_loc:=cur_loc+4;
if a<128 then signed_quad:=((a*256+b)*256+c)*256+d else signed_quad:=(((
a-256)*256+b)*256+c)*256+d;end;{:27}{28:}function dvi_length:integer;
begin set_pos(dvi_file,-1);dvi_length:=cur_pos(dvi_file);end;
procedure move_to_byte(n:integer);begin set_pos(dvi_file,n);cur_loc:=n;
end;{:28}{32:}procedure print_font(f:integer);var k:0..name_size;
begin if f=max_fonts then write('UNDEFINED!')else begin for k:=font_name
[f]to font_name[f+1]-1 do write(xchr[names[k]]);end;end;
{:32}{34:}function in_TFM(z:integer):boolean;label 9997,9998,9999;
var k:integer;lh:integer;nw:integer;wp:0..max_widths;alpha,beta:integer;
begin{35:}read_tfm_word;lh:=b2*256+b3;read_tfm_word;
font_bc[nf]:=b0*256+b1;font_ec[nf]:=b2*256+b3;
if font_ec[nf]<font_bc[nf]then font_bc[nf]:=font_ec[nf]+1;
if width_ptr+font_ec[nf]-font_bc[nf]+1>max_widths then begin write_ln(
'---not loaded, DVItype needs larger width table');goto 9998;end;
wp:=width_ptr+font_ec[nf]-font_bc[nf]+1;read_tfm_word;nw:=b0*256+b1;
if(nw=0)or(nw>256)then goto 9997;
for k:=1 to 3+lh do begin if eof(tfm_file)then goto 9997;read_tfm_word;
if k=4 then if b0<128 then tfm_check_sum:=((b0*256+b1)*256+b2)*256+b3
else tfm_check_sum:=(((b0-256)*256+b1)*256+b2)*256+b3 else if k=5 then
if b0<128 then tfm_design_size:=round(tfm_conv*(((b0*256+b1)*256+b2)*256
+b3))else goto 9997;end;{:35};
{36:}if wp>0 then for k:=width_ptr to wp-1 do begin read_tfm_word;
if b0>nw then goto 9997;width[k]:=b0;end;{:36};
{37:}{38:}begin alpha:=16;while z>=8388608 do begin z:=z div 2;
alpha:=alpha+alpha;end;beta:=256 div alpha;alpha:=alpha*z;end{:38};
for k:=0 to nw-1 do begin read_tfm_word;
in_width[k]:=(((((b3*z)div 256)+(b2*z))div 256)+(b1*z))div beta;
if b0>0 then if b0<255 then goto 9997 else in_width[k]:=in_width[k]-
alpha;end{:37};{40:}if in_width[0]<>0 then goto 9997;
width_base[nf]:=width_ptr-font_bc[nf];
if wp>0 then for k:=width_ptr to wp-1 do if width[k]=0 then begin width[
k]:=2147483647;pixel_width[k]:=0;
end else begin width[k]:=in_width[width[k]];
pixel_width[k]:=round(conv*(width[k]));end{:40};width_ptr:=wp;
in_TFM:=true;goto 9999;9997:write_ln('---not loaded, TFM file is bad');
9998:in_TFM:=false;9999:end;{:34}{44:}function start_match:boolean;
var k:0..9;match:boolean;begin match:=true;
for k:=0 to start_vals do if start_there[k]and(start_count[k]<>count[k])
then match:=false;start_match:=match;end;{:44}{47:}procedure input_ln;
var k:0..terminal_line_length;begin break(term_out);reset(term_in);
if eoln(term_in)then read_ln(term_in);k:=0;
while(k<terminal_line_length)and not eoln(term_in)do begin buffer[k]:=
xord[term_in^];k:=k+1;get(term_in);end;buffer[k]:=32;end;
{:47}{49:}function get_integer:integer;var x:integer;negative:boolean;
begin if buffer[buf_ptr]=45 then begin negative:=true;
buf_ptr:=buf_ptr+1;end else negative:=false;x:=0;
while(buffer[buf_ptr]>=48)and(buffer[buf_ptr]<=57)do begin x:=10*x+
buffer[buf_ptr]-48;buf_ptr:=buf_ptr+1;end;
if negative then get_integer:=-x else get_integer:=x;end;
{:49}{50:}procedure dialog;label 1,2,3,4,5;var k:integer;
begin rewrite(term_out);
write_ln(term_out,'This is DVItype, Version 3.6');
{51:}1:write(term_out,'Output level (default=4, ? for help): ');
out_mode:=4;input_ln;
if buffer[0]<>32 then if(buffer[0]>=48)and(buffer[0]<=52)then out_mode:=
buffer[0]-48 else begin write(term_out,'Type 4 for complete listing,');
write(term_out,' 0 for errors and fonts only,');
write_ln(term_out,' 1 or 2 or 3 for something in between.');goto 1;
end{:51};{52:}2:write(term_out,'Starting page (default=*): ');
start_vals:=0;start_there[0]:=false;input_ln;buf_ptr:=0;k:=0;
if buffer[0]<>32 then repeat if buffer[buf_ptr]=42 then begin
start_there[k]:=false;buf_ptr:=buf_ptr+1;
end else begin start_there[k]:=true;start_count[k]:=get_integer;end;
if(k<9)and(buffer[buf_ptr]=46)then begin k:=k+1;buf_ptr:=buf_ptr+1;
end else if buffer[buf_ptr]=32 then start_vals:=k else begin write(
term_out,'Type, e.g., 1.*.-5 to specify the ');
write_ln(term_out,'first page with \count0=1, \count2=-5.');goto 2;end;
until start_vals=k{:52};
{53:}3:write(term_out,'Maximum number of pages (default=1000000): ');
max_pages:=1000000;input_ln;buf_ptr:=0;
if buffer[0]<>32 then begin max_pages:=get_integer;
if max_pages<=0 then begin write_ln(term_out,
'Please type a positive number.');goto 3;end;end{:53};
{54:}4:write(term_out,'Assumed device resolution');
write(term_out,' in pixels per inch (default=300/1): ');
resolution:=300.0;input_ln;buf_ptr:=0;
if buffer[0]<>32 then begin k:=get_integer;
if(k>0)and(buffer[buf_ptr]=47)and(buffer[buf_ptr+1]>48)and(buffer[
buf_ptr+1]<=57)then begin buf_ptr:=buf_ptr+1;resolution:=k/get_integer;
end else begin write(term_out,'Type a ratio of positive integers;');
write_ln(term_out,' (1 pixel per mm would be 254/10).');goto 4;end;
end{:54};{55:}5:write(term_out,
'New magnification (default=0 to keep the old one): ');new_mag:=0;
input_ln;buf_ptr:=0;
if buffer[0]<>32 then if(buffer[0]>=48)and(buffer[0]<=57)then new_mag:=
get_integer else begin write(term_out,
'Type a positive integer to override ');
write_ln(term_out,'the magnification in the DVI file.');goto 5;end{:55};
{56:}write_ln('Options selected:');write('  Starting page = ');
for k:=0 to start_vals do begin if start_there[k]then write(start_count[
k]:1)else write('*');if k<start_vals then write('.')else write_ln(' ');
end;write_ln('  Maximum number of pages = ',max_pages:1);
write('  Output level = ',out_mode:1);case out_mode of 0:write_ln(
' (showing bops, fonts, and error messages only)');
1:write_ln(' (terse)');2:write_ln(' (mnemonics)');
3:write_ln(' (verbose)');
4:if true then write_ln(' (the works)')else begin out_mode:=3;
write_ln(' (the works: same as level 3 in this DVItype)');end;end;
write_ln('  Resolution = ',resolution:12:8,' pixels per inch');
if new_mag>0 then write_ln('  New magnification factor = ',new_mag/1000:
8:3){:56};end;{:50}{59:}procedure define_font(e:integer);
var f:0..max_fonts;p:integer;n:integer;c,q,d,m:integer;r:0..name_length;
j,k:0..name_size;mismatch:boolean;
begin if nf=max_fonts then begin write(' ',
'DVItype capacity exceeded (max fonts=',max_fonts:1,')!');jump_out;end;
font_num[nf]:=e;f:=0;while font_num[f]<>e do f:=f+1;{61:}c:=signed_quad;
font_check_sum[nf]:=c;q:=signed_quad;font_scaled_size[nf]:=q;
d:=signed_quad;font_design_size[nf]:=d;
if(q<=0)or(d<=0)then m:=1000 else m:=round((1000.0*conv*q)/(true_conv*d)
);p:=get_byte;n:=get_byte;
if font_name[nf]+n+p>name_size then begin write(' ',
'DVItype capacity exceeded (name size=',name_size:1,')!');jump_out;end;
font_name[nf+1]:=font_name[nf]+n+p;
if showing then write(': ')else write('Font ',e:1,': ');
if n+p=0 then write('null font name!')else for k:=font_name[nf]to
font_name[nf+1]-1 do names[k]:=get_byte;print_font(nf);
if not showing then if m<>1000 then write(' scaled ',m:1){:61};
if((out_mode=4)and in_postamble)or((out_mode<4)and not in_postamble)then
begin if f<nf then write_ln('---this font was already defined!');
end else begin if f=nf then write_ln(
'---this font wasn''t loaded before!');end;
if f=nf then{62:}begin{66:}for k:=1 to name_length do cur_name[k]:=' ';
if p=0 then begin for k:=1 to 9 do cur_name[k]:=default_directory[k];
r:=9;end else r:=0;
for k:=font_name[nf]to font_name[nf+1]-1 do begin r:=r+1;
if r+5>name_length then begin write(' ',
'DVItype capacity exceeded (max font name length=',name_length:1,')!');
jump_out;end;cur_name[r]:=xchr[names[k]];end;cur_name[r+1]:='.';
cur_name[r+2]:='t';cur_name[r+3]:='f';cur_name[r+4]:='m';
cur_name[r+5]:='\0';{:66};open_tfm_file;
if eof(tfm_file)then write('---not loaded, TFM file can''t be opened!')
else begin if(q<=0)or(q>=134217728)then write(
'---not loaded, bad scale (',q:1,')!')else if(d<=0)or(d>=134217728)then
write('---not loaded, bad design size (',d:1,')!')else if in_TFM(q)then
{63:}begin font_space[nf]:=q div 6;
if(c<>0)and(tfm_check_sum<>0)and(c<>tfm_check_sum)then begin write_ln(
'---beware: check sums do not agree!');
write_ln('   (',c:1,' vs. ',tfm_check_sum:1,')');write('   ');end;
if abs(tfm_design_size-d)>2 then begin write_ln(
'---beware: design sizes do not agree!');
write_ln('   (',d:1,' vs. ',tfm_design_size:1,')');write('   ');end;
write('---loaded at size ',q:1,' DVI units');
d:=round((100.0*conv*q)/(true_conv*d));
if d<>100 then begin write_ln(' ');
write(' (this font is magnified ',d:1,'%)');end;nf:=nf+1;end{:63};end;
if out_mode=0 then write_ln(' ');
end{:62}else{60:}begin if font_check_sum[f]<>c then write_ln(
'---check sum doesn''t match previous definition!');
if font_scaled_size[f]<>q then write_ln(
'---scaled size doesn''t match previous definition!');
if font_design_size[f]<>d then write_ln(
'---design size doesn''t match previous definition!');j:=font_name[f];
k:=font_name[nf];
if font_name[f+1]-j<>font_name[nf+1]-k then mismatch:=true else begin
mismatch:=false;
while j<font_name[f+1]do begin if names[j]<>names[k]then mismatch:=true;
j:=j+1;k:=k+1;end;end;if mismatch then write_ln(
'---font name doesn''t match previous definition!');end{:60};end;
{:59}{69:}procedure flush_text;var k:0..line_length;
begin if text_ptr>0 then begin if out_mode>0 then begin write('[');
for k:=1 to text_ptr do write(xchr[text_buf[k]]);write_ln(']');end;
text_ptr:=0;end;end;{:69}{70:}procedure out_text(c:ASCII_code);
begin if text_ptr=line_length-2 then flush_text;text_ptr:=text_ptr+1;
text_buf[text_ptr]:=c;end;
{:70}{75:}function first_par(o:eight_bits):integer;
begin case o of 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,
46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,
70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,
94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,
113,114,115,116,117,118,119,120,121,122,123,124,125,126,127:first_par:=o
-0;128,133,235,239,243:first_par:=get_byte;
129,134,236,240,244:first_par:=get_two_bytes;
130,135,237,241,245:first_par:=get_three_bytes;
143,148,153,157,162,167:first_par:=signed_byte;
144,149,154,158,163,168:first_par:=signed_pair;
145,150,155,159,164,169:first_par:=signed_trio;
131,132,136,137,146,151,156,160,165,170,238,242,246:first_par:=
signed_quad;
138,139,140,141,142,247,248,249,250,251,252,253,254,255:first_par:=0;
147:first_par:=w;152:first_par:=x;161:first_par:=y;166:first_par:=z;
171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,
189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,
207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,
225,226,227,228,229,230,231,232,233,234:first_par:=o-171;end;end;
{:75}{76:}function rule_pixels(x:integer):integer;var n:integer;
begin n:=trunc(conv*x);
if n<conv*x then rule_pixels:=n+1 else rule_pixels:=n;end;
{:76}{79:}{82:}function special_cases(o:eight_bits;p,a:integer):boolean;
label 46,44,30,9998;var q:integer;k:integer;bad_char:boolean;
pure:boolean;vvv:integer;begin pure:=true;
case o of{85:}157,158,159,160:begin if abs(p)>=5*font_space[cur_font]
then vv:=round(conv*(v+p))else vv:=vv+round(conv*(p));
if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','down',o-156:1,' ',p:1);end;goto 44;end;
161,162,163,164,165:begin y:=p;
if abs(p)>=5*font_space[cur_font]then vv:=round(conv*(v+p))else vv:=vv+
round(conv*(p));if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','y',o-161:1,' ',p:1);end;goto 44;end;
166,167,168,169,170:begin z:=p;
if abs(p)>=5*font_space[cur_font]then vv:=round(conv*(v+p))else vv:=vv+
round(conv*(p));if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','z',o-166:1,' ',p:1);end;goto 44;end;
{:85}{86:}171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,
186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,
204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,
222,223,224,225,226,227,228,229,230,231,232,233,234:begin if out_mode>0
then begin flush_text;showing:=true;write(a:1,': ','fntnum',p:1);end;
goto 46;end;235,236,237,238:begin if out_mode>0 then begin flush_text;
showing:=true;write(a:1,': ','fnt',o-234:1,' ',p:1);end;goto 46;end;
243,244,245,246:begin if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','fntdef',o-242:1,' ',p:1);end;define_font(p);goto 30;end;
{:86}239,240,241,242:{87:}begin if out_mode>0 then begin flush_text;
showing:=true;write(a:1,': ','xxx ''');end;bad_char:=false;
if p<0 then if not showing then begin flush_text;showing:=true;
write(a:1,': ','string of negative length!');
end else write(' ','string of negative length!');
for k:=1 to p do begin q:=get_byte;if(q<32)or(q>126)then bad_char:=true;
if showing then write(xchr[q]);end;if showing then write('''');
if bad_char then if not showing then begin flush_text;showing:=true;
write(a:1,': ','non-ASCII character in xxx command!');
end else write(' ','non-ASCII character in xxx command!');goto 30;
end{:87};247:begin if not showing then begin flush_text;showing:=true;
write(a:1,': ','preamble command within a page!');
end else write(' ','preamble command within a page!');goto 9998;end;
248,249:begin if not showing then begin flush_text;showing:=true;
write(a:1,': ','postamble command within a page!');
end else write(' ','postamble command within a page!');goto 9998;end;
others:begin if not showing then begin flush_text;showing:=true;
write(a:1,': ','undefined command ',o:1,'!');
end else write(' ','undefined command ',o:1,'!');goto 30;end end;
44:{92:}if(v>0)and(p>0)then if v>2147483647-p then begin if not showing
then begin flush_text;showing:=true;
write(a:1,': ','arithmetic overflow! parameter changed from ',p:1,' to '
,2147483647-v:1);
end else write(' ','arithmetic overflow! parameter changed from ',p:1,
' to ',2147483647-v:1);p:=2147483647-v;end;
if(v<0)and(p<0)then if-v>p+2147483647 then begin if not showing then
begin flush_text;showing:=true;
write(a:1,': ','arithmetic overflow! parameter changed from ',p:1,' to '
,(-v)-2147483647:1);
end else write(' ','arithmetic overflow! parameter changed from ',p:1,
' to ',(-v)-2147483647:1);p:=(-v)-2147483647;end;vvv:=round(conv*(v+p));
if abs(vvv-vv)>2 then if vvv>vv then vv:=vvv-2 else vv:=vvv+2;
if showing then if out_mode>2 then begin write(' v:=',v:1);
if p>=0 then write('+');write(p:1,'=',v+p:1,', vv:=',vv:1);end;v:=v+p;
if abs(v)>max_v_so_far then begin if abs(v)>max_v+99 then begin if not
showing then begin flush_text;showing:=true;
write(a:1,': ','warning: |v|>',max_v:1,'!');
end else write(' ','warning: |v|>',max_v:1,'!');max_v:=abs(v);end;
max_v_so_far:=abs(v);end;goto 30{:92};46:{94:}font_num[nf]:=p;
cur_font:=0;while font_num[cur_font]<>p do cur_font:=cur_font+1;
if cur_font=nf then begin cur_font:=max_fonts;
if not showing then begin flush_text;showing:=true;
write(a:1,': ','invalid font selection: font ',p:1,' was never defined!'
);end else write(' ','invalid font selection: font ',p:1,
' was never defined!');end;
if showing then if out_mode>2 then begin write(' current font is ');
print_font(cur_font);end;goto 30{:94};9998:pure:=false;
30:special_cases:=pure;end;{:82}function do_page:boolean;
label 41,42,43,45,30,9998,9999;var o:eight_bits;p,q:integer;a:integer;
hhh:integer;begin cur_font:=max_fonts;s:=0;h:=0;v:=0;w:=0;x:=0;y:=0;
z:=0;hh:=0;vv:=0;while true do{80:}begin a:=cur_loc;showing:=false;
o:=get_byte;p:=first_par(o);
if eof(dvi_file)then begin write(' ','Bad DVI file: ',
'the file ended prematurely','!');jump_out;end;
{81:}if o<128 then{88:}begin if(o>32)and(o<=126)then begin out_text(p);
if out_mode>1 then begin showing:=true;write(a:1,': ','setchar',p:1);
end;end else if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','setchar',p:1);end;goto 41;
end{:88}else case o of 128,129,130,131:begin if out_mode>0 then begin
flush_text;showing:=true;write(a:1,': ','set',o-127:1,' ',p:1);end;
goto 41;end;133,134,135,136:begin if out_mode>0 then begin flush_text;
showing:=true;write(a:1,': ','put',o-132:1,' ',p:1);end;goto 41;end;
132:begin if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','setrule');end;goto 42;end;
137:begin if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','putrule');end;goto 42;end;
{83:}138:begin if out_mode>1 then begin showing:=true;
write(a:1,': ','nop');end;goto 30;end;
139:begin if not showing then begin flush_text;showing:=true;
write(a:1,': ','bop occurred before eop!');
end else write(' ','bop occurred before eop!');goto 9998;end;
140:begin if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','eop');end;
if s<>0 then if not showing then begin flush_text;showing:=true;
write(a:1,': ','stack not empty at end of page (level ',s:1,')!');
end else write(' ','stack not empty at end of page (level ',s:1,')!');
do_page:=true;write_ln(' ');goto 9999;end;
141:begin if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','push');end;
if s=max_s_so_far then begin max_s_so_far:=s+1;
if s=max_s then if not showing then begin flush_text;showing:=true;
write(a:1,': ','deeper than claimed in postamble!');
end else write(' ','deeper than claimed in postamble!');
if s=stack_size then begin if not showing then begin flush_text;
showing:=true;
write(a:1,': ','DVItype capacity exceeded (stack size=',stack_size:1,')'
);
end else write(' ','DVItype capacity exceeded (stack size=',stack_size:1
,')');goto 9998;end;end;hstack[s]:=h;vstack[s]:=v;wstack[s]:=w;
xstack[s]:=x;ystack[s]:=y;zstack[s]:=z;hhstack[s]:=hh;vvstack[s]:=vv;
s:=s+1;ss:=s-1;goto 45;end;
142:begin if out_mode>0 then begin flush_text;showing:=true;
write(a:1,': ','pop');end;
if s=0 then if not showing then begin flush_text;showing:=true;
write(a:1,': ','(illegal at level zero)!');
end else write(' ','(illegal at level zero)!')else begin s:=s-1;
hh:=hhstack[s];vv:=vvstack[s];h:=hstack[s];v:=vstack[s];w:=wstack[s];
x:=xstack[s];y:=ystack[s];z:=zstack[s];end;ss:=s;goto 45;end;
{:83}{84:}143,144,145,146:begin if(p>=font_space[cur_font])or(p<=-4*
font_space[cur_font])then begin out_text(32);hh:=round(conv*(h+p));
end else hh:=hh+round(conv*(p));if out_mode>1 then begin showing:=true;
write(a:1,': ','right',o-142:1,' ',p:1);end;q:=p;goto 43;end;
147,148,149,150,151:begin w:=p;
if(p>=font_space[cur_font])or(p<=-4*font_space[cur_font])then begin
out_text(32);hh:=round(conv*(h+p));end else hh:=hh+round(conv*(p));
if out_mode>1 then begin showing:=true;
write(a:1,': ','w',o-147:1,' ',p:1);end;q:=p;goto 43;end;
152,153,154,155,156:begin x:=p;
if(p>=font_space[cur_font])or(p<=-4*font_space[cur_font])then begin
out_text(32);hh:=round(conv*(h+p));end else hh:=hh+round(conv*(p));
if out_mode>1 then begin showing:=true;
write(a:1,': ','x',o-152:1,' ',p:1);end;q:=p;goto 43;end;
{:84}others:if special_cases(o,p,a)then goto 30 else goto 9998 end{:81};
41:{89:}if p<0 then p:=255-((-1-p)mod 256)else if p>=256 then p:=p mod
256;
if(p<font_bc[cur_font])or(p>font_ec[cur_font])then q:=2147483647 else q
:=width[width_base[cur_font]+p];
if q=2147483647 then begin if not showing then begin flush_text;
showing:=true;write(a:1,': ','character ',p:1,' invalid in font ');
end else write(' ','character ',p:1,' invalid in font ');
print_font(cur_font);if cur_font<>max_fonts then write('!');end;
if o>=133 then goto 30;
if q=2147483647 then q:=0 else hh:=hh+pixel_width[width_base[cur_font]+p
];goto 43{:89};42:{90:}q:=signed_quad;
if showing then begin write(' height ',p:1,', width ',q:1);
if out_mode>2 then if(p<=0)or(q<=0)then write(' (invisible)')else write(
' (',rule_pixels(p):1,'x',rule_pixels(q):1,' pixels)');end;
if o=137 then goto 30;if showing then if out_mode>2 then write_ln(' ');
hh:=hh+rule_pixels(q);goto 43{:90};
43:{91:}if(h>0)and(q>0)then if h>2147483647-q then begin if not showing
then begin flush_text;showing:=true;
write(a:1,': ','arithmetic overflow! parameter changed from ',q:1,' to '
,2147483647-h:1);
end else write(' ','arithmetic overflow! parameter changed from ',q:1,
' to ',2147483647-h:1);q:=2147483647-h;end;
if(h<0)and(q<0)then if-h>q+2147483647 then begin if not showing then
begin flush_text;showing:=true;
write(a:1,': ','arithmetic overflow! parameter changed from ',q:1,' to '
,(-h)-2147483647:1);
end else write(' ','arithmetic overflow! parameter changed from ',q:1,
' to ',(-h)-2147483647:1);q:=(-h)-2147483647;end;hhh:=round(conv*(h+q));
if abs(hhh-hh)>2 then if hhh>hh then hh:=hhh-2 else hh:=hhh+2;
if showing then if out_mode>2 then begin write(' h:=',h:1);
if q>=0 then write('+');write(q:1,'=',h+q:1,', hh:=',hh:1);end;h:=h+q;
if abs(h)>max_h_so_far then begin if abs(h)>max_h+99 then begin if not
showing then begin flush_text;showing:=true;
write(a:1,': ','warning: |h|>',max_h:1,'!');
end else write(' ','warning: |h|>',max_h:1,'!');max_h:=abs(h);end;
max_h_so_far:=abs(h);end;goto 30{:91};
45:{93:}if showing then if out_mode>2 then begin write_ln(' ');
write('level ',ss:1,':(h=',h:1,',v=',v:1,',w=',w:1,',x=',x:1,',y=',y:1,
',z=',z:1,',hh=',hh:1,',vv=',vv:1,')');end;goto 30{:93};
30:if showing then write_ln(' ');end{:80};9998:write_ln('!');
do_page:=false;9999:end;{:79}{95:}{99:}procedure scan_bop;var k:0..255;
begin repeat if eof(dvi_file)then begin write(' ','Bad DVI file: ',
'the file ended prematurely','!');jump_out;end;k:=get_byte;
if(k>=243)and(k<247)then begin define_font(first_par(k));k:=138;end;
until k<>138;
if k=248 then in_postamble:=true else begin if k<>139 then begin write(
' ','Bad DVI file: ','byte ',cur_loc-1:1,' is not bop','!');jump_out;
end;new_backpointer:=cur_loc-1;page_count:=page_count+1;
for k:=0 to 9 do count[k]:=signed_quad;
if signed_quad<>old_backpointer then write_ln('backpointer in byte ',
cur_loc-4:1,' should be ',old_backpointer:1,'!');
old_backpointer:=new_backpointer;end;end;
{:99}procedure skip_pages(bop_seen:boolean);label 9999;var p:integer;
k:0..255;down_the_drain:integer;begin showing:=false;
while true do begin if not bop_seen then begin scan_bop;
if in_postamble then goto 9999;
if not started then if start_match then begin started:=true;goto 9999;
end;end;
{96:}repeat if eof(dvi_file)then begin write(' ','Bad DVI file: ',
'the file ended prematurely','!');jump_out;end;k:=get_byte;
p:=first_par(k);case k of 132,137:down_the_drain:=signed_quad;
243,244,245,246:begin define_font(p);write_ln(' ');end;
239,240,241,242:while p>0 do begin down_the_drain:=get_byte;p:=p-1;end;
139,247,248,249,250,251,252,253,254,255:begin write(' ','Bad DVI file: '
,'illegal command at byte ',cur_loc-1:1,'!');jump_out;end;others:end;
until k=140;{:96};bop_seen:=false;end;9999:end;
{:95}{103:}procedure read_postamble;var k:integer;p,q,m:integer;
begin showing:=false;post_loc:=cur_loc-5;
write_ln('Postamble starts at byte ',post_loc:1,'.');
if signed_quad<>numerator then write_ln(
'numerator doesn''t match the preamble!');
if signed_quad<>denominator then write_ln(
'denominator doesn''t match the preamble!');
if signed_quad<>mag then if new_mag=0 then write_ln(
'magnification doesn''t match the preamble!');max_v:=signed_quad;
max_h:=signed_quad;write('maxv=',max_v:1,', maxh=',max_h:1);
max_s:=get_two_bytes;total_pages:=get_two_bytes;
write_ln(', maxstackdepth=',max_s:1,', totalpages=',total_pages:1);
if out_mode<4 then{104:}begin if max_v+99<max_v_so_far then write_ln(
'warning: observed maxv was ',max_v_so_far:1);
if max_h+99<max_h_so_far then write_ln('warning: observed maxh was ',
max_h_so_far:1);if max_s<max_s_so_far then write_ln(
'warning: observed maxstackdepth was ',max_s_so_far:1);
if page_count<>total_pages then write_ln('there are really ',page_count:
1,' pages, not ',total_pages:1,'!');end{:104};{106:}repeat k:=get_byte;
if(k>=243)and(k<247)then begin p:=first_par(k);define_font(p);
write_ln(' ');k:=138;end;until k<>138;
if k<>249 then write_ln('byte ',cur_loc-1:1,' is not postpost!'){:106};
{105:}q:=signed_quad;
if q<>post_loc then write_ln('bad postamble pointer in byte ',cur_loc-4:
1,'!');m:=get_byte;
if m<>2 then write_ln('identification in byte ',cur_loc-1:1,
' should be ',2:1,'!');k:=cur_loc;m:=223;
while(m=223)and not eof(dvi_file)do m:=get_byte;
if not eof(dvi_file)then begin write(' ','Bad DVI file: ',
'signature in byte ',cur_loc-1:1,' should be 223','!');jump_out;
end else if cur_loc<k+4 then write_ln(
'not enough signature bytes at end of file (',cur_loc-k:1,')');{:105};
end;{:103}{107:}begin initialize;dialog;{109:}open_dvi_file;p:=get_byte;
if p<>247 then begin write(' ','Bad DVI file: ',
'First byte isn''t start of preamble!','!');jump_out;end;p:=get_byte;
if p<>2 then write_ln('identification in byte 1 should be ',2:1,'!');
{110:}numerator:=signed_quad;denominator:=signed_quad;
if numerator<=0 then begin write(' ','Bad DVI file: ','numerator is ',
numerator:1,'!');jump_out;end;
if denominator<=0 then begin write(' ','Bad DVI file: ',
'denominator is ',denominator:1,'!');jump_out;end;
write_ln('numerator/denominator=',numerator:1,'/',denominator:1);
tfm_conv:=(25400000.0/numerator)*(denominator/473628672)/16.0;
conv:=(numerator/254000.0)*(resolution/denominator);mag:=signed_quad;
if new_mag>0 then mag:=new_mag else if mag<=0 then begin write(' ',
'Bad DVI file: ','magnification is ',mag:1,'!');jump_out;end;
true_conv:=conv;conv:=true_conv*(mag/1000.0);
write_ln('magnification=',mag:1,'; ',conv:16:8,' pixels per DVI unit')
{:110};p:=get_byte;write('''');while p>0 do begin p:=p-1;
write(xchr[get_byte]);end;write_ln('''');after_pre:=cur_loc{:109};
if out_mode=4 then begin{100:}n:=dvi_length;
if n<53 then begin write(' ','Bad DVI file: ','only ',n:1,' bytes long',
'!');jump_out;end;m:=n-4;
repeat if m=0 then begin write(' ','Bad DVI file: ','all 223s','!');
jump_out;end;move_to_byte(m);k:=get_byte;m:=m-1;until k<>223;
if k<>2 then begin write(' ','Bad DVI file: ','ID byte is ',k:1,'!');
jump_out;end;move_to_byte(m-3);q:=signed_quad;
if(q<0)or(q>m-33)then begin write(' ','Bad DVI file: ','post pointer ',q
:1,' at byte ',m-3:1,'!');jump_out;end;move_to_byte(q);k:=get_byte;
if k<>248 then begin write(' ','Bad DVI file: ','byte ',q:1,
' is not post','!');jump_out;end;post_loc:=q;
first_backpointer:=signed_quad{:100};in_postamble:=true;read_postamble;
in_postamble:=false;{102:}q:=post_loc;p:=first_backpointer;
start_loc:=-1;
if p<0 then in_postamble:=true else begin repeat if p>q-46 then begin
write(' ','Bad DVI file: ','page link ',p:1,' after byte ',q:1,'!');
jump_out;end;q:=p;move_to_byte(q);k:=get_byte;
if k=139 then page_count:=page_count+1 else begin write(' ',
'Bad DVI file: ','byte ',q:1,' is not bop','!');jump_out;end;
for k:=0 to 9 do count[k]:=signed_quad;p:=signed_quad;
if start_match then begin start_loc:=q;old_backpointer:=p;end;until p<0;
if start_loc<0 then begin write(' ',
'starting page number could not be found!');jump_out;end;
if old_backpointer<0 then start_loc:=after_pre;move_to_byte(start_loc);
end;
if page_count<>total_pages then write_ln('there are really ',page_count:
1,' pages, not ',total_pages:1,'!'){:102};end;skip_pages(false);
if not in_postamble then{111:}begin while max_pages>0 do begin max_pages
:=max_pages-1;write_ln(' ');write(cur_loc-45:1,': beginning of page ');
for k:=0 to start_vals do begin write(count[k]:1);
if k<start_vals then write('.')else write_ln(' ');end;
if not do_page then begin write(' ','Bad DVI file: ',
'page ended unexpectedly','!');jump_out;end;scan_bop;
if in_postamble then goto 30;end;30:end{:111};
if out_mode<4 then begin if not in_postamble then skip_pages(true);
if signed_quad<>old_backpointer then write_ln('backpointer in byte ',
cur_loc-4:1,' should be ',old_backpointer:1,'!');read_postamble;end;
9999:end.{:107}
