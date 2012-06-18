{2:}{4:}{$C-,A+,D-}{[$C+,D+]}
{:4}program TANGLE(web_file,change_file,Pascal_file,pool);label 9999;
const{8:}buf_size=100;max_bytes=45000;max_toks=50000;max_names=4000;
max_texts=2000;hash_size=353;longest_name=400;line_length=72;
out_buf_size=144;stack_size=50;max_id_length=50;unambig_length=7;
{:8}type{11:}ASCII_code=0..255;{:11}{12:}text_file=packed file of char;
{:12}{37:}eight_bits=0..255;sixteen_bits=0..65535;
{:37}{39:}name_pointer=0..max_names;{:39}{43:}text_pointer=0..max_texts;
{:43}{78:}output_state=record end_field:sixteen_bits;
byte_field:sixteen_bits;name_field:name_pointer;repl_field:text_pointer;
mod_field:0..12287;end;{:78}var{9:}history:0..3;
{:9}{13:}xord:array[char]of ASCII_code;xchr:array[ASCII_code]of char;
{:13}{20:}term_out:text_file;{:20}{23:}web_file:text_file;
change_file:text_file;{:23}{25:}Pascal_file:text_file;pool:text_file;
{:25}{27:}buffer:array[0..buf_size]of ASCII_code;
{:27}{29:}phase_one:boolean;
{:29}{38:}byte_mem:packed array[0..1,0..max_bytes]of ASCII_code;
tok_mem:packed array[0..2,0..max_toks]of eight_bits;
byte_start:array[0..max_names]of sixteen_bits;
tok_start:array[0..max_texts]of sixteen_bits;
link:array[0..max_names]of sixteen_bits;
ilk:array[0..max_names]of sixteen_bits;
equiv:array[0..max_names]of sixteen_bits;
text_link:array[0..max_texts]of sixteen_bits;
{:38}{40:}name_ptr:name_pointer;string_ptr:name_pointer;
byte_ptr:array[0..1]of 0..max_bytes;pool_check_sum:integer;
{:40}{44:}text_ptr:text_pointer;tok_ptr:array[0..2]of 0..max_toks;
z:0..2;{max_tok_ptr:array[0..2]of 0..max_toks;}
{:44}{50:}id_first:0..buf_size;id_loc:0..buf_size;
double_chars:0..buf_size;
hash,chop_hash:array[0..hash_size]of sixteen_bits;
chopped_id:array[0..unambig_length]of ASCII_code;
{:50}{65:}mod_text:array[0..longest_name]of ASCII_code;
{:65}{70:}last_unnamed:text_pointer;{:70}{79:}cur_state:output_state;
stack:array[1..stack_size]of output_state;stack_ptr:0..stack_size;
{:79}{80:}zo:0..2;{:80}{82:}brace_level:eight_bits;
{:82}{86:}cur_val:integer;
{:86}{94:}out_buf:array[0..out_buf_size]of ASCII_code;
out_ptr:0..out_buf_size;break_ptr:0..out_buf_size;
semi_ptr:0..out_buf_size;{:94}{95:}out_state:eight_bits;
out_val,out_app:integer;out_sign:ASCII_code;last_sign:-1..+1;
{:95}{100:}out_contrib:array[1..line_length]of ASCII_code;
{:100}{124:}ii:integer;line:integer;other_line:integer;
temp_line:integer;limit:0..buf_size;loc:0..buf_size;
input_has_ended:boolean;changing:boolean;
{:124}{126:}change_buffer:array[0..buf_size]of ASCII_code;
change_limit:0..buf_size;{:126}{143:}cur_module:name_pointer;
scanning_hex:boolean;{:143}{156:}next_control:eight_bits;
{:156}{164:}cur_repl_text:text_pointer;
{:164}{171:}module_count:0..12287;{:171}{179:}{trouble_shooting:boolean;
ddt:integer;dd:integer;debug_cycle:integer;debug_skipped:integer;
term_in:text_file;}{:179}{185:}{wo:0..1;}
{:185}{30:}{procedure debug_help;forward;}{:30}{31:}procedure error;
var j:0..out_buf_size;k,l:0..buf_size;
begin if phase_one then{32:}begin if changing then write(term_out,
'. (change file ')else write(term_out,'. (');
write_ln(term_out,'l.',line:1,')');
if loc>=limit then l:=limit else l:=loc;
for k:=1 to l do if buffer[k-1]=9 then write(term_out,' ')else write(
term_out,xchr[buffer[k-1]]);write_ln(term_out);
for k:=1 to l do write(term_out,' ');
for k:=l+1 to limit do write(term_out,xchr[buffer[k-1]]);
write(term_out,' ');
end{:32}else{33:}begin write_ln(term_out,'. (l.',line:1,')');
for j:=1 to out_ptr do write(term_out,xchr[out_buf[j-1]]);
write(term_out,'... ');end{:33};break(term_out);history:=2;
{debug_skipped:=debug_cycle;debug_help;}end;
{:31}{34:}procedure jump_out;begin goto 9999;end;
{:34}procedure initialize;var{16:}i:0..255;{:16}{41:}wi:0..1;
{:41}{45:}zi:0..2;{:45}{51:}h:0..hash_size;{:51}begin{10:}history:=0;
{:10}{14:}xchr[32]:=' ';xchr[33]:='!';xchr[34]:='"';xchr[35]:='#';
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
xchr[121]:='y';xchr[122]:='z';xchr[123]:='{';xchr[124]:='|';
xchr[125]:='}';xchr[126]:='~';xchr[0]:=' ';xchr[127]:=' ';
{:14}{17:}for i:=1 to 31 do xchr[i]:=' ';
for i:=128 to 255 do xchr[i]:=' ';
{:17}{18:}for i:=0 to 255 do xord[chr(i)]:=32;
for i:=1 to 255 do xord[xchr[i]]:=i;xord[' ']:=32;
{:18}{21:}rewrite(term_out,'TTY:');{:21}{26:}rewrite(Pascal_file);
rewrite(pool);{:26}{42:}for wi:=0 to 1 do begin byte_start[wi]:=0;
byte_ptr[wi]:=0;end;byte_start[2]:=0;name_ptr:=1;string_ptr:=256;
pool_check_sum:=271828;
{:42}{46:}for zi:=0 to 2 do begin tok_start[zi]:=0;tok_ptr[zi]:=0;end;
tok_start[3]:=0;text_ptr:=1;z:=1 mod 3;{:46}{48:}ilk[0]:=0;equiv[0]:=0;
{:48}{52:}for h:=0 to hash_size-1 do begin hash[h]:=0;chop_hash[h]:=0;
end;{:52}{71:}last_unnamed:=0;text_link[0]:=0;
{:71}{144:}scanning_hex:=false;{:144}{152:}mod_text[0]:=32;
{:152}{180:}{trouble_shooting:=true;debug_cycle:=1;debug_skipped:=0;
trouble_shooting:=false;debug_cycle:=99999;reset(term_in,'TTY:','/I');}
{:180}end;{:2}{24:}procedure open_input;begin reset(web_file);
reset(change_file);end;
{:24}{28:}function input_ln(var f:text_file):boolean;
var final_limit:0..buf_size;begin limit:=0;final_limit:=0;
if eof(f)then input_ln:=false else begin while not eoln(f)do begin
buffer[limit]:=xord[f^];get(f);limit:=limit+1;
if buffer[limit-1]<>32 then final_limit:=limit;
if limit=buf_size then begin while not eoln(f)do get(f);limit:=limit-1;
if final_limit>limit then final_limit:=limit;begin write_ln(term_out);
write(term_out,'! Input line too long');end;loc:=0;error;end;end;
read_ln(f);limit:=final_limit;input_ln:=true;end;end;
{:28}{49:}procedure print_id(p:name_pointer);var k:0..max_bytes;w:0..1;
begin if p>=name_ptr then write(term_out,'IMPOSSIBLE')else begin w:=p
mod 2;
for k:=byte_start[p]to byte_start[p+2]-1 do write(term_out,xchr[byte_mem
[w,k]]);end;end;{:49}{53:}function id_lookup(t:eight_bits):name_pointer;
label 31,32;var c:eight_bits;i:0..buf_size;h:0..hash_size;
k:0..max_bytes;w:0..1;l:0..buf_size;p,q:name_pointer;
s:0..unambig_length;begin l:=id_loc-id_first;{54:}h:=buffer[id_first];
i:=id_first+1;while i<id_loc do begin h:=(h+h+buffer[i])mod hash_size;
i:=i+1;end{:54};{55:}p:=hash[h];
while p<>0 do begin if byte_start[p+2]-byte_start[p]=l then{56:}begin i
:=id_first;k:=byte_start[p];w:=p mod 2;
while(i<id_loc)and(buffer[i]=byte_mem[w,k])do begin i:=i+1;k:=k+1;end;
if i=id_loc then goto 31;end{:56};p:=link[p];end;p:=name_ptr;
link[p]:=hash[h];hash[h]:=p;31:{:55};
if(p=name_ptr)or(t<>0)then{57:}begin if((p<>name_ptr)and(t<>0)and(ilk[p]
=0))or((p=name_ptr)and(t=0)and(buffer[id_first]<>34))then{58:}begin i:=
id_first;s:=0;h:=0;
while(i<id_loc)and(s<unambig_length)do begin if buffer[i]<>95 then begin
if buffer[i]>=97 then chopped_id[s]:=buffer[i]-32 else chopped_id[s]:=
buffer[i];h:=(h+h+chopped_id[s])mod hash_size;s:=s+1;end;i:=i+1;end;
chopped_id[s]:=0;end{:58};
if p<>name_ptr then{59:}begin if ilk[p]=0 then begin if t=1 then begin
write_ln(term_out);
write(term_out,'! This identifier has already appeared');error;end;
{60:}q:=chop_hash[h];
if q=p then chop_hash[h]:=equiv[p]else begin while equiv[q]<>p do q:=
equiv[q];equiv[q]:=equiv[p];end{:60};end else begin write_ln(term_out);
write(term_out,'! This identifier was defined before');error;end;
ilk[p]:=t;
end{:59}else{61:}begin if(t=0)and(buffer[id_first]<>34)then{62:}begin q
:=chop_hash[h];while q<>0 do begin{63:}begin k:=byte_start[q];s:=0;
w:=q mod 2;
while(k<byte_start[q+2])and(s<unambig_length)do begin c:=byte_mem[w,k];
if c<>95 then begin if c>=97 then c:=c-32;
if chopped_id[s]<>c then goto 32;s:=s+1;end;k:=k+1;end;
if(k=byte_start[q+2])and(chopped_id[s]<>0)then goto 32;
begin write_ln(term_out);write(term_out,'! Identifier conflict with ');
end;
for k:=byte_start[q]to byte_start[q+2]-1 do write(term_out,xchr[byte_mem
[w,k]]);error;q:=0;32:end{:63};q:=equiv[q];end;equiv[p]:=chop_hash[h];
chop_hash[h]:=p;end{:62};w:=name_ptr mod 2;k:=byte_ptr[w];
if k+l>max_bytes then begin write_ln(term_out);
write(term_out,'! Sorry, ','byte memory',' capacity exceeded');error;
history:=3;jump_out;end;
if name_ptr>max_names-2 then begin write_ln(term_out);
write(term_out,'! Sorry, ','name',' capacity exceeded');error;
history:=3;jump_out;end;i:=id_first;
while i<id_loc do begin byte_mem[w,k]:=buffer[i];k:=k+1;i:=i+1;end;
byte_ptr[w]:=k;byte_start[name_ptr+2]:=k;name_ptr:=name_ptr+1;
if buffer[id_first]<>34 then ilk[p]:=t else{64:}begin ilk[p]:=1;
if l-double_chars=2 then equiv[p]:=buffer[id_first+1]+32768 else begin
equiv[p]:=string_ptr+32768;l:=l-double_chars-1;
if l>99 then begin write_ln(term_out);
write(term_out,'! Preprocessed string is too long');error;end;
string_ptr:=string_ptr+1;
write(pool,xchr[48+l div 10],xchr[48+l mod 10]);
pool_check_sum:=pool_check_sum+pool_check_sum+l;
while pool_check_sum>536870839 do pool_check_sum:=pool_check_sum
-536870839;i:=id_first+1;
while i<id_loc do begin write(pool,xchr[buffer[i]]);
pool_check_sum:=pool_check_sum+pool_check_sum+buffer[i];
while pool_check_sum>536870839 do pool_check_sum:=pool_check_sum
-536870839;if(buffer[i]=34)or(buffer[i]=64)then i:=i+2 else i:=i+1;end;
write_ln(pool);end;end{:64};end{:61};end{:57};id_lookup:=p;end;
{:53}{66:}function mod_lookup(l:sixteen_bits):name_pointer;label 31;
var c:0..4;j:0..longest_name;k:0..max_bytes;w:0..1;p:name_pointer;
q:name_pointer;begin c:=2;q:=0;p:=ilk[0];
while p<>0 do begin{68:}begin k:=byte_start[p];w:=p mod 2;c:=1;j:=1;
while(k<byte_start[p+2])and(j<=l)and(mod_text[j]=byte_mem[w,k])do begin
k:=k+1;j:=j+1;end;
if k=byte_start[p+2]then if j>l then c:=1 else c:=4 else if j>l then c:=
3 else if mod_text[j]<byte_mem[w,k]then c:=0 else c:=2;end{:68};q:=p;
if c=0 then p:=link[q]else if c=2 then p:=ilk[q]else goto 31;end;
{67:}w:=name_ptr mod 2;k:=byte_ptr[w];
if k+l>max_bytes then begin write_ln(term_out);
write(term_out,'! Sorry, ','byte memory',' capacity exceeded');error;
history:=3;jump_out;end;
if name_ptr>max_names-2 then begin write_ln(term_out);
write(term_out,'! Sorry, ','name',' capacity exceeded');error;
history:=3;jump_out;end;p:=name_ptr;
if c=0 then link[q]:=p else ilk[q]:=p;link[p]:=0;ilk[p]:=0;c:=1;
equiv[p]:=0;for j:=1 to l do byte_mem[w,k+j-1]:=mod_text[j];
byte_ptr[w]:=k+l;byte_start[name_ptr+2]:=k+l;name_ptr:=name_ptr+1;{:67};
31:if c<>1 then begin begin write_ln(term_out);
write(term_out,'! Incompatible section names');error;end;p:=0;end;
mod_lookup:=p;end;
{:66}{69:}function prefix_lookup(l:sixteen_bits):name_pointer;
var c:0..4;count:0..max_names;j:0..longest_name;k:0..max_bytes;w:0..1;
p:name_pointer;q:name_pointer;r:name_pointer;begin q:=0;p:=ilk[0];
count:=0;r:=0;while p<>0 do begin{68:}begin k:=byte_start[p];w:=p mod 2;
c:=1;j:=1;
while(k<byte_start[p+2])and(j<=l)and(mod_text[j]=byte_mem[w,k])do begin
k:=k+1;j:=j+1;end;
if k=byte_start[p+2]then if j>l then c:=1 else c:=4 else if j>l then c:=
3 else if mod_text[j]<byte_mem[w,k]then c:=0 else c:=2;end{:68};
if c=0 then p:=link[p]else if c=2 then p:=ilk[p]else begin r:=p;
count:=count+1;q:=ilk[p];p:=link[p];end;if p=0 then begin p:=q;q:=0;end;
end;if count<>1 then if count=0 then begin write_ln(term_out);
write(term_out,'! Name does not match');error;
end else begin write_ln(term_out);write(term_out,'! Ambiguous prefix');
error;end;prefix_lookup:=r;end;
{:69}{73:}procedure store_two_bytes(x:sixteen_bits);
begin if tok_ptr[z]+2>max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=x div 256;
tok_mem[z,tok_ptr[z]+1]:=x mod 256;tok_ptr[z]:=tok_ptr[z]+2;end;
{:73}{74:}{procedure print_repl(p:text_pointer);var k:0..max_toks;
a:sixteen_bits;zp:0..2;
begin if p>=text_ptr then write(term_out,'BAD')else begin k:=tok_start[p
];zp:=p mod 3;while k<tok_start[p+3]do begin a:=tok_mem[zp,k];
if a>=128 then[75:]begin k:=k+1;
if a<168 then begin a:=(a-128)*256+tok_mem[zp,k];print_id(a);
if byte_mem[a mod 2,byte_start[a]]=34 then write(term_out,'"')else write
(term_out,' ');end else if a<208 then begin write(term_out,'@<');
print_id((a-168)*256+tok_mem[zp,k]);write(term_out,'@>');
end else begin a:=(a-208)*256+tok_mem[zp,k];
write(term_out,'@',xchr[123],a:1,'@',xchr[125]);end;
end[:75]else[76:]case a of 9:write(term_out,'@',xchr[123]);
10:write(term_out,'@',xchr[125]);12:write(term_out,'@''');
13:write(term_out,'@"');125:write(term_out,'@$');0:write(term_out,'#');
64:write(term_out,'@@');2:write(term_out,'@=');3:write(term_out,'@\');
others:write(term_out,xchr[a])end[:76];k:=k+1;end;end;end;}
{:74}{84:}procedure push_level(p:name_pointer);
begin if stack_ptr=stack_size then begin write_ln(term_out);
write(term_out,'! Sorry, ','stack',' capacity exceeded');error;
history:=3;jump_out;end else begin stack[stack_ptr]:=cur_state;
stack_ptr:=stack_ptr+1;cur_state.name_field:=p;
cur_state.repl_field:=equiv[p];zo:=cur_state.repl_field mod 3;
cur_state.byte_field:=tok_start[cur_state.repl_field];
cur_state.end_field:=tok_start[cur_state.repl_field+3];
cur_state.mod_field:=0;end;end;{:84}{85:}procedure pop_level;label 10;
begin if text_link[cur_state.repl_field]=0 then begin if ilk[cur_state.
name_field]=3 then{91:}begin name_ptr:=name_ptr-1;text_ptr:=text_ptr-1;
z:=text_ptr mod 3;
{if tok_ptr[z]>max_tok_ptr[z]then max_tok_ptr[z]:=tok_ptr[z];}
tok_ptr[z]:=tok_start[text_ptr];
{byte_ptr[name_ptr mod 2]:=byte_ptr[name_ptr mod 2]-1;}end{:91};
end else if text_link[cur_state.repl_field]<max_texts then begin
cur_state.repl_field:=text_link[cur_state.repl_field];
zo:=cur_state.repl_field mod 3;
cur_state.byte_field:=tok_start[cur_state.repl_field];
cur_state.end_field:=tok_start[cur_state.repl_field+3];goto 10;end;
stack_ptr:=stack_ptr-1;
if stack_ptr>0 then begin cur_state:=stack[stack_ptr];
zo:=cur_state.repl_field mod 3;end;10:end;
{:85}{87:}function get_output:sixteen_bits;label 20,30,31;
var a:sixteen_bits;b:eight_bits;bal:sixteen_bits;k:0..max_bytes;w:0..1;
begin 20:if stack_ptr=0 then begin a:=0;goto 31;end;
if cur_state.byte_field=cur_state.end_field then begin cur_val:=-
cur_state.mod_field;pop_level;if cur_val=0 then goto 20;a:=129;goto 31;
end;a:=tok_mem[zo,cur_state.byte_field];
cur_state.byte_field:=cur_state.byte_field+1;
if a<128 then if a=0 then{92:}begin push_level(name_ptr-1);goto 20;
end{:92}else goto 31;a:=(a-128)*256+tok_mem[zo,cur_state.byte_field];
cur_state.byte_field:=cur_state.byte_field+1;
if a<10240 then{89:}begin case ilk[a]of 0:begin cur_val:=a;a:=130;end;
1:begin cur_val:=equiv[a]-32768;a:=128;end;2:begin push_level(a);
goto 20;end;
3:begin{90:}while(cur_state.byte_field=cur_state.end_field)and(stack_ptr
>0)do pop_level;
if(stack_ptr=0)or(tok_mem[zo,cur_state.byte_field]<>40)then begin begin
write_ln(term_out);write(term_out,'! No parameter given for ');end;
print_id(a);error;goto 20;end;{93:}bal:=1;
cur_state.byte_field:=cur_state.byte_field+1;
while true do begin b:=tok_mem[zo,cur_state.byte_field];
cur_state.byte_field:=cur_state.byte_field+1;
if b=0 then store_two_bytes(name_ptr+32767)else begin if b>=128 then
begin begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=b;
tok_ptr[z]:=tok_ptr[z]+1;end;b:=tok_mem[zo,cur_state.byte_field];
cur_state.byte_field:=cur_state.byte_field+1;
end else case b of 40:bal:=bal+1;41:begin bal:=bal-1;
if bal=0 then goto 30;end;
39:repeat begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=b;
tok_ptr[z]:=tok_ptr[z]+1;end;b:=tok_mem[zo,cur_state.byte_field];
cur_state.byte_field:=cur_state.byte_field+1;until b=39;others:end;
begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=b;
tok_ptr[z]:=tok_ptr[z]+1;end;end;end;30:{:93};equiv[name_ptr]:=text_ptr;
ilk[name_ptr]:=2;w:=name_ptr mod 2;k:=byte_ptr[w];
{if k=max_bytes then begin write_ln(term_out);
write(term_out,'! Sorry, ','byte memory',' capacity exceeded');error;
history:=3;jump_out;end;byte_mem[w,k]:=35;k:=k+1;byte_ptr[w]:=k;}
if name_ptr>max_names-2 then begin write_ln(term_out);
write(term_out,'! Sorry, ','name',' capacity exceeded');error;
history:=3;jump_out;end;byte_start[name_ptr+2]:=k;name_ptr:=name_ptr+1;
if text_ptr>max_texts-3 then begin write_ln(term_out);
write(term_out,'! Sorry, ','text',' capacity exceeded');error;
history:=3;jump_out;end;text_link[text_ptr]:=0;
tok_start[text_ptr+3]:=tok_ptr[z];text_ptr:=text_ptr+1;
z:=text_ptr mod 3{:90};push_level(a);goto 20;end;
others:begin write_ln(term_out);
write(term_out,'! This can''t happen (','output',')');error;history:=3;
jump_out;end end;goto 31;end{:89};if a<20480 then{88:}begin a:=a-10240;
if equiv[a]<>0 then push_level(a)else if a<>0 then begin begin write_ln(
term_out);write(term_out,'! Not present: <');end;print_id(a);
write(term_out,'>');error;end;goto 20;end{:88};cur_val:=a-20480;a:=129;
cur_state.mod_field:=cur_val;31:{if trouble_shooting then debug_help;}
get_output:=a;end;{:87}{97:}procedure flush_buffer;
var k:0..out_buf_size;b:0..out_buf_size;begin b:=break_ptr;
if(semi_ptr<>0)and(out_ptr-semi_ptr<=line_length)then break_ptr:=
semi_ptr;for k:=1 to break_ptr do write(Pascal_file,xchr[out_buf[k-1]]);
write_ln(Pascal_file);line:=line+1;
if line mod 100=0 then begin write(term_out,'.');
if line mod 500=0 then write(term_out,line:1);break(term_out);end;
if break_ptr<out_ptr then begin if out_buf[break_ptr]=32 then begin
break_ptr:=break_ptr+1;if break_ptr>b then b:=break_ptr;end;
for k:=break_ptr to out_ptr-1 do out_buf[k-break_ptr]:=out_buf[k];end;
out_ptr:=out_ptr-break_ptr;break_ptr:=b-break_ptr;semi_ptr:=0;
if out_ptr>line_length then begin begin write_ln(term_out);
write(term_out,'! Long line must be truncated');error;end;
out_ptr:=line_length;end;end;{:97}{99:}procedure app_val(v:integer);
var k:0..out_buf_size;begin k:=out_buf_size;repeat out_buf[k]:=v mod 10;
v:=v div 10;k:=k-1;until v=0;repeat k:=k+1;
begin out_buf[out_ptr]:=out_buf[k]+48;out_ptr:=out_ptr+1;end;
until k=out_buf_size;end;{:99}{101:}procedure send_out(t:eight_bits;
v:sixteen_bits);label 20;var k:0..line_length;
begin{102:}20:case out_state of 1:if t<>3 then begin break_ptr:=out_ptr;
if t=2 then begin out_buf[out_ptr]:=32;out_ptr:=out_ptr+1;end;end;
2:begin begin out_buf[out_ptr]:=44-out_app;out_ptr:=out_ptr+1;end;
if out_ptr>line_length then flush_buffer;break_ptr:=out_ptr;end;
3,4:begin{103:}if(out_val<0)or((out_val=0)and(last_sign<0))then begin
out_buf[out_ptr]:=45;out_ptr:=out_ptr+1;
end else if out_sign>0 then begin out_buf[out_ptr]:=out_sign;
out_ptr:=out_ptr+1;end;app_val(abs(out_val));
if out_ptr>line_length then flush_buffer;{:103};out_state:=out_state-2;
goto 20;end;
5:{104:}begin if(t=3)or({105:}((t=2)and(v=3)and(((out_contrib[1]=100)and
(out_contrib[2]=105)and(out_contrib[3]=118))or((out_contrib[1]=109)and(
out_contrib[2]=111)and(out_contrib[3]=100))))or((t=0)and((v=42)or(v=47))
){:105})then begin{103:}if(out_val<0)or((out_val=0)and(last_sign<0))then
begin out_buf[out_ptr]:=45;out_ptr:=out_ptr+1;
end else if out_sign>0 then begin out_buf[out_ptr]:=out_sign;
out_ptr:=out_ptr+1;end;app_val(abs(out_val));
if out_ptr>line_length then flush_buffer;{:103};out_sign:=43;
out_val:=out_app;end else out_val:=out_val+out_app;out_state:=3;goto 20;
end{:104};0:if t<>3 then break_ptr:=out_ptr;others:end{:102};
if t<>0 then for k:=1 to v do begin out_buf[out_ptr]:=out_contrib[k];
out_ptr:=out_ptr+1;end else begin out_buf[out_ptr]:=v;
out_ptr:=out_ptr+1;end;if out_ptr>line_length then flush_buffer;
if(t=0)and((v=59)or(v=125))then begin semi_ptr:=out_ptr;
break_ptr:=out_ptr;end;if t>=2 then out_state:=1 else out_state:=0 end;
{:101}{106:}procedure send_sign(v:integer);
begin case out_state of 2,4:out_app:=out_app*v;3:begin out_app:=v;
out_state:=4;end;5:begin out_val:=out_val+out_app;out_app:=v;
out_state:=4;end;others:begin break_ptr:=out_ptr;out_app:=v;
out_state:=2;end end;last_sign:=out_app;end;
{:106}{107:}procedure send_val(v:integer);label 666,10;
begin case out_state of 1:begin{110:}if(out_ptr=break_ptr+3)or((out_ptr=
break_ptr+4)and(out_buf[break_ptr]=32))then if((out_buf[out_ptr-3]=100)
and(out_buf[out_ptr-2]=105)and(out_buf[out_ptr-1]=118))or((out_buf[
out_ptr-3]=109)and(out_buf[out_ptr-2]=111)and(out_buf[out_ptr-1]=100))
then goto 666{:110};out_sign:=32;out_state:=3;out_val:=v;
break_ptr:=out_ptr;last_sign:=+1;end;
0:begin{109:}if(out_ptr=break_ptr+1)and((out_buf[break_ptr]=42)or(
out_buf[break_ptr]=47))then goto 666{:109};out_sign:=0;out_state:=3;
out_val:=v;break_ptr:=out_ptr;last_sign:=+1;end;
{108:}2:begin out_sign:=43;out_state:=3;out_val:=out_app*v;end;
3:begin out_state:=5;out_app:=v;begin write_ln(term_out);
write(term_out,'! Two numbers occurred without a sign between them');
error;end;end;4:begin out_state:=5;out_app:=out_app*v;end;
5:begin out_val:=out_val+out_app;out_app:=v;begin write_ln(term_out);
write(term_out,'! Two numbers occurred without a sign between them');
error;end;end;{:108}others:goto 666 end;goto 10;
666:{111:}if v>=0 then begin if out_state=1 then begin break_ptr:=
out_ptr;begin out_buf[out_ptr]:=32;out_ptr:=out_ptr+1;end;end;
app_val(v);if out_ptr>line_length then flush_buffer;out_state:=1;
end else begin begin out_buf[out_ptr]:=40;out_ptr:=out_ptr+1;end;
begin out_buf[out_ptr]:=45;out_ptr:=out_ptr+1;end;app_val(-v);
begin out_buf[out_ptr]:=41;out_ptr:=out_ptr+1;end;
if out_ptr>line_length then flush_buffer;out_state:=0;end{:111};10:end;
{:107}{113:}procedure send_the_output;label 2,21,22;
var cur_char:eight_bits;k:0..line_length;j:0..max_bytes;w:0..1;
n:integer;begin while stack_ptr>0 do begin cur_char:=get_output;
21:case cur_char of 0:;
{116:}65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,
87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112
,113,114,115,116,117,118,119,120,121,122:begin out_contrib[1]:=cur_char;
send_out(2,1);end;130:begin k:=0;j:=byte_start[cur_val];
w:=cur_val mod 2;
while(k<max_id_length)and(j<byte_start[cur_val+2])do begin k:=k+1;
out_contrib[k]:=byte_mem[w,j];j:=j+1;end;send_out(2,k);end;
{:116}{119:}48,49,50,51,52,53,54,55,56,57:begin n:=0;
repeat cur_char:=cur_char-48;
if n>=214748364 then begin write_ln(term_out);
write(term_out,'! Constant too big');error;end else n:=10*n+cur_char;
cur_char:=get_output;until(cur_char>57)or(cur_char<48);send_val(n);k:=0;
if cur_char=101 then cur_char:=69;
if cur_char=69 then goto 2 else goto 21;end;
125:send_val(pool_check_sum);12:begin n:=0;cur_char:=48;
repeat cur_char:=cur_char-48;
if n>=268435456 then begin write_ln(term_out);
write(term_out,'! Constant too big');error;end else n:=8*n+cur_char;
cur_char:=get_output;until(cur_char>55)or(cur_char<48);send_val(n);
goto 21;end;13:begin n:=0;cur_char:=48;
repeat if cur_char>=65 then cur_char:=cur_char-55 else cur_char:=
cur_char-48;if n>=134217728 then begin write_ln(term_out);
write(term_out,'! Constant too big');error;end else n:=16*n+cur_char;
cur_char:=get_output;
until(cur_char>70)or(cur_char<48)or((cur_char>57)and(cur_char<65));
send_val(n);goto 21;end;128:send_val(cur_val);46:begin k:=1;
out_contrib[1]:=46;cur_char:=get_output;
if cur_char=46 then begin out_contrib[2]:=46;send_out(1,2);
end else if(cur_char>=48)and(cur_char<=57)then goto 2 else begin
send_out(0,46);goto 21;end;end;{:119}43,45:send_sign(44-cur_char);
{114:}4:begin out_contrib[1]:=97;out_contrib[2]:=110;
out_contrib[3]:=100;send_out(2,3);end;5:begin out_contrib[1]:=110;
out_contrib[2]:=111;out_contrib[3]:=116;send_out(2,3);end;
6:begin out_contrib[1]:=105;out_contrib[2]:=110;send_out(2,2);end;
31:begin out_contrib[1]:=111;out_contrib[2]:=114;send_out(2,2);end;
24:begin out_contrib[1]:=58;out_contrib[2]:=61;send_out(1,2);end;
26:begin out_contrib[1]:=60;out_contrib[2]:=62;send_out(1,2);end;
28:begin out_contrib[1]:=60;out_contrib[2]:=61;send_out(1,2);end;
29:begin out_contrib[1]:=62;out_contrib[2]:=61;send_out(1,2);end;
30:begin out_contrib[1]:=61;out_contrib[2]:=61;send_out(1,2);end;
32:begin out_contrib[1]:=46;out_contrib[2]:=46;send_out(1,2);end;
{:114}39:{117:}begin k:=1;out_contrib[1]:=39;
repeat if k<line_length then k:=k+1;out_contrib[k]:=get_output;
until(out_contrib[k]=39)or(stack_ptr=0);
if k=line_length then begin write_ln(term_out);
write(term_out,'! String too long');error;end;send_out(1,k);
cur_char:=get_output;if cur_char=39 then out_state:=6;goto 21;end{:117};
{115:}33,34,35,36,37,38,40,41,42,44,47,58,59,60,61,62,63,64,91,92,93,94,
95,96,123,124{:115}:send_out(0,cur_char);
{121:}9:begin if brace_level=0 then send_out(0,123)else send_out(0,91);
brace_level:=brace_level+1;end;
10:if brace_level>0 then begin brace_level:=brace_level-1;
if brace_level=0 then send_out(0,125)else send_out(0,93);
end else begin write_ln(term_out);write(term_out,'! Extra @}');error;
end;129:begin k:=2;
if brace_level=0 then out_contrib[1]:=123 else out_contrib[1]:=91;
if cur_val<0 then begin out_contrib[k]:=58;cur_val:=-cur_val;k:=k+1;end;
n:=10;while cur_val>=n do n:=10*n;repeat n:=n div 10;
out_contrib[k]:=48+(cur_val div n);cur_val:=cur_val mod n;k:=k+1;
until n=1;if out_contrib[2]<>58 then begin out_contrib[k]:=58;k:=k+1;
end;if brace_level=0 then out_contrib[k]:=125 else out_contrib[k]:=93;
send_out(1,k);end;{:121}127:begin send_out(3,0);out_state:=6;end;
2:{118:}begin k:=0;repeat if k<line_length then k:=k+1;
out_contrib[k]:=get_output;until(out_contrib[k]=2)or(stack_ptr=0);
if k=line_length then begin write_ln(term_out);
write(term_out,'! Verbatim string too long');error;end;send_out(1,k-1);
end{:118};3:{122:}begin send_out(1,0);
while out_ptr>0 do begin if out_ptr<=line_length then break_ptr:=out_ptr
;flush_buffer;end;out_state:=0;end{:122};
others:begin write_ln(term_out);
write(term_out,'! Can''t output ASCII code ',cur_char:1);error;end end;
goto 22;2:{120:}repeat if k<line_length then k:=k+1;
out_contrib[k]:=cur_char;cur_char:=get_output;
if(out_contrib[k]=69)and((cur_char=43)or(cur_char=45))then begin if k<
line_length then k:=k+1;out_contrib[k]:=cur_char;cur_char:=get_output;
end else if cur_char=101 then cur_char:=69;
until(cur_char<>69)and((cur_char<48)or(cur_char>57));
if k=line_length then begin write_ln(term_out);
write(term_out,'! Fraction too long');error;end;send_out(3,k);
goto 21{:120};22:end;end;{:113}{127:}function lines_dont_match:boolean;
label 10;var k:0..buf_size;begin lines_dont_match:=true;
if change_limit<>limit then goto 10;
if limit>0 then for k:=0 to limit-1 do if change_buffer[k]<>buffer[k]
then goto 10;lines_dont_match:=false;10:end;
{:127}{128:}procedure prime_the_change_buffer;label 22,30,10;
var k:0..buf_size;begin change_limit:=0;
{129:}while true do begin line:=line+1;
if not input_ln(change_file)then goto 10;if limit<2 then goto 22;
if buffer[0]<>64 then goto 22;
if(buffer[1]>=88)and(buffer[1]<=90)then buffer[1]:=buffer[1]+32;
if buffer[1]=120 then goto 30;
if(buffer[1]=121)or(buffer[1]=122)then begin loc:=2;
begin write_ln(term_out);write(term_out,'! Where is the matching @x?');
error;end;end;22:end;30:{:129};{130:}repeat line:=line+1;
if not input_ln(change_file)then begin begin write_ln(term_out);
write(term_out,'! Change file ended after @x');error;end;goto 10;end;
until limit>0;{:130};{131:}begin change_limit:=limit;
if limit>0 then for k:=0 to limit-1 do change_buffer[k]:=buffer[k];
end{:131};10:end;{:128}{132:}procedure check_change;label 10;
var n:integer;k:0..buf_size;begin if lines_dont_match then goto 10;n:=0;
while true do begin changing:=not changing;temp_line:=other_line;
other_line:=line;line:=temp_line;line:=line+1;
if not input_ln(change_file)then begin begin write_ln(term_out);
write(term_out,'! Change file ended before @y');error;end;
change_limit:=0;changing:=not changing;temp_line:=other_line;
other_line:=line;line:=temp_line;goto 10;end;
{133:}if limit>1 then if buffer[0]=64 then begin if(buffer[1]>=88)and(
buffer[1]<=90)then buffer[1]:=buffer[1]+32;
if(buffer[1]=120)or(buffer[1]=122)then begin loc:=2;
begin write_ln(term_out);write(term_out,'! Where is the matching @y?');
error;end;end else if buffer[1]=121 then begin if n>0 then begin loc:=2;
begin write_ln(term_out);
write(term_out,'! Hmm... ',n:1,' of the preceding lines failed to match'
);error;end;end;goto 10;end;end{:133};{131:}begin change_limit:=limit;
if limit>0 then for k:=0 to limit-1 do change_buffer[k]:=buffer[k];
end{:131};changing:=not changing;temp_line:=other_line;other_line:=line;
line:=temp_line;line:=line+1;
if not input_ln(web_file)then begin begin write_ln(term_out);
write(term_out,'! WEB file ended during a change');error;end;
input_has_ended:=true;goto 10;end;if lines_dont_match then n:=n+1;end;
10:end;{:132}{135:}procedure get_line;label 20;
begin 20:if changing then{137:}begin line:=line+1;
if not input_ln(change_file)then begin begin write_ln(term_out);
write(term_out,'! Change file ended without @z');error;end;
buffer[0]:=64;buffer[1]:=122;limit:=2;end;
if limit>1 then if buffer[0]=64 then begin if(buffer[1]>=88)and(buffer[1
]<=90)then buffer[1]:=buffer[1]+32;
if(buffer[1]=120)or(buffer[1]=121)then begin loc:=2;
begin write_ln(term_out);write(term_out,'! Where is the matching @z?');
error;end;end else if buffer[1]=122 then begin prime_the_change_buffer;
changing:=not changing;temp_line:=other_line;other_line:=line;
line:=temp_line;end;end;end{:137};
if not changing then begin{136:}begin line:=line+1;
if not input_ln(web_file)then input_has_ended:=true else if limit=
change_limit then if buffer[0]=change_buffer[0]then if change_limit>0
then check_change;end{:136};if changing then goto 20;end;loc:=0;
buffer[limit]:=32;end;
{:135}{139:}function control_code(c:ASCII_code):eight_bits;
begin case c of 64:control_code:=64;39:control_code:=12;
34:control_code:=13;36:control_code:=125;32,9:control_code:=136;
42:begin write(term_out,'*',module_count+1:1);break(term_out);
control_code:=136;end;68,100:control_code:=133;70,102:control_code:=132;
123:control_code:=9;125:control_code:=10;80,112:control_code:=134;
84,116,94,46,58:control_code:=131;38:control_code:=127;
60:control_code:=135;61:control_code:=2;92:control_code:=3;
others:control_code:=0 end;end;
{:139}{140:}function skip_ahead:eight_bits;label 30;var c:eight_bits;
begin while true do begin if loc>limit then begin get_line;
if input_has_ended then begin c:=136;goto 30;end;end;
buffer[limit+1]:=64;while buffer[loc]<>64 do loc:=loc+1;
if loc<=limit then begin loc:=loc+2;c:=control_code(buffer[loc-1]);
if(c<>0)or(buffer[loc-1]=62)then goto 30;end;end;30:skip_ahead:=c;end;
{:140}{141:}procedure skip_comment;label 10;var bal:eight_bits;
c:ASCII_code;begin bal:=0;
while true do begin if loc>limit then begin get_line;
if input_has_ended then begin begin write_ln(term_out);
write(term_out,'! Input ended in mid-comment');error;end;goto 10;end;
end;c:=buffer[loc];loc:=loc+1;{142:}if c=64 then begin c:=buffer[loc];
if(c<>32)and(c<>9)and(c<>42)and(c<>122)and(c<>90)then loc:=loc+1 else
begin begin write_ln(term_out);
write(term_out,'! Section ended in mid-comment');error;end;loc:=loc-1;
goto 10;
end end else if(c=92)and(buffer[loc]<>64)then loc:=loc+1 else if c=123
then bal:=bal+1 else if c=125 then begin if bal=0 then goto 10;
bal:=bal-1;end{:142};end;10:end;
{:141}{145:}function get_next:eight_bits;label 20,30,31;
var c:eight_bits;d:eight_bits;j,k:0..longest_name;
begin 20:if loc>limit then begin get_line;
if input_has_ended then begin c:=136;goto 31;end;end;c:=buffer[loc];
loc:=loc+1;
if scanning_hex then{146:}if((c>=48)and(c<=57))or((c>=65)and(c<=70))then
goto 31 else scanning_hex:=false{:146};
case c of 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85
,86,87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111
,112,113,114,115,116,117,118,119,120,121,122:{148:}begin if((c=101)or(c=
69))and(loc>1)then if(buffer[loc-2]<=57)and(buffer[loc-2]>=48)then c:=0;
if c<>0 then begin loc:=loc-1;id_first:=loc;repeat loc:=loc+1;
d:=buffer[loc];
until((d<48)or((d>57)and(d<65))or((d>90)and(d<97))or(d>122))and(d<>95);
if loc>id_first+1 then begin c:=130;id_loc:=loc;end;end else c:=69;
end{:148};34:{149:}begin double_chars:=0;id_first:=loc-1;
repeat d:=buffer[loc];loc:=loc+1;
if(d=34)or(d=64)then if buffer[loc]=d then begin loc:=loc+1;d:=0;
double_chars:=double_chars+1;
end else begin if d=64 then begin write_ln(term_out);
write(term_out,'! Double @ sign missing');error;
end end else if loc>limit then begin begin write_ln(term_out);
write(term_out,'! String constant didn''t end');error;end;d:=34;end;
until d=34;id_loc:=loc-1;c:=130;end{:149};
64:{150:}begin c:=control_code(buffer[loc]);loc:=loc+1;
if c=0 then goto 20 else if c=13 then scanning_hex:=true else if c=135
then{151:}begin{153:}k:=0;
while true do begin if loc>limit then begin get_line;
if input_has_ended then begin begin write_ln(term_out);
write(term_out,'! Input ended in section name');error;end;goto 30;end;
end;d:=buffer[loc];{154:}if d=64 then begin d:=buffer[loc+1];
if d=62 then begin loc:=loc+2;goto 30;end;
if(d=32)or(d=9)or(d=42)then begin begin write_ln(term_out);
write(term_out,'! Section name didn''t end');error;end;goto 30;end;
k:=k+1;mod_text[k]:=64;loc:=loc+1;end{:154};loc:=loc+1;
if k<longest_name-1 then k:=k+1;if(d=32)or(d=9)then begin d:=32;
if mod_text[k-1]=32 then k:=k-1;end;mod_text[k]:=d;end;
30:{155:}if k>=longest_name-2 then begin begin write_ln(term_out);
write(term_out,'! Section name too long: ');end;
for j:=1 to 25 do write(term_out,xchr[mod_text[j]]);
write(term_out,'...');if history=0 then history:=1;end{:155};
if(mod_text[k]=32)and(k>0)then k:=k-1;{:153};
if k>3 then begin if(mod_text[k]=46)and(mod_text[k-1]=46)and(mod_text[k
-2]=46)then cur_module:=prefix_lookup(k-3)else cur_module:=mod_lookup(k)
;end else cur_module:=mod_lookup(k);
end{:151}else if c=131 then begin repeat c:=skip_ahead;until c<>64;
if buffer[loc-1]<>62 then begin write_ln(term_out);
write(term_out,'! Improper @ within control text');error;end;goto 20;
end;end{:150};
{147:}46:if buffer[loc]=46 then begin if loc<=limit then begin c:=32;
loc:=loc+1;end;
end else if buffer[loc]=41 then begin if loc<=limit then begin c:=93;
loc:=loc+1;end;end;
58:if buffer[loc]=61 then begin if loc<=limit then begin c:=24;
loc:=loc+1;end;end;
61:if buffer[loc]=61 then begin if loc<=limit then begin c:=30;
loc:=loc+1;end;end;
62:if buffer[loc]=61 then begin if loc<=limit then begin c:=29;
loc:=loc+1;end;end;
60:if buffer[loc]=61 then begin if loc<=limit then begin c:=28;
loc:=loc+1;end;
end else if buffer[loc]=62 then begin if loc<=limit then begin c:=26;
loc:=loc+1;end;end;
40:if buffer[loc]=42 then begin if loc<=limit then begin c:=9;
loc:=loc+1;end;
end else if buffer[loc]=46 then begin if loc<=limit then begin c:=91;
loc:=loc+1;end;end;
42:if buffer[loc]=41 then begin if loc<=limit then begin c:=10;
loc:=loc+1;end;end;{:147}32,9:goto 20;123:begin skip_comment;goto 20;
end;125:begin begin write_ln(term_out);write(term_out,'! Extra }');
error;end;goto 20;end;others:if c>=128 then goto 20 else end;
31:{if trouble_shooting then debug_help;}get_next:=c;end;
{:145}{157:}procedure scan_numeric(p:name_pointer);label 21,30;
var accumulator:integer;next_sign:-1..+1;q:name_pointer;val:integer;
begin{158:}accumulator:=0;next_sign:=+1;
while true do begin next_control:=get_next;
21:case next_control of 48,49,50,51,52,53,54,55,56,57:begin{160:}val:=0;
repeat val:=10*val+next_control-48;next_control:=get_next;
until(next_control>57)or(next_control<48){:160};
begin accumulator:=accumulator+next_sign*(val);next_sign:=+1;end;
goto 21;end;12:begin{161:}val:=0;next_control:=48;
repeat val:=8*val+next_control-48;next_control:=get_next;
until(next_control>55)or(next_control<48){:161};
begin accumulator:=accumulator+next_sign*(val);next_sign:=+1;end;
goto 21;end;13:begin{162:}val:=0;next_control:=48;
repeat if next_control>=65 then next_control:=next_control-7;
val:=16*val+next_control-48;next_control:=get_next;
until(next_control>70)or(next_control<48)or((next_control>57)and(
next_control<65)){:162};begin accumulator:=accumulator+next_sign*(val);
next_sign:=+1;end;goto 21;end;130:begin q:=id_lookup(0);
if ilk[q]<>1 then begin next_control:=42;goto 21;end;
begin accumulator:=accumulator+next_sign*(equiv[q]-32768);next_sign:=+1;
end;end;43:;45:next_sign:=-next_sign;132,133,135,134,136:goto 30;
59:begin write_ln(term_out);
write(term_out,'! Omit semicolon in numeric definition');error;end;
others:{159:}begin begin write_ln(term_out);
write(term_out,'! Improper numeric definition will be flushed');error;
end;repeat next_control:=skip_ahead until(next_control>=132);
if next_control=135 then begin loc:=loc-2;next_control:=get_next;end;
accumulator:=0;goto 30;end{:159}end;end;30:{:158};
if abs(accumulator)>=32768 then begin begin write_ln(term_out);
write(term_out,'! Value too big: ',accumulator:1);error;end;
accumulator:=0;end;equiv[p]:=accumulator+32768;end;
{:157}{165:}procedure scan_repl(t:eight_bits);label 22,30,31,21;
var a:sixteen_bits;b:ASCII_code;bal:eight_bits;begin bal:=0;
while true do begin 22:a:=get_next;case a of 40:bal:=bal+1;
41:if bal=0 then begin write_ln(term_out);write(term_out,'! Extra )');
error;end else bal:=bal-1;39:{168:}begin b:=39;
while true do begin begin if tok_ptr[z]=max_toks then begin write_ln(
term_out);write(term_out,'! Sorry, ','token',' capacity exceeded');
error;history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=b;
tok_ptr[z]:=tok_ptr[z]+1;end;
if b=64 then if buffer[loc]=64 then loc:=loc+1 else begin write_ln(
term_out);write(term_out,'! You should double @ signs in strings');
error;end;if loc=limit then begin begin write_ln(term_out);
write(term_out,'! String didn''t end');error;end;buffer[loc]:=39;
buffer[loc+1]:=0;end;b:=buffer[loc];loc:=loc+1;
if b=39 then begin if buffer[loc]<>39 then goto 31 else begin loc:=loc+1
;begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=39;
tok_ptr[z]:=tok_ptr[z]+1;end;end;end;end;31:end{:168};
35:if t=3 then a:=0;{167:}130:begin a:=id_lookup(0);
begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=(a div 256)+128;
tok_ptr[z]:=tok_ptr[z]+1;end;a:=a mod 256;end;
135:if t<>135 then goto 30 else begin begin if tok_ptr[z]=max_toks then
begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=(cur_module div 256)+168;
tok_ptr[z]:=tok_ptr[z]+1;end;a:=cur_module mod 256;end;
2:{169:}begin begin if tok_ptr[z]=max_toks then begin write_ln(term_out)
;write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=2;
tok_ptr[z]:=tok_ptr[z]+1;end;buffer[limit+1]:=64;
21:if buffer[loc]=64 then begin if loc<limit then if buffer[loc+1]=64
then begin begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=64;
tok_ptr[z]:=tok_ptr[z]+1;end;loc:=loc+2;goto 21;end;
end else begin begin if tok_ptr[z]=max_toks then begin write_ln(term_out
);write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=buffer[loc];
tok_ptr[z]:=tok_ptr[z]+1;end;loc:=loc+1;goto 21;end;
if loc>=limit then begin write_ln(term_out);
write(term_out,'! Verbatim string didn''t end');error;
end else if buffer[loc+1]<>62 then begin write_ln(term_out);
write(term_out,'! You should double @ signs in verbatim strings');error;
end;loc:=loc+2;end{:169};
133,132,134:if t<>135 then goto 30 else begin begin write_ln(term_out);
write(term_out,'! @',xchr[buffer[loc-1]],' is ignored in Pascal text');
error;end;goto 22;end;136:goto 30;{:167}others:end;
begin if tok_ptr[z]=max_toks then begin write_ln(term_out);
write(term_out,'! Sorry, ','token',' capacity exceeded');error;
history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=a;
tok_ptr[z]:=tok_ptr[z]+1;end;end;30:next_control:=a;
{166:}if bal>0 then begin if bal=1 then begin write_ln(term_out);
write(term_out,'! Missing )');error;end else begin write_ln(term_out);
write(term_out,'! Missing ',bal:1,' )''s');error;end;
while bal>0 do begin begin if tok_ptr[z]=max_toks then begin write_ln(
term_out);write(term_out,'! Sorry, ','token',' capacity exceeded');
error;history:=3;jump_out;end;tok_mem[z,tok_ptr[z]]:=41;
tok_ptr[z]:=tok_ptr[z]+1;end;bal:=bal-1;end;end{:166};
if text_ptr>max_texts-3 then begin write_ln(term_out);
write(term_out,'! Sorry, ','text',' capacity exceeded');error;
history:=3;jump_out;end;cur_repl_text:=text_ptr;
tok_start[text_ptr+3]:=tok_ptr[z];text_ptr:=text_ptr+1;
if z=2 then z:=0 else z:=z+1;end;
{:165}{170:}procedure define_macro(t:eight_bits);var p:name_pointer;
begin p:=id_lookup(t);scan_repl(t);equiv[p]:=cur_repl_text;
text_link[cur_repl_text]:=0;end;{:170}{172:}procedure scan_module;
label 22,30,10;var p:name_pointer;begin module_count:=module_count+1;
{173:}next_control:=0;
while true do begin 22:while next_control<=132 do begin next_control:=
skip_ahead;if next_control=135 then begin loc:=loc-2;
next_control:=get_next;end;end;if next_control<>133 then goto 30;
next_control:=get_next;
if next_control<>130 then begin begin write_ln(term_out);
write(term_out,'! Definition flushed, must start with ',
'identifier of length > 1');error;end;goto 22;end;
next_control:=get_next;
if next_control=61 then begin scan_numeric(id_lookup(1));goto 22;
end else if next_control=30 then begin define_macro(2);goto 22;
end else{174:}if next_control=40 then begin next_control:=get_next;
if next_control=35 then begin next_control:=get_next;
if next_control=41 then begin next_control:=get_next;
if next_control=61 then begin begin write_ln(term_out);
write(term_out,'! Use == for macros');error;end;next_control:=30;end;
if next_control=30 then begin define_macro(3);goto 22;end;end;end;end;
{:174};begin write_ln(term_out);
write(term_out,'! Definition flushed since it starts badly');error;end;
end;30:{:173};{175:}case next_control of 134:p:=0;
135:begin p:=cur_module;{176:}repeat next_control:=get_next;
until next_control<>43;
if(next_control<>61)and(next_control<>30)then begin begin write_ln(
term_out);write(term_out,'! Pascal text flushed, = sign is missing');
error;end;repeat next_control:=skip_ahead;until next_control=136;
goto 10;end{:176};end;others:goto 10 end;
{177:}store_two_bytes(53248+module_count);{:177};scan_repl(135);
{178:}if p=0 then begin text_link[last_unnamed]:=cur_repl_text;
last_unnamed:=cur_repl_text;
end else if equiv[p]=0 then equiv[p]:=cur_repl_text else begin p:=equiv[
p];while text_link[p]<max_texts do p:=text_link[p];
text_link[p]:=cur_repl_text;end;text_link[cur_repl_text]:=max_texts;
{:178};{:175};10:end;{:172}{181:}{procedure debug_help;label 888,10;
var k:integer;begin debug_skipped:=debug_skipped+1;
if debug_skipped<debug_cycle then goto 10;debug_skipped:=0;
while true do begin begin write_ln(term_out);write(term_out,'#');end;
break(term_out);read(term_in,ddt);
if ddt<0 then goto 10 else if ddt=0 then begin goto 888;
888:ddt:=0;
end else begin read(term_in,dd);case ddt of 1:print_id(dd);
2:print_repl(dd);3:for k:=1 to dd do write(term_out,xchr[buffer[k]]);
4:for k:=1 to dd do write(term_out,xchr[mod_text[k]]);
5:for k:=1 to out_ptr do write(term_out,xchr[out_buf[k]]);
6:for k:=1 to dd do write(term_out,xchr[out_contrib[k]]);
others:write(term_out,'?')end;end;end;10:end;}
{:181}{182:}begin initialize;{134:}open_input;line:=0;other_line:=0;
changing:=true;prime_the_change_buffer;changing:=not changing;
temp_line:=other_line;other_line:=line;line:=temp_line;limit:=0;loc:=1;
buffer[0]:=32;input_has_ended:=false;{:134};
write_ln(term_out,'This is TANGLE, Version 4.5');{183:}phase_one:=true;
module_count:=0;repeat next_control:=skip_ahead;until next_control=136;
while not input_has_ended do scan_module;
{138:}if change_limit<>0 then begin for ii:=0 to change_limit do buffer[
ii]:=change_buffer[ii];limit:=change_limit;changing:=true;
line:=other_line;loc:=change_limit;begin write_ln(term_out);
write(term_out,'! Change file entry did not match');error;end;end{:138};
phase_one:=false;{:183};{for ii:=0 to 2 do max_tok_ptr[ii]:=tok_ptr[ii];
}{112:}if text_link[0]=0 then begin begin write_ln(term_out);
write(term_out,'! No output was specified.');end;
if history=0 then history:=1;end else begin begin write_ln(term_out);
write(term_out,'Writing the output file');end;break(term_out);
{83:}stack_ptr:=1;brace_level:=0;cur_state.name_field:=0;
cur_state.repl_field:=text_link[0];zo:=cur_state.repl_field mod 3;
cur_state.byte_field:=tok_start[cur_state.repl_field];
cur_state.end_field:=tok_start[cur_state.repl_field+3];
cur_state.mod_field:=0;{:83};{96:}out_state:=0;out_ptr:=0;break_ptr:=0;
semi_ptr:=0;out_buf[0]:=0;line:=1;{:96};send_the_output;
{98:}break_ptr:=out_ptr;semi_ptr:=0;flush_buffer;
if brace_level<>0 then begin write_ln(term_out);
write(term_out,'! Program ended at brace level ',brace_level:1);error;
end;{:98};begin write_ln(term_out);write(term_out,'Done.');end;
end{:112};
9999:if string_ptr>256 then{184:}begin begin write_ln(term_out);
write(term_out,string_ptr-256:1,' strings written to string pool file.')
;end;write(pool,'*');
for ii:=1 to 9 do begin out_buf[ii]:=pool_check_sum mod 10;
pool_check_sum:=pool_check_sum div 10;end;
for ii:=9 downto 1 do write(pool,xchr[48+out_buf[ii]]);write_ln(pool);
end{:184};{[186:]begin write_ln(term_out);
write(term_out,'Memory usage statistics:');end;begin write_ln(term_out);
write(term_out,name_ptr:1,' names, ',text_ptr:1,' replacement texts;');
end;begin write_ln(term_out);write(term_out,byte_ptr[0]:1);end;
for wo:=1 to 1 do write(term_out,'+',byte_ptr[wo]:1);
if phase_one then for ii:=0 to 2 do max_tok_ptr[ii]:=tok_ptr[ii];
write(term_out,' bytes, ',max_tok_ptr[0]:1);
for ii:=1 to 2 do write(term_out,'+',max_tok_ptr[ii]:1);
write(term_out,' tokens.');[:186];}
{187:}case history of 0:begin write_ln(term_out);
write(term_out,'(No errors were found.)');end;
1:begin write_ln(term_out);
write(term_out,'(Did you see the warning message above?)');end;
2:begin write_ln(term_out);
write(term_out,'(Pardon me, but I think I spotted something wrong.)');
end;3:begin write_ln(term_out);
write(term_out,'(That was a fatal error, my friend.)');end;end{:187};
write_ln(term_out);end.{:182}
